import 'package:commute_guide/models/commute_trip.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/track_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackBottomSheet extends ConsumerStatefulWidget {
  final MainProvider changeMainProvider;
  final DraggableScrollableController controller;
  final CommuteTrip trip;
  const TrackBottomSheet({
    super.key,
    required this.changeMainProvider,
    required this.controller,
    required this.trip,
  });

  @override
  ConsumerState<TrackBottomSheet> createState() => _TrackBottomSheetState();
}

class _TrackBottomSheetState extends ConsumerState<TrackBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mainProvider = widget.changeMainProvider;
    return DraggableScrollableSheet(
        initialChildSize: mainProvider.midPanelHeight,
        minChildSize: mainProvider.midPanelHeight,
        maxChildSize: mainProvider.maxPanelHeight,
        shouldCloseOnMinExtent: false,
        snap: true,
        builder: (ctx, controller) {
          return TrackBottomSheetWidget(
            changeMainProvider: widget.changeMainProvider,
            scrollController: controller,
            controller: widget.controller,
            trip: widget.trip,
          );
        });
  }
}
