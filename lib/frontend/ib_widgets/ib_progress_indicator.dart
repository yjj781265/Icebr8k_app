import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../ib_config.dart';

class IbProgressIndicator extends StatelessWidget {
  final double padding;

  const IbProgressIndicator({this.padding = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Lottie.asset('assets/icons/loading.json',
          width: IbConfig.kLoadingIndicatorSize,
          height: IbConfig.kLoadingIndicatorSize),
    );
  }
}
