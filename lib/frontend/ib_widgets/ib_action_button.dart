import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbActionButton extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final bool showCircle;
  final double size;
  final double fontSize;
  final IconData? iconData;
  final String text;
  final Function onPressed;

  const IbActionButton(
      {required this.color,
      this.bgColor = Colors.transparent,
      this.size = 24,
      this.fontSize = IbConfig.kSecondaryTextSize,
      this.showCircle = true,
      required this.iconData,
      required this.onPressed,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            onPressed();
          },
          child: Container(
            padding: showCircle ? const EdgeInsets.all(8) : null,
            decoration: showCircle
                ? BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: color))
                : null,
            child: Icon(
              iconData,
              size: size,
              color: color,
            ),
          ),
        ),
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(fontSize: fontSize),
          )
      ],
    );
  }
}
