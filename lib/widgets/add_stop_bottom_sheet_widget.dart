import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/utils/utility.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/favorite_editable_list_tile_widget.dart';
import 'package:commute_guide/widgets/move_point_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/place_list_tile_widget.dart';
import 'package:commute_guide/widgets/search_form_field_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddStopBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  final bool isChange;
  const AddStopBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
    this.isChange = false,
  });

  @override
  ConsumerState<AddStopBottomSheetWidget> createState() =>
      _AddStopBottomSheetWidgetState();
}

class _AddStopBottomSheetWidgetState
    extends ConsumerState<AddStopBottomSheetWidget> {
  late Timer timer;
  Timer? searchTimer;
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
  }

  double dividerOpacity = 0;
  bool isSearching = false;
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  List<CommutePlace> places = [];

  @override
  void dispose() {
    timer.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    final userGlobalProvider = ref.watch(globalProvider);
    final favorites = [...?userGlobalProvider.user?.favorites]
      ..removeWhere((e) {
        return mainProvider.directionPlaces.any((p) => p?.placeId == e.placeId);
      })
      ..sort((a, b) => b.placeType.index.compareTo(a.placeType.index));
    final recents = [...?userGlobalProvider.user?.recents]..removeWhere((e) {
        return mainProvider.directionPlaces.any((p) => p?.placeId == e.placeId);
      });
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
                                Expanded(
                                  child: Text(
                                    widget.isChange
                                        ? 'Change Stop'
                                        : 'Add Stop',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 50),
                              ],
                            ),
                            const SizedBox(height: 5),
                            SearchFieldWidget(
                              hintText: 'Search...',
                              prefixIcon: const Icon(
                                CupertinoIcons.search,
                                color: Colors.grey,
                              ),
                              backgroundColor: Colors.grey.withOpacity(.1),
                              controller: searchController,
                              focusNode: searchFocusNode,
                              suffixIcon: searchController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        searchController.clear();
                                        if (searchTimer != null) {
                                          Utility.clearTimeout(searchTimer!);
                                        }
                                        setState(() {
                                          isSearching = false;
                                          places = [];
                                        });
                                      },
                                      child: const Icon(
                                        CupertinoIcons.clear_thick_circled,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        searchController.clear();
                                        searchFocusNode.unfocus();
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
                                              currentLatLng: mainProvider
                                                  .mapController.camera.center,
                                              shouldShowRemovePin: false,
                                            );
                                          },
                                        );
                                        if (result == null) {
                                          return;
                                        }

                                        final newLatLng = result as LatLng;
                                        if (!mounted) return;
                                        setState(() {
                                          isSearching = true;
                                          places = [];
                                        });

                                        final place = await mainProvider
                                            .getDetailsAboutLocation(newLatLng);
                                        if (place == null) {
                                          return setState(() {
                                            isSearching = false;
                                            places = [];
                                          });
                                        }
                                        if (!mounted) return;
                                        setState(() {
                                          isSearching = false;
                                          places = [place];
                                        });
                                      },
                                      child: const Icon(
                                        CupertinoIcons.map_pin_ellipse,
                                        color: Colors.grey,
                                      ),
                                    ),
                              onChanged: (val) {
                                val = val.trim();
                                if (searchTimer != null) {
                                  Utility.clearTimeout(searchTimer!);
                                }

                                if (val.trim().isEmpty) {
                                  setState(() {
                                    isSearching = false;
                                    places = [];
                                  });
                                  return;
                                }

                                setState(() {
                                  isSearching = true;
                                  places = [];
                                });
                                searchTimer = Utility.setTimeout(() async {
                                  if (!mounted) return;
                                  final places =
                                      await mainProvider.searchLocation(val);

                                  if (!mounted) return;
                                  setState(() {
                                    isSearching = false;
                                    this.places = places
                                      ..removeWhere((e) {
                                        return mainProvider.directionPlaces.any(
                                            (p) => p?.placeId == e.placeId);
                                      });
                                  });
                                });
                              },
                              onFocus: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isSearching)
                            const SizedBox(
                              height: 100,
                              child: Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            )
                          else if (places.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                left: mainProvider.leftPadding,
                              ),
                              child: Column(
                                children: [
                                  ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (ctx, index) {
                                      return PlaceListTileWidget(
                                        showSearchIcon: !favorites.any((e) =>
                                            e.placeId == places[index].placeId),
                                        showStarIcon: favorites.any((e) =>
                                            e.placeId == places[index].placeId),
                                        changeMainProvider:
                                            widget.changeMainProvider,
                                        place: places[index],
                                        showAddIcon: false,
                                        onTap: () async {
                                          Navigator.of(context)
                                              .pop(places[index]);
                                        },
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return Divider(
                                        color: Colors.grey.withOpacity(.05),
                                        height: 1,
                                        // indent: 45,
                                        thickness: 1,
                                      );
                                    },
                                    itemCount: places.length,
                                  ),
                                  Divider(
                                    color: Colors.grey.withOpacity(.05),
                                    height: 1,
                                    // indent: 45,
                                    thickness: 1,
                                  ),
                                ],
                              ),
                            )
                          else if ((recents.isNotEmpty || favorites.isEmpty) &&
                              searchController.text.isEmpty) ...[
                            if (favorites.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 10,
                                      left: mainProvider.leftPadding,
                                    ),
                                    child: const Text(
                                      'Favorites',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.withOpacity(.05),
                                height: 1,
                                indent: mainProvider.leftPadding,
                                thickness: 1,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.grey.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.only(
                                  left: mainProvider.leftPadding,
                                ),
                                child: ListView.separated(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (ctx, index) {
                                    final place =
                                        favorites.reversed.elementAt(index);
                                    return FavoriteEditableListTileWidget(
                                      changeMainProvider:
                                          widget.changeMainProvider,
                                      placeTypeEnum: place.placeType,
                                      address: place.address,
                                      isEditing: false,
                                      onDelete: () {},
                                      onShare: () {},
                                      isAddStopScreen: true,
                                      index: null,
                                      onTap: () async {
                                        Navigator.of(context).pop(place);
                                      },
                                    );
                                  },
                                  separatorBuilder: (ctx, index) {
                                    return Divider(
                                      color: Colors.grey.withOpacity(.05),
                                      height: 1,
                                      // indent: 45,
                                      thickness: 1,
                                    );
                                  },
                                  itemCount: favorites.length,
                                ),
                              ),
                            ],
                            if (favorites.isNotEmpty && recents.isEmpty)
                              Divider(
                                color: Colors.grey.withOpacity(.1),
                                height: 1,
                                indent: mainProvider.leftPadding,
                                thickness: 1,
                              ),
                            if (favorites.isNotEmpty && recents.isNotEmpty)
                              const SizedBox(height: 20),
                            if (recents.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 10,
                                      left: mainProvider.leftPadding,
                                    ),
                                    child: const Text(
                                      'Recents',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey.withOpacity(.05),
                                height: 1,
                                indent: mainProvider.leftPadding,
                                thickness: 1,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  // color: Colors.grey.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.only(
                                  left: mainProvider.leftPadding,
                                ),
                                child: ListView.separated(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (ctx, index) {
                                    final place =
                                        recents.reversed.elementAt(index);
                                    return PlaceListTileWidget(
                                      showSearchIcon: false,
                                      showStarIcon: false,
                                      changeMainProvider:
                                          widget.changeMainProvider,
                                      place: place,
                                      showAddIcon: false,
                                      onTap: () async {
                                        Navigator.of(context).pop(place);
                                      },
                                    );
                                  },
                                  separatorBuilder: (ctx, index) {
                                    return Divider(
                                      color: Colors.grey.withOpacity(.05),
                                      height: 1,
                                      // indent: 45,
                                      thickness: 1,
                                    );
                                  },
                                  itemCount: recents.length,
                                ),
                              ),
                              Divider(
                                color: Colors.grey.withOpacity(.1),
                                height: 1,
                                indent: mainProvider.leftPadding,
                                thickness: 1,
                              ),
                            ],
                          ],
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
