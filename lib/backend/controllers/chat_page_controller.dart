import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class ChatPageController extends GetxController {
  final title = ''.obs;
  final subtitle = ''.obs;
  final List<String> memberUids;
  final messages = <ChatMessageItem>[].obs;
  final ibUserMap = <String, IbUser>{};
  late StreamSubscription _messageSub;
  late String chatRoomId;
  final isLoading = true.obs;
  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();

  ChatPageController(this.memberUids);

  @override
  Future<void> onInit() async {
    await initUserMap();
    isLoading.value = false;
    chatRoomId = await IbChatDbService().getChatRoomId(memberUids);
    _messageSub =
        IbChatDbService().listenToMessageChanges(chatRoomId).listen((event) {
      for (final docChange in event.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          print('added');
          final ChatMessageItem chatMessageItem =
              ChatMessageItem(IbMessage.fromJson(docChange.doc.data()!));

          if (!messages.contains(chatMessageItem)) {
            messages.insert(0, chatMessageItem);
            if (listKey.currentState != null) {
              listKey.currentState!.insertItem(0,
                  duration: const Duration(
                      milliseconds: IbConfig.kEventTriggerDelayInMillis));
              /*scrollController.animateTo(0,
                  duration: const Duration(
                      milliseconds: IbConfig.kEventTriggerDelayInMillis),
                  curve: Curves.bounceOut);*/
              scrollController.jumpTo(0);
            }
          }
        }

        if (docChange.type == DocumentChangeType.modified) {
          final ChatMessageItem chatMessageItem =
              ChatMessageItem(IbMessage.fromJson(docChange.doc.data()!));

          if (messages.contains(chatMessageItem)) {
            messages[messages.indexOf(chatMessageItem)] = chatMessageItem;
            print('modified');
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          print('removed');
        }
      }
    });
    super.onInit();
  }

  Future<void> uploadMessage(String text) async {
    final String mUid = Get.find<AuthController>().firebaseUser!.uid;
    final IbMessage ibMessage = IbMessage(
        messageId: IbUtils.getUniqueName(),
        content: text.trim(),
        readUids: [mUid],
        timestamp: FieldValue.serverTimestamp(),
        senderUid: mUid,
        messageType: IbMessage.kMessageTypeText,
        chatRoomId: chatRoomId);
    if (messages.isEmpty) {
      await IbChatDbService().uploadMessage(ibMessage, memberUids: memberUids);
      return;
    }
    await IbChatDbService().uploadMessage(ibMessage);
  }

  Future<void> initUserMap() async {
    for (final String uid in memberUids) {
      final IbUser? user = await IbUserDbService().queryIbUser(uid);
      final String mUid = Get.find<AuthController>().firebaseUser!.uid;
      if (user != null) {
        ibUserMap.putIfAbsent(uid, () => user);
      }

      if (user != null && user.id != mUid) {
        title.value = user.username;
      }
    }
  }

  @override
  void onClose() {
    _messageSub.cancel();
    super.onClose();
  }
}

class ChatMessageItem {
  final IbMessage message;

  ChatMessageItem(this.message) {
    _updateReadUidArray();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageItem &&
          runtimeType == other.runtimeType &&
          message.messageId == other.message.messageId;

  @override
  int get hashCode => message.hashCode;

  void _updateReadUidArray() {
    final String mUid = Get.find<AuthController>().firebaseUser!.uid;
    if (message.readUids.contains(mUid)) {
      return;
    }
    IbChatDbService().updateReadUidArray(
        chatRoomId: message.chatRoomId,
        messageId: message.messageId,
        uids: [mUid]);
    print('_updateReadUidArray');
  }
}
