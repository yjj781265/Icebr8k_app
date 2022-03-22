import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatPageController extends GetxController {
  IbChat? ibChat;
  final String recipientId;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final showOptions = false.obs;
  final messages = <IbMessage>[].obs;
  final avatarUrl = ''.obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  late StreamSubscription _messageSub;
  final isSending = false.obs;
  final isInChat = true.obs;
  final isGroupChat = false.obs;
  final int kQueryLimit = 16;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  final txtController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final RefreshController refreshController = RefreshController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  ChatPageController({this.ibChat, this.recipientId = ''});
  final IbMessage loadMessage = IbMessage(
      messageId: '',
      content: 'content',
      senderUid: '',
      messageType: IbMessage.kMessageTypeLoadMore,
      chatRoomId: '');

  @override
  Future<void> onInit() async {
    await initData();
    super.onInit();
  }

  @override
  void onReady() {}

  @override
  void onClose() {
    _messageSub.cancel();
  }

  Future<void> initData() async {
    if (ibChat == null && recipientId.isEmpty) {
      return;
    }
    ibChat = await IbChatDbService().queryOneToOneIbChat(recipientId);
    print('ChatPageController looking for IbChat');
    if (ibChat == null) {
      try {
        print('ChatPageController creating new IbChat');
        ibChat = IbChat(
            chatId: IbUtils.getUniqueId(),
            name: title.value,
            photoUrl: avatarUrl.value);
        await IbChatDbService().addIbChat(ibChat!);
        await IbChatDbService().addMember(
            chatId: ibChat!.chatId,
            member: IbChatMember(
                IbUtils.getCurrentUid()!, IbChatMember.kRoleLeader));
        await IbChatDbService().addMember(
            chatId: ibChat!.chatId,
            member: IbChatMember(recipientId, IbChatMember.kRoleMember));
      } catch (e) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to create chat room $e',
            backgroundColor: IbColors.errorRed);
      }
    }

    isGroupChat.value = ibChat!.memberCount > 2;

    ///loading messages from stream
    _messageSub = IbChatDbService()
        .listenToMessageChanges(ibChat!.chatId)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbMessage ibMessage = IbMessage.fromJson(docChange.doc.data()!);
        print('chat page controller ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          messages.insert(0, ibMessage);
        } else if (docChange.type == DocumentChangeType.modified) {
        } else {}
      }

      if (event.docs.isNotEmpty) {
        lastSnap = event.docs.first;
      }
    });

    isLoading.value = false;
  }

  Future<void> sendMessage() async {
    isSending.value = true;
    try {
      if (txtController.text.trim().isNotEmpty) {
        await IbChatDbService().uploadMessage(buildMessage());
        txtController.clear();
      }
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to send message $e", backgroundColor: IbColors.errorRed);
    } finally {
      isSending.value = false;
    }
  }

  IbMessage buildMessage() {
    return IbMessage(
        messageId: IbUtils.getUniqueId(),
        content: txtController.text.trim(),
        senderUid: IbUtils.getCurrentUid()!,
        messageType: IbMessage.kMessageTypeText,
        chatRoomId: ibChat!.chatId);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.isTrue || lastSnap == null) {
      return;
    }
    if (lastSnap != null) {
      isLoadingMore.value = true;
      messages.add(loadMessage);
      final snapshot = await Future.delayed(
          const Duration(milliseconds: 1000),
          () => IbChatDbService().queryMessages(
              chatRoomId: ibChat!.chatId,
              snapshot: lastSnap!,
              limit: kQueryLimit));

      final List<IbMessage> tempList = [];

      for (final doc in snapshot.docs) {
        tempList.add(IbMessage.fromJson(doc.data()));
      }
      messages.remove(loadMessage);
      messages.addAll(tempList);

      lastSnap = tempList.length >= kQueryLimit ? snapshot.docs.last : null;
    }
    isLoadingMore.value = false;
  }
}
