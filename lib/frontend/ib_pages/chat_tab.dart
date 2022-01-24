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
  final ChatTabController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.isTrue) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.chatTabItems.isEmpty) {
        return Center(
          child: SizedBox(
              width: 230,
              height: 230,
              child: Lottie.asset('assets/images/business_chat.json')),
        );
      }

      return ListView.builder(
        itemBuilder: (context, index) {
          final ChatTabItem item = _controller.chatTabItems[index];
          return Material(
            color: Theme.of(context).primaryColor,
            child: InkWell(
              onTap: () {
                Get.to(() => ChatPage(Get.put(
                    ChatPageController(item.memberUids,
                        chatRoomId: item.chatRoomId),
                    tag: item.chatRoomId)));
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IbUserAvatar(
                      avatarUrl: item.ibUser!.avatarUrl,
                      uid: item.ibUser!.id,
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
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (item.ibMessage.timestamp != null)
                            Text(
                              IbUtils.getChatTabDateString(
                                  (item.ibMessage.timestamp as Timestamp)
                                      .toDate()),
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: _controller.chatTabItems.length,
      );
    });
  }
}
