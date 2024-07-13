import 'dart:ui';

import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/global_provider.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/services/navigation_service.dart';
import 'package:commute_guide/utils/distance.dart';
import 'package:commute_guide/widgets/persistent_header_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackBottomSheetWidget extends ConsumerStatefulWidget {
  final MainProvider changeMainProvider;
  final ScrollController scrollController;
  final DraggableScrollableController controller;
  final CommuteTrip trip;
  const TrackBottomSheetWidget({
    super.key,
    required this.changeMainProvider,
    required this.scrollController,
    required this.controller,
    required this.trip,
  });

  @override
  ConsumerState<TrackBottomSheetWidget> createState() =>
      _TrackBottomSheetWidgetState();
}

class _TrackBottomSheetWidgetState
    extends ConsumerState<TrackBottomSheetWidget> {

  @override
  Widget build(BuildContext context) {
     ref.watch(globalProvider);
    final mainProvider = widget.changeMainProvider;
    final trip = widget.trip;
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
                      color: const Color.fromARGB(255, 255, 255, 255),
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
                                          const Text(
                                            'Tracking Details',
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
                                            '${DistanceUtility.getDistance(trip.distanceLeft)} left',
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 11),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: 1,
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
                    opacity: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: mainProvider.leftPadding,
                        right: mainProvider.rightPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                        'Distance',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Distance Covered: ${DistanceUtility.getDistance(trip.distanceCovered)}\nDistance Left: ${DistanceUtility.getDistance(trip.distanceLeft)}',
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
                                        'Duration',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Time Spent: ${DistanceUtility.getDuration(trip.durationCovered)}\nTime Left: ${DistanceUtility.getDuration(trip.durationLeft)}',
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
                                        'Speed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Speed: ${(trip.speed * 3.6).toStringAsFixed(2)} km/h',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (trip.currentPosition != null) ...[
                                  Divider(
                                    thickness: 1,
                                    height: 1,
                                    color: Colors.grey.withOpacity(.05),
                                    indent: 15,
                                  ),
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
                                          'Current Location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Latitude: ${trip.currentPosition!.latitude}\nLongitude: ${trip.currentPosition!.longitude}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ref.read(navigationService).pop();
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
                                            color: Colors.grey.withOpacity(.05),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          child: const Icon(
                                            CupertinoIcons.delete_solid,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Expanded(
                                          child: Text(
                                            'Stop Tracking',
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
