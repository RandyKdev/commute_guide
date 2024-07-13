import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commute_guide/access_token.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/repositories/user_repository.dart';
import 'package:commute_guide/screens/base_screen.dart';
import 'package:commute_guide/screens/track_bottom_sheet.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/widgets/current_location_widget.dart';
import 'package:commute_guide/widgets/direction_waypoint_location_widget.dart';
import 'package:commute_guide/widgets/marked_location_widget.dart';
import 'package:commute_guide/widgets/snackbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String id;
  final MainProvider changeMainProvider;
  const TrackingScreen({
    super.key,
    required this.id,
    required this.changeMainProvider,
  });

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late MapController mapController;
  late CommuteTrip trip;
  late DraggableScrollableController controller;
  bool loading = true;
  late MapOptions options;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? sub;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    controller = DraggableScrollableController();
    init();
  }

  void init() async {
    final l = ref.read(userRepository).getTripStream(widget.id);
    // print(widget.id);
    if (l == null) {
      CommuteSnackBarError(title: 'Something went wrong', context: context);
      ref.read(navigationService).pop();
      return;
    }
    sub = l.listen(
      (data) {
        // print(widget.id);
        if (!data.exists) {
          CommuteSnackBarInfo(
              title: 'User has stopped sharing his location', context: context);
          ref.read(navigationService).pop();
          return;
        }

        final d = data.data();
        if (d == null) return;
        trip = CommuteTrip.fromJson(d);
        if (trip.done) {
          CommuteSnackBarSuccessful(
              title: 'User has arrived', context: context);
          ref.read(navigationService).pop();
          return;
        }
        if (loading = true) {
          options = MapOptions(
            initialZoom: 20,
            initialCenter: trip.currentPosition ??
                LatLng(trip.places.first.lat, trip.places.first.lng),
            initialCameraFit: CameraFit.coordinates(coordinates: trip.points),
          );
        }
        setState(() {
          loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    controller.dispose();
    sub?.cancel();
    super.dispose();
  }

  TileLayer openStreetMapTileLayer() => TileLayer(
        urlTemplate:
            'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}?access_token=$accessToken',
        tileProvider: CancellableNetworkTileProvider(),
        retinaMode: true,
      );
  @override
  Widget build(BuildContext context) {
    return BaseScreen(build: ({required EdgeInsets padding}) {
      return Scaffold(
        body: loading
            ? const Center(
                child: CupertinoActivityIndicator(
                  color: Colors.black,
                  radius: 20,
                ),
              )
            : Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: options,
                    children: [
                      openStreetMapTileLayer(),
                      if (trip.points.isNotEmpty == true)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: trip.points,
                              color: Colors.blue,
                              borderColor: Colors.blue.shade500,
                              borderStrokeWidth: 3,
                              strokeWidth: 7,
                              strokeJoin: StrokeJoin.bevel,
                              pattern:
                                  trip.travelModeEnum == TravelModeEnum.driving
                                      ? const StrokePattern.solid()
                                      : StrokePattern.dotted(
                                          spacingFactor: trip.travelModeEnum ==
                                                  TravelModeEnum.bicycling
                                              ? 3
                                              : 2),
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          if (trip.currentPosition != null)
                            Marker(
                              point: trip.currentPosition!,
                              width: 23,
                              height: 23,
                              child: const CurrentLocationWidget(),
                            ),
                          if (trip.points.isNotEmpty == true) ...[
                            ...trip.places.map((e) {
                              return Marker(
                                point: LatLng(e.lat, e.lng),
                                width: 23,
                                height: 23,
                                child: DirectionWaypointLocationWidget(
                                  directionPlaces: trip.places,
                                  place: e,
                                ),
                              );
                            }),
                            Marker(
                              point: LatLng(
                                trip.places.last.lat,
                                trip.places.last.lng,
                              ),
                              width: 95,
                              height: 95,
                              rotate: true,
                              child: MarkedLocationWidget(
                                key: ValueKey(trip.places.last),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                  TrackBottomSheet(
                    changeMainProvider: widget.changeMainProvider,
                    controller: controller,
                    trip: trip,
                  ),
                ],
              ),
      );
    });
  }
}
