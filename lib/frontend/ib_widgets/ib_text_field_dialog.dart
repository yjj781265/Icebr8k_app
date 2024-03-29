import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbTextFieldDialog extends StatelessWidget {
  final String introTrKey;
  final List<Widget> buttons;
  final Icon titleIcon;
  final TextEditingController? controller;
  final Widget suffixIcon;
  final String titleTrKey;
  final String hintTrKey;
  final String errorTrKey;
  final String prefixText;
  final Color borderColor;
  final bool obscureText;
  final Iterable<String> autofillHints;
  final TextInputType textInputType;
  final Function(String) onChanged;
  final bool enabled;
  const IbTextFieldDialog({
    Key? key,
    required this.buttons,
    required this.introTrKey,
    required this.titleIcon,
    required this.titleTrKey,
    required this.hintTrKey,
    this.suffixIcon = const Icon(null),
    this.errorTrKey = '',
    this.borderColor = IbColors.lightGrey,
    this.enabled = true,
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
      keyboardType: textInputType,
      textInputAction: TextInputAction.done,
      onChanged: (text) {
        onChanged(text);
      },
      autofocus: true,
      controller: controller,
      decoration: InputDecoration(
          hintStyle: const TextStyle(color: IbColors.lightGrey),
          hintText: hintTrKey.tr,
          border: InputBorder.none,
          suffixIcon: suffixIcon),
    );
    return Center(
      child: SizedBox(
        width: Get.width * 0.95,
        child: IbCard(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    introTrKey.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                ),
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
                    child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: textField),
                  ),
                ),
                /******* error text ****/
                SizedBox(
                  width: Get.width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 16, 0),
                    child: Text(
                      errorTrKey.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: const TextStyle(
                          color: IbColors.errorRed,
                          fontSize: IbConfig.kSecondaryTextSize),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: buttons,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
