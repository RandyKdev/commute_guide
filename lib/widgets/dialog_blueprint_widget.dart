import 'package:commute_guide/widgets/blur_widget.dart';
import 'package:flutter/material.dart';

class DialogBlueprintWidget extends StatelessWidget {
  final Widget child;
  const DialogBlueprintWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: BlurWidget(child: child),
    );
  }
}
