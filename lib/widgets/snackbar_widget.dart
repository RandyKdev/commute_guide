import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
void CommuteSnackBarError({
  required String title,
  String subTitle = "",
  required BuildContext context,
}) =>
    _CommuteSnackBar(
      title: title,
      subTitle: subTitle,
      color: const Color(0xffD50525),
      darkColor: const Color(0xff880216),
      context: context,
    );

// ignore: non_constant_identifier_names
void CommuteSnackBarSuccessful({
  required String title,
  String subTitle = "",
  required BuildContext context,
}) =>
    _CommuteSnackBar(
      title: title,
      subTitle: subTitle,
      color: const Color(0xff13B674),
      darkColor: const Color(0xff0D7E51),
      context: context,
    );

// ignore: non_constant_identifier_names
void CommuteSnackBarWarning({
  required String title,
  String subTitle = "",
  required BuildContext context,
}) =>
    _CommuteSnackBar(
      title: title,
      subTitle: subTitle,
      color: const Color(0xffFFB727),
      darkColor: const Color(0xffB17804),
      context: context,
    );

// ignore: non_constant_identifier_names
void CommuteSnackBarInfo({
  required String title,
  String subTitle = "",
  required BuildContext context,
}) =>
    _CommuteSnackBar(
      title: title,
      subTitle: subTitle,
      color: const Color(0xff5B42FF),
      darkColor: const Color(0xff412EB8),
      context: context,
    );

// ignore: non_constant_identifier_names
void _CommuteSnackBar({
  required String title,
  String subTitle = "",
  required Color color,
  required Color darkColor,
  required BuildContext context,
}) {
  final snackbar = SnackBar(
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  subTitle.isNotEmpty ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.left,
          ),
          if (subTitle.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              subTitle,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.left,
            ),
          ],
        ],
      ),
    ),
    padding: EdgeInsets.zero,
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
    margin: EdgeInsets.zero,
    action: SnackBarAction(
      label: "Done",
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
    dismissDirection: DismissDirection.down,
    // animation: Animation,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
