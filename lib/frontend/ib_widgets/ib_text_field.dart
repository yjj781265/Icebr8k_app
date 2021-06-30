import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbTextField extends StatelessWidget {
  final Icon titleIcon;
  final Icon suffixIcon;
  final String titleTrKey;
  final String hintTrKey;
  final String errorTrKey;
  final Color borderColor;
  const IbTextField(
      {Key? key,
      required this.titleIcon,
      required this.titleTrKey,
      required this.hintTrKey,
      this.suffixIcon = const Icon(null),
      required this.errorTrKey,
      this.borderColor = IbColors.lightGrey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                decoration: InputDecoration(
                    hintStyle: const TextStyle(color: IbColors.lightGrey),
                    hintText: hintTrKey.tr,
                    border: InputBorder.none,
                    suffixIcon: suffixIcon),
              ),
            ),
          ),
        ),
        /******* error text ****/
        SizedBox(
          width: Get.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 16, 16),
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
      ],
    );
  }
}
