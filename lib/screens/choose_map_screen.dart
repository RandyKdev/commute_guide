import 'dart:ui';

import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/map_style_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseMapScreen extends ConsumerWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const ChooseMapScreen({
    super.key,
    required this.changeMainProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainProvider = ref.watch(changeMainProvider);
    return Container(
      decoration: const BoxDecoration(
        // color: Colors.white.withOpacity(.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      height: mainProvider.midPanelHeight * MediaQuery.sizeOf(context).height,
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
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              // color: Colors.white.withAlpha(240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Choose Map',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(.2),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: const Icon(
                                  CupertinoIcons.clear_thick,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              MapStyles(
                                image: 'assets/maps/explore.png',
                                onPressed: () {
                                  mainProvider
                                      .setMapStyle(MapStyleEnum.explore);
                                },
                                title: 'Explore',
                                selected: mainProvider.mapStyleEnum ==
                                    MapStyleEnum.explore,
                              ),
                              const SizedBox(width: 20),
                              MapStyles(
                                image: 'assets/maps/driving.jpg',
                                onPressed: () {
                                  mainProvider
                                      .setMapStyle(MapStyleEnum.driving);
                                },
                                title: 'Driving',
                                selected: mainProvider.mapStyleEnum ==
                                    MapStyleEnum.driving,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: [
                              MapStyles(
                                image: 'assets/maps/transit.png',
                                onPressed: () {
                                  mainProvider
                                      .setMapStyle(MapStyleEnum.terrain);
                                },
                                title: 'Terrain',
                                selected: mainProvider.mapStyleEnum ==
                                    MapStyleEnum.terrain,
                              ),
                              const SizedBox(width: 20),
                              MapStyles(
                                image: 'assets/maps/satellite.png',
                                onPressed: () {
                                  mainProvider
                                      .setMapStyle(MapStyleEnum.satellite);
                                },
                                title: 'Satellite',
                                selected: mainProvider.mapStyleEnum ==
                                    MapStyleEnum.satellite,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: mainProvider.bottomPadding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
