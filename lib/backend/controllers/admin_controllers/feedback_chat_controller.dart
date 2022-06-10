import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedbackChatController extends GetxController {
  final input = ''.obs;
  final bool isAdmin;
  final String chatId;
  final feedbacks = <IbMessage>[].obs;
  late StreamSubscription feedbackSub;
  TextEditingController textEditingController = TextEditingController();
  RefreshController refreshController = RefreshController();

  FeedbackChatController(this.chatId, {this.isAdmin = false});

  @override
  void onInit() {
    textEditingController.addListener(() {
      input.value = textEditingController.text.trim();
    });
    feedbackSub =
        IbAdminDbService().listenToSingleFeedbacks(chatId).listen((event) {
      if (event.data() == null) {
        return;
      }

      final list = event.data()!['feedbacks'] as List;
      final temp = <IbMessage>[].obs;
      for (final item in list) {
        final msg = IbMessage.fromJson(item as Map<String, dynamic>);
        if (feedbacks.contains(msg)) {
          continue;
        }
        temp.add(msg);
      }

      feedbacks.addAll(temp);
      feedbacks.sort((a, b) =>
          (b.timestamp as Timestamp).compareTo(a.timestamp as Timestamp));
    });

    super.onInit();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await feedbackSub.cancel();
  }

  Future<void> addFeedback() async {
    if (textEditingController.text.trim().isEmpty) {
      return;
    }
    final IbMessage message = IbMessage(
        messageId: IbUtils.getUniqueId(),
        content: textEditingController.text.trim(),
        senderUid: IbUtils.getCurrentUid()!,
        messageType: IbMessage.kMessageTypeText,
        chatRoomId: chatId,
        readUids: [IbUtils.getCurrentUid()!]);

    await IbAdminDbService().addFeedback(message);
    textEditingController.clear();
  }
}
