import 'package:flutter/material.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class IbLinearIndicator extends StatelessWidget {
  const IbLinearIndicator(
      {Key? key, required this.endValue, this.disableAnimation = false})
      : super(key: key);
  final double endValue;
  final bool disableAnimation;
  @override
  Widget build(BuildContext context) {
    if (disableAnimation) {
      return Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              color: _handleIndicatorColor(endValue),
              backgroundColor: IbColors.lightGrey,
              minHeight: 5,
              value: endValue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${(endValue * 100).toInt()}%'),
          )
        ],
      );
    }
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: endValue),
        duration: Duration(
            milliseconds:
                endValue < 0.5 ? IbConfig.kEventTriggerDelayInMillis : 1200),
        builder: (context, double value, child) {
          return Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  color: _handleIndicatorColor(value),
                  backgroundColor: IbColors.lightGrey,
                  minHeight: 5,
                  value: value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${(value * 100).toInt()}%'),
              )
            ],
          );
        });
  }

  Color _handleIndicatorColor(double value) {
    if (value > 0 && value <= 0.2) {
      return const Color(0xFFFF0000);
    }

    if (value > 0.2 && value <= 0.4) {
      return const Color(0xFFFF6600);
    }

    if (value > 0.4 && value <= 0.6) {
      return const Color(0xFFFFB700);
    }

    if (value > 0.6 && value <= 0.8) {
      return const Color(0xFFB3FF00);
    }

    if (value > 0.8 && value <= 1.0) {
      return IbColors.accentColor;
    }
    return IbColors.errorRed;
  }
}
