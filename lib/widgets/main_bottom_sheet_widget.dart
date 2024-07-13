import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/utils/utility.dart';
import 'package:commute_guide/widgets/account_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/default_main_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/move_point_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/persistent_header_widget.dart';
import 'package:commute_guide/widgets/search_form_field_widget.dart';
import 'package:commute_guide/widgets/searching_main_bottom_sheet_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MainBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const MainBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<MainBottomSheetWidget> createState() =>
      _MainBottomSheetWidgetState();
}

class _MainBottomSheetWidgetState extends ConsumerState<MainBottomSheetWidget> {
  late Timer timer;
  Timer? searchTimer;
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
      double temp = widget.scrollController.offset <= 0 ? 0 : 1;
      if (opacity != t || dividerOpacity != temp) {
        if (!mounted) return;
        setState(() {
          dividerOpacity = temp;
          opacity = t;
        });
      }
    });
  }

  double opacity = 0;
  double dividerOpacity = 0;
  bool isFetching = false;
  List<CommutePlace> places = [];

  @override
  void dispose() {
    timer.cancel();
    searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    ref.watch(globalProvider);
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
            color: mainProvider.isSearching
                ? Colors.white
                : Colors.white.withOpacity(.85),
            child: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: PersistentHeaderWidgetDelegate(
                    minHeight: 80,
                    maxHeight: 80,
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
                            padding: const EdgeInsets.symmetric(),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: mainProvider.leftPadding),
                                    Expanded(
                                      child: SearchFieldWidget(
                                        hintText: 'Search...',
                                        prefixIcon: const Icon(
                                          CupertinoIcons.search,
                                          color: Colors.grey,
                                        ),
                                        backgroundColor:
                                            Colors.grey.withOpacity(.1),
                                        controller:
                                            mainProvider.searchController,
                                        focusNode: mainProvider.searchFocusNode,
                                        suffixIcon: mainProvider.isSearching &&
                                                mainProvider.searchController
                                                    .text.isNotEmpty
                                            ? InkWell(
                                                onTap: () {
                                                  mainProvider.searchController
                                                      .clear();
                                                  if (searchTimer != null) {
                                                    Utility.clearTimeout(
                                                        searchTimer!);
                                                  }
                                                  setState(() {
                                                    isFetching = false;
                                                    places = [];
                                                  });
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .clear_thick_circled,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await showMaterialModalBottomSheet(
                                                    context: context,
                                                    isDismissible: false,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                    )),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (ctx) {
                                                      return MovePointBottomSheetWidget(
                                                        changeMainProvider: widget
                                                            .changeMainProvider,
                                                        scrollController:
                                                            ModalScrollController
                                                                .of(ctx)!,
                                                        currentLatLng:
                                                            mainProvider
                                                                .mapController
                                                                .camera
                                                                .center,
                                                        shouldShowRemovePin:
                                                            false,
                                                      );
                                                    },
                                                  );
                                                  if (result == null) {
                                                    return;
                                                  }

                                                  final newLatLng =
                                                      result as LatLng;
                                                  mainProvider
                                                      .unfocusSearchField();
                                                  mainProvider
                                                      .addPoint(newLatLng);
                                                },
                                                child: const Icon(
                                                  CupertinoIcons
                                                      .map_pin_ellipse,
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
                                              isFetching = false;
                                              places = [];
                                            });
                                            return;
                                          }

                                          setState(() {
                                            isFetching = true;
                                            places = [];
                                          });
                                          searchTimer =
                                              Utility.setTimeout(() async {
                                            if (!mounted) return;
                                            final places = await mainProvider
                                                .searchLocation(val);

                                            if (!mounted) return;
                                            setState(() {
                                              isFetching = false;
                                              this.places = places;
                                            });
                                          });
                                        },
                                        onFocus: () {
                                          mainProvider.focusSearchField();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    if (mainProvider.isSearching)
                                      ButtonWidget(
                                        onTap: () {
                                          if (searchTimer != null) {
                                            Utility.clearTimeout(searchTimer!);
                                          }
                                          mainProvider.unfocusSearchField();
                                          setState(() {
                                            places = [];
                                            isFetching = false;
                                          });
                                        },
                                        text: 'Cancel',
                                        buttonType: ButtonTypeEnum.textButton,
                                      )
                                    else
                                      InkWell(
                                        onTap: () async {
                                          final position = mainProvider
                                              .mainBottomSheetController.size;
                                          if (position >
                                              mainProvider.minPanelHeight) {
                                            mainProvider
                                                .mainBottomSheetController
                                                .animateTo(
                                              mainProvider.minPanelHeight,
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              curve: Curves.easeInOut,
                                            );
                                          }
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
                                              return AccountBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                              );
                                            },
                                          );
                                          if (position >
                                              mainProvider.minPanelHeight) {
                                            mainProvider
                                                .mainBottomSheetController
                                                .animateTo(
                                              position,
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                        child: const Icon(
                                          CupertinoIcons.person_crop_circle,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    SizedBox(width: mainProvider.rightPadding),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 11),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: mainProvider.isSearching
                                ? 1
                                : math.min(opacity, dividerOpacity),
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
                if (mainProvider.isSearching)
                  SearchingMainBottomSheetWidget(
                    changeMainProvider: widget.changeMainProvider,
                    isSearching: isFetching,
                    places: places,
                  )
                else
                  DefaultMainBottomSheetWidget(
                    changeMainProvider: widget.changeMainProvider,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
