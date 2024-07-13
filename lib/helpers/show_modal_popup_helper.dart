import 'package:commute_guide/widgets/modal_popup_blueprint_widget.dart';
import 'package:flutter/cupertino.dart';

Future<void> showModalPopupHelper({
  required BuildContext context,
  required Widget child,
  Color? barrierColor,
  bool? barrierDismissible,
}) async {
  return await showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    barrierColor: barrierColor ?? kCupertinoModalBarrierColor,
    builder: (context) {
      return ModalPopupBlueprintWidget(child: child);
    },
  );
}
