import 'package:commute_guide/route_arguments/main_route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final navigationService = Provider((ref) => NavigationService());

class NavigationService {
  late GlobalKey<NavigatorState> navigatorKey;

  set setNavigatorKey(GlobalKey<NavigatorState> key) => navigatorKey = key;

  BuildContext get currentContext => navigatorKey.currentContext!;

  Future<T?> pushNamedScreen<T extends Object?>(
    String routeName, {
    Object? data,
  }) =>
      currentContext.push<T>(
        routeName,
        extra: data,
      );

  void pushNamedReplacementScreen(
    String routeName, {
    MainRouteArgument? data,
  }) =>
      currentContext.pushReplacement(
        routeName,
        extra: data,
      );

  Future<dynamic> pushDialog(Widget dialog) => showDialog(
        context: currentContext,
        builder: (context) => dialog,
      );

  void showSnackbar(SnackBar snackbar) {
    ScaffoldMessenger.of(currentContext).showSnackBar(snackbar);
  }

  void pop([dynamic value]) => currentContext.pop(value);

  void mayPop([dynamic value]) =>
      currentContext.canPop() ? Navigator.of(currentContext).pop(value) : null;

  void popAllAndPushNamed(
    String routeName, {
    MainRouteArgument? data,
  }) {
    popUntilFirstRoute();

    currentContext.pushReplacement(routeName, extra: data);
  }

  void popUntilFirstRoute() {
    Navigator.of(currentContext).popUntil((route) => route.isFirst);
  }

  Future<T?> pushModalBottomSheet<T>({
    required bool enableDrag,
    required double maxHeight,
    required Widget child,
  }) {
    return showModalBottomSheet(
      context: currentContext,
      showDragHandle: true,
      enableDrag: enableDrag,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      builder: (context) {
        return child;
      },
    );
  }
}
