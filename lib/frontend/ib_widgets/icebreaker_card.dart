import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

class IcebreakerCard extends StatelessWidget {
  final Icebreaker icebreaker;
  final IbCollection ibCollection;
  final bool showCollectionName;
  const IcebreakerCard(
      {required this.ibCollection,
      required this.icebreaker,
      this.showCollectionName = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IbCard(
        color: Color(icebreaker.bgColor),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: AutoSizeText(
                  icebreaker.text,
                  textAlign: TextAlign.center,
                  minFontSize: IbConfig.kNormalTextSize,
                  maxFontSize: IbConfig.kSloganSize,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: IbUtils.getIbFonts(TextStyle(
                      fontSize: IbConfig.kSloganSize,
                      color: Color(icebreaker.textColor),
                      fontStyle: icebreaker.isItalic
                          ? FontStyle.italic
                          : FontStyle.normal,
                      fontWeight: FontWeight.bold))[icebreaker.textStyleIndex],
                ),
              ),
            ),
            if (showCollectionName)
              Positioned(
                  bottom: 16,
                  right: 4,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => IbCoverPage(ibCollection));
                    },
                    child: LimitedBox(
                      maxWidth: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          ibCollection.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IbUtils.getIbFonts(TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: Color(ibCollection.textColor),
                              fontWeight: FontWeight.bold,
                              fontStyle: ibCollection.isItalic
                                  ? FontStyle.italic
                                  : FontStyle
                                      .normal))[ibCollection.textStyleIndex],
                        ),
                      ),
                    ),
                  ))
          ],
        ));
  }
}
