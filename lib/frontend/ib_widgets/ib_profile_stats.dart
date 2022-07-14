import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../ib_config.dart';
import '../ib_utils.dart';

class IbProfileStats extends StatelessWidget {
  final int number;
  final Function onTap;
  final String subText;

  const IbProfileStats(
      {required this.number, required this.onTap, required this.subText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).backgroundColor,
        ),
        height: 56,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                IbUtils().getStatsString(number),
                maxLines: 1,
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontSize: IbConfig.kPageTitleSize),
              ),
              AutoSizeText(
                maxLines: 1,
                subText,
                style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontSize: IbConfig.kDescriptionTextSize),
              )
            ],
          ),
        ),
      ),
    );
  }
}
