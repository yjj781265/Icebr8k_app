import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

class IcebreakerCard extends StatelessWidget {
  final Icebreaker _icebreaker;
  const IcebreakerCard(this._icebreaker, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IbCard(
        margin: EdgeInsets.zero,
        color: Color(_icebreaker.bgColor),
        child: Column(
          children: [
            Expanded(
              child: Align(
                child: AutoSizeText(
                  _icebreaker.text,
                  minFontSize: IbConfig.kNormalTextSize,
                  maxFontSize: IbConfig.kSloganSize,
                  maxLines: 3,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(_icebreaker.textColor)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                _icebreaker.collectionId,
                style: const TextStyle(
                    color: IbColors.lightGrey, fontStyle: FontStyle.italic),
              ),
            )
          ],
        ));
  }
}
