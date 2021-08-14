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
  final isSending = false.obs;
  bool isInit = true;
  late bool isGroupChat;
  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();
  DocumentSnapshot<Map<String, dynamic>>? lastDocumentSnapshot;

  ChatPageController(this.memberUids);

  @override
  Future<void> onInit() async {
    isInit = true;
    scrollController.addListener(() {
      IbUtils.hideKeyboard();
    });
    await initUserMap();
    isGroupChat = memberUids.length > 2;
    chatRoomId = await IbChatDbService().getChatRoomId(memberUids);
    _messageSub = IbChatDbService()
        .listenToMessageChanges(chatRoomId)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final ChatMessageItem chatMessageItem = ChatMessageItem(
              message: IbMessage.fromJson(docChange.doc.data()!),
              controller: this);
          if (!messages.contains(chatMessageItem)) {
            messages.insert(0, chatMessageItem);
            print('message added');
            chatMessageItem.updateIndicator();
            if (listKey.currentState != null) {
              listKey.currentState!.insertItem(0);
              scrollController.jumpTo(0);
            }
          }
        }

        if (docChange.type == DocumentChangeType.modified) {
          final ChatMessageItem chatMessageItem = ChatMessageItem(
              message: IbMessage.fromJson(docChange.doc.data()!),
              controller: this);
          final index = messages.indexOf(chatMessageItem);

          if (messages.contains(chatMessageItem)) {
            messages[index] = chatMessageItem;
            chatMessageItem.updateIndicator();
            print('message modified');
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          print('removed');
        }
      }

      await updateReadUidArray();

      if (isInit && event.docs.isNotEmpty) {
        print('loading first ${event.docs.length} messages');
        lastDocumentSnapshot = event.docs.first;
        isInit = false;
        await setInChat();
      }
    });

    super.onInit();
  }

  Future<void> updateReadUidArray() async {
    if (messages.isEmpty) {
      return;
    }

    final IbMessage message = messages.first.message;
    if (message.readUids.contains(IbUtils.getCurrentUid())) {
      return;
    }

    await IbChatDbService().updateReadUidArray(
        chatRoomId: message.chatRoomId,
        messageId: message.messageId,
        uids: [IbUtils.getCurrentUid()!]);
    print('updateReadUidArray');
  }

  Future<void> uploadMessage(String text) async {
    isSending.value = true;
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
      isSending.value = false;
      return;
    }
    await IbChatDbService().uploadMessage(ibMessage);
    isSending.value = false;
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

  Future<void> loadMoreMessages() async {
    if (messages.length < IbConfig.kInitChatMessagesLoadSize) {
      return;
    }

    if (lastDocumentSnapshot != null) {
      final _snapshot = await IbChatDbService().queryMessages(
          chatRoomId: chatRoomId, snapshot: lastDocumentSnapshot!);
      if (_snapshot.docs.isEmpty) {
        lastDocumentSnapshot = null;
        return;
      }
      lastDocumentSnapshot = _snapshot.docs.last;
      print('loadMoreMessages');

      for (final doc in _snapshot.docs) {
        final ChatMessageItem chatMessageItem = ChatMessageItem(
            message: IbMessage.fromJson(doc.data()), controller: this);
        if (!messages.contains(chatMessageItem)) {
          final index = messages.length - 1;
          messages.add(chatMessageItem);
          if (listKey.currentState != null) {
            listKey.currentState!.insertItem(index);
          }
        }
      }
    }
  }

  Future<void> setInChat() async {
    if (messages.isEmpty) {
      return;
    }
    await IbChatDbService().updateInChatUidArray(
        chatRoomId: chatRoomId, uids: [IbUtils.getCurrentUid()!]);
  }

  Future<void> setOffChat() async {
    if (messages.isEmpty) {
      return;
    }
    await IbChatDbService().removeInChatUidArray(
        chatRoomId: chatRoomId, uids: [IbUtils.getCurrentUid()!]);
  }

  @override
  void onClose() {
    IbChatDbService().removeInChatUidArray(
        chatRoomId: chatRoomId, uids: [IbUtils.getCurrentUid()!]);
    _messageSub.cancel();
    super.onClose();
  }
}

class ChatMessageItem {
  final IbMessage message;
  late bool isMe;
  bool showReadIndicator = false;
  late String msgStatus;
  final String mUid = Get.find<AuthController>().firebaseUser!.uid;
  final ChatPageController controller;

  ChatMessageItem({required this.message, required this.controller}) {
    final String mUid = Get.find<AuthController>().firebaseUser!.uid;
    isMe = message.senderUid == mUid;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageItem &&
          runtimeType == other.runtimeType &&
          message.messageId == other.message.messageId;

  @override
  int get hashCode => message.hashCode;

  void updateIndicator() {
    final List<String> tempArr = [];
    tempArr.addAll(message.readUids);
    tempArr.remove(mUid);

    if (isMe && controller.messages.indexOf(this) == 0) {
      showReadIndicator = tempArr.isNotEmpty;
    } else {
      showReadIndicator = false;
    }

    if (showReadIndicator ||
        (!isMe && controller.messages.indexOf(this) == 0)) {
      //remove all the old ones
      for (int i = 1; i < controller.messages.length; i++) {
        controller.messages[i].showReadIndicator = false;
      }
    }
  }
}
