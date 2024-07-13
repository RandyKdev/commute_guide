import 'dart:ui';

import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/material.dart';

class ModalPopupBlueprintWidget extends StatelessWidget {
  final Widget child;
  const ModalPopupBlueprintWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
        child: Container(
          decoration: ShapeDecoration(
            color: AppColors.secondaryButtonBGColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.70,
                color: Colors.white.withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
