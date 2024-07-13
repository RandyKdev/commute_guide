import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/material.dart';

enum ButtonTypeEnum {
  filledPrimary,
  filledSecondary,
  textButton,
  ;

  BorderSide get getBorderSide {
    if (this == ButtonTypeEnum.filledSecondary) {
      return BorderSide(
        width: 0.70,
        color: Colors.white.withOpacity(0.1),
      );
    }
    return const BorderSide(
      color: AppColors.transparent,
    );
  }

  Color get getColor {
    switch (this) {
      case ButtonTypeEnum.filledPrimary:
        return AppColors.primaryBlue;
      case ButtonTypeEnum.filledSecondary:
        return AppColors.secondaryButtonBGColor;
      case ButtonTypeEnum.textButton:
        return AppColors.transparent;
    }
  }
}
