import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/helpers/show_dialog_helper.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:flutter/material.dart';

Future<void> showInfoDialogHelper({
  required BuildContext context,
  String? childText,
  String? title,
  Widget? child,
  required VoidCallback onTap,
  required String btnText,
  bool? barrierDismissible,
}) {
  assert(childText != null || child != null);

  return showDialoHelper(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 6),
          child ??
              Text(
                childText!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
          const SizedBox(height: 25),
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  strokeAlign: BorderSide.strokeAlignCenter,
                  color: Colors.white.withOpacity(.1),
                ),
              ),
            ),
          ),
          ButtonWidget(
            buttonType: ButtonTypeEnum.textButton,
            padding: const EdgeInsets.symmetric(
              vertical: 22,
              horizontal: 16,
            ),
            onTap: onTap,
            text: btnText,
          ),
        ],
      ),
    ),
  );
}
