import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_size_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showDatePickerHelper({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  return await showCupertinoModalPopup<DateTime?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      DateTime? tempPickedDate = initialDate;
      return Container(
        height: 250,
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ButtonWidget(
                  buttonType: ButtonTypeEnum.textButton,
                  buttonSize: ButtonSizeEnum.contentWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
                ButtonWidget(
                  buttonType: ButtonTypeEnum.textButton,
                  buttonSize: ButtonSizeEnum.contentWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(tempPickedDate);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 0,
              thickness: 1,
              color: Colors.grey.withOpacity(.2),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime dateTime) {
                  tempPickedDate = dateTime;
                },
                dateOrder: DatePickerDateOrder.dmy,
                maximumDate: DateTime.now().add(const Duration(days: 1)),
                initialDateTime: initialDate,
              ),
            ),
          ],
        ),
      );
    },
  );
}
