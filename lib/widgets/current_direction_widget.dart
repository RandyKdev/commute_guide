import 'dart:async';

import 'package:commute_guide/providers/main_provider.dart';
import 'package:commute_guide/widgets/current_direction_paint_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class CurrentDirectionWidget extends ConsumerStatefulWidget {
  final ChangeNotifierProvider<MainProvider> changeMainProvider;
  const CurrentDirectionWidget({super.key, required this.changeMainProvider});

  @override
  ConsumerState<CurrentDirectionWidget> createState() =>
      _CurrentDirectionWidgetState();
}

class _CurrentDirectionWidgetState
    extends ConsumerState<CurrentDirectionWidget> {
  double width = 10;
  late Timer timer;
  double? compassHeading;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(milliseconds: 17),
      (_) {
        WidgetsBinding.instance.addPostFrameCallback((t) {
          if (!mounted) return;
          final mainProvider = ref.read(widget.changeMainProvider);
          if (compassHeading == mainProvider.compassHeading) return;
          setState(() {
            compassHeading = mainProvider.compassHeading;
          });
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
    return Transform.rotate(
      angle: mainProvider.browseModeEnum == BrowseModeEnum.pan
          ? 0
          : ((compassHeading ?? 0) * (math.pi / 180)),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(bottom: 30),
        child: CustomPaint(
          painter: CurrentDirectionPaintWidget(
            angle: 35,
            length: 70,
            percentageStart: 20,
          ),
        ),
      ),
    );
  }
}
