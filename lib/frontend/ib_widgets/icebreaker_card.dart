import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_pages/select_chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/user_controllers/social_tab_controller.dart';
import '../../backend/models/ib_chat_models/ib_message.dart';
import '../ib_colors.dart';
import 'ib_dialog.dart';
import 'ib_loading_dialog.dart';

class IcebreakerCard extends StatelessWidget {
  final Icebreaker icebreaker;
  final IbCollection? ibCollection;
  final bool showCollectionName;
  final double minSize;
  final double maxSize;
  const IcebreakerCard(
      {this.ibCollection,
      required this.icebreaker,
      this.minSize = 16,
      this.maxSize = 32,
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
              child: GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  Clipboard.setData(ClipboardData(text: icebreaker.text));
                  IbUtils.showSimpleSnackBar(
                      msg: "Text copied to clipboard",
                      backgroundColor: IbColors.primaryColor);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AutoSizeText(
                    icebreaker.text,
                    textAlign: TextAlign.center,
                    minFontSize: minSize,
                    maxFontSize: maxSize,
                    maxLines: IbConfig.kIbCardMaxLine,
                    overflow: TextOverflow.ellipsis,
                    style: IbUtils.getIbFonts(TextStyle(
                        fontSize: maxSize,
                        color: Color(icebreaker.textColor),
                        fontStyle: icebreaker.isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        fontWeight:
                            FontWeight.bold))[icebreaker.textStyleIndex],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor:
                    Theme.of(context).backgroundColor.withOpacity(0.8),
                child: IconButton(
                    onPressed: () async {
                      final list = await Get.to(() => const SelectChatPage());
                      if (list == null) {
                        return;
                      }
                      final items = (list as List<dynamic>)
                          .map((e) => e as ChatTabItem)
                          .toList();
                      if (items.isNotEmpty) {
                        Get.dialog(
                            const IbLoadingDialog(messageTrKey: 'Sharing...'),
                            barrierDismissible: false);
                        try {
                          for (final item in items) {
                            final message = IbMessage(
                                messageId: IbUtils.getUniqueId(),
                                content: icebreaker.id,
                                extra: [icebreaker.collectionId],
                                senderUid: IbUtils.getCurrentUid()!,
                                messageType: IbMessage.kMessageTypeIcebreaker,
                                chatRoomId: item.ibChat.chatId,
                                readUids: [IbUtils.getCurrentUid()!]);
                            await IbChatDbService().uploadMessage(message);
                          }
                          Get.back();
                          IbUtils.showSimpleSnackBar(
                              msg: 'Icebreaker shared successfully',
                              backgroundColor: IbColors.accentColor);
                        } catch (e) {
                          Get.back();
                          Get.dialog(IbDialog(
                            title: 'Error',
                            subtitle: e.toString(),
                            showNegativeBtn: false,
                          ));
                        }
                      }
                    },
                    icon: Icon(
                      FontAwesomeIcons.share,
                      color: Theme.of(context).indicatorColor,
                      size: 16,
                    )),
              ),
            ),
            if (showCollectionName && ibCollection != null)
              Positioned(
                  bottom: 16,
                  right: 4,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => IbCoverPage(ibCollection!));
                    },
                    child: LimitedBox(
                      maxWidth: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          ibCollection!.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: IbUtils.getIbFonts(TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: Color(ibCollection!.textColor),
                              fontWeight: FontWeight.bold,
                              fontStyle: ibCollection!.isItalic
                                  ? FontStyle.italic
                                  : FontStyle
                                      .normal))[ibCollection!.textStyleIndex],
                        ),
                      ),
                    ),
                  ))
          ],
        ));
  }
}
