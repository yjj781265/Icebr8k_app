import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../ib_config.dart';

/// show stats such as how many question asked in the profile page
class IbStats extends StatelessWidget {
  final String title;
  final int num;
  const IbStats({Key? key, required this.title, required this.num})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IbCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              IbUtils.getStatsString(num),
              style: const TextStyle(
                  fontSize: IbConfig.kNormalTextSize,
                  fontWeight: FontWeight.w800),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }
}
