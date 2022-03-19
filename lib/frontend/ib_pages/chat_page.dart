import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../backend/controllers/user_controllers/chat_page_controller.dart';

class ChatPage extends StatelessWidget {
  const ChatPage(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Obx(
            () => SizedBox(
              width: Get.width * 0.6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IbUserAvatar(
                    avatarUrl: _controller.avatarUrl.value,
                    radius: 16,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    _controller.title.value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (_controller.isLoading.isTrue) {
            return const Center(child: IbProgressIndicator());
          }
          return GestureDetector(
            onTap: () {
              IbUtils.hideKeyboard();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: ScrollablePositionedList.builder(
                  itemScrollController: _controller.itemScrollController,
                  itemPositionsListener: _controller.itemPositionsListener,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      return _meItem(_controller.messages[index]);
                    }
                    return _item(_controller.messages[index]);
                  },
                  itemCount: _controller.messages.length,
                )),
                _inputWidget(context),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          );
        }));
  }

  Widget _inputWidget(BuildContext context) {
    return SafeArea(
      child: IbCard(
        radius: 24,
        margin: EdgeInsets.zero,
        color: Theme.of(context).backgroundColor,
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          duration:
              const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CircleAvatar(
                          backgroundColor: IbColors.accentColor,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              _controller.showOptions.value =
                                  !_controller.showOptions.value;
                            },
                            icon: Icon(
                                _controller.showOptions.isTrue
                                    ? Icons.remove
                                    : Icons.add,
                                color: Theme.of(context).indicatorColor),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 8,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: IbColors.lightGrey.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: TextField(
                          scrollPadding: EdgeInsets.zero,
                          minLines: 1,
                          maxLines: 8,
                          maxLength: 2000,
                          onSubmitted: (value) async {
                            if (value.isNotEmpty) {}
                          },
                          textInputAction: TextInputAction.send,
                          controller: _controller.txtController,
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 4.0),
                            counterText: '',
                            fillColor: IbColors.lightGrey,
                            border: InputBorder.none,
                            hintText: 'Write a message',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CircleAvatar(
                          backgroundColor: IbColors.primaryColor,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.send,
                                color: Theme.of(context).indicatorColor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.showOptions.isTrue)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IbActionButton(
                          color: IbColors.errorRed,
                          iconData: Icons.mic,
                          onPressed: () {},
                          text: 'Voice'),
                      IbActionButton(
                          color: IbColors.primaryColor,
                          iconData: Icons.image,
                          onPressed: () {},
                          text: 'Images'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 40, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                  color: IbColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.black, fontSize: IbConfig.kNormalTextSize),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _item(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 40, left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IbUserAvatar(
            avatarUrl: _controller.avatarUrl.value,
            radius: 16,
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: Container(
              decoration: const BoxDecoration(
                  color: IbColors.accentColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.black, fontSize: IbConfig.kNormalTextSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handleMessageType(IbMessage message) {
    //TODO
    return const SizedBox();
  }
}
