import 'package:commute_guide/access_token.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/repositories/auth_repository.dart';
import 'package:commute_guide/repositories/message_repository.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/screens/base_screen.dart';
import 'package:commute_guide/screens/directions_bottom_sheet.dart';
import 'package:commute_guide/screens/main_bottom_sheet.dart';
import 'package:commute_guide/screens/marked_point_bottom_sheet.dart';
import 'package:commute_guide/screens/my_location_bottom_sheet.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/services/size_config_service.dart';
import 'package:commute_guide/widgets/current_direction_widget.dart';
import 'package:commute_guide/widgets/current_location_widget.dart';
import 'package:commute_guide/widgets/direction_waypoint_location_widget.dart';
import 'package:commute_guide/widgets/map_controls_widget.dart';
import 'package:commute_guide/widgets/map_overlay_widget.dart';
import 'package:commute_guide/widgets/marked_location_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  late ChangeNotifierProvider<MainProvider> changeMainProvider;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(changeMainProvider).processApplifecycle(state);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    changeMainProvider = ChangeNotifierProvider(
      (ref) {
        return MainProvider(
          authRepository: ref.read(authRepository),
          globalProvider: ref.read(globalProvider),
          navigationService: ref.read(navigationService),
          messageRepository: ref.read(messageRepository),
          userRepository: ref.read(userRepository),
          sizeConfigService: ref.read(sizeConfigService),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  TileLayer openStreetMapTileLayer(MainProvider mainProvider) => TileLayer(
        urlTemplate: mainProvider.mapStyleEnum == MapStyleEnum.terrain
            ? 'https://mt0.google.com/vt/lyrs=p@221097413&x={x}&y={y}&z={z}'
            : 'https://api.mapbox.com/styles/v1/${mainProvider.getMapChar()}/tiles/{z}/{x}/{y}?access_token=$accessToken',
        // 'https://mt0.google.com/vt/lyrs=${mainProvider.getMapChar()}&x={x}&y={y}&z={z}',
        // 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        //'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        // 'https://mt0.google.com/vt/lyrs=m@221097413,traffic&x={x}&y={y}&z={z}',ß
        // 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        //
        // Use the recommended flutter_map_cancellable_tile_provider package to
        // support the cancellation of loading tiles.
        tileProvider: CancellableNetworkTileProvider(),
        retinaMode: true,
      );
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(changeMainProvider);
    return BaseScreen(build: ({required EdgeInsets padding}) {
      return Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: mainProvider.mapController,
              options: MapOptions(
                onLongPress: (tapPosition, point) =>
                    mainProvider.addPoint(point),
                onMapEvent: (event) {},
                onPositionChanged: (camera, hasGesture) {
                  mainProvider.storeCurrentMapCenter();
                  if (!hasGesture) {
                    if (camera.center == mainProvider.currentLatLng) {
                      return;
                    }
                  }
                  mainProvider.resetBrowseMode();
                },
                // midnZoom: 13,
                maxZoom: 20,
              ),
              children: [
                openStreetMapTileLayer(mainProvider),
                if (mainProvider.trip?.points.isNotEmpty == true)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: mainProvider.trip!.points,
                        color: Colors.blue,
                        borderColor: Colors.blue.shade500,
                        borderStrokeWidth: 3,
                        strokeWidth: 7,
                        strokeJoin: StrokeJoin.bevel,
                        pattern:
                            mainProvider.travelMode == TravelModeEnum.driving
                                ? const StrokePattern.solid()
                                : StrokePattern.dotted(
                                    spacingFactor: mainProvider.travelMode ==
                                            TravelModeEnum.bicycling
                                        ? 3
                                        : 2),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (mainProvider.currentLatLng != null &&
                        mainProvider.compassHeading != null)
                      Marker(
                        point: mainProvider.currentLatLng!,
                        width: 100,
                        height: 100,
                        rotate: true,
                        child: CurrentDirectionWidget(
                          changeMainProvider: changeMainProvider,
                        ),
                      ),
                    if (mainProvider.currentLatLng != null)
                      Marker(
                        point: mainProvider.currentLatLng!,
                        width: 23,
                        height: 23,
                        child: CurrentLocationWidget(
                          onTap: mainProvider.showMyLocation,
                        ),
                      ),
                    if (mainProvider.markedPoint != null)
                      Marker(
                        point: mainProvider.markedPoint!,
                        width: 95,
                        height: 95,
                        rotate: true,
                        child: MarkedLocationWidget(
                          key: ValueKey(mainProvider.markedPoint),
                        ),
                      ),
                    if (mainProvider.trip?.points.isNotEmpty == true) ...[
                      ...mainProvider.directionPlaces.map((e) {
                        return Marker(
                          point: e == null
                              ? mainProvider.currentLatLng!
                              : LatLng(e.lat, e.lng),
                          width: 23,
                          height: 23,
                          child: DirectionWaypointLocationWidget(
                            place: e,
                            directionPlaces: mainProvider.directionPlaces,
                          ),
                        );
                      }),
                      if (mainProvider.directionPlaces.last?.placeId !=
                          mainProvider.markedPlace?.placeId)
                        Marker(
                          point: mainProvider.directionPlaces.last == null
                              ? mainProvider.currentLatLng!
                              : LatLng(mainProvider.directionPlaces.last!.lat,
                                  mainProvider.directionPlaces.last!.lng),
                          width: 95,
                          height: 95,
                          rotate: true,
                          child: MarkedLocationWidget(
                            key: ValueKey(mainProvider.markedPoint),
                          ),
                        ),
                    ]
                  ],
                ),
              ],
            ),
            MapOverlayWidget(changeMainProvider: changeMainProvider),

            MapControlsWidget(changeMainProvider: changeMainProvider),

            // if (mainProvider.mainBottomSheetController ==
            //     mainProvider.sheetControllers.last)
            ...mainProvider.sheetControllers.map((e) {
              if (e == mainProvider.mainBottomSheetController) {
                return AnimatedOpacity(
                  opacity: mainProvider.mainBottomSheetController ==
                          mainProvider.showSheetControllers.last
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 100),
                  child: MainBottomSheet(
                    changeMainProvider: changeMainProvider,
                  ),
                );
              }

              if (e == mainProvider.markedPointBottomSheetController) {
                return AnimatedOpacity(
                  key: ValueKey(mainProvider.markedPointBottomSheetController),
                  opacity: mainProvider.markedPointBottomSheetController ==
                          mainProvider.showSheetControllers.last
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 100),
                  child: MarkedPointBottomSheet(
                    key:
                        ValueKey(mainProvider.markedPointBottomSheetController),
                    changeMainProvider: changeMainProvider,
                  ),
                );
              }
              if (e == mainProvider.myLocationBottomSheetController) {
                return AnimatedOpacity(
                  key: ValueKey(mainProvider.myLocationBottomSheetController),
                  opacity: mainProvider.myLocationBottomSheetController ==
                          mainProvider.showSheetControllers.last
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 100),
                  child: MyLocationBottomSheet(
                    key: ValueKey(mainProvider.myLocationBottomSheetController),
                    changeMainProvider: changeMainProvider,
                  ),
                );
              }

              if (e == mainProvider.directionsBottomSheetController) {
                return AnimatedOpacity(
                  key: ValueKey(mainProvider.directionsBottomSheetController),
                  opacity: mainProvider.directionsBottomSheetController ==
                          mainProvider.showSheetControllers.last
                      ? 1
                      : 0,
                  duration: const Duration(milliseconds: 100),
                  child: DirectionsBottomSheet(
                    key: ValueKey(mainProvider.directionsBottomSheetController),
                    changeMainProvider: changeMainProvider,
                  ),
                );
              }

              return Container();
            })

            // DirectionsBottomSheet(
            //   changeMainProvider: changeMainProvider,
            // ),
          ],
        ),
      );
    });
  }
}
