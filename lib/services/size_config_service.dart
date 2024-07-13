import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sizeConfigService = Provider((ref) => SizeConfigService());

class SizeConfigService {
  MediaQueryData? mediaQueryData;
  BuildContext? context;

  double? _screenWidth;
  double? _screenHeight;

  void init(BuildContext context) {
    this.context = context;
    mediaQueryData = MediaQuery.of(context);
    _screenWidth = mediaQueryData!.size.width;
    _screenHeight = mediaQueryData!.size.height;
  }

  double heightOfAppBar = 70;

  double get screenHeight => _screenHeight!;

  double get screenWidth => _screenWidth!;
}
