import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/avoid_enum.dart';
import 'package:commute_guide/enums/place_type_enum.dart';
import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/extensions/string_ext.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/utils/distance.dart';
import 'package:commute_guide/widgets/add_stop_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/avoid_bottom_sheet_widget.dart';
import 'package:commute_guide/widgets/persistent_header_widget.dart';
import 'package:commute_guide/widgets/snackbar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:math' as math;

import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class DirectionsBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const DirectionsBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<DirectionsBottomSheetWidget> createState() =>
      _DirectionsBottomSheetWidgetState();
}

class _DirectionsBottomSheetWidgetState
    extends ConsumerState<DirectionsBottomSheetWidget> {
  //   with AutomaticKeepAliveClientMixin<DirectionsBottomSheetWidget> {
  // @override
  // bool get wantKeepAlive => !disposed;

  late Timer timer;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    final mainProvider = ref.read(widget.changeMainProvider);
    timer = Timer.periodic(const Duration(milliseconds: 17), (_) {
      final controller = mainProvider.directionsBottomSheetController;
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
    if (ref.read(widget.changeMainProvider).defaultDirections) {
      ref.read(widget.changeMainProvider).travelMode =
          ref.read(globalProvider).user?.preferredTravelMode ??
              TravelModeEnum.driving;
      switch (ref.read(widget.changeMainProvider).travelMode) {
        case TravelModeEnum.driving:
          ref.read(widget.changeMainProvider).directionAvoidance =
              ref.read(globalProvider).user?.drivingPreferences ?? [];
          break;
        case TravelModeEnum.bicycling:
          ref.read(widget.changeMainProvider).directionAvoidance =
              ref.read(globalProvider).user?.cyclingPreferences ?? [];
          break;
        case TravelModeEnum.walking:
          ref.read(widget.changeMainProvider).directionAvoidance =
              ref.read(globalProvider).user?.walkingPreferences ?? [];
          break;
      }
    }
  }

  double opacity = 1;
  double dividerOpacity = 0;
  MainProvider? mainProvider1;
  bool isGettingDirections = false;
  bool isStartingTrip = false;
  bool isSchedulingTrip = false;

  MainProvider get mainProvider => mainProvider1!;

  String getScheduleTimeString() {
    final mainProvider = ref.read(widget.changeMainProvider);
    return 'Leave ${DateFormat('d/M, hh:mm a').format(
      mainProvider.scheduledDate!,
    )}';
  }

  @override
  void dispose() {
    timer.cancel();
    if (disposed) {
      mainProvider.resetDirections();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mainProvider1 = ref.watch(widget.changeMainProvider);
    final userGlobalProvider = ref.watch(globalProvider);
    final favorites = userGlobalProvider.user?.favorites ?? [];

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
                    minHeight: mainProvider.trip == null ? 70 : 72,
                    maxHeight: mainProvider.trip == null ? 70 : 72,
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
                                    if (mainProvider.trip == null)
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Directions',
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Directions',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                height: 1,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${DistanceUtility.getDistance(mainProvider.trip!.distance)}, ${DistanceUtility.getDuration(mainProvider.trip!.duration.toInt())}',
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
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        disposed = true;
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
                          SizedBox(height: mainProvider.trip == null ? 13 : 11),
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
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      mainProvider.setTravelMode(
                                        TravelModeEnum.driving,
                                      );
                                      mainProvider.setDirectionAvoidance(
                                        userGlobalProvider
                                                .user?.drivingPreferences ??
                                            [],
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: mainProvider.travelMode ==
                                                TravelModeEnum.driving
                                            ? AppColors.primaryBlue
                                            : Colors.grey.withOpacity(.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            CupertinoIcons.car_detailed,
                                            color: mainProvider.travelMode ==
                                                    TravelModeEnum.driving
                                                ? AppColors.white
                                                : AppColors.grey,
                                            size: 20,
                                          ),
                                          Text(
                                            'Driving',
                                            style: TextStyle(
                                              color: mainProvider.travelMode ==
                                                      TravelModeEnum.driving
                                                  ? AppColors.white
                                                  : AppColors.grey,
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
                                  child: GestureDetector(
                                    onTap: () {
                                      mainProvider.setTravelMode(
                                        TravelModeEnum.bicycling,
                                      );
                                      mainProvider.setDirectionAvoidance(
                                        userGlobalProvider
                                                .user?.cyclingPreferences ??
                                            [],
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: mainProvider.travelMode ==
                                                TravelModeEnum.bicycling
                                            ? AppColors.primaryBlue
                                            : Colors.grey.withOpacity(.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.directions_bike_rounded,
                                            color: mainProvider.travelMode ==
                                                    TravelModeEnum.bicycling
                                                ? AppColors.white
                                                : AppColors.grey,
                                            size: 20,
                                          ),
                                          Text(
                                            'Cycling',
                                            style: TextStyle(
                                              color: mainProvider.travelMode ==
                                                      TravelModeEnum.bicycling
                                                  ? AppColors.white
                                                  : AppColors.grey,
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
                                  child: GestureDetector(
                                    onTap: () {
                                      mainProvider.setTravelMode(
                                        TravelModeEnum.walking,
                                      );
                                      mainProvider.setDirectionAvoidance(
                                        userGlobalProvider
                                                .user?.walkingPreferences ??
                                            [],
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: mainProvider.travelMode ==
                                                TravelModeEnum.walking
                                            ? AppColors.primaryBlue
                                            : Colors.grey.withOpacity(.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.directions_walk_rounded,
                                            color: mainProvider.travelMode ==
                                                    TravelModeEnum.walking
                                                ? AppColors.white
                                                : AppColors.grey,
                                            size: 20,
                                          ),
                                          Text(
                                            'Walking',
                                            style: TextStyle(
                                              color: mainProvider.travelMode ==
                                                      TravelModeEnum.walking
                                                  ? AppColors.white
                                                  : AppColors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height:
                                (((mainProvider.directionPlaces.length + 1) /
                                            3) *
                                        126) -
                                    (mainProvider.directionPlaces.length > 24
                                        ? 42
                                        : 0),
                            child: Stack(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 17),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 32),
                                        ...mainProvider.directionPlaces
                                            .map((e) {
                                          if (mainProvider
                                                      .directionPlaces.length >
                                                  24 &&
                                              mainProvider
                                                      .directionPlaces.last ==
                                                  e) {
                                            return const SizedBox.shrink();
                                          }
                                          return Column(
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .ellipsis_vertical,
                                                size: 17,
                                                color:
                                                    Colors.grey.withOpacity(.5),
                                              ),
                                              const SizedBox(height: 25),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ReorderableListView(
                                      buildDefaultDragHandles: false,
                                      shrinkWrap: true,
                                      clipBehavior: Clip.hardEdge,
                                      primary: false,
                                      onReorder: (oldIndex, newIndex) {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final places =
                                            mainProvider.directionPlaces;
                                        final place = places[oldIndex];

                                        places.removeAt(oldIndex);
                                        places.insert(newIndex, place);
                                        mainProvider.setDirectionPlaces(
                                          places,
                                        );
                                        setState(() {});
                                      },
                                      children: mainProvider.directionPlaces
                                          .map((place) {
                                        return Column(
                                          key: ValueKey(place),
                                          children: [
                                            ReorderableDragStartListener(
                                              index: mainProvider
                                                  .directionPlaces
                                                  .indexOf(place),
                                              enabled: true,
                                              child: PullDownButton(
                                                itemBuilder: (context) => [
                                                  PullDownMenuItem(
                                                    onTap: () {
                                                      mainProvider
                                                          .setDirectionPlaces([
                                                        ...mainProvider
                                                            .directionPlaces
                                                      ]..remove(place));
                                                    },
                                                    title: 'Delete',
                                                    isDestructive: false,
                                                    icon: CupertinoIcons.delete,
                                                  ),
                                                ],
                                                buttonBuilder:
                                                    (context, showMenu) =>
                                                        GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                        await showMaterialModalBottomSheet(
                                                      context: context,
                                                      isDismissible: true,
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
                                                        return AddStopBottomSheetWidget(
                                                          changeMainProvider: widget
                                                              .changeMainProvider,
                                                          scrollController:
                                                              ModalScrollController
                                                                  .of(ctx)!,
                                                          isChange: true,
                                                        );
                                                      },
                                                    );
                                                    if (result
                                                        is CommutePlace) {
                                                      final isAlreadyAdded =
                                                          mainProvider
                                                              .directionPlaces
                                                              .any(
                                                        (e) =>
                                                            e?.placeId ==
                                                            result.placeId,
                                                      );
                                                      if (!isAlreadyAdded) {
                                                        final index =
                                                            mainProvider
                                                                .directionPlaces
                                                                .indexOf(place);
                                                        mainProvider
                                                            .setDirectionPlaces(
                                                          mainProvider
                                                              .directionPlaces
                                                            ..remove(place)
                                                            ..insert(
                                                                index, result),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  onLongPress: () {
                                                    if (mainProvider
                                                            .directionPlaces
                                                            .length <
                                                        3) {
                                                      return;
                                                    }
                                                    showMenu();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 15,
                                                      vertical: 10,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: place ==
                                                                        null ||
                                                                    favorites.any((e) =>
                                                                        e.placeId ==
                                                                        place
                                                                            .placeId)
                                                                ? AppColors
                                                                    .primaryBlue
                                                                : AppColors.red,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(3),
                                                          child: Icon(
                                                            place == null
                                                                ? CupertinoIcons
                                                                    .location_fill
                                                                : place.placeType ==
                                                                        PlaceTypeEnum
                                                                            .home
                                                                    ? CupertinoIcons
                                                                        .house_fill
                                                                    : place.placeType ==
                                                                            PlaceTypeEnum
                                                                                .work
                                                                        ? CupertinoIcons
                                                                            .briefcase_fill
                                                                        : favorites.any((e) =>
                                                                                e.placeId ==
                                                                                place.placeId)
                                                                            ? CupertinoIcons.star_fill
                                                                            : CupertinoIcons.map_pin,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            place == null
                                                                ? 'My Location'
                                                                : place.placeType ==
                                                                        PlaceTypeEnum
                                                                            .home
                                                                    ? 'Home Location'
                                                                    : place.placeType ==
                                                                            PlaceTypeEnum
                                                                                .work
                                                                        ? 'Work Location'
                                                                        : place
                                                                            .address,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Icon(
                                                          CupertinoIcons
                                                              .line_horizontal_3,
                                                          size: 20,
                                                          color: Colors.grey
                                                              .withOpacity(.2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (mainProvider.directionPlaces
                                                        .length >
                                                    24 &&
                                                mainProvider
                                                        .directionPlaces.last ==
                                                    place)
                                              Container()
                                            else
                                              Divider(
                                                thickness: 1,
                                                height: 1,
                                                color:
                                                    Colors.grey.withOpacity(.1),
                                                indent: 47,
                                              ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                    if (mainProvider.directionPlaces.length <
                                        25)
                                      GestureDetector(
                                        onTap: () async {
                                          final result =
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
                                              return AddStopBottomSheetWidget(
                                                changeMainProvider:
                                                    widget.changeMainProvider,
                                                scrollController:
                                                    ModalScrollController.of(
                                                        ctx)!,
                                                isChange: false,
                                              );
                                            },
                                          );
                                          if (result is CommutePlace) {
                                            final isAlreadyAdded = mainProvider
                                                .directionPlaces
                                                .any(
                                              (e) =>
                                                  e?.placeId == result.placeId,
                                            );
                                            if (!isAlreadyAdded) {
                                              mainProvider.setDirectionPlaces(
                                                mainProvider.directionPlaces
                                                  ..add(result),
                                              );
                                            }
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primaryBlue,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: const Icon(
                                                  CupertinoIcons.add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              const Expanded(
                                                child: Text(
                                                  'Add Stop',
                                                  style: TextStyle(
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(width: mainProvider.leftPadding),
                                GestureDetector(
                                  onTap: () {
                                    final now = DateTime.now();
                                    picker.DatePicker.showDateTimePicker(
                                      context,
                                      showTitleActions: true,
                                      minTime: now,
                                      maxTime: now.add(
                                        const Duration(days: 14),
                                      ),
                                      onChanged: (date) {
                                        // print(
                                        //     'change $date in time zone ${date.timeZoneOffset.inHours}');
                                      },
                                      onConfirm: (date) {
                                        // print('confirm $date');
                                        final diffNow = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          now.hour,
                                          now.minute,
                                        );
                                        final diff = date.difference(diffNow);

                                        mainProvider.setScheduledDate(
                                          diff.inMinutes < 1 ? null : date,
                                        );
                                      },
                                      currentTime:
                                          mainProvider.scheduledDate ?? now,
                                      locale: picker.LocaleType.en,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: mainProvider.scheduledDate == null
                                          ? Border.all(
                                              width: 1,
                                              color:
                                                  Colors.grey.withOpacity(.2),
                                            )
                                          : null,
                                      color: mainProvider.scheduledDate == null
                                          ? null
                                          : AppColors.primaryBlue,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          mainProvider.scheduledDate == null
                                              ? 'Now'
                                              : getScheduleTimeString(),
                                          style: TextStyle(
                                            color: mainProvider.scheduledDate ==
                                                    null
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 1),
                                          child: Icon(
                                            CupertinoIcons.chevron_down,
                                            size: 15,
                                            color: mainProvider.scheduledDate ==
                                                    null
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    final avoid =
                                        await showMaterialModalBottomSheet(
                                      context: context,
                                      isDismissible: false,
                                      enableDrag: false,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      )),
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) {
                                        return AvoidBottomSheetWidget(
                                          changeMainProvider:
                                              widget.changeMainProvider,
                                          scrollController:
                                              ModalScrollController.of(ctx)!,
                                          avoidances:
                                              mainProvider.directionAvoidance,
                                        );
                                      },
                                    );

                                    if (avoid is List) {
                                      mainProvider.setDirectionAvoidance(
                                        avoid.cast<AvoidEnum>(),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: mainProvider
                                              .directionAvoidance.isEmpty
                                          ? Border.all(
                                              width: 1,
                                              color:
                                                  Colors.grey.withOpacity(.2),
                                            )
                                          : null,
                                      color: mainProvider
                                              .directionAvoidance.isEmpty
                                          ? null
                                          : AppColors.primaryBlue,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          mainProvider
                                                  .directionAvoidance.isEmpty
                                              ? 'Avoid'
                                              : mainProvider.directionAvoidance
                                                          .length ==
                                                      1
                                                  ? 'Avoid ${mainProvider.directionAvoidance.first.name.getUncloggedWords.getWordsCapitalized}'
                                                  : 'Avoid ${mainProvider.directionAvoidance.length}',
                                          style: TextStyle(
                                            color: mainProvider
                                                    .directionAvoidance.isEmpty
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 1),
                                          child: Icon(
                                            CupertinoIcons.chevron_down,
                                            size: 15,
                                            color: mainProvider
                                                    .directionAvoidance.isEmpty
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: mainProvider.rightPadding),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          if (!(mainProvider.trip?.points.isNotEmpty == true))
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isGettingDirections = true;
                                });
                                await mainProvider.getDirectionPolylines();
                                setState(() {
                                  isGettingDirections = false;
                                });
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
                                child: isGettingDirections
                                    ? const Center(
                                        child: CupertinoActivityIndicator(),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 15),
                                          Icon(
                                            CupertinoIcons
                                                .arrow_up_right_diamond,
                                            color: AppColors.primaryBlue,
                                          ),
                                          Spacer(),
                                          Text(
                                            'Directions',
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(width: 40),
                                        ],
                                      ),
                              ),
                            ),
                          if (mainProvider.scheduledDate != null &&
                              !(userGlobalProvider.user!.scheduledTrips ?? [])
                                  .any((e) =>
                                      e.id == mainProvider.trip?.id)) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  isSchedulingTrip = true;
                                });

                                final user = userGlobalProvider.user;
                                final newUser = await mainProvider
                                    .addTripToSchedules(user!);
                                userGlobalProvider.user = newUser;
                                setState(() {
                                  isSchedulingTrip = false;
                                });

                                CommuteSnackBarSuccessful(
                                  title: 'Your trip has been scheduled',
                                  context: context,
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
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: isSchedulingTrip
                                    ? const Center(
                                        child: CupertinoActivityIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 15),
                                          Icon(
                                            CupertinoIcons.timer,
                                            color: AppColors.white,
                                          ),
                                          Spacer(),
                                          Text(
                                            'Schedule',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Spacer(),
                                          SizedBox(width: 40),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isStartingTrip = true;
                              });
                              await mainProvider
                                  .startTrip(widget.changeMainProvider);

                              setState(() {
                                isStartingTrip = false;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: mainProvider.leftPadding,
                                right: mainProvider.rightPadding,
                              ),
                              width: double.maxFinite,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: isStartingTrip
                                  ? const Center(
                                      child: CupertinoActivityIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 15),
                                        Icon(
                                          CupertinoIcons.location_north_fill,
                                          color: AppColors.white,
                                        ),
                                        Spacer(),
                                        Text(
                                          'Start',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(width: 40),
                                      ],
                                    ),
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
