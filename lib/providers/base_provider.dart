import 'dart:math';

import 'package:commute_guide/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';

class BaseProvider extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;
  set disposed(bool value) => _disposed = value;

  final NavigationService _navigationService;

  BaseProvider({
    required NavigationService navigationService,
  }) : _navigationService = navigationService;

  EdgeInsets get padding {
    return EdgeInsets.only(
      top: topPadding,
      bottom: bottomPadding,
      left: leftPadding,
      right: rightPadding,
    );
  }

  double get screenHeight {
    return MediaQuery.sizeOf(_navigationService.currentContext).height;
  }

  double get screenWidth {
    return MediaQuery.sizeOf(_navigationService.currentContext).width;
  }

  double get leftPadding {
    return max(
      15,
      max(
        MediaQuery.viewInsetsOf(_navigationService.currentContext).left,
        MediaQuery.viewPaddingOf(_navigationService.currentContext).left,
      ),
    );
  }

  double get rightPadding {
    return max(
      15,
      max(
        MediaQuery.viewInsetsOf(_navigationService.currentContext).right,
        MediaQuery.viewPaddingOf(_navigationService.currentContext).right,
      ),
    );
  }

  double get topPadding {
    return max(
      25,
      max(
        MediaQuery.viewInsetsOf(_navigationService.currentContext).top,
        MediaQuery.viewPaddingOf(_navigationService.currentContext).top,
      ),
    );
  }

  double get bottomPadding {
    return max(
      25,
      max(
        MediaQuery.viewInsetsOf(_navigationService.currentContext).bottom,
        MediaQuery.viewPaddingOf(_navigationService.currentContext).bottom,
      ),
    );
  }

  double get leftOnlyPadding {
    return max(
      MediaQuery.viewInsetsOf(_navigationService.currentContext).left,
      MediaQuery.viewPaddingOf(_navigationService.currentContext).left,
    );
  }

  double get rightOnlyPadding {
    return max(
      MediaQuery.viewInsetsOf(_navigationService.currentContext).right,
      MediaQuery.viewPaddingOf(_navigationService.currentContext).right,
    );
  }

  double get topOnlyPadding {
    return max(
      MediaQuery.viewInsetsOf(_navigationService.currentContext).top,
      MediaQuery.viewPaddingOf(_navigationService.currentContext).top,
    );
  }

  double get bottomOnlyPadding {
    return max(
      MediaQuery.viewInsetsOf(_navigationService.currentContext).bottom,
      MediaQuery.viewPaddingOf(_navigationService.currentContext).bottom,
    );
  }

  @override
  void notifyListeners() {
    Future.delayed(Duration.zero, () {
      if (_disposed) return;
      super.notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    debugPrint('adsfa');
    super.dispose();
  }
}
