import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../ib_config.dart';

class IbProgressIndicator extends StatelessWidget {
  final double padding;
  final double width;
  final double height;

  const IbProgressIndicator(
      {this.padding = 16,
      this.height = IbConfig.kLoadingIndicatorSize,
      this.width = IbConfig.kLoadingIndicatorSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Lottie.asset('assets/icons/loading.json',
          width: width, height: height),
    );
  }
}
