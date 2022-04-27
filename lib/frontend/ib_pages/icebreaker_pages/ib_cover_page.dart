import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/icebreaker_controller.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/icebreaker_main_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:url_launcher/url_launcher.dart';

class IbCoverPage extends StatelessWidget {
  final IbCollection ibCollection;
  final bool isEdit;
  const IbCoverPage(this.ibCollection, {this.isEdit = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ibCollection.name),
      ),
      body: ListView(
        children: [
          Hero(
            tag: ibCollection.id,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: Get.width,
                    height: (Get.width) * 1.44,
                    child: IbCard(
                      color: Color(ibCollection.bgColor),
                      child: Center(
                        child: AutoSizeText(
                          ibCollection.name,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          minFontSize: IbConfig.kPageTitleSize,
                          maxFontSize: IbConfig.kSloganSize,
                          maxLines: 4,
                          style: IbUtils.getIbFonts(TextStyle(
                              fontSize: IbConfig.kSloganSize,
                              fontStyle: ibCollection.isItalic
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: Color(ibCollection.textColor),
                              fontWeight: FontWeight
                                  .bold))[ibCollection.textStyleIndex],
                        ),
                      ),
                    ),
                  ),
                  if (ibCollection.link.trim().isNotEmpty)
                    Positioned(
                        top: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.8),
                          child: IconButton(
                            icon: Icon(
                              Icons.link,
                              color: Theme.of(context).indicatorColor,
                            ),
                            onPressed: () async {
                              if (await canLaunch(ibCollection.link.trim())) {
                                launch(ibCollection.link);
                              }
                            },
                          ),
                        )),
                  if (ibCollection.icebreakers.isNotEmpty)
                    Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).backgroundColor,
                          child: Text(
                            '${ibCollection.icebreakers.length}',
                            style: const TextStyle(color: IbColors.lightGrey),
                          ),
                        ))
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 56,
            child: IbElevatedButton(
              textTrKey: isEdit ? '✏️' : "Let's 🧊🔨",
              onPressed: () {
                Get.to(() => IcebreakerMainPage(
                    Get.put(IcebreakerController(ibCollection, isEdit: true))));
              },
              textColor: Color(ibCollection.textColor),
              color: Color(ibCollection.bgColor).withOpacity(0.8),
            ),
          )
        ],
      ),
    );
  }
}
