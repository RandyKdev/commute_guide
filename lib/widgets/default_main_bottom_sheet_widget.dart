import 'dart:async';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/add_favorite_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/favorite_grid_tile_widget.dart';
import 'package:commute_guide/widgets/favorites_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/issues_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/place_list_tile_widget.dart';
import 'package:commute_guide/widgets/recents_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/scheduled_trips_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/trip_list_tile_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class DefaultMainBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const DefaultMainBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
  });

  @override
  ConsumerState<DefaultMainBottomSheetWidget> createState() =>
      _DefaultMainBottomSheetWidgetState();
}

class _DefaultMainBottomSheetWidgetState
    extends ConsumerState<DefaultMainBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    final mainProvider = ref.read(widget.changeMainProvider);
    // widget.scrollController.
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      final controller = mainProvider.mainBottomSheetController;
      final endOpacity =
          ((mainProvider.midPanelHeight + mainProvider.minPanelHeight) / 2);
      double t = controller.isAttached
          ? controller.size <= mainProvider.minPanelHeight
              ? 0
              : controller.size <= endOpacity
                  ? (controller.size - mainProvider.minPanelHeight) / endOpacity
                  : 1
          : 0;
      if (opacity != t) {
        if (!mounted) return;
        setState(() {
          opacity = t;
        });
      }
    });
  }

  double opacity = 0;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    final userGlobalProvider = ref.watch(globalProvider);
    final hasHomeLocation = userGlobalProvider.user?.favorites
            ?.any((e) => e.placeType == PlaceTypeEnum.home) ==
        true;
    final hasWorkLocation = userGlobalProvider.user?.favorites
            ?.any((e) => e.placeType == PlaceTypeEnum.work) ==
        true;
    return SliverToBoxAdapter(
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: mainProvider.leftPadding,
                      right: mainProvider.rightPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 0,
                          ),
                          child: Text(
                            'Favorites',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ButtonWidget(
                          onTap: () {
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
                                return FavoritesBottomSheetWidget(
                                  changeMainProvider:
                                      widget.changeMainProvider,
                                  scrollController:
                                      ModalScrollController.of(ctx)!,
                                );
                              },
                            );
                          },
                          text: 'More',
                          color: AppColors.primaryBlue,
                          buttonType: ButtonTypeEnum.textButton,
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: mainProvider.screenWidth,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: mainProvider.leftPadding),
                          Container(
                            height: 130,
                            constraints: BoxConstraints(
                              minWidth: mainProvider.screenWidth -
                                  mainProvider.leftPadding -
                                  mainProvider.rightPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                FavoriteGridTileWidget(
                                  changeMainProvider:
                                      widget.changeMainProvider,
                                  address: hasHomeLocation
                                      ? userGlobalProvider.user!.favorites!
                                          .firstWhere((e) =>
                                              e.placeType ==
                                              PlaceTypeEnum.home)
                                          .address
                                      : null,
                                  onTap: () async {
                                    if (!hasHomeLocation) {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        isDismissible: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) {
                                          return AddFavoriteBottomSheetWidget(
                                            changeMainProvider:
                                                widget.changeMainProvider,
                                            scrollController:
                                                ModalScrollController.of(
                                                    ctx)!,
                                            placeType: PlaceTypeEnum.home,
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    final home = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType ==
                                            PlaceTypeEnum.home);
              
                                    mainProvider.directionPlaces.add(
                                      home,
                                    );
                                    mainProvider.setVisiblePoints([]);
                                    mainProvider.showDirections();
                                    // mainProvider.addPoint(
                                    //   LatLng(home.lat, home.lng),
                                    //   home,
                                    // );
                                  },
                                  placeTypeEnum: PlaceTypeEnum.home,
                                ),
                                FavoriteGridTileWidget(
                                  changeMainProvider:
                                      widget.changeMainProvider,
                                  address: hasWorkLocation
                                      ? userGlobalProvider.user!.favorites!
                                          .firstWhere((e) =>
                                              e.placeType ==
                                              PlaceTypeEnum.work)
                                          .address
                                      : null,
                                  onTap: () async {
                                    if (!hasWorkLocation) {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        isDismissible: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) {
                                          return AddFavoriteBottomSheetWidget(
                                            changeMainProvider:
                                                widget.changeMainProvider,
                                            scrollController:
                                                ModalScrollController.of(
                                                    ctx)!,
                                            placeType: PlaceTypeEnum.work,
                                          );
                                        },
                                      );
                                      return;
                                    }
              
                                    final work = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType ==
                                            PlaceTypeEnum.work);
                                    mainProvider.directionPlaces.add(
                                      work,
                                    );
                                    mainProvider.setVisiblePoints([]);
                                    mainProvider.showDirections();
                                    // mainProvider.addPoint(
                                    //   LatLng(work.lat, work.lng),
                                    //   work,
                                    // );
                                  },
                                  placeTypeEnum: PlaceTypeEnum.work,
                                ),
                                if (userGlobalProvider.user?.favorites
                                        ?.where((e) =>
                                            e.placeType ==
                                            PlaceTypeEnum.other)
                                        .isNotEmpty ==
                                    true)
                                  ListView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    children: userGlobalProvider
                                        .user!.favorites!
                                        .where((e) =>
                                            e.placeType ==
                                            PlaceTypeEnum.other)
                                        .map((place) {
                                      return FavoriteGridTileWidget(
                                        changeMainProvider:
                                            widget.changeMainProvider,
                                        onTap: () async {
                                          mainProvider.directionPlaces.add(
                                            place,
                                          );
                                          mainProvider.setVisiblePoints([]);
                                          mainProvider.showDirections();
                                          // sd
                                          // mainProvider.addPoint(
                                          //   LatLng(place.lat, place.lng),
                                          //   place,
                                          // );
                                        },
                                        address: place.address,
                                        placeTypeEnum: PlaceTypeEnum.other,
                                      );
                                    }).toList(),
                                  ),
                                FavoriteGridTileWidget(
                                  changeMainProvider:
                                      widget.changeMainProvider,
                                  address: 'Add',
                                  isAdd: true,
                                  onTap: () async {
                                    showMaterialModalBottomSheet(
                                      context: context,
                                      isDismissible: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) {
                                        return AddFavoriteBottomSheetWidget(
                                          changeMainProvider:
                                              widget.changeMainProvider,
                                          scrollController:
                                              ModalScrollController.of(ctx)!,
                                        );
                                      },
                                    );
                                  },
                                  placeTypeEnum: PlaceTypeEnum.other,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: mainProvider.rightPadding,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (userGlobalProvider
                      .user?.getCurrentScheduledTrips.isNotEmpty ==
                  true) ...[
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.only(
                    left: mainProvider.leftPadding,
                    right: mainProvider.rightPadding,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Scheduled Trips',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ButtonWidget(
                            onTap: () {
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
                                  return ScheduledBottomSheetWidget(
                                    changeMainProvider:
                                        widget.changeMainProvider,
                                    scrollController:
                                        ModalScrollController.of(ctx)!,
                                  );
                                },
                              );
                            },
                            text: 'More',
                            color: AppColors.primaryBlue,
                            buttonType: ButtonTypeEnum.textButton,
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                          left: 20,
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            final trip = userGlobalProvider
                                .user!.getCurrentScheduledTrips
                                .elementAt(index);
                            return TripListTileWidget(
                              changeMainProvider: widget.changeMainProvider,
                              trip: trip,
                              onTap: () async {
                                mainProvider.setScheduledTripDirections(trip);
                              },
                            );
                          },
                          separatorBuilder: (ctx, index) {
                            return Divider(
                              color: Colors.grey.withOpacity(.05),
                              height: 1,
                              indent: 0,
                              thickness: 1,
                            );
                          },
                          itemCount: math.min(
                            userGlobalProvider
                                .user!.getCurrentScheduledTrips.length,
                            5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (userGlobalProvider.user?.recents?.isNotEmpty == true) ...[
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.only(
                    left: mainProvider.leftPadding,
                    right: mainProvider.rightPadding,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recents',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ButtonWidget(
                            onTap: () {
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
                                  return RecentsBottomSheetWidget(
                                    changeMainProvider:
                                        widget.changeMainProvider,
                                    scrollController:
                                        ModalScrollController.of(ctx)!,
                                  );
                                },
                              );
                            },
                            text: 'More',
                            color: AppColors.primaryBlue,
                            buttonType: ButtonTypeEnum.textButton,
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.only(
                          left: 20,
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            final place = userGlobalProvider
                                .user!.recents!.reversed
                                .elementAt(index);
                            return PlaceListTileWidget(
                              showSearchIcon: false,
                              changeMainProvider: widget.changeMainProvider,
                              place: place,
                              showAddIcon: false,
                              onTap: () async {
                                mainProvider.addPoint(
                                  LatLng(place.lat, place.lng),
                                  place,
                                );
                              },
                              showStarIcon: false,
                            );
                          },
                          separatorBuilder: (ctx, index) {
                            return Divider(
                              color: Colors.grey.withOpacity(.05),
                              height: 1,
                              indent: 0,
                              thickness: 1,
                            );
                          },
                          itemCount: math.min(
                              userGlobalProvider.user!.recents!.length, 5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (mainProvider.currentLatLng != null) ...[
                GestureDetector(
                  onTap: () async {
                    final url = await FirebaseDynamicLinks.instance
                        .buildLink(DynamicLinkParameters(
                      link: Uri.parse(
                        'https://commuteguide.page.link/share_location/${mainProvider.currentLatLng!.latitude}/${mainProvider.currentLatLng!.longitude}',
                      ),
                      uriPrefix: 'https://commuteguide.page.link',
                      iosParameters:
                          const IOSParameters(bundleId: 'com.commuteguide.app'),
                    ));
                    await Share.shareUri(url);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: mainProvider.leftPadding,
                      right: mainProvider.rightPadding,
                    ),
                    width: double.maxFinite,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: const Center(
                      child: Text(
                        'Share My Location',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    mainProvider.addPoint(mainProvider.currentLatLng!);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: mainProvider.leftPadding,
                      right: mainProvider.rightPadding,
                    ),
                    width: double.maxFinite,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: const Center(
                      child: Text(
                        'Mark My Location',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              GestureDetector(
                onTap: () {
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
                      return IssuesBottomSheetWidget(
                        changeMainProvider: widget.changeMainProvider,
                        scrollController: ModalScrollController.of(ctx)!,
                      );
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: mainProvider.leftPadding,
                    right: mainProvider.rightPadding,
                  ),
                  width: double.maxFinite,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: const Center(
                    child: Text(
                      'Issues',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: mainProvider.bottomPadding),
            ],
          ),
        ),
      ),
    );
  }
}
