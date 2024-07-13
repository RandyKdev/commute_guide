import 'dart:async';

import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/screens/choose_map_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MapControlsWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const MapControlsWidget({super.key, required this.changeMainProvider});

  @override
  ConsumerState<MapControlsWidget> createState() => _MapControlsWidgetState();
}

class _MapControlsWidgetState extends ConsumerState<MapControlsWidget> {
  late Timer timer;
  double opacity = 1;
  double? compassHeading;
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 17),
      (_) {
        WidgetsBinding.instance.addPostFrameCallback((t) {
          if (!mounted) return;
          final mainProvider = ref.read(widget.changeMainProvider);
          if (opacity == mainProvider.mapControlsOpacity &&
              compassHeading == mainProvider.compassHeading) return;
          setState(() {
            opacity = mainProvider.mapControlsOpacity;
            compassHeading = mainProvider.compassHeading;
          });
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: opacity,
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(
              top: mainProvider.padding.top + 20,
              // bottom: mainProvider.padding.bottom,
              left: mainProvider.padding.left,
              right: mainProvider.padding.right,
            ),
            child: Builder(builder: (context) {
              return Column(
                children: [
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 45,
                      child: Column(
                        children: [
                          InkWell(
                            child: SizedBox(
                              height: 50,
                              child: Icon(
                                mainProvider.getMapIcon(),
                                color: Colors.black.withOpacity(.5),
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              showMaterialModalBottomSheet(
                                context: context,
                                enableDrag: true,
                                isDismissible: true,
                                // elevation: 10,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                builder: (context) {
                                  return ChooseMapScreen(
                                    changeMainProvider:
                                        widget.changeMainProvider,
                                  );
                                },
                              );
                            },
                          ),
                          const Divider(
                            thickness: 1,
                            height: 1,
                          ),
                          InkWell(
                            child: SizedBox(
                              height: 50,
                              child: mainProvider.browseModeEnum ==
                                          BrowseModeEnum.myLocation &&
                                      mainProvider.currentLatLng == null
                                  ? const CupertinoActivityIndicator()
                                  : Icon(
                                      mainProvider.getBrowseModeIcon(),
                                      color: Colors.black.withOpacity(.5),
                                      size: 20,
                                    ),
                            ),
                            onTap: () {
                              mainProvider.setBrowseMode();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (compassHeading != null)
                    InkWell(
                      onTap: () {
                        mainProvider.setMapToNorth();
                      },
                      child: Material(
                        elevation: 5,
                        shape: const CircleBorder(),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          width: 45,
                          height: 45,
                          // padding: EdgeInsets.all(2.5),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle:
                                      (compassHeading! * (math.pi / 180) * -1),
                                  child: Image.asset(
                                    'assets/maps/compass.png',
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 25,
                                  height: 25,
                                  child: Center(
                                    child: Text(
                                      mainProvider.getCompassHeading(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
