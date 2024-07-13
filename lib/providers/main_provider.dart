import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:commute_guide/access_token.dart';
import 'package:commute_guide/constants/global.dart';
import 'package:commute_guide/constants/routes.dart';
import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/issue_enum.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/models/issue.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/providers/base_provider.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/services/size_config_service.dart';
import 'package:commute_guide/utils/utility.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum MapStyleEnum {
  explore,
  driving,
  terrain,
  satellite;
}

enum BrowseModeEnum {
  free,
  myLocation,
  pan;
}

class MainProvider extends BaseProvider {
  final NavigationService _navigationService;
  final SizeConfigService _sizeConfigService;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  bool _loading = true;
  bool get loading => _loading;

  Position? currentPosition;
  LatLng? currentLatLng;
  double? speed;
  late MapController mapController;
  LatLng? markedPoint;
  CommutePlace? markedPlace;
  CommuteTrip? trip;
  double get minPanelHeight {
    return (80 + bottomOnlyPadding) / screenHeight;
  }

  double get maxPanelHeight {
    if (screenHeight < screenWidth) {
      return 1;
    }
    return .9;
  }

  double get midPanelHeight {
    return minPanelHeight < 0.4 ? 0.4 : minPanelHeight;
  }

  MapStyleEnum mapStyleEnum = MapStyleEnum.driving;

  StreamSubscription<CompassEvent>? compassStream;
  double? compassHeading;

  BrowseModeEnum browseModeEnum = BrowseModeEnum.free;
  Timer? compassTimer;
  Timer? overlayTimer;
  DraggableScrollableController mainBottomSheetController =
      DraggableScrollableController();
  DraggableScrollableController markedPointBottomSheetController =
      DraggableScrollableController();
  DraggableScrollableController directionsBottomSheetController =
      DraggableScrollableController();
  DraggableScrollableController myLocationBottomSheetController =
      DraggableScrollableController();
  late List<DraggableScrollableController> sheetControllers = [
    mainBottomSheetController,
  ];
  late List<DraggableScrollableController> showSheetControllers = [
    mainBottomSheetController,
  ];
  late List<double> sheetPositions = [
    0,
  ];

  StreamSubscription<Position>? positionStream;
  late SharedPreferences sharedPreferences;
  List<String>? lastMapCenter;
  String? lastMapStyle;
  double? lastZoom;
  Timer? updateLastMapCenterTimer;
  bool isSearching = false;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  // bool isPopping = false;
  // bool isAdding = true;

  bool get isCentered => browseModeEnum == BrowseModeEnum.myLocation;
  bool get canPan => browseModeEnum == BrowseModeEnum.pan;

  double mapControlsOpacity = 1;
  double overlayMapOpacity = 0;

  TravelModeEnum travelMode = TravelModeEnum.driving;
  List<CommutePlace?> directionPlaces = [null];
  DateTime? scheduledDate;
  List<AvoidEnum> directionAvoidance = [];
  bool defaultDirections = true;

  MainProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required super.navigationService,
    required GlobalProvider globalProvider,
    required MessageRepository messageRepository,
    required SizeConfigService sizeConfigService,
  })  : _navigationService = navigationService,
        _sizeConfigService = sizeConfigService,
        _userRepository = userRepository,
        _authRepository = authRepository {
    mapController = MapController();
    _sizeConfigService.init(_navigationService.currentContext);
    init();
  }

  @override
  void dispose() {
    mapController.dispose();
    _stopPanning();
    _stopOverlayCalc();
    markedPointBottomSheetController.dispose();
    mainBottomSheetController.dispose();
    directionsBottomSheetController.dispose();
    positionStream?.cancel();
    updateLastMapCenterTimer?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void setTravelMode(TravelModeEnum travelMode) {
    this.travelMode = travelMode;
    defaultDirections = false;
    notifyListeners();
  }

  void setScheduledDate(DateTime? scheduledDate) {
    this.scheduledDate = scheduledDate;
    defaultDirections = false;
    notifyListeners();
  }

  void setDirectionAvoidance(List<AvoidEnum> avoids) {
    directionAvoidance = avoids.sublist(0);
    defaultDirections = false;
    trip = null;
    notifyListeners();
  }

  void setDirectionPlaces(List<CommutePlace?> directionPlaces) {
    this.directionPlaces = directionPlaces.sublist(0);
    defaultDirections = false;
    trip = null;
    notifyListeners();
  }

  void setVisiblePoints(List<LatLng> points) {
    trip = trip?.copy(points: points.sublist(0));
    notifyListeners();
  }

  void resetDirections() {
    travelMode = TravelModeEnum.driving;
    trip = null;
    scheduledDate = null;
    directionAvoidance = [];
    directionPlaces = [null];
    defaultDirections = true;
    notifyListeners();
  }

  void processApplifecycle(AppLifecycleState applifecycle) {
    switch (applifecycle) {
      case AppLifecycleState.resumed:
        _getPosition();
        _startPanning();
        _startOverlayCalc();
      default:
        positionStream?.cancel();
        _stopOverlayCalc();
        _stopPanning();
    }
  }

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    lastMapCenter = sharedPreferences.getStringList('map_center');
    lastZoom = sharedPreferences.getDouble('map_zoom');
    lastMapStyle = sharedPreferences.getString('map_style');
    if (lastMapCenter != null) {
      mapController.move(
        LatLng(
          double.parse(lastMapCenter![0]),
          double.parse(lastMapCenter![1]),
        ),
        lastZoom ?? 13,
      );
      mapStyleEnum =
          MapStyleEnum.values.firstWhere((e) => e.name == lastMapStyle);
    }

    await _determinePosition();

    _loading = false;

    notifyListeners();
    _startPanning();
    _startOverlayCalc();

    if (dynamicLinks?.isNotEmpty == true) {
      if (dynamicLinks![0] == 'track_trip') {
        _navigationService
            .pushNamedScreen('${Routes.home}/${Routes.track}', data: {
          'main_provider': this,
          'id': dynamicLinks![1],
        });
      } else if (dynamicLinks![0] == 'share_location') {
        addPoint(LatLng(
            double.parse(dynamicLinks![1]), double.parse(dynamicLinks![2])));
      }
      dynamicLinks = null;
    }

    FirebaseDynamicLinks.instance.onLink.listen(
      (pendingDynamicLinkData) {
        // Set up the `onLink` event listener next as it may be received here
        final Uri deepLink = pendingDynamicLinkData.link;
        // Example of using the dynamic link to push the user to a different screen

        final segments = deepLink.pathSegments;
        if (segments[0] == 'track_trip') {
          _navigationService
              .pushNamedScreen('${Routes.home}/${Routes.track}', data: {
            'main_provider': this,
            'id': segments[1],
          });
        } else if (segments[0] == 'share_location') {
          addPoint(
              LatLng(double.parse(segments[1]), double.parse(segments[2])));
        }
      },
    );
  }

  void setBrowseMode() {
    if (browseModeEnum == BrowseModeEnum.free) {
      browseModeEnum = BrowseModeEnum.myLocation;
      if (currentLatLng == null) {
        notifyListeners();
        return;
      }
      mapController.move(currentLatLng!, 17);
    } else if (browseModeEnum == BrowseModeEnum.myLocation) {
      if (currentLatLng == null) return;
      browseModeEnum = BrowseModeEnum.pan;
    } else {
      browseModeEnum = BrowseModeEnum.myLocation;
    }

    _changeBrowseMode();
  }

  void _changeBrowseMode() {
    switch (browseModeEnum) {
      case BrowseModeEnum.free:
        break;
      case BrowseModeEnum.myLocation:
        mapController.move(currentLatLng!, 17);
        break;
      case BrowseModeEnum.pan:
        mapController.rotate(compassHeading!);
        break;
    }
    notifyListeners();
  }

  IconData getBrowseModeIcon() {
    switch (browseModeEnum) {
      case BrowseModeEnum.free:
        return CupertinoIcons.location;
      case BrowseModeEnum.myLocation:
        return CupertinoIcons.location_fill;
      case BrowseModeEnum.pan:
        return CupertinoIcons.location_north_line_fill;
    }
  }

  void resetBrowseMode() {
    browseModeEnum = BrowseModeEnum.free;
    notifyListeners();
  }

  String getCompassHeading() {
    if (compassHeading == null) return '';
    if (compassHeading! > 315 || compassHeading! <= 45) {
      return 'N';
    }
    if (compassHeading! > 45 && compassHeading! <= 135) {
      return 'E';
    }
    if (compassHeading! > 135 && compassHeading! <= 225) {
      return 'S';
    }
    // print(compassHeading);
    return 'W';
  }

  void setMapToNorth() {
    mapController.rotate(0);
    browseModeEnum = BrowseModeEnum.myLocation;
    notifyListeners();
  }

  Future<void> _determinePosition() async {
    late bool serviceEnabled;
    late LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _getPosition();

    // final lastKnown = await Geolocator.getLastKnownPosition();
    // return lastKnown ?? await Geolocator.getCurrentPosition();
  }

  void storeCurrentMapCenter() {
    lastMapCenter = [
      mapController.camera.center.latitude.toString(),
      mapController.camera.center.longitude.toString(),
    ];
    lastZoom = mapController.camera.zoom;
    lastMapStyle = mapStyleEnum.name;

    if (updateLastMapCenterTimer != null) {
      Utility.clearTimeout(updateLastMapCenterTimer!);
    }

    updateLastMapCenterTimer = Utility.setTimeout(() async {
      await sharedPreferences.setStringList('map_center', lastMapCenter!);
      await sharedPreferences.setDouble('map_zoom', lastZoom!);
      await sharedPreferences.setString('map_style', lastMapStyle!);
    });
  }

  void _getPosition() {
    // final lastKnown = await Geolocator.getLastKnownPosition();
    try {
      positionStream = Geolocator.getPositionStream().listen(
        (position) async {
          if (position.latitude != currentPosition?.latitude ||
              position.longitude != currentPosition?.longitude) {
            currentPosition = position;
            currentLatLng = LatLng(position.latitude, position.longitude);
            if (browseModeEnum == BrowseModeEnum.myLocation) {
              mapController.move(currentLatLng!, 17);
            }
            if (lastMapCenter == null) {
              mapController.move(currentLatLng!, 17);
              lastMapCenter = [
                position.latitude.toString(),
                position.longitude.toString(),
              ];

              storeCurrentMapCenter();
            }
            speed = position.speed;
            notifyListeners();
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      // print(e);
    }
  }

  String getMapChar() {
    switch (mapStyleEnum) {
      case MapStyleEnum.explore:
        return 'mapbox/outdoors-v12';
      case MapStyleEnum.driving:
        return 'mapbox/streets-v12';
      case MapStyleEnum.terrain:
        return 'mapbox/satellite-v9';
      case MapStyleEnum.satellite:
        return 'mapbox/satellite-streets-v12';
    }
  }

  IconData getMapIcon() {
    switch (mapStyleEnum) {
      case MapStyleEnum.explore:
        return CupertinoIcons.map_fill;
      case MapStyleEnum.driving:
        return CupertinoIcons.car_detailed;
      case MapStyleEnum.terrain:
        return Icons.terrain_rounded;
      case MapStyleEnum.satellite:
        return CupertinoIcons.globe;
    }
  }

  void setMapStyle(MapStyleEnum mapStyleEnum) {
    this.mapStyleEnum = mapStyleEnum;
    notifyListeners();
  }

  void showDirections() async {
    final lastSheetController = sheetControllers.last;

    if (lastSheetController == directionsBottomSheetController) {
      return;
    }

    if (sheetControllers.contains(directionsBottomSheetController)) {
      sheetControllers.remove(directionsBottomSheetController);
      showSheetControllers.remove(directionsBottomSheetController);
    }

    showSheetControllers.add(directionsBottomSheetController);
    final position = double.parse(
      lastSheetController.size.toStringAsFixed(1),
    );
    notifyListeners();
    await animateSheet(
      sheetController: lastSheetController,
      position: 0,
      duration: Duration(
        milliseconds: lastSheetController.size <= midPanelHeight ? 100 : 250,
      ),
    );
    sheetPositions.add(position);
    sheetControllers.add(directionsBottomSheetController);

    // pushBottomSheet(ctx);
    notifyListeners();
  }

  void showMyLocation() async {
    final lastSheetController = sheetControllers.last;

    if (lastSheetController == myLocationBottomSheetController) {
      return;
    }

    if (sheetControllers.contains(myLocationBottomSheetController)) {
      sheetControllers.remove(myLocationBottomSheetController);
      showSheetControllers.remove(myLocationBottomSheetController);
    }

    showSheetControllers.add(myLocationBottomSheetController);
    final position = double.parse(
      lastSheetController.size.toStringAsFixed(1),
    );
    notifyListeners();
    await animateSheet(
      sheetController: lastSheetController,
      position: 0,
      duration: Duration(
        milliseconds: lastSheetController.size <= midPanelHeight ? 100 : 250,
      ),
    );
    sheetPositions.add(position);
    sheetControllers.add(myLocationBottomSheetController);
    notifyListeners();

    await HapticFeedback.lightImpact();
    final location = mapController.camera.latLngToScreenPoint(currentLatLng!);
    if (location.y >= screenHeight - (midPanelHeight * screenHeight)) {
      mapController.move(currentLatLng!, mapController.camera.zoom);
      browseModeEnum = BrowseModeEnum.myLocation;
    }
    // pushBottomSheet(ctx);
    notifyListeners();
  }

  void addPoint(LatLng point, [CommutePlace? place]) async {
    markedPoint = point;
    markedPlace = place;

    final lastSheetController = sheetControllers.last;

    if (lastSheetController == markedPointBottomSheetController) {
      if (lastSheetController.size != midPanelHeight) {
        await animateSheet(
          sheetController: lastSheetController,
          position: midPanelHeight,
          duration: const Duration(
            milliseconds: 100,
          ),
        );
      }
      sheetControllers.removeLast();
      showSheetControllers.removeLast();
      markedPointBottomSheetController = DraggableScrollableController();
      sheetControllers.add(markedPointBottomSheetController);
      showSheetControllers.add(markedPointBottomSheetController);
      notifyListeners();
      lastSheetController.dispose();
    } else {
      if (sheetControllers.contains(markedPointBottomSheetController)) {
        sheetControllers.remove(markedPointBottomSheetController);
        showSheetControllers.remove(markedPointBottomSheetController);
      }

      showSheetControllers.add(markedPointBottomSheetController);
      final position = double.parse(
        lastSheetController.size.toStringAsFixed(1),
      );
      notifyListeners();

      await animateSheet(
        sheetController: lastSheetController,
        position: 0,
        duration: Duration(
          milliseconds: lastSheetController.size <= midPanelHeight ? 100 : 250,
        ),
      );
      sheetPositions.add(position);
      sheetControllers.add(markedPointBottomSheetController);
      notifyListeners();
    }
    await HapticFeedback.heavyImpact();
    final location = mapController.camera.latLngToScreenPoint(point);
    if (location.y >= screenHeight - (midPanelHeight * screenHeight)) {
      mapController.move(point, mapController.camera.zoom);
    }
    // pushBottomSheet(ctx);
    notifyListeners();
  }

  void setScheduledTripDirections(CommuteTrip trip) {
    this.trip = trip;
    directionAvoidance = trip.avoids;
    travelMode = trip.travelModeEnum;
    scheduledDate = trip.scheduledAt;
    directionPlaces = trip.places;
    defaultDirections = false;
    showDirections();
  }

  Future<void> animateSheet({
    required DraggableScrollableController sheetController,
    required double position,
    required Duration duration,
  }) async {
    while (true) {
      if (!sheetController.isAttached) {
        await Future.delayed(Duration.zero);
        continue;
      }

      await sheetController.animateTo(
        position,
        duration: duration,
        curve: Curves.easeInOut,
      );
      break;
    }
  }

  void popSheet() async {
    final lastSheetController = showSheetControllers.removeLast();
    notifyListeners();

    await animateSheet(
      sheetController: lastSheetController,
      position: 0,
      duration: const Duration(milliseconds: 100),
    );

    sheetControllers.removeLast();
    notifyListeners();

    await animateSheet(
      sheetController: sheetControllers.last,
      position: sheetPositions.removeLast(),
      duration: const Duration(milliseconds: 100),
    );
    if (lastSheetController == markedPointBottomSheetController) {
      lastSheetController.dispose();
      markedPoint = null;
      markedPlace = null;
      markedPointBottomSheetController = DraggableScrollableController();
    } else if (lastSheetController == myLocationBottomSheetController) {
      myLocationBottomSheetController.dispose();
      myLocationBottomSheetController = DraggableScrollableController();
    } else {
      lastSheetController.dispose();
      directionsBottomSheetController = DraggableScrollableController();
    }
    notifyListeners();
  }

  Future<void> getDirectionPolylines() async {
    if (directionPlaces.length < 2) return;

    // final url = Uri(
    //   scheme: 'https',
    //   host: 'api.mapbox.com',
    //   path: 'directions/v5/mapbox/driving-traffic/${directionPlaces.map((e) {
    //     if (e == null) {
    //       return '${currentLatLng?.latitude ?? ''},${currentLatLng?.longitude ?? ''}';
    //     }

    //     return '${e.lat},${e.lng}';
    //   }).join(';')}',
    //   queryParameters: {
    //     'access_token': accessToken,
    //     'alternatives': 'true',
    //     'annotations': 'distance,duration,speed,congestion,congestion_numeric',
    //     'overview': 'full',
    //     'exclude': directionAvoidance.map((e) => e.getMapBoxString()).join(','),
    //     'steps': 'true',
    //     'banner_instructions': 'true',
    //     'voice_units': 'metric',
    //     'geometries': 'geojson',
    //   },
    // );
    // final result = await http.get(url);
    // final body = json.decode(result.body);
    // print(body);
    // final directions = body["routes"][0]["geometry"];
    // final pointsWithLatLng = PolylinePoints().decodePolyline(directions);
    // visiblePoints =
    //     pointsWithLatLng.map((e) => LatLng(e.latitude, e.longitude)).toList();
    // print(visiblePoints);
    // notifyListeners();
    // if (visiblePoints.isNotEmpty) {
    //   _navigationService.pushNamedScreen(Routes.navigation, data: p);
    // }
    final startPoint = directionPlaces.first;
    final endPoint = directionPlaces.last;
    final additionalWaypoints = [...directionPlaces]
      ..removeAt(0)
      ..removeLast();
    CommutePlace? currentPlace;
    if (directionPlaces.contains(null)) {
      currentPlace = await getDetailsAboutLocation(currentLatLng!);
    }
    final url = Uri(
      scheme: 'https',
      host: 'maps.googleapis.com',
      path: 'maps/api/directions/json',
      queryParameters: {
        'key': 'AIzaSyBGZwovpSyZAnZ4H4vv1K8V_7TUo_1uGf8',
        'origin': 'place_id:${startPoint?.placeId ?? currentPlace?.placeId}',
        'destination': 'place_id:${endPoint?.placeId ?? currentPlace?.placeId}',
        'alternatives': 'true',
        'avoid': directionAvoidance.map((e) => e.getGoogleJson()).join('|'),
        'mode': travelMode == TravelModeEnum.bicycling
            ? 'driving'
            : travelMode.name,
        'traffic_model': 'best_guess',
        'units': 'metric',
        'departure_time': 'now',
        if (additionalWaypoints.isNotEmpty)
          'waypoints':
              'optimize:true|${additionalWaypoints.map((e) => 'place_id:${e?.placeId ?? currentPlace?.placeId}').join('|')}',
      },
    );

    final result = await http.get(url);
    final body = json.decode(result.body);
    // print(body);
    final temp = (body['routes'][0]['legs'] as List).map<List<num>>((e) {
      return [e['distance']['value'], e['duration']['value']];
    }).reduce((a, b) => [a[0] + b[0], a[1] + b[1]]);
    final directions = body["routes"][0]["overview_polyline"]['points'];
    final pointsWithLatLng = PolylinePoints().decodePolyline(directions);
    final points =
        pointsWithLatLng.map((e) => LatLng(e.latitude, e.longitude)).toList();
    trip = CommuteTrip(
      id: const Uuid().v4(),
      points: points,
      distance: temp[0].toDouble(),
      travelModeEnum: travelMode,
      createdAt: DateTime.now(),
      duration: Utility.getDurationWRTTravelMode(
        distance: temp[0].toInt(),
        mode: travelMode,
        duration: temp[1].toInt(),
      ).toDouble(),
      scheduledAt: DateTime.now(),
      avoids: directionAvoidance,
      places: directionPlaces
          .map((e) => e ?? currentPlace)
          .toList()
          .cast<CommutePlace>(),
      speed: 0,
      durationLeft: 0,
      durationCovered: 0,
      distanceLeft: 0,
      distanceCovered: 0,
      done: false,
    );

    notifyListeners();

    directionsBottomSheetController.animateTo(
      minPanelHeight,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: trip!.points,
        padding: const EdgeInsets.all(100),
      ),
    );
  }

  Future<CommutePlace?> getDetailsAboutLocation(LatLng point) async {
    try {
      final url = Uri(
        scheme: 'https',
        host: 'maps.googleapis.com',
        path: 'maps/api/geocode/json',
        queryParameters: {
          'key': googleKey,
          'latlng': '${point.latitude},${point.longitude}',
        },
      );

      final result = await http.get(url);
      final body = json.decode(result.body);
      // print(body);
      return CommutePlace.fromGoogleGeocodeJson(body['results'][0]);
    } catch (e) {
      return null;
    }
  }

  Future<List<CommutePlace>> searchLocation(String searchString) async {
    try {
      final url = Uri(
        scheme: 'https',
        host: 'places.googleapis.com',
        path: 'v1/places:searchText',
      );

      final result = await http.post(
        url,
        headers: {
          'X-Goog-FieldMask': '*',
          'X-Goog-Api-Key': googleKey,
        },
        body: jsonEncode({
          'textQuery': searchString,
          if (currentLatLng != null)
            'locationBias': {
              "circle": {
                "center": {
                  "latitude": currentLatLng!.latitude,
                  "longitude": currentLatLng!.longitude,
                },
                "radius": 500.0
              }
            },
        }),
      );
      final body = json.decode(result.body);
      final places = body["places"];
      return (places as List)
          .map((e) => CommutePlace.fromGooglePlacesJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> startTripTracking(CommuteTrip trip) async {
    await _userRepository.trackCurrentTrip(trip);
  }

  Future<void> stopTripTracking(CommuteTrip trip) async {
    await _userRepository.stopTrackingTrip(trip);
  }

  Future<CommuteIssue?> uploadIssue({
    required List<File> images,
    required String description,
    required IssueEnum issue,
    required String userId,
  }) async {
    final imagesString = await _userRepository.uploadImagesForIssue(images);
    final issueObj = CommuteIssue(
      lat: currentLatLng?.latitude ?? 0,
      lng: currentLatLng?.longitude ?? 0,
      images: imagesString,
      issue: issue,
      description: description,
      accepted: false,
      createdAt: DateTime.now(),
      id: '',
      userId: userId,
      address: currentLatLng == null
          ? null
          : (await getDetailsAboutLocation(currentLatLng!))?.address,
    );
    return await _userRepository.uploadIssue(issueObj);
  }

  Future<List<CommuteIssue>> getListOfApprovedIssues() async {
    return await _userRepository.getApprovedIssues();
  }

  Future<List<CommuteIssue>> getUserIssues(String userId) async {
    return await _userRepository.getUserIssues(userId);
  }

  Future<bool> deleteIssue(CommuteIssue issue) async {
    return await _userRepository.deleteIssue(issue);
  }

  void signOut() {
    _authRepository.signOut();
  }

  Future<AppUser> addPlaceToFavorite({
    required CommutePlace place,
    required AppUser user,
  }) async {
    final favorites = [...?user.favorites];
    final recents = [...?user.recents];
    final favoritedContainsPlace =
        favorites.any((e) => e.placeId == place.placeId);

    user = user.copy(
      recents: recents..removeWhere((e) => e.placeId == place.placeId),
    );

    if (favoritedContainsPlace) {
      return user;
    }

    if (place.placeType != PlaceTypeEnum.other) {
      favorites.removeWhere((e) => e.placeType == place.placeType);
    }
    favorites.add(place);
    user = user.copy(favorites: favorites);
    await _userRepository.updateUser(user);
    return user;
  }

  Future<AppUser> addTripToSchedules(AppUser user) async {
    if (!(trip?.points.isNotEmpty == true)) {
      await getDirectionPolylines();
    }

    trip = trip!.copy(
      scheduledAt: scheduledDate,
      done: false,
    );

    final scheduledTrips = [...?user.scheduledTrips];

    user = user.copy(
      scheduledTrips: scheduledTrips..add(trip!),
    );

    await _userRepository.updateUser(user);
    return user;
  }

  Future<void> startTrip(ChangeNotifierProvider<MainProvider> prov) async {
    if (!(trip?.points.isNotEmpty == true)) {
      await getDirectionPolylines();
    }

    await _navigationService.pushNamedScreen(
      '${Routes.home}/${Routes.navigation}',
      data: {'trip': trip, 'main_provider': prov},
    );
    resetDirections();
    popSheet();
  }

  AppUser removePlaceFromFavorite({
    required CommutePlace place,
    required AppUser user,
  }) {
    final favorites = [...?user.favorites];
    final favoritedContainsPlace =
        favorites.any((e) => e.placeId == place.placeId);

    if (!favoritedContainsPlace) {
      return user;
    }
    favorites.removeWhere((e) => e.placeId == place.placeId);
    user = user.copy(favorites: favorites);
    _userRepository.updateUser(user);
    return user;
  }

  AppUser reorderFavorites({
    required int oldIndex,
    required int newIndex,
    required AppUser user,
  }) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final favorites = user.favorites!
        .where((e) => e.placeType == PlaceTypeEnum.other)
        .toList();
    final place = favorites[oldIndex];

    favorites.removeAt(oldIndex);
    favorites.insert(newIndex, place);

    user = user.copy(favorites: [
      ...user.favorites!.where((e) => e.placeType != PlaceTypeEnum.other),
      ...favorites,
    ]);
    _userRepository.updateUser(user);
    return user;
  }

  Future<AppUser> addPlaceToRecents({
    required CommutePlace place,
    required AppUser user,
  }) async {
    final favorites = [...?user.favorites];
    final recents = [...?user.recents];
    final favoritedContainsPlace =
        favorites.any((e) => e.placeId == place.placeId);

    user = user.copy(
      recents: recents..removeWhere((e) => e.placeId == place.placeId),
    );

    if (favoritedContainsPlace) {
      return user;
    }

    recents.add(place.copy(createdAt: DateTime.now()));
    user = user.copy(recents: recents);
    await _userRepository.updateUser(user);
    return user;
  }

  AppUser removeRecents({
    required AppUser user,
    required List<CommutePlace> places,
  }) {
    final recents = [...?user.recents];
    user = user.copy(
      recents: recents..removeWhere((e) => places.contains(e)),
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser removeScheduleTrips({
    required AppUser user,
    required List<CommuteTrip> trips,
  }) {
    final temps = [...?user.scheduledTrips];
    user = user.copy(
      scheduledTrips: temps..removeWhere((e) => trips.contains(e)),
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setDirectionPref({
    required AppUser user,
    required TravelModeEnum travelMode,
  }) {
    user = user.copy(
      preferredTravelMode: travelMode,
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setDrivingPrefs({
    required AppUser user,
    required List<AvoidEnum> avoids,
  }) {
    user = user.copy(
      drivingPreferences: avoids,
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setWalkingPrefs({
    required AppUser user,
    required List<AvoidEnum> avoids,
  }) {
    user = user.copy(
      walkingPreferences: avoids,
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setCyclingPrefs({
    required AppUser user,
    required List<AvoidEnum> avoids,
  }) {
    user = user.copy(
      cyclingPreferences: avoids,
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setNotficationPrefs({
    required AppUser user,
    required List<IssueEnum> issues,
  }) {
    user = user.copy(
      notificationPreferences: issues,
    );
    _userRepository.updateUser(user);
    return user;
  }

  AppUser setAuthPrefs({
    required AppUser user,
    required bool auth,
  }) {
    user = user.copy(
      auth: auth,
    );
    _userRepository.updateUser(user);
    return user;
  }

  void focusSearchField() async {
    isSearching = true;
    searchFocusNode.requestFocus();
    notifyListeners();
    await animateSheet(
      sheetController: mainBottomSheetController,
      position: maxPanelHeight,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
  }

  void unfocusSearchField() async {
    searchController.clear();
    searchFocusNode.unfocus();
    isSearching = false;
    notifyListeners();
    await animateSheet(
      sheetController: mainBottomSheetController,
      position: midPanelHeight,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
  }

  void _startOverlayCalc() {
    overlayTimer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      if (isDisposed) return;

      final sheetController = sheetControllers.last;
      if (!sheetController.isAttached) {
        return;
      }
      final size = double.parse(sheetController.size.toStringAsFixed(5));

      // if (sheetController == mainBottomSheetController &&
      //     size <= midPanelHeight &&
      //     isSearching) {
      //   Future.delayed(Duration(milliseconds: 500), () {
      //     if (isDisposed || !isSearching || size > midPanelHeight) return;
      //     unfocusSearchField();
      //   });
      // }
      // print(size);
      final isSheetSmall = size <= midPanelHeight &&
          overlayMapOpacity == 0 &&
          mapControlsOpacity == 1;
      final isSheetAtMax = size == maxPanelHeight &&
          overlayMapOpacity == 1 &&
          mapControlsOpacity == 0;
      if (isSheetAtMax || isSheetSmall) {
        // print(size);
        return;
      }

      final overMid = midPanelHeight + 0.1;
      if (size > overMid) {
        mapControlsOpacity = 0;
      } else if (size > midPanelHeight && size <= overMid) {
        final diff = overMid - midPanelHeight;
        final percentage = 1 - ((size - midPanelHeight) / diff);
        mapControlsOpacity = percentage;
      } else {
        mapControlsOpacity = 1;
      }

      if (size >= maxPanelHeight) {
        overlayMapOpacity = 1;
      } else if (size > midPanelHeight && size < maxPanelHeight) {
        final diff = maxPanelHeight - midPanelHeight;
        final percentage = (size - midPanelHeight) / diff;
        overlayMapOpacity = percentage;
      } else {
        overlayMapOpacity = 0;
      }
    });
  }

  void _stopOverlayCalc() {
    overlayTimer?.cancel();
  }

  void _startPanning() {
    compassTimer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      if (isDisposed || compassHeading == null || !canPan) return;
      mapController.rotate(360 - compassHeading!);
    });
    compassStream = FlutterCompass.events!.listen((event) {
      final heading = event.heading;
      if (heading == null) {
        return;
      }
      compassHeading = heading;
    });
  }

  void _stopPanning() async {
    await compassStream?.cancel();
    compassTimer?.cancel();
  }
}
