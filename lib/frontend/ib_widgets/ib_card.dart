import 'package:flutter/material.dart';

import '../ib_config.dart';

class IbCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double elevation;
  const IbCard(
      {Key? key,
      required this.child,
      this.margin,
      this.color,
      this.radius = IbConfig.kCardCornerRadius,
      this.elevation = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: elevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
