import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

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
            flex: 6,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                  Radius.circular(IbConfig.kScrollbarCornerRadius)),
              child: LinearProgressIndicator(
                color: IbUtils().handleIndicatorColor(endValue),
                backgroundColor: IbColors.lightGrey,
                minHeight: 8,
                value: endValue,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${(endValue * 100).toInt()}%',
                  style: TextStyle(
                      color: IbUtils().handleIndicatorColor(endValue)),
                )),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(IbConfig.kScrollbarCornerRadius)),
                  child: LinearProgressIndicator(
                    color: IbUtils().handleIndicatorColor(value),
                    backgroundColor: IbColors.lightGrey,
                    minHeight: 8,
                    value: value,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${(value * 100).toInt()}%',
                    style:
                        TextStyle(color: IbUtils().handleIndicatorColor(value)),
                  ),
                ),
              )
            ],
          );
        });
  }
}
