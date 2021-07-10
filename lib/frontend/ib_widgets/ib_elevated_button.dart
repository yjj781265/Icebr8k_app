import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbElevatedButton extends StatelessWidget {
  final String textTrKey;
  final Function onPressed;
  final Color color;
  final Widget? icon;
  const IbElevatedButton(
      {Key? key,
      required this.textTrKey,
      required this.onPressed,
      this.icon,
      this.color = IbColors.accentColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: Get.width * 0.6,
        child: icon == null ? _regularButton() : _iconButton(),
      ),
    );
  }

  Widget _regularButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(IbConfig.kButtonCornerRadius),
          ),
          primary: color),
      onPressed: () => onPressed(),
      child: Text(
        textTrKey.tr,
        style: const TextStyle(
            fontSize: IbConfig.kNormalTextSize,
            color: IbColors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _iconButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(IbConfig.kButtonCornerRadius),
          ),
          primary: color),
      onPressed: () => onPressed(),
      icon: icon!,
      label: Text(
        textTrKey.tr,
        style: const TextStyle(
            fontSize: IbConfig.kNormalTextSize,
            color: IbColors.white,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
