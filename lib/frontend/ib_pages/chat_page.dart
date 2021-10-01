import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ib_config.dart';

class ChatPage extends StatelessWidget {
  ChatPage(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;
  final _txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: IbColors.lightBlue,
        appBar: AppBar(
          backgroundColor: IbColors.lightBlue,
          title: Obx(
            () => Text(
              _controller.title.value,
              style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
            ),
          ),
        ),
        body: Obx(() {
          return Column(
            children: [
              Expanded(
                child: NotificationListener(
                  onNotification: (t) {
                    if (t is UserScrollNotification) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    }
                    return true;
                  },
                  child: AnimatedList(
                    reverse: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _controller.scrollController,
                    key: _controller.listKey,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      if (index == _controller.messages.length - 2) {
                        _controller.loadMoreMessages();
                      }

                      return buildItem(_controller.messages[index], animation);
                    },
                    initialItemCount: _controller.messages.length,
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(IbConfig.kTextBoxCornerRadius)),
                    border: Border.all(
                      color: IbColors.primaryColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: TextField(
                      controller: _txtController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(
                              color: IbColors.lightGrey,
                              fontSize: IbConfig.kNormalTextSize),
                          hintText: 'Type something creative',
                          border: InputBorder.none,
                          suffixIcon: _controller.isSending.isTrue
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator()),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.send_outlined,
                                    color: IbColors.primaryColor,
                                  ),
                                  onPressed: () async {
                                    if (_txtController.text.trim().isEmpty) {
                                      return;
                                    }
                                    final text = _txtController.text.trim();
                                    _txtController.clear();
                                    await _controller.uploadMessage(text);
                                  },
                                )),
                    ),
                  ),
                ),
              )
            ],
          );
        }));
  }

  Widget buildItem(ChatMessageItem item, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        end: Offset.zero,
        begin: item.isMe ? const Offset(1.5, 0) : const Offset(-1.5, 0),
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.linearToEaseOut)),
      child: item.isMe ? MyMessageItemView(item) : MessageItemView(item),
    );
  }
}

class MyMessageItemView extends StatelessWidget {
  const MyMessageItemView(
    this.item, {
    Key? key,
  }) : super(key: key);
  final ChatMessageItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LimitedBox(
            maxWidth: Get.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: IbColors.primaryColor,
                    borderRadius: BorderRadius.all(
                        Radius.circular(IbConfig.kTextBoxCornerRadius)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableLinkify(
                      onOpen: (link) async {
                        if (await canLaunch(link.url)) {
                          launch(link.url);
                        }
                      },
                      text: item.message.content,
                      linkStyle: const TextStyle(color: Colors.white),
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    ),
                  ),
                ),
                handleSeenIndicator()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget handleSeenIndicator() {
    if (!item.showReadIndicator) {
      return const SizedBox();
    }

    final List<Widget> widgets = [];
    for (final String uid in item.message.readUids) {
      if (uid != IbUtils.getCurrentUid()) {
        widgets.add(Padding(
          padding: const EdgeInsets.all(2.0),
          child: IbUserAvatar(
            disableOnTap: true,
            avatarUrl: item.controller.ibUserMap[uid]!.avatarUrl,
            uid: uid,
            radius: 6,
          ),
        ));
      }
    }
    return Wrap(
      children: widgets,
    );
  }
}

class MessageItemView extends StatelessWidget {
  final ChatMessageItem item;
  const MessageItemView(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IbUser? user = item.controller.ibUserMap[item.message.senderUid];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IbUserAvatar(
            disableOnTap: true,
            radius: 16,
            avatarUrl: user!.avatarUrl,
            uid: user.id,
          ),
          const SizedBox(
            width: 8,
          ),
          LimitedBox(
            maxWidth: Get.width * 0.8,
            child: Container(
              decoration: const BoxDecoration(
                color: IbColors.accentColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(IbConfig.kTextBoxCornerRadius)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableLinkify(
                  text: item.message.content,
                  onOpen: (link) async {
                    if (await canLaunch(link.url)) {
                      launch(link.url);
                    }
                  },
                  linkStyle: const TextStyle(color: Colors.white),
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
