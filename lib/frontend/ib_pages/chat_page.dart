import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

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
          if (_controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }
          return Column(
            children: [
              Expanded(
                child: AnimatedList(
                  reverse: true,
                  controller: _controller.scrollController,
                  key: _controller.listKey,
                  itemBuilder: (BuildContext context, int index,
                      Animation<double> animation) {
                    return buildItem(_controller.messages[index], animation);
                  },
                  initialItemCount: _controller.messages.length,
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
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(color: IbColors.lightGrey),
                          hintText: 'Type something creative',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.send_outlined,
                              color: IbColors.primaryColor,
                            ),
                            onPressed: () async {
                              if (_txtController.text.trim().isEmpty) {
                                return;
                              }
                              await _controller
                                  .uploadMessage(_txtController.text);
                              _txtController.clear();
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
    final String mUid = Get.find<AuthController>().firebaseUser!.uid;
    final bool isMe = item.message.senderUid == mUid;

    return SlideTransition(
      position: Tween<Offset>(
        end: Offset.zero,
        begin: isMe ? const Offset(1.5, 0) : const Offset(-1.5, 0),
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.linearToEaseOut)),
      child: isMe
          ? MyMessageItemView(item.message.content)
          : MessageItemView(
              text: item.message.content,
              user: _controller.ibUserMap[item.message.senderUid],
            ),
    );
  }
}

class MyMessageItemView extends StatelessWidget {
  const MyMessageItemView(
    this.text, {
    Key? key,
  }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LimitedBox(
            maxWidth: Get.width * 0.8,
            child: Container(
              decoration: const BoxDecoration(
                color: IbColors.primaryColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(IbConfig.kTextBoxCornerRadius)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
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

class MessageItemView extends StatelessWidget {
  final String text;
  final IbUser? user;
  const MessageItemView({required this.text, required this.user, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IbUserAvatar(
            radius: 16,
            avatarUrl: user == null ? '' : user!.avatarUrl,
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
                child: Text(
                  text,
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
