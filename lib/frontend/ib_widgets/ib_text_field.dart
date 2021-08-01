import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbTextField extends StatelessWidget {
  final Icon titleIcon;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String titleTrKey;
  final String hintTrKey;
  final String errorTrKey;
  final String prefixText;
  final Color borderColor;
  final bool obscureText;
  final int? charLimit;
  final Iterable<String> autofillHints;
  final TextInputType textInputType;
  final Function(String) onChanged;
  final bool enabled;
  const IbTextField({
    Key? key,
    required this.titleIcon,
    required this.titleTrKey,
    required this.hintTrKey,
    this.suffixIcon,
    this.errorTrKey = '',
    this.borderColor = IbColors.lightGrey,
    this.enabled = true,
    this.charLimit,
    required this.onChanged,
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
      scrollPhysics: const NeverScrollableScrollPhysics(),
      obscureText: obscureText,
      maxLength: charLimit,
      onChanged: (text) {
        onChanged(text);
      },
      controller: controller,
      decoration: InputDecoration(
          prefixText: prefixText,
          enabled: enabled,
          hintStyle: const TextStyle(color: IbColors.lightGrey),
          hintText: hintTrKey.tr,
          border: InputBorder.none,
          suffixIcon: suffixIcon),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              titleIcon,
              const SizedBox(
                width: 8,
              ),
              Text(titleTrKey.tr),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                  Radius.circular(IbConfig.kTextBoxCornerRadius)),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Padding(padding: const EdgeInsets.all(8), child: textField),
          ),
        ),
        /******* error text ****/
        SizedBox(
          width: Get.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
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
