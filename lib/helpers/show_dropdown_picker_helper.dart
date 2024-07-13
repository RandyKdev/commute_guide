import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_size_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:commute_guide/widgets/btn_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T?> showDropdownPickerHelper<T>({
  required BuildContext context,
  required List<T> items,
  required Widget Function(BuildContext, int index) itemBuilder,
  T? initialItem,
}) async {
  return await showCupertinoModalPopup<T?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      T? tempItem = initialItem;
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
                    Navigator.of(context).pop(tempItem);
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
              child: CupertinoPicker.builder(
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  tempItem = items[index];
                },
                itemBuilder: itemBuilder,
                childCount: items.length,
                scrollController: FixedExtentScrollController(
                  initialItem:
                      initialItem == null ? 0 : items.indexOf(initialItem),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
