import 'package:commute_guide/widgets/dialog_blueprint_widget.dart';
import 'package:flutter/cupertino.dart';

void showLoaderDialoHelper(BuildContext context) {
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const DialogBlueprintWidget(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CupertinoActivityIndicator(
              radius: 15,
            ),
          ),
        ),
      );
    },
  );
}
