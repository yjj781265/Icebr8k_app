import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbElevatedButton extends StatelessWidget {
  final String textTrKey;
  final Function onPressed;
  const IbElevatedButton(
      {Key? key, required this.textTrKey, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: Get.width * 0.75,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                //to set border radius to button
                borderRadius:
                    BorderRadius.circular(IbConfig.kButtonCornerRadius),
              ),
              primary: IbColors.accentColor),
          onPressed: () => onPressed(),
          child: Text(
            textTrKey.tr,
            style: const TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                color: IbColors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
