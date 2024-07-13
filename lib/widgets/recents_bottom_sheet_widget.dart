import 'dart:async';
import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class RecentsBottomSheetWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final ScrollController scrollController;
  const RecentsBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
  });

  @override
  ConsumerState<RecentsBottomSheetWidget> createState() =>
      _RecentsBottomSheetWidgetState();
}

class _RecentsBottomSheetWidgetState
    extends ConsumerState<RecentsBottomSheetWidget> {
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
    catsStartDate[0] = today;
    catsStartDate[1] = today.subtract(Duration(days: weekday));
    catsStartDate[2] = DateTime(today.year, today.month);
    catsStartDate[3] = DateTime(today.year);
    catsStartDate[4] = DateTime(2023);

    final t = userGlobalProvider.user!.recents!.reversed.toList();
    recents.add(t.where((e) => e.createdAt.isAfter(today)).toList());
    recents.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[1]) &&
            e.createdAt.isBefore(catsStartDate[0]))
        .toList());
    recents.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[2]) &&
            e.createdAt.isBefore(catsStartDate[1]))
        .toList());
    recents.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[3]) &&
            e.createdAt.isBefore(catsStartDate[2]))
        .toList());
    recents.add(t
        .where((e) =>
            e.createdAt.isAfter(catsStartDate[4]) &&
            e.createdAt.isBefore(catsStartDate[3]))
        .toList());
    for (int i = 1; i < recents.length; i++) {
      for (int j = i - 1; j >= 0; j--) {
        recents[i].removeWhere((e) => recents[j].contains(e));
      }
    }
  }

  final cats = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Older',
  ];

  List<DateTime> catsStartDate = [
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
    DateTime.now(),
  ];

  void removeRecents(int index) {
    final remove = [...recents[index]];
    recents[index] = [];
    setState(() {});
    final mainProvider = ref.read(widget.changeMainProvider);
    final userGlobalProvider = ref.read(globalProvider);
    final user = mainProvider.removeRecents(
      user: userGlobalProvider.user!,
      places: remove,
    );
    userGlobalProvider.user = user;
  }

  List<List<CommutePlace>> recents = [];
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
                                          'Recents',
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
                                final temp = recents[index];
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
                                            removeRecents(index);
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
                                      child: ListView.separated(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (ctx, index1) {
                                          final recent = recents[index][index1];
                                          return InkWell(
                                            splashColor: Colors.white,
                                            focusColor: Colors.white,
                                            hoverColor: Colors.white,
                                            highlightColor: Colors.white,
                                            onTap: () {
                                              mainProvider.addPoint(
                                                LatLng(recent.lat, recent.lng),
                                                recent,
                                              );
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.blueGrey,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: const Icon(
                                                      CupertinoIcons.map_pin,
                                                      color: Colors.white,
                                                      size: 17,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          recent.address
                                                              .substring(
                                                            0,
                                                            recent.address
                                                                .indexOf(','),
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          recent.address
                                                              .substring(
                                                            recent.address
                                                                    .indexOf(
                                                                        ',') +
                                                                2,
                                                          ),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.left,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                        itemCount: recents[index].length,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (ctx, index) {
                                return const SizedBox(height: 15);
                              },
                              itemCount: recents.length,
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
