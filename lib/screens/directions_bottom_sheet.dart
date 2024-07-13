import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/directions_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectionsBottomSheet extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const DirectionsBottomSheet({super.key, required this.changeMainProvider});

  @override
  ConsumerState<DirectionsBottomSheet> createState() =>
      _DirectionsBottomSheetState();
}

class _DirectionsBottomSheetState extends ConsumerState<DirectionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return DraggableScrollableSheet(
        controller: mainProvider.directionsBottomSheetController,
        initialChildSize: mainProvider.midPanelHeight,
        minChildSize: mainProvider.minPanelHeight,
        maxChildSize: mainProvider.maxPanelHeight,
        shouldCloseOnMinExtent: false,
        snapSizes: [
          mainProvider.midPanelHeight,
        ],
        snap: true,
        builder: (ctx, controller) {
          return DirectionsBottomSheetWidget(
            changeMainProvider: widget.changeMainProvider,
            scrollController: controller,
          );
        });
  }
}
