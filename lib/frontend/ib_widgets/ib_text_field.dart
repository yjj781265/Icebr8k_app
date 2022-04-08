import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbTextField extends StatelessWidget {
  final Icon titleIcon;
  final TextEditingController? controller;
  final TextAlign textAlign;
  final Widget? suffixIcon;
  final TextStyle? textStyle;
  final String titleTrKey;
  final String hintTrKey;
  final String errorTrKey;
  final String prefixText;
  final Color borderColor;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatter;
  final int? charLimit;
  final int maxLines;
  final String? text;
  final bool hideCounterText;
  final Iterable<String> autofillHints;
  final TextInputType textInputType;
  final Function(String value)? onChanged;
  final bool enabled;
  const IbTextField({
    Key? key,
    required this.titleIcon,
    required this.titleTrKey,
    required this.hintTrKey,
    this.textAlign = TextAlign.left,
    this.inputFormatter,
    this.suffixIcon,
    this.errorTrKey = '',
    this.textStyle,
    this.borderColor = IbColors.lightGrey,
    this.enabled = true,
    this.charLimit,
    this.maxLines = 1,
    this.hideCounterText = false,
    this.text,
    this.onChanged,
    this.textInputType = TextInputType.text,
    this.obscureText = false,
    this.autofillHints = const [],
    this.prefixText = '',
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      autofillHints: enabled ? autofillHints : null,
      keyboardType: textInputType,
      textAlign: textAlign,
      style: textStyle,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      obscureText: obscureText,
      maxLength: charLimit,
      maxLines: maxLines,
      minLines: 1,
      inputFormatters: inputFormatter,
      onChanged: (text) {
        onChanged?.call(text);
      },
      controller: controller,
      decoration: InputDecoration(
          counterText: hideCounterText ? '' : null,
          prefixText: prefixText,
          enabled: enabled,
          hintStyle: const TextStyle(color: IbColors.lightGrey),
          hintText: hintTrKey.tr,
          border: InputBorder.none,
          suffixIcon: suffixIcon),
    );
    if (text != null && controller != null) {
      controller!.text = text!;
    }
    return Column(
      children: [
        Row(
          children: [
            titleIcon,
            const SizedBox(
              width: 8,
            ),
            Text(titleTrKey.tr),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
                Radius.circular(IbConfig.kTextBoxCornerRadius)),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: textField,
          ),
        ),
        /******* error text ****/
        SizedBox(
          width: Get.width * 0.9,
          child: Padding(
            padding: errorTrKey.isEmpty
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(8, 0, 16, 8),
            child: Text(
              errorTrKey.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                  color: IbColors.errorRed,
                  fontSize: IbConfig.kSecondaryTextSize),
            ),
          ),
        ),
      ],
    );
  }
}
