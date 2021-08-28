import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbActionButton extends StatelessWidget {
  final Color color;
  final IconData? iconData;
  final String text;
  final Function onPressed;

  const IbActionButton(
      {required this.color,
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
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: color)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                iconData,
                color: color,
              ),
            ),
          ),
        ),
        Text(
          text,
          style: const TextStyle(fontSize: IbConfig.kDescriptionTextSize),
        )
      ],
    );
  }
}
