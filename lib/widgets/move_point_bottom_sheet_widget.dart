import 'dart:ui';

import 'package:commute_guide/access_token.dart';
import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/current_direction_widget.dart';
import 'package:commute_guide/widgets/current_location_widget.dart';
import 'package:commute_guide/widgets/marked_location_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MovePointBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  final LatLng currentLatLng;
  final CameraFit? cameraFit;
  final bool shouldShowRemovePin;
  const MovePointBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
    required this.currentLatLng,
    this.shouldShowRemovePin = true,
    this.cameraFit,
  });

  @override
  ConsumerState<MovePointBottomSheetWidget> createState() =>
      _MovePointBottomSheetWidgetState();
}

class _MovePointBottomSheetWidgetState
    extends ConsumerState<MovePointBottomSheetWidget> {
  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  bool isCentered = false;
  late MapController mapController;

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);

    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: mainProvider.maxPanelHeight * MediaQuery.sizeOf(context).height,
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.white.withOpacity(.96),
            child: Column(
              children: [
                Container(
                  // color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.only(
                          left: mainProvider.leftPadding,
                          right: mainProvider.rightPadding,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ButtonWidget(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  text: 'Cancel',
                                  buttonType: ButtonTypeEnum.textButton,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Move Pin',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                ButtonWidget(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pop(mapController.camera.center);
                                  },
                                  text: 'Done',
                                  buttonType: ButtonTypeEnum.textButton,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      // SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                            initialCenter: widget.currentLatLng,
                            initialCameraFit: widget.cameraFit,
                            initialZoom: 18,
                            onPositionChanged: (camera, hasGesture) {
                              if (!hasGesture) {
                                if (camera.center ==
                                    mainProvider.currentLatLng) {
                                  return;
                                }
                              }
                              setState(() {
                                isCentered = false;
                              });
                            }),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://api.mapbox.com/styles/v1/mapbox/satellite-streets-v12/tiles/{z}/{x}/{y}?access_token=$accessToken',
                            tileProvider: CancellableNetworkTileProvider(),
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
                                    changeMainProvider:
                                        widget.changeMainProvider,
                                  ),
                                ),
                              if (mainProvider.currentLatLng != null)
                                Marker(
                                  point: mainProvider.currentLatLng!,
                                  width: 23,
                                  height: 23,
                                  child: const CurrentLocationWidget(),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: mainProvider.leftPadding,
                            right: mainProvider.rightPadding,
                            top: 10,
                            bottom: 10,
                          ),
                          width: double.maxFinite,
                          color: Colors.grey.withOpacity(.9),
                          child: const Text(
                            'Move the map to the correct location',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (mainProvider.currentLatLng != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                              bottom: !widget.shouldShowRemovePin
                                  ? mainProvider.bottomPadding + 15
                                  : 15,
                            ),
                            child: FloatingActionButton(
                              onPressed: () {
                                mapController.move(
                                    mainProvider.currentLatLng!, 18);
                                setState(() {
                                  isCentered = true;
                                });
                              },
                              backgroundColor: Colors.white,
                              child: Icon(
                                isCentered
                                    ? CupertinoIcons.location_fill
                                    : CupertinoIcons.location,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      const Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 95,
                          height: 95,
                          child: MarkedLocationWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.shouldShowRemovePin)
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonWidget(
                              onTap: () {
                                Navigator.of(context).pop('remove');
                              },
                              text: 'Remove Pin',
                              buttonType: ButtonTypeEnum.textButton,
                              color: AppColors.red,
                              textStyle: const TextStyle(
                                color: AppColors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: mainProvider.bottomPadding),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
