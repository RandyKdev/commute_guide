import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/cupertino.dart';

Future<T?> showAlertDialogHelper<T>({
  required BuildContext context,
  required String subtitle,
  required String title,
  required VoidCallback primaryCallback,
  required VoidCallback secondaryCallback,
  required String primaryBtnText,
  required String secondaryBtnText,
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: <Widget>[
        CupertinoDialogAction(
          onPressed: secondaryCallback,
          textStyle: const TextStyle(
            fontFamily: '.SF UI Text',
            inherit: false,
            fontSize: 16.8,
            fontWeight: FontWeight.w400,
            textBaseline: TextBaseline.alphabetic,
            color: AppColors.primaryBlue,
          ),
          child: Text(secondaryBtnText),
        ),
        CupertinoDialogAction(
          onPressed: primaryCallback,
          textStyle: const TextStyle(
            fontFamily: '.SF UI Text',
            inherit: false,
            fontSize: 16.8,
            fontWeight: FontWeight.w400,
            textBaseline: TextBaseline.alphabetic,
            color: AppColors.primaryBlue,
          ),
          child: Text(primaryBtnText),
        ),
      ],
    ),
  );
}
