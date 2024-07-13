import 'package:commute_guide/enums/travel_mode_enum.dart';
import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TripListTileWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  final CommuteTrip trip;
  final Future<void> Function() onTap;
  const TripListTileWidget({
    super.key,
    required this.changeMainProvider,
    required this.trip,
    required this.onTap,
  });

  @override
  ConsumerState<TripListTileWidget> createState() => _TripListTileWidgetState();
}

class _TripListTileWidgetState extends ConsumerState<TripListTileWidget> {
  @override
  Widget build(BuildContext context) {
    ref.watch(widget.changeMainProvider);
    return InkWell(
      splashColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
      highlightColor: Colors.white,
      onTap: () async {
        await widget.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 15,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(5),
              child: Icon(
                widget.trip.travelModeEnum == TravelModeEnum.driving
                    ? CupertinoIcons.car_detailed
                    : widget.trip.travelModeEnum == TravelModeEnum.bicycling
                        ? Icons.directions_bike_sharp
                        : Icons.directions_walk_outlined,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('hh:mm a, M/d/y')
                          .format(widget.trip.scheduledAt),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.trip.places.first.address,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(CupertinoIcons.arrow_right, size: 10),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            widget.trip.places.last.address,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
