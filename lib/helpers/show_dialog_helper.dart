import 'package:commute_guide/widgets/dialog_blueprint_widget.dart';
import 'package:flutter/material.dart';

Future<void> showDialoHelper({
  required BuildContext context,
  required Widget child,
  bool? barrierDismissible,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    builder: (context) {
      return DialogBlueprintWidget(child: child);
    },
  );
}
