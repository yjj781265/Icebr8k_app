import 'package:flutter/material.dart';

import '../ib_config.dart';

class IbCard extends StatelessWidget {
  final Widget child;
  const IbCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IbConfig.kCardCornerRadius),
      ),
      child: child,
    );
  }
}
