import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:commute_guide/widgets/trip_list_tile_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduledBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const ScheduledBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<ScheduledBottomSheetWidget> createState() =>
      _ScheduledBottomSheetWidgetState();
}

class _ScheduledBottomSheetWidgetState
    extends ConsumerState<ScheduledBottomSheetWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    final userGlobalProvider = ref.read(globalProvider);
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday % 7;
    catsStartDate[0] = today.add(const Duration(days: 1));
    catsStartDate[1] = today.add(const Duration(days: 2));
    catsStartDate[2] = today.add(Duration(days: 6 - weekday));
    catsStartDate[3] = today.add(Duration(days: 7 + (6 - weekday)));

    final t = userGlobalProvider.user!.getCurrentScheduledTrips.toList();
    trips.add(t.where((e) => e.createdAt.isAfter(today)).toList());
    trips.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[0]) &&
            e.createdAt.isBefore(catsStartDate[1]))
        .toList());
    trips.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[1]) &&
            e.createdAt.isBefore(catsStartDate[2]))
        .toList());
    trips.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[1]) &&
            e.createdAt.isBefore(catsStartDate[3]))
        .toList());
    for (int i = 1; i < trips.length; i++) {
      for (int j = i - 1; j >= 0; j--) {
        trips[i].removeWhere((e) => trips[j].contains(e));
      }
    }
  }

  final cats = [
    'Today',
    'Tomorrow',
    'This Week',
    'Next Week',
  ];

  List<DateTime> catsStartDate = [
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
  ];

  void removeSchedules(int index) {
    final remove = [...trips[index]];
    trips[index] = [];
    setState(() {});
    final mainProvider = ref.read(widget.changeMainProvider);
    final userGlobalProvider = ref.read(globalProvider);
    final user = mainProvider.removeScheduleTrips(
      user: userGlobalProvider.user!,
      trips: remove,
    );
    userGlobalProvider.user = user;
  }

  List<List<CommuteTrip>> trips = [];
  double dividerOpacity = 0;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: mainProvider.leftPadding,
                                right: mainProvider.rightPadding,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Scheduled Trips',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: mainProvider.leftPadding,
                              right: mainProvider.rightPadding,
                            ),
                            child: ListView.separated(
                              itemBuilder: (ctx, index) {
                                final temp = trips[index];
                                if (temp.isEmpty) {
                                  return Container();
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cats[index],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        ButtonWidget(
                                          onTap: () {
                                            removeSchedules(index);
                                          },
                                          text: 'Clear',
                                          color: AppColors.primaryBlue,
                                          buttonType: ButtonTypeEnum.textButton,
                                        ),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (ctx, index1) {
                                          final trip = trips[index][index1];
                                          return TripListTileWidget(
                                            changeMainProvider:
                                                widget.changeMainProvider,
                                            trip: trip,
                                            onTap: () async {
                                              mainProvider
                                                  .setScheduledTripDirections(
                                                      trip);
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                        separatorBuilder: (ctx, index) {
                                          return Divider(
                                            color: Colors.grey.withOpacity(.05),
                                            height: 1,
                                            indent: 20,
                                            thickness: 1,
                                          );
                                        },
                                        itemCount: trips[index].length,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (ctx, index) {
                                return const SizedBox(height: 15);
                              },
                              itemCount: trips.length,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              primary: false,
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
