import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/feedback_chat_controller.dart';
import 'package:icebr8k/frontend/admin/feedback_chat_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_widgets/ib_card.dart';

class FeedBackChatList extends StatelessWidget {
  FeedBackChatList({Key? key}) : super(key: key);
  final AdminMainController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks'),
      ),
      body: Obx(() => ListView.builder(
            itemBuilder: (context, index) {
              final item = _controller.pendingFeedbacks[index];
              return IbCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: () {
                      Get.to(() => FeedBackChatPage(Get.put(
                          FeedbackChatController(item.user.id,
                              isAdmin: true))));
                    },
                    leading: IbUserAvatar(
                      avatarUrl: item.user.avatarUrl,
                    ),
                    title: Text(
                      item.user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item.lastMessage.content,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: IbConfig.kSecondaryTextSize),
                    ),
                    trailing: Text(
                      IbUtils().getChatTabDateString(
                        DateTime.fromMillisecondsSinceEpoch(
                            (item.lastMessage.timestamp as Timestamp)
                                .millisecondsSinceEpoch),
                      ),
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                  ),
                ),
              );
            },
            itemCount: _controller.pendingFeedbacks.length,
          )),
    );
  }
}
