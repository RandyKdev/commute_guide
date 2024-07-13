import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/marked_point_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkedPointBottomSheet extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const MarkedPointBottomSheet({super.key, required this.changeMainProvider});

  @override
  ConsumerState<MarkedPointBottomSheet> createState() =>
      _MarkedPointBottomSheetState();
}

class _MarkedPointBottomSheetState
    extends ConsumerState<MarkedPointBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return DraggableScrollableSheet(
        controller: mainProvider.markedPointBottomSheetController,
        initialChildSize: mainProvider.midPanelHeight,
        minChildSize: mainProvider.minPanelHeight,
        maxChildSize: mainProvider.maxPanelHeight,
        shouldCloseOnMinExtent: false,
        snapSizes: [
          mainProvider.midPanelHeight,
        ],
        snap: true,
        builder: (ctx, controller) {
          return MarkedPointBottomSheetWidget(
            changeMainProvider: widget.changeMainProvider,
            scrollController: controller,
          );
        });
  }
}
