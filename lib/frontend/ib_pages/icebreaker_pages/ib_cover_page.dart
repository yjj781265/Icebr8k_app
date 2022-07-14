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
import 'package:url_launcher/url_launcher_string.dart';

class IbCoverPage extends StatelessWidget {
  final IbCollection ibCollection;
  final bool isEdit;
  const IbCoverPage(this.ibCollection, {this.isEdit = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: AutoSizeText(
            ibCollection.name,
            maxFontSize: IbConfig.kPageTitleSize,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: IbConfig.kPageTitleSize),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Align(
              child: Hero(
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
                              style: IbUtils().getIbFonts(TextStyle(
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
                                  if (await canLaunchUrlString(
                                      ibCollection.link.trim())) {
                                    launchUrlString(ibCollection.link);
                                  }
                                },
                              ),
                            )),
                      if (ibCollection.icebreakers.isNotEmpty)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: IbCard(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '${ibCollection.icebreakers.length} Question(s)',
                                  style: const TextStyle(
                                      color: IbColors.lightGrey),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 56,
                width: Get.width,
                child: IbElevatedButton(
                  textTrKey: isEdit ? 'Edit ✏' : "Let's break the ice",
                  onPressed: () async {
                    Get.off(() => IcebreakerMainPage(Get.put(
                        IcebreakerController(ibCollection, isEdit: isEdit),
                        tag: ibCollection.id)));
                  },
                  textSize: IbConfig.kPageTitleSize,
                  textColor: Color(ibCollection.textColor),
                  color: Color(ibCollection.bgColor).withOpacity(0.8),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
