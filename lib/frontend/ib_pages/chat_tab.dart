import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/chat_tab_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';

class ChatTab extends StatelessWidget {
  ChatTab({Key? key}) : super(key: key);
  final _controller = Get.find<ChatTabController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.isTrue) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.chatTabItems.isEmpty) {
        return Container(
          color: IbColors.lightBlue,
          child: Center(
            child: SizedBox(
                width: 230,
                height: 230,
                child: Lottie.asset('assets/images/business_chat.json')),
          ),
        );
      }

      return Material(
        color: IbColors.lightBlue,
        child: ListView.builder(
          itemBuilder: (context, index) {
            final ChatTabItem item = _controller.chatTabItems[index];
            return Material(
              child: InkWell(
                onTap: () {
                  Get.to(() => ChatPage(Get.put(
                      ChatPageController(item.memberUids),
                      tag: item.chatRoomId)));
                },
                child: buildItem(item),
              ),
            );
          },
          itemCount: _controller.chatTabItems.length,
        ),
      );
    });
  }

  Widget buildItem(ChatTabItem item) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(item.chatRoomId),
      confirmDismiss: (direction) {
        return Get.defaultDialog<bool>(
            middleText: '',
            titleStyle: const TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: FontWeight.bold),
            confirmTextColor: IbColors.primaryColor,
            cancelTextColor: IbColors.errorRed,
            buttonColor: Colors.transparent,
            title: 'Are you sure to delete chat with ${item.title}',
            onConfirm: () {
              _controller.removeChatItem(item);
              Get.back(result: true);
            },
            onCancel: () => Get.back(result: false));
      },
      background: Container(
        color: IbColors.errorRed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: const [
                Text(
                  'Delete Chat',
                  style: TextStyle(
                      color: IbColors.white, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.delete_forever_outlined,
                    color: IbColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      child: Container(
        color: IbColors.white,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IbUserAvatar(
                  avatarUrl: item.ibUser!.avatarUrl,
                  uid: item.ibUser!.id,
                  radius: 32,
                ),
              ),
            ),
            Expanded(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: IbConfig.kNormalTextSize),
                      ),
                      Text(item.ibMessage.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: IbConfig.kSecondaryTextSize)),
                    ],
                  ),
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.ibMessage.timestamp != null)
                        Text(
                          IbUtils.getChatDateTimeString(
                              (item.ibMessage.timestamp as Timestamp).toDate()),
                          style: const TextStyle(
                              color: IbColors.lightGrey,
                              fontSize: IbConfig.kDescriptionTextSize),
                        ),
                      if (item.unReadCount == 0)
                        const SizedBox(
                          width: 16,
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: IbColors.errorRed,
                            radius: 11,
                            child: Text(
                              item.unReadCount >= 99
                                  ? '99+'
                                  : item.unReadCount.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: IbColors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
