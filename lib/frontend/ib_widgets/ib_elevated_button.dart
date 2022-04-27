import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbElevatedButton extends StatelessWidget {
  final String textTrKey;
  final Function onPressed;
  final Function? onLongPressed;
  final Color color;
  final Color? textColor;
  final Widget? icon;
  final bool disabled;
  const IbElevatedButton(
      {Key? key,
      required this.textTrKey,
      required this.onPressed,
      this.onLongPressed,
      this.icon,
      this.textColor,
      this.disabled = false,
      this.color = IbColors.accentColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: icon == null ? _regularButton() : _iconButton(),
    );
  }

  Widget _regularButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(IbConfig.kButtonCornerRadius),
          ),
          primary: color),
      onPressed: disabled ? null : () => onPressed(),
      onHover: (flag) {
        print(flag);
      },
      onLongPress: disabled
          ? null
          : () => onLongPressed == null ? null : onLongPressed!(),
      child: Text(
        textTrKey.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: IbConfig.kNormalTextSize,
            color: textColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _iconButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(IbConfig.kButtonCornerRadius),
          ),
          primary: color),
      onPressed: disabled ? null : () => onPressed(),
      onLongPress: disabled
          ? null
          : () => onLongPressed == null ? null : onLongPressed!(),
      icon: icon!,
      label: Text(
        textTrKey.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: IbConfig.kNormalTextSize,
            color: textColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
