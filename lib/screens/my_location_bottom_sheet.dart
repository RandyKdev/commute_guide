import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/my_location_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyLocationBottomSheet extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const MyLocationBottomSheet({super.key, required this.changeMainProvider});

  @override
  ConsumerState<MyLocationBottomSheet> createState() =>
      _MyLocationBottomSheetState();
}

class _MyLocationBottomSheetState extends ConsumerState<MyLocationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    return DraggableScrollableSheet(
        controller: mainProvider.myLocationBottomSheetController,
        initialChildSize: mainProvider.midPanelHeight,
        minChildSize: mainProvider.minPanelHeight,
        maxChildSize: mainProvider.maxPanelHeight,
        shouldCloseOnMinExtent: false,
        snapSizes: [
          mainProvider.midPanelHeight,
        ],
        snap: true,
        builder: (ctx, controller) {
          return MyLocationBottomSheetWidget(
            changeMainProvider: widget.changeMainProvider,
            scrollController: controller,
          );
        });
  }
}
