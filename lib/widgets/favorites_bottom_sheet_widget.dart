import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/add_favorite_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/favorite_editable_list_tile_widget.dart';
import 'package:commute_guide/widgets/place_list_tile_widget.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:share_plus/share_plus.dart';

class FavoritesBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const FavoritesBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<FavoritesBottomSheetWidget> createState() =>
      _FavoritesBottomSheetWidgetState();
}

class _FavoritesBottomSheetWidgetState
    extends ConsumerState<FavoritesBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      double temp = widget.scrollController.positions.firstOrNull == null
          ? 0
          : widget.scrollController.positions.first.pixels <= 0
              ? 0
              : 1;
      if (dividerOpacity != temp) {
        if (!mounted) return;
        setState(() {
          dividerOpacity = temp;
        });
      }
    });
    favorites = ref.read(globalProvider).user?.favorites;
  }

  double dividerOpacity = 0;
  bool isEditing = false;
  List<CommutePlace>? favorites = [];

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
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Favorites',
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
                                  onTap: () {
                                    Navigator.of(context).pop();
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
                        opacity: dividerOpacity,
                        child: Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey.withOpacity(.1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: mainProvider.leftPadding,
                        right: mainProvider.rightPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              children: [
                                FavoriteEditableListTileWidget(
                                  changeMainProvider: widget.changeMainProvider,
                                  index: null,
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
                                                ModalScrollController.of(ctx)!,
                                            placeType: PlaceTypeEnum.home,
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    final home = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.home);
                                    Navigator.of(context)
                                        .popUntil((r) => r.isFirst);

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
                                  address: hasHomeLocation
                                      ? userGlobalProvider.user!.favorites!
                                          .firstWhere((e) =>
                                              e.placeType == PlaceTypeEnum.home)
                                          .address
                                      : null,
                                  placeTypeEnum: PlaceTypeEnum.home,
                                  isEditing: isEditing,
                                  onDelete: () async {
                                    if (!hasHomeLocation) {
                                      return;
                                    }
                                    final home = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.home);
                                    final user =
                                        mainProvider.removePlaceFromFavorite(
                                      place: home,
                                      user: userGlobalProvider.user!,
                                    );
                                    userGlobalProvider.user = user;
                                  },
                                  onShare: () async {
                                    if (!hasHomeLocation) {
                                      return;
                                    }

                                    final home = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.home);

                                    final url = await FirebaseDynamicLinks
                                        .instance
                                        .buildLink(DynamicLinkParameters(
                                      link: Uri.parse(
                                        'https://commuteguide.page.link/share_location/${home.lat}/${home.lng}',
                                      ),
                                      uriPrefix:
                                          'https://commuteguide.page.link',
                                      iosParameters: const IOSParameters(
                                          bundleId: 'com.commuteguide.app'),
                                    ));
                                    await Share.shareUri(url);
                                  },
                                ),
                                Divider(
                                  color: Colors.grey.withOpacity(.05),
                                  height: 1,
                                  indent: 20,
                                  thickness: 1,
                                ),
                                FavoriteEditableListTileWidget(
                                  changeMainProvider: widget.changeMainProvider,
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
                                                ModalScrollController.of(ctx)!,
                                            placeType: PlaceTypeEnum.work,
                                          );
                                        },
                                      );
                                      return;
                                    }
                                    final work = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.work);
                                    Navigator.of(context)
                                        .popUntil((r) => r.isFirst);

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
                                  index: null,
                                  address: hasWorkLocation
                                      ? userGlobalProvider.user!.favorites!
                                          .firstWhere((e) =>
                                              e.placeType == PlaceTypeEnum.work)
                                          .address
                                      : null,
                                  placeTypeEnum: PlaceTypeEnum.work,
                                  isEditing: isEditing,
                                  onDelete: () async {
                                    if (!hasWorkLocation) {
                                      return;
                                    }
                                    final work = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.work);
                                    final user =
                                        mainProvider.removePlaceFromFavorite(
                                      place: work,
                                      user: userGlobalProvider.user!,
                                    );
                                    userGlobalProvider.user = user;
                                  },
                                  onShare: () async {
                                    if (!hasWorkLocation) {
                                      return;
                                    }

                                    final work = userGlobalProvider
                                        .user!.favorites!
                                        .firstWhere((e) =>
                                            e.placeType == PlaceTypeEnum.work);

                                    final url = await FirebaseDynamicLinks
                                        .instance
                                        .buildLink(DynamicLinkParameters(
                                      link: Uri.parse(
                                        'https://commuteguide.page.link/share_location/${work.lat}/${work.lng}',
                                      ),
                                      uriPrefix:
                                          'https://commuteguide.page.link',
                                      iosParameters: const IOSParameters(
                                          bundleId: 'com.commuteguide.app'),
                                    ));
                                    await Share.shareUri(url);
                                  },
                                ),
                                ReorderableListView(
                                  buildDefaultDragHandles: false,
                                  shrinkWrap: true,
                                  clipBehavior: Clip.hardEdge,
                                  primary: false,
                                  onReorder: (oldIndex, newIndex) {
                                    final user = mainProvider.reorderFavorites(
                                      oldIndex: oldIndex,
                                      newIndex: newIndex,
                                      user: userGlobalProvider.user!,
                                    );
                                    userGlobalProvider.user = user;
                                    setState(() {
                                      favorites = user.favorites;
                                    });
                                  },
                                  children: favorites!
                                      .where((e) =>
                                          e.placeType == PlaceTypeEnum.other)
                                      .map(
                                    (place) {
                                      final favs = favorites!
                                          .where((e) =>
                                              e.placeType ==
                                              PlaceTypeEnum.other)
                                          .toList();

                                      return FavoriteEditableListTileWidget(
                                        key: ValueKey(place.placeId),
                                        index: favs.indexOf(place),
                                        changeMainProvider:
                                            widget.changeMainProvider,
                                        onTap: () async {
                                          Navigator.of(context)
                                              .popUntil((r) => r.isFirst);

                                          mainProvider.directionPlaces.add(
                                            place,
                                          );
                                          mainProvider.setVisiblePoints([]);
                                          mainProvider.showDirections();
                                          // mainProvider.addPoint(
                                          //   LatLng(place.lat, place.lng),
                                          //   place,
                                          // );
                                        },
                                        address: place.address,
                                        placeTypeEnum: PlaceTypeEnum.other,
                                        isEditing: isEditing,
                                        onDelete: () async {
                                          final user = mainProvider
                                              .removePlaceFromFavorite(
                                            place: place,
                                            user: userGlobalProvider.user!,
                                          );
                                          userGlobalProvider.user = user;
                                          setState(() {
                                            favorites = user.favorites;
                                          });
                                        },
                                        onShare: () async {
                                          final url = await FirebaseDynamicLinks
                                              .instance
                                              .buildLink(DynamicLinkParameters(
                                            link: Uri.parse(
                                              'https://commuteguide.page.link/share_location/${place.lat}/${place.lng}',
                                            ),
                                            uriPrefix:
                                                'https://commuteguide.page.link',
                                            iosParameters: const IOSParameters(
                                                bundleId:
                                                    'com.commuteguide.app'),
                                          ));
                                          await Share.shareUri(url);
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!isEditing &&
                              userGlobalProvider.user?.recents?.isNotEmpty ==
                                  true) ...[
                            Container(
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          'Recents',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.only(left: 20),
                                    child: ListView.separated(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (ctx, index) {
                                        final place = userGlobalProvider
                                            .user!.recents!.reversed
                                            .elementAt(index);
                                        return PlaceListTileWidget(
                                          key: ValueKey(place),
                                          showSearchIcon: false,
                                          showStarIcon: false,
                                          changeMainProvider:
                                              widget.changeMainProvider,
                                          place: place,
                                          showAddIcon: true,
                                          onTap: () async {
                                            final user = await mainProvider
                                                .addPlaceToFavorite(
                                              place: place,
                                              user: userGlobalProvider.user!,
                                            );

                                            userGlobalProvider.user = user;
                                          },
                                          addRightPadding: false,
                                        );
                                      },
                                      separatorBuilder: (ctx, index) {
                                        return Divider(
                                          color: Colors.grey.withOpacity(.1),
                                          height: 1,
                                          indent: 0,
                                          thickness: 1,
                                        );
                                      },
                                      itemCount: userGlobalProvider
                                          .user!.recents!.length,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.withOpacity(.2),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: mainProvider.leftPadding,
                    right: mainProvider.rightPadding,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: ButtonWidget(
                                onTap: () {
                                  setState(() {
                                    isEditing = !isEditing;
                                  });
                                },
                                text: isEditing ? 'Done' : 'Edit',
                                buttonType: ButtonTypeEnum.textButton,
                                color: AppColors.primaryBlue),
                          ),
                          if (!isEditing)
                            SizedBox(
                              height: 47,
                              child: GestureDetector(
                                onTap: () {
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
                                child: const Icon(
                                  CupertinoIcons.add,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 47),
                        ],
                      ),
                      SizedBox(height: mainProvider.bottomPadding),
                    ],
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
