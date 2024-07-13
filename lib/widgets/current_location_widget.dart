import 'dart:async';

import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentLocationWidget extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  const CurrentLocationWidget({
    super.key,
    this.onTap,
  });

  @override
  ConsumerState<CurrentLocationWidget> createState() =>
      _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends ConsumerState<CurrentLocationWidget> {
  double width = 10;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        width = width == 10 ? 20 : 10;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(
        elevation: 5,
        shape: const CircleBorder(),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 4),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                  ),
                  width: width,
                  // height: 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
