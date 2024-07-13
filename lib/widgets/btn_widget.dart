import 'package:commute_guide/constants/colors.dart';
import 'package:commute_guide/enums/button_size_enum.dart';
import 'package:commute_guide/enums/button_type_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? text;
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ButtonTypeEnum buttonType;
  final Widget? leading;
  final ButtonSizeEnum buttonSize;
  final bool loading;
  final bool enabled;
  final BorderRadius? borderRadius;
  final Color? color;
  final TextStyle? textStyle;

  const ButtonWidget({
    super.key,
    required this.onTap,
    this.text,
    this.child,
    this.padding,
    this.buttonType = ButtonTypeEnum.filledPrimary,
    this.leading,
    this.buttonSize = ButtonSizeEnum.fullWidth,
    this.loading = false,
    this.enabled = true,
    this.margin,
    this.borderRadius,
    this.color,
    this.textStyle,
  })  : assert(!(text == null && child == null)),
        assert(!(text != null && child != null)),
        assert(!(leading != null && child != null)),
        assert(!(leading != null && text == null)),
        assert(!(textStyle != null && child != null)),
        assert(!(buttonSize == ButtonSizeEnum.fullWidth && child != null));

  @override
  Widget build(BuildContext context) {
    const loader = CupertinoActivityIndicator();

    final textStyle = buttonType == ButtonTypeEnum.textButton
        ? const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          )
        : buttonType == ButtonTypeEnum.filledPrimary
            ? const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )
            : const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              );

    final textWidget = text != null
        ? Center(
            child: Text(
              text!,
              style: textStyle.merge(this.textStyle),
            ),
          )
        : null;

    final leadingWidget = leading != null
        ? Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: leading,
              ),
              Expanded(
                child: textWidget!,
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: buttonSize == ButtonSizeEnum.fullWidth && loading
                    ? loader
                    : null,
              ),
            ],
          )
        : null;

    final paddingUsed = padding ??
        (buttonType == ButtonTypeEnum.textButton
            ? const EdgeInsets.symmetric(vertical: 10)
            : leading != null
                ? const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 30,
                  )
                : const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 30,
                  ));

    final canTap = !loading && enabled;
    // final bgColor = buttonType == ButtonTypeEnum.filledSecondary
    //     ? AppColors.bgColor
    //     : AppColors.transparent;

    if (buttonType == ButtonTypeEnum.textButton) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: canTap ? onTap : () {},
          child: Container(
            padding: paddingUsed,
            child: child ??
                Text(
                  text!,
                  style: textStyle.merge(this.textStyle),
                ),
          ),
        ),
      );
    }

    if (buttonType == ButtonTypeEnum.filledSecondary) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: OutlinedButton(
          onPressed: canTap ? onTap : () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: color ?? buttonType.getColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: buttonType.getBorderSide,
              borderRadius: borderRadius ?? BorderRadius.circular(10),
            ),
          ),
          child: Container(
            padding: paddingUsed,
            child: buttonSize == ButtonSizeEnum.contentWidth && loading
                ? loader
                : child ?? (leading != null ? leadingWidget : textWidget),
          ),
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ElevatedButton(
        onPressed: canTap ? onTap : () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? buttonType.getColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: buttonType.getBorderSide,
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
        ),
        child: Container(
          padding: paddingUsed,
          child: buttonSize == ButtonSizeEnum.contentWidth && loading
              ? loader
              : child ?? (leading != null ? leadingWidget : textWidget),
        ),
      ),
    );
  }
}
