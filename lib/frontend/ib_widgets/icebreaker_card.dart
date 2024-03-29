import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/user_controllers/social_tab_controller.dart';
import '../../backend/models/ib_chat_models/ib_message.dart';
import '../ib_colors.dart';
import '../ib_pages/chat_picker_page.dart';
import 'ib_dialog.dart';
import 'ib_loading_dialog.dart';

class IcebreakerCard extends StatefulWidget {
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
  State<IcebreakerCard> createState() => _IcebreakerCardState();
}

class _IcebreakerCardState extends State<IcebreakerCard> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!IbLocalDataService()
          .retrieveBoolValue(StorageKey.icebreakerProTipBool)) {
        Get.dialog(Padding(
          padding: const EdgeInsets.all(4.0),
          child: IbDialog(
            title: 'Pro Tip',
            subtitle: '',
            content: Wrap(
              children: const [
                Text('Click'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    FontAwesomeIcons.share,
                    size: 16,
                  ),
                ),
                Text(
                    'at the top right corner to share this icebreaker to chats')
              ],
            ),
            showNegativeBtn: false,
          ),
        ));
      }
      IbLocalDataService()
          .updateBoolValue(key: StorageKey.icebreakerProTipBool, value: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.618,
      child: IbCard(
          color: Color(widget.icebreaker.bgColor),
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    Clipboard.setData(
                        ClipboardData(text: widget.icebreaker.text));
                    IbUtils().showSimpleSnackBar(
                        msg: "Text copied to clipboard",
                        backgroundColor: IbColors.primaryColor);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AutoSizeText(
                      widget.icebreaker.text,
                      textAlign: TextAlign.center,
                      minFontSize: widget.minSize,
                      maxFontSize: widget.maxSize,
                      maxLines: IbConfig.kIbCardMaxLine,
                      overflow: TextOverflow.ellipsis,
                      style: IbUtils().getIbFonts(TextStyle(
                          fontSize: widget.maxSize,
                          color: Color(widget.icebreaker.textColor),
                          fontStyle: widget.icebreaker.isItalic
                              ? FontStyle.italic
                              : FontStyle.normal,
                          fontWeight: FontWeight
                              .bold))[widget.icebreaker.textStyleIndex],
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
                        final list = await Get.to(() => const ChatPickerPage());
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
                                  messageId: IbUtils().getUniqueId(),
                                  content: widget.icebreaker.id,
                                  extra: [widget.icebreaker.collectionId],
                                  senderUid: IbUtils().getCurrentUid()!,
                                  messageType: IbMessage.kMessageTypeIcebreaker,
                                  chatRoomId: item.ibChat.chatId,
                                  readUids: [IbUtils().getCurrentUid()!]);
                              await IbChatDbService().uploadMessage(message);
                            }
                            Get.back();
                            IbUtils().showSimpleSnackBar(
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
              if (widget.showCollectionName && widget.ibCollection != null)
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        Get.to(() => IbCoverPage(widget.ibCollection!));
                      },
                      child: LimitedBox(
                        maxWidth: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            widget.ibCollection!.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: IbUtils().getIbFonts(TextStyle(
                                fontSize: IbConfig.kDescriptionTextSize,
                                color: Color(widget.ibCollection!.textColor),
                                fontWeight: FontWeight.bold,
                                fontStyle: widget.ibCollection!.isItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal))[widget
                                .ibCollection!.textStyleIndex],
                          ),
                        ),
                      ),
                    )),
            ],
          )),
    );
  }
}
