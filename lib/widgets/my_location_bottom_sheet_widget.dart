import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/persistent_header_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:share_plus/share_plus.dart';

class MyLocationBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const MyLocationBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<MyLocationBottomSheetWidget> createState() =>
      _MyLocationBottomSheetWidgetState();
}

class _MyLocationBottomSheetWidgetState
    extends ConsumerState<MyLocationBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    final mainProvider = ref.read(widget.changeMainProvider);
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      final controller = mainProvider.myLocationBottomSheetController;
      final endOpacity =
          ((mainProvider.midPanelHeight + mainProvider.minPanelHeight) / 2);
      double t = controller.isAttached
          ? controller.size <= mainProvider.minPanelHeight
              ? 0
              : controller.size <= endOpacity
                  ? (controller.size - mainProvider.minPanelHeight) / endOpacity
                  : 1
          : 0;

      double temp = !widget.scrollController.hasClients
          ? 0
          : widget.scrollController.offset <= 0
              ? 0
              : 1;
      if (opacity != t || dividerOpacity != temp) {
        if (!mounted) return;
        setState(() {
          dividerOpacity = temp;
          opacity = t;
        });
      }
    });

    getDetailsAboutLocation();
  }

  double opacity = 0;
  double dividerOpacity = 0;
  CommutePlace? place;
  bool loading = true;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> getDetailsAboutLocation() async {
    final mainProvider = ref.read(widget.changeMainProvider);
    place = mainProvider.markedPlace ??
        await mainProvider.getDetailsAboutLocation(
          mainProvider.currentLatLng!,
        );

    mainProvider.markedPlace ??= place;
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

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
      clipBehavior: Clip.hardEdge,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.white.withOpacity(.85),
            child: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: PersistentHeaderWidgetDelegate(
                    minHeight: 68,
                    maxHeight: 68,
                    child: Container(
                      color: dividerOpacity == 1
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : Colors.transparent,
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            width: 40,
                            height: 5,
                          ),
                          const SizedBox(height: 10),
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
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'My Location',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () async {
                                        final url = await FirebaseDynamicLinks
                                            .instance
                                            .buildLink(DynamicLinkParameters(
                                          link: Uri.parse(
                                            'https://commuteguide.page.link/share_location/${mainProvider.currentLatLng!.latitude}/${mainProvider.currentLatLng!.longitude}',
                                          ),
                                          uriPrefix:
                                              'https://commuteguide.page.link',
                                          iosParameters: const IOSParameters(
                                              bundleId: 'com.commuteguide.app'),
                                        ));
                                        await Share.shareUri(url);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(.1),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: const Icon(
                                          CupertinoIcons.share_up,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        mainProvider.popSheet();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(.1),
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
                          const SizedBox(height: 11),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: math.min(opacity, dividerOpacity),
                            child: Divider(
                              thickness: 1,
                              height: 1,
                              color: Colors.grey.withOpacity(.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Opacity(
                    opacity: opacity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: mainProvider.leftPadding,
                        right: mainProvider.rightPadding,
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 100,
                              child: CupertinoActivityIndicator(),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          mainProvider.popSheet();
                                          mainProvider.addPoint(
                                              mainProvider.currentLatLng!);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          child: const Column(
                                            children: [
                                              Icon(
                                                CupertinoIcons.map_pin_ellipse,
                                                color: AppColors.primaryBlue,
                                                size: 20,
                                              ),
                                              Text(
                                                'Drop Pin',
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Details',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.maxFinite,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (place != null) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Address',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                place!.address
                                                    .replaceAll(', ', '\n'),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                          height: 1,
                                          color: Colors.grey.withOpacity(.05),
                                          indent: 15,
                                        ),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Coordinates',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'Latitude: ${mainProvider.currentLatLng!.latitude}\nLongitude: ${mainProvider.currentLatLng!.longitude}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
