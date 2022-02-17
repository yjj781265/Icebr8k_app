import 'package:flutter/material.dart';

import '../ib_config.dart';

class IbCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final double elevation;
  const IbCard(
      {Key? key,
      required this.child,
      this.color,
      this.radius = IbConfig.kCardCornerRadius,
      this.elevation = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
