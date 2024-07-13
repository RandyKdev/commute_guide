import 'package:commute_guide/constants/direction.dart';
import 'package:commute_guide/models/commute_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectionWaypointLocationWidget extends ConsumerStatefulWidget {
  final CommutePlace? place;
  final List<CommutePlace?> directionPlaces;
  const DirectionWaypointLocationWidget({
    super.key,
    required this.directionPlaces,
    required this.place,
  });

  @override
  ConsumerState<DirectionWaypointLocationWidget> createState() =>
      _DirectionWaypointLocationWidgetState();
}

class _DirectionWaypointLocationWidgetState
    extends ConsumerState<DirectionWaypointLocationWidget> {
  double width = 20;

  @override
  void initState() {
    super.initState();
    index = widget.directionPlaces.indexOf(widget.place);
  }

  late int index;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = index == widget.directionPlaces.length - 1;
    return Material(
      elevation: 1,
      shape: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.only(),
        child: Container(
          decoration: BoxDecoration(
            color: isLast ? Colors.white : Colors.black,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLast ? Colors.red : Colors.white,
              ),
              width: width - (isLast ? 10 : 0),
              child: isLast
                  ? null
                  : Center(
                      child: Text(
                        directionLetters[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              // height: 3,
            ),
          ),
        ),
      ),
    );
  }
}
