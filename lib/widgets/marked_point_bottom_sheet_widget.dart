import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/models/user.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/utils/distance.dart';
import 'package:commute_guide/widgets/move_point_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/persistent_header_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:math' as math;

import 'package:pull_down_button/pull_down_button.dart';
import 'package:share_plus/share_plus.dart';

class MarkedPointBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const MarkedPointBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<MarkedPointBottomSheetWidget> createState() =>
      _MarkedPointBottomSheetWidgetState();
}

class _MarkedPointBottomSheetWidgetState
    extends ConsumerState<MarkedPointBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    final mainProvider = ref.read(widget.changeMainProvider);
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      final controller = mainProvider.markedPointBottomSheetController;
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

    getDistance();
    getDetailsAboutLocation();
  }

  double opacity = 0;
  double dividerOpacity = 0;
  double distance = 0;
  CommutePlace? place;
  bool loading = true;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getDistance() {
    final mainProvider = ref.read(widget.changeMainProvider);
    distance = Geolocator.distanceBetween(
      mainProvider.currentLatLng!.latitude,
      mainProvider.currentLatLng!.longitude,
      mainProvider.markedPoint!.latitude,
      mainProvider.markedPoint!.longitude,
    );
  }

  Future<void> getDetailsAboutLocation() async {
    final mainProvider = ref.read(widget.changeMainProvider);
    final userGlobalProvider = ref.read(globalProvider);

    place = mainProvider.markedPlace ??
        await mainProvider.getDetailsAboutLocation(
          mainProvider.markedPoint!,
        );

    mainProvider.markedPlace ??= place;
    if (place != null) {
      await mainProvider.addPlaceToRecents(
        place: place!,
        user: userGlobalProvider.user!,
      );
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    final userGlobalProvider = ref.watch(globalProvider);
    final inFavorites = userGlobalProvider.user?.favorites
            ?.any((e) => e.placeId == place?.placeId) ==
        true;
    return Container(
      decoration: const BoxDecoration(
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
                    minHeight: 72,
                    maxHeight: 72,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            place?.placeType ==
                                                    PlaceTypeEnum.home
                                                ? 'Home Location'
                                                : place?.placeType ==
                                                        PlaceTypeEnum.work
                                                    ? 'Work Location'
                                                    : 'Dropped Pin',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              height: 1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${DistanceUtility.getDistance(distance)} away',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              height: 1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
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
                                            'https://commuteguide.page.link/share_location/${mainProvider.markedPoint!.latitude}/${mainProvider.markedPoint!.longitude}',
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
                                    if (place != null) ...[
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            mainProvider.directionPlaces.add(
                                              mainProvider.markedPlace,
                                            );
                                            mainProvider.setVisiblePoints([]);
                                            mainProvider.showDirections();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(.1),
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
                                                  CupertinoIcons
                                                      .arrow_up_right_diamond,
                                                  color: AppColors.primaryBlue,
                                                  size: 20,
                                                ),
                                                Text(
                                                  'Directions',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await showMaterialModalBottomSheet(
                                            context: context,
                                            isDismissible: false,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            )),
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) {
                                              return MovePointBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                                currentLatLng:
                                                    mainProvider.markedPoint!,
                                              );
                                            },
                                          );
                                          if (result == null) {
                                            return;
                                          }

                                          if (result is String &&
                                              result == 'remove') {
                                            return mainProvider.popSheet();
                                          }
                                          final newLatLng = result as LatLng;
                                          mainProvider.addPoint(newLatLng);
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
                                                'Move',
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
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: PullDownButton(
                                        itemBuilder: (context) => [
                                          if (place != null)
                                            PullDownMenuItem(
                                              onTap: () async {
                                                late AppUser user;
                                                if (inFavorites) {
                                                  user = mainProvider
                                                      .removePlaceFromFavorite(
                                                    place: place!,
                                                    user: userGlobalProvider
                                                        .user!,
                                                  );
                                                } else {
                                                  user = await mainProvider
                                                      .addPlaceToFavorite(
                                                    place: place!,
                                                    user: userGlobalProvider
                                                        .user!,
                                                  );
                                                }
                                                userGlobalProvider.user = user;
                                              },
                                              title: inFavorites
                                                  ? 'Remove from Favorites'
                                                  : 'Add to Favorites',
                                              icon: inFavorites
                                                  ? CupertinoIcons.star_slash
                                                  : CupertinoIcons.star,
                                            ),
                                          PullDownMenuItem(
                                            onTap: () {
                                              mainProvider.popSheet();
                                            },
                                            title: 'Remove',
                                            isDestructive: true,
                                            icon: CupertinoIcons.delete,
                                          ),
                                        ],
                                        buttonBuilder: (context, showMenu) =>
                                            GestureDetector(
                                          onTap: showMenu,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(.1),
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
                                                  CupertinoIcons.ellipsis,
                                                  color: AppColors.primaryBlue,
                                                  size: 20,
                                                ),
                                                Text(
                                                  'More',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
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
                                              'Latitude: ${mainProvider.markedPoint?.latitude ?? ''}\nLongitude: ${mainProvider.markedPoint?.longitude ?? ''}',
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
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (place != null) ...[
                                        GestureDetector(
                                          onTap: () async {
                                            late AppUser user;
                                            if (inFavorites) {
                                              user = mainProvider
                                                  .removePlaceFromFavorite(
                                                place: place!,
                                                user: userGlobalProvider.user!,
                                              );
                                            } else {
                                              user = await mainProvider
                                                  .addPlaceToFavorite(
                                                place: place!,
                                                user: userGlobalProvider.user!,
                                              );
                                            }
                                            userGlobalProvider.user = user;
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(.05),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Icon(
                                                    inFavorites
                                                        ? CupertinoIcons
                                                            .star_slash
                                                        : CupertinoIcons
                                                            .star_fill,
                                                    color:
                                                        AppColors.primaryBlue,
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    inFavorites
                                                        ? 'Remove from Favorites'
                                                        : 'Add to Favorites',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.primaryBlue,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                          height: 1,
                                          color: Colors.grey.withOpacity(.05),
                                          indent: 55,
                                        ),
                                      ],
                                      GestureDetector(
                                        onTap: () {
                                          mainProvider.popSheet();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(.05),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: const Icon(
                                                  CupertinoIcons.delete_solid,
                                                  color: Colors.red,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
