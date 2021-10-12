import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
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
  String? chatRoomId;
  final isSending = false.obs;
  bool isInit = true;
  final isInChat = true.obs;
  late bool isGroupChat;
  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();
  DocumentSnapshot<Map<String, dynamic>>? lastDocumentSnapshot;

  ChatPageController(this.memberUids, {this.chatRoomId});

  @override
  Future<void> onInit() async {
    isInit = true;
    scrollController.addListener(() {
      IbUtils.hideKeyboard();
    });
    await initUserMap();
    isGroupChat = memberUids.length > 2;
    if (chatRoomId != null) {
      _handleChatMessages();
    }
    super.onInit();
  }

  Future<void> _handleChatMessages() async {
    _messageSub = IbChatDbService()
        .listenToMessageChanges(chatRoomId!)
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

      if (messages.length > 1) {
        messages.sort((a, b) {
          if (b.message.timestamp == null || a.message.timestamp == null) {
            return 0;
          }
          return (b.message.timestamp as Timestamp)
              .compareTo(a.message.timestamp as Timestamp);
        });
      }
    });
  }

  Future<void> updateReadUidArray() async {
    if (messages.isEmpty || isInChat.isFalse) {
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
    chatRoomId ??= await IbChatDbService().getChatRoomId(memberUids);
    final IbMessage ibMessage = IbMessage(
        messageId: IbUtils.getUniqueName(),
        content: text.trim(),
        readUids: [mUid],
        timestamp: FieldValue.serverTimestamp(),
        senderUid: mUid,
        messageType: IbMessage.kMessageTypeText,
        chatRoomId: chatRoomId!);

    if (messages.isEmpty) {
      await IbChatDbService().uploadMessage(ibMessage, memberUids: memberUids);
      _handleChatMessages();
    } else {
      await IbChatDbService().uploadMessage(ibMessage);
    }
    isSending.value = false;

    await _handleNotificationDelivery(ibMessage);
  }

  Future<void> _handleNotificationDelivery(IbMessage ibMessage) async {
    memberUids.remove(IbUtils.getCurrentUid());
    if (memberUids.isNotEmpty) {
      final List<String> tokens = [];

      for (final uid in memberUids) {
        final token = await IbUserDbService().retrieveTokenFromDatabase(uid);
        tokens.addIf(token != null, token!);
      }

      if (tokens.isEmpty) {
        return;
      }

      await IbCloudMessagingService().sendNotification(
          tokens: tokens,
          chatRoomId: chatRoomId,
          title: IbUtils.getCurrentIbUser()!.username,
          body: ibMessage.content,
          type: IbCloudMessagingService.kNotificationTypeChat);
    }
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
          chatRoomId: chatRoomId!, snapshot: lastDocumentSnapshot!);
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
    print('setInChat');
    isInChat.value = true;
    await IbChatDbService().updateInChatUidArray(
        chatRoomId: chatRoomId!, uids: [IbUtils.getCurrentUid()!]);
    await updateReadUidArray();
  }

  Future<void> setOffChat() async {
    if (messages.isEmpty) {
      return;
    }
    print('setOffChat');
    isInChat.value = false;
    await IbChatDbService().removeInChatUidArray(
        chatRoomId: chatRoomId!, uids: [IbUtils.getCurrentUid()!]);
  }

  @override
  void onClose() {
    setOffChat();
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
