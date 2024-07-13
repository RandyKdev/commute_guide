import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/main_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainBottomSheet extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const MainBottomSheet({super.key, required this.changeMainProvider});

  @override
  ConsumerState<MainBottomSheet> createState() => _MainBottomSheetState();
}

class _MainBottomSheetState extends ConsumerState<MainBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return DraggableScrollableSheet(
        controller: mainProvider.mainBottomSheetController,
        initialChildSize: mainProvider.minPanelHeight,
        minChildSize: mainProvider.minPanelHeight,
        maxChildSize: mainProvider.maxPanelHeight,
        shouldCloseOnMinExtent: false,
        snapSizes: [
          mainProvider.midPanelHeight,
        ],
        snap: true,
        builder: (ctx, controller) {
          return MainBottomSheetWidget(
            changeMainProvider: widget.changeMainProvider,
            scrollController: controller,
          );
        });
  }
}
