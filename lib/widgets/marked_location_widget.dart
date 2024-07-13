import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarkedLocationWidget extends ConsumerStatefulWidget {
  const MarkedLocationWidget({super.key});

  @override
  ConsumerState<MarkedLocationWidget> createState() =>
      _MarkedLocationWidgetState();
}

class _MarkedLocationWidgetState extends ConsumerState<MarkedLocationWidget> {
  double width = 30;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      width = 40;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 30,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.bounceIn,
              height: 40,
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: width,
              ),
            ),
            const SizedBox(height: 5),
            Material(
              elevation: 5,
              shape: const CircleBorder(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                width: 5,
                height: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
