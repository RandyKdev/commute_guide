import 'package:flutter/cupertino.dart';

Future<T?> showActionSheetHelper<T>({
  required BuildContext context,
  required Widget child,
}) async {
  return await showCupertinoModalPopup<T?>(
    context: context,
    builder: (BuildContext context) => child,
  );
}
