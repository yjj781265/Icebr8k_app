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

class IbCoverPage extends StatefulWidget {
  final IbCollection ibCollection;
  final bool isEdit;
  const IbCoverPage(this.ibCollection, {this.isEdit = false, Key? key})
      : super(key: key);

  @override
  State<IbCoverPage> createState() => _IbCoverPageState();
}

class _IbCoverPageState extends State<IbCoverPage> {
  int count = 0;
  @override
  void initState() {
    count = widget.ibCollection.icebreakers.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ibCollection.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            child: Hero(
              tag: widget.ibCollection.id,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: Get.width,
                      height: (Get.width) * 1.44,
                      child: IbCard(
                        color: Color(widget.ibCollection.bgColor),
                        child: Center(
                          child: AutoSizeText(
                            widget.ibCollection.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: IbConfig.kPageTitleSize,
                            maxFontSize: IbConfig.kSloganSize,
                            maxLines: 4,
                            style: IbUtils.getIbFonts(TextStyle(
                                fontSize: IbConfig.kSloganSize,
                                fontStyle: widget.ibCollection.isItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: Color(widget.ibCollection.textColor),
                                fontWeight: FontWeight
                                    .bold))[widget.ibCollection.textStyleIndex],
                          ),
                        ),
                      ),
                    ),
                    if (widget.ibCollection.link.trim().isNotEmpty)
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
                                if (await canLaunch(
                                    widget.ibCollection.link.trim())) {
                                  launch(widget.ibCollection.link);
                                }
                              },
                            ),
                          )),
                    if (widget.ibCollection.icebreakers.isNotEmpty)
                      Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).backgroundColor,
                            child: Text(
                              '$count',
                              style: const TextStyle(color: IbColors.lightGrey),
                            ),
                          ))
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            height: 56,
            width: Get.width,
            child: IbElevatedButton(
              textTrKey: widget.isEdit ? 'Edit ✏️' : "Let's 🧊🔨",
              onPressed: () async {
                final ibCollection = await Get.to(() => IcebreakerMainPage(
                    Get.put(IcebreakerController(widget.ibCollection,
                        isEdit: widget.isEdit))));
                setState(() {
                  count = ibCollection == null
                      ? 0
                      : (ibCollection as IbCollection).icebreakers.length;
                });
              },
              textSize: IbConfig.kPageTitleSize,
              textColor: Color(widget.ibCollection.textColor),
              color: Color(widget.ibCollection.bgColor).withOpacity(0.8),
            ),
          )
        ],
      ),
    );
  }
}
