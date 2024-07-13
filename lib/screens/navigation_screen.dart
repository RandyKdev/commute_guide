import 'dart:async';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/screens/base_screen.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/widgets/add_issue_bottom_sheet_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math' as math;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final CommuteTrip trip;
  const NavigationScreen({
    super.key,
    required this.changeMainProvider,
    required this.trip,
  });

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  late ChangeNotifierProvider<MainProvider> changeMainProvider;
  MapBoxNavigationViewController? controller;
  double _distanceRemaining = 0;
  double _durationRemaining = 0;
  double _distanceCovered = 0;
  double _durationCovered = 0;
  bool _arrived = false;
  bool _isNavigating = false;
  CommuteTrip? trip;
  Timer? timer;
  Timer? durationTimer;
  @override
  void initState() {
    super.initState();

    changeMainProvider = widget.changeMainProvider;
    final now = DateTime.now();
    durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _durationCovered = DateTime.now().difference(now).inSeconds.toDouble();
    });
  }

  MapBoxOptions get mapBoxOptions => MapBoxOptions(
        // initialLatitude: 36.1175275,
        // initialLongitude: -115.1839524,
        zoom: 13.0,
        tilt: 0.0,
        bearing: 0.0,
        enableRefresh: false,
        alternatives: false,
        voiceInstructionsEnabled: false,
        bannerInstructionsEnabled: false,
        isOptimized: true,
        allowsUTurnAtWayPoints: true,
        mode: widget.trip.travelModeEnum == TravelModeEnum.driving
            ? MapBoxNavigationMode.drivingWithTraffic
            : widget.trip.travelModeEnum == TravelModeEnum.bicycling
                ? MapBoxNavigationMode.cycling
                : MapBoxNavigationMode.walking,

        units: VoiceUnits.metric,
        animateBuildRoute: true,
        showReportFeedbackButton: false,
        showEndOfRouteFeedback: false,

        language: "en",
        simulateRoute: false,
      );

  @override
  void dispose() {
    stopShareTrip();
    controller?.dispose();
    timer?.cancel();
    durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRouteEvent(RouteEvent e) async {
    if (controller == null) return;

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        _distanceCovered = progressEvent.distanceTraveled ?? 0;
        _arrived = progressEvent.arrived ?? false;
        _distanceRemaining = await controller!.distanceRemaining;
        _durationRemaining = await controller!.durationRemaining;
        break;
      case MapBoxEvent.on_arrival:
        // print('arrived');
        _arrived = true;
        // if (widget.trip.places.length < 3) {
        Future.delayed(const Duration(seconds: 6), () async {
          // print('d');

          if (!mounted) return;
          await stopShareTrip();
          ref.read(navigationService).popUntilFirstRoute();
        });
        // ref.read(navigationService).pop();
        // } else {}
        break;
      case MapBoxEvent.navigation_running:
        _isNavigating = true;

        break;
      case MapBoxEvent.navigation_finished:
        // print('finished');
        ref.read(navigationService).popUntilFirstRoute();
        break;
      case MapBoxEvent.navigation_cancelled:
        // print('cancelled');
        await stopShareTrip();
        final result = await controller!.finishNavigation();
        if (result != true) {
          ref.read(navigationService).popUntilFirstRoute();
        }
        // ref.read(navigationService).pop();

        break;

      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  Future<void> stopShareTrip() async {
    if (trip == null) return;
    final mainProvider = ref.read(changeMainProvider);
    await mainProvider.stopTripTracking(trip!);
    trip = null;
    timer?.cancel();
    timer = null;
    if (!context.mounted) return;
    setState(() {});
  }

  Future<void> startShareTrip() async {
    final mainProvider = ref.read(changeMainProvider);
    trip = widget.trip.copy(
      id: const Uuid().v4(),
      currentPosition: mainProvider.currentLatLng,
      speed: mainProvider.speed,
    );
    await mainProvider.startTripTracking(trip!);

    timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      if (trip == null) {
        timer.cancel();
        return;
      }

      trip = trip!.copy(
        currentPosition: mainProvider.currentLatLng,
        speed: mainProvider.speed,
        durationCovered: _durationCovered,
        durationLeft: _durationRemaining,
        distanceCovered: _distanceCovered,
        distanceLeft: _distanceRemaining,
        done: _arrived,
      );
      await mainProvider.startTripTracking(trip!);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(build: ({required EdgeInsets padding}) {
      return Scaffold(
        body: MapBoxNavigationView(
            options: mapBoxOptions,
            onRouteEvent: _onRouteEvent,
            onCreated: (MapBoxNavigationViewController _) async {
              controller = _;
              await controller!.buildRoute(
                wayPoints: widget.trip.places.map((e) {
                  return WayPoint(
                    name: e.address,
                    latitude: e.lat,
                    longitude: e.lng,
                  );
                }).toList(),
              );
              // await Future.delayed(Duration(minutes: 1));
              await controller!.startNavigation(options: mapBoxOptions);
            }),
        floatingActionButton: _arrived || !_isNavigating
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.sizeOf(context).height >
                          MediaQuery.sizeOf(context).width
                      ? kBottomNavigationBarHeight + 12
                      : 0,
                ),
                child: SpeedDial(
                  activeChild: Transform.rotate(
                    angle: math.pi / 4,
                    child: const Icon(
                      CupertinoIcons.gear_alt_fill,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.primaryBlue,
                  visible: true,
                  curve: Curves.bounceIn,
                  // activeIcon: Icons.close,

                  overlayOpacity: .5,
                  overlayColor: Colors.black,

                  children: [
                    SpeedDialChild(
                      // child: Text('Appointments'),
                      backgroundColor: Colors.white,
                      onTap: () async {
                        showMaterialModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          )),
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return AddIssueBottomSheetWidget(
                              changeMainProvider: widget.changeMainProvider,
                              scrollController: ModalScrollController.of(ctx)!,
                            );
                          },
                        );
                      },
                      labelWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: const Row(
                          children: [
                            Text('Report an Issue'),
                            SizedBox(width: 10),
                            Icon(
                              CupertinoIcons.exclamationmark_bubble_fill,
                              color: AppColors.red,
                            ),
                          ],
                        ),
                      ),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue,
                        fontSize: 16.0,
                      ),
                      labelBackgroundColor: Colors.white,
                    ),
                    SpeedDialChild(
                      // child: Text('Appointments'),
                      backgroundColor: Colors.white,
                      onTap: () async {
                        if (trip == null) {
                          await startShareTrip();
                          final url = await FirebaseDynamicLinks.instance
                              .buildLink(DynamicLinkParameters(
                            link: Uri.parse(
                              'https://commuteguide.page.link/track_trip/${trip!.id}',
                            ),
                            uriPrefix: 'https://commuteguide.page.link',
                            iosParameters: const IOSParameters(
                                bundleId: 'com.commuteguide.app'),
                          ));
                          await Share.shareUri(url);
                        } else {
                          await stopShareTrip();
                        }
                      },
                      labelWidget: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            if (trip == null) ...[
                              const Text('Share Progress'),
                              const SizedBox(width: 10),
                              const Icon(
                                CupertinoIcons.share_solid,
                                color: AppColors.primaryBlue,
                              ),
                            ] else ...[
                              const Text('Stop Sharing Progress'),
                              const SizedBox(width: 10),
                              const Icon(
                                CupertinoIcons.stop_circle_fill,
                                color: AppColors.red,
                              ),
                            ],
                          ],
                        ),
                      ),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue,
                        fontSize: 16.0,
                      ),
                      labelBackgroundColor: Colors.white,
                    ),
                  ],
                  child: const Icon(
                    CupertinoIcons.gear_alt_fill,
                    color: Colors.white,
                  ),
                ),
              ),
      );
    });
  }
}
