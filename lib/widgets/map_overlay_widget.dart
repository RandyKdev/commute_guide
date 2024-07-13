import 'dart:async';

import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapOverlayWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const MapOverlayWidget({super.key, required this.changeMainProvider});

  @override
  ConsumerState<MapOverlayWidget> createState() => _MapOverlayWidgetState();
}

class _MapOverlayWidgetState extends ConsumerState<MapOverlayWidget> {
  late Timer timer;
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(milliseconds: 17),
      (_) {
        WidgetsBinding.instance.addPostFrameCallback((t) {
          if (!mounted) return;
          setState(() {});
        });
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainProvider = ref.watch(widget.changeMainProvider);
    if (mainProvider.overlayMapOpacity > 0) {
      return Align(
        alignment: Alignment.center,
        child: Opacity(
          opacity: mainProvider.overlayMapOpacity * 0.5,
          child: AbsorbPointer(
            // absorbing: mainProvider.overlayMapOpacity > 0,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: AppColors.black.withOpacity(.2),
            ),
          ),
        ),
      );
    }
    return Container();
  }
}
