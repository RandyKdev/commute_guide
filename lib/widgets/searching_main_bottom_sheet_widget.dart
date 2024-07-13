import 'dart:async';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/place_list_tile_widget.dart';
import 'package:commute_guide/widgets/recents_bottom_sheet_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SearchingMainBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final bool isSearching;
  final List<CommutePlace> places;
  const SearchingMainBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.isSearching,
    required this.places,
  });

  @override
  ConsumerState<SearchingMainBottomSheetWidget> createState() =>
      _SearchingMainBottomSheetWidgetState();
}

class _SearchingMainBottomSheetWidgetState
    extends ConsumerState<SearchingMainBottomSheetWidget> {
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
    return SliverToBoxAdapter(
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Container(
            child: Column(
              children: [
                if (widget.isSearching)
                  const SizedBox(
                    height: 100,
                    child: Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                else if (widget.places.isNotEmpty)
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
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, index) {
                            final place = widget.places[index];

                            return PlaceListTileWidget(
                              showSearchIcon: true,
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
                              color: Colors.grey.withOpacity(.1),
                              height: 1,
                              // indent: mainProvider.leftPadding,
                              thickness: 1,
                            );
                          },
                          itemCount: widget.places.length,
                        ),
                        Divider(
                          color: Colors.grey.withOpacity(.1),
                          height: 1,
                          // indent: mainProvider.leftPadding,
                          thickness: 1,
                        ),
                      ],
                    ),
                  )
                else if (userGlobalProvider.user?.recents?.isNotEmpty == true)
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
                            const Text(
                              'Recents',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ButtonWidget(
                              onTap: () async {
                                await showMaterialModalBottomSheet(
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
                                mainProvider.focusSearchField();
                              },
                              text: 'More',
                              color: AppColors.primaryBlue,
                              buttonType: ButtonTypeEnum.textButton,
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.withOpacity(.1),
                        height: 1,
                        indent: mainProvider.leftPadding,
                        thickness: 1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: mainProvider.leftPadding,
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
                              color: Colors.grey.withOpacity(.1),
                              height: 1,
                              // indent: mainProvider.leftPadding,
                              thickness: 1,
                            );
                          },
                          itemCount: userGlobalProvider.user!.recents!.length,
                        ),
                      ),
                      Divider(
                        color: Colors.grey.withOpacity(.1),
                        height: 1,
                        indent: mainProvider.leftPadding,
                        thickness: 1,
                      ),
                    ],
                  ),
                SizedBox(height: mainProvider.bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
