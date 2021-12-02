import 'package:flutter/material.dart';

import '../ib_config.dart';

class IbCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  const IbCard({Key? key, required this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IbConfig.kCardCornerRadius),
      ),
      child: child,
    );
  }
}
