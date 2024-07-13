import 'package:commute_guide/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final String errorMSG;
  final bool enabled;
  final bool showForceBgColor;
  final TextEditingController? controller;
  final int multiLines;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode autovalidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Function? onTapDontOpenKeyboard;
  final Color backgroundColor, disabledColor;
  final bool isDanger;
  final VoidCallback? onLoseFocus;
  final VoidCallback? onFocus;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onEditingComplete;
  final FloatingLabelBehavior floatingLabelBehaviour;
  final TextAlign textAlign;
  final double fontSize, borderRadius;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final int minLines;
  final TextStyle? hintStyle;
  final Widget? suffix;
  final FocusNode? focusNode;

  const TextFieldWidget({
    super.key,
    required this.labelText,
    this.hintText,
    this.errorMSG = "",
    this.controller,
    this.enabled = true,
    this.multiLines = 1,
    this.obscureText = false,
    this.validator,
    this.onEditingComplete,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onFocus,
    this.isDanger = false,
    this.onTapDontOpenKeyboard,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.backgroundColor = Colors.white,
    this.disabledColor = AppColors.grey,
    this.onLoseFocus,
    this.floatingLabelBehaviour = FloatingLabelBehavior.auto,
    this.prefixIcon,
    this.textAlign = TextAlign.start,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w400,
    this.padding = const EdgeInsets.all(15),
    this.borderRadius = 24.0,
    this.minLines = 1,
    this.showForceBgColor = false,
    this.suffixIcon,
    this.hintStyle,
    this.suffix,
    this.focusNode,
  });

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  late FocusNode myFocusNode;
  bool hasFocus = false;

  get hasError => widget.errorMSG.isNotEmpty;

  @override
  void initState() {
    super.initState();
    myFocusNode = widget.focusNode ?? FocusNode();
    myFocusNode.addListener(() {
      if (hasFocus && !myFocusNode.hasFocus && widget.onLoseFocus != null) {
        widget.onLoseFocus!();
      }
      if (!hasFocus && myFocusNode.hasFocus && widget.onFocus != null) {
        widget.onFocus!();
      }
      if (!mounted) return;
      setState(() {
        hasFocus = myFocusNode.hasFocus;
      });
      // debugPrint("Focus: " + myFocusNode.hasFocus.toString());
    });
    if (!mounted) return;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      myFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final returnValue = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          onEditingComplete: widget.onEditingComplete,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          maxLines: widget.multiLines,
          minLines: widget.minLines,
          autovalidateMode: widget.autovalidateMode,
          obscureText: widget.obscureText,
          textAlign: widget.textAlign,
          enabled:
              widget.onTapDontOpenKeyboard != null ? false : widget.enabled,
          focusNode: myFocusNode,
          controller: widget.controller,
          onTap: widget.enabled
              ? () {
                  if (widget.onTapDontOpenKeyboard != null) {
                    widget.onTapDontOpenKeyboard!();
                    return;
                  }
                  if (!mounted) return;
                  setState(() {
                    FocusScope.of(context).unfocus();
                    FocusScope.of(context).requestFocus(myFocusNode);
                  });
                }
              : null,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            // fontFamily: 'Calibre',
            fontWeight: FontWeight.w400,
            // height: 0,
            // textBaseline: TextBaseline.alphabetic,
          ),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,

            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.grey,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: widget.minLines * 5,
            ),

            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.grey,
              ),
            ),

            filled: false,

            alignLabelWithHint: true,
            constraints: const BoxConstraints(
              // maxHeight: 35,
              minHeight: 35,
            ),
            enabled: widget.enabled,
            disabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.grey,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.red,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(
                color: AppColors.red,
              ),
            ),
            // label: CSMDText(''),

            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                const TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                  // fontFamily: 'Calibre',
                  fontWeight: FontWeight.w400,
                ),

            suffixIcon: widget.suffixIcon,
            suffix: widget.suffix,
          ),
          validator: widget.validator,
        ),
        hasError
            ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14.0, top: 10),
                  child: Text(
                    widget.errorMSG,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );

    if (widget.onTapDontOpenKeyboard != null) {
      return InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: widget.enabled
            ? () {
                widget.onTapDontOpenKeyboard!();
              }
            : null,
        child: returnValue,
      );
    }
    return returnValue;
  }
}
