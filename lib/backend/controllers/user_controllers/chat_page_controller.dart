import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatPageController extends GetxController {
  IbChat? ibChat;
  final String recipientId;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isCircle = false.obs;
  final showOptions = false.obs;
  final messages = <IbMessage>[].obs;
  final avatarUrl = ''.obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  late StreamSubscription _messageSub;
  late StreamSubscription _memberSub;
  late StreamSubscription _chatSub;
  final isSending = false.obs;
  final isMuted = false.obs;
  final int kQueryLimit = 16;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  final txtController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final RefreshController refreshController = RefreshController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ibChatMembers = <IbChatMemberModel>[].obs;

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
    _memberSub.cancel();
    _chatSub.cancel();
  }

  Future<void> initData() async {
    if (ibChat == null && recipientId.isEmpty) {
      return;
    }

    if (recipientId.isNotEmpty && ibChat == null) {
      ibChat = await IbChatDbService().queryOneToOneIbChat(recipientId);
    }

    print('ChatPageController looking for IbChat');
    if (ibChat == null) {
      try {
        print('ChatPageController creating new IbChat');
        final List<String> sortedArr = [IbUtils.getCurrentUid()!, recipientId];
        sortedArr.sort();
        ibChat = IbChat(chatId: IbUtils.getUniqueId(), memberUids: sortedArr);
        await IbChatDbService().addIbChat(ibChat!);
        await IbChatDbService().addChatMember(
            member: IbChatMember(
                chatId: ibChat!.chatId,
                uid: IbUtils.getCurrentUid()!,
                role: IbChatMember.kRoleLeader));
        await IbChatDbService().addChatMember(
            member: IbChatMember(
                chatId: ibChat!.chatId,
                uid: recipientId,
                role: IbChatMember.kRoleMember));
      } catch (e) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to create chat room $e',
            backgroundColor: IbColors.errorRed);
      }
    }

    isMuted.value = ibChat!.mutedUids.contains(IbUtils.getCurrentUid());
    isCircle.value = ibChat!.isCircle;

    if (ibChat != null) {
      title.value = ibChat!.name;
      avatarUrl.value = ibChat!.photoUrl;
    }

    ///loading messages from stream
    _messageSub = IbChatDbService()
        .listenToMessageChanges(ibChat!.chatId)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbMessage ibMessage = IbMessage.fromJson(docChange.doc.data()!);
        print('ChatPageController ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          messages.insert(0, ibMessage);
        } else if (docChange.type == DocumentChangeType.modified) {
          final int index = messages.indexOf(ibMessage);
          if (index != -1) {
            messages[index] = ibMessage;
          }
        } else {}
      }

      if (event.docs.isNotEmpty) {
        lastSnap = event.docs.first;
      }

      /// update readUids
      if (messages.isNotEmpty &&
          messages.first.senderUid != IbUtils.getCurrentUid() &&
          !messages.first.readUids.contains(IbUtils.getCurrentUid())) {
        final IbMessage lastMessage = messages.first;
        await IbChatDbService().updateReadUidArray(
            chatRoomId: ibChat!.chatId, messageId: lastMessage.messageId);
      }
    });

    _memberSub = IbChatDbService()
        .listenToIbMemberChanges(ibChat!.chatId)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbChatMember ibChatMember =
            IbChatMember.fromJson(docChange.doc.data()!);
        print('chat page controller member ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          IbUser? ibUser;
          if (IbCacheManager().getIbUser(ibChatMember.uid) == null) {
            ibUser = await IbUserDbService().queryIbUser(ibChatMember.uid);
          } else {
            ibUser = IbCacheManager().getIbUser(ibChatMember.uid);
          }

          if (ibUser != null) {
            ibChatMembers
                .add(IbChatMemberModel(member: ibChatMember, user: ibUser));
          }
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = ibChatMembers
              .indexWhere((element) => element.member.uid == ibChatMember.uid);
          if (index != -1) {
            ibChatMembers[index].member = ibChatMember;
            ibChatMembers.refresh();
          }
        } else {
          final index = ibChatMembers
              .indexWhere((element) => element.member.uid == ibChatMember.uid);
          if (index != -1) {
            ibChatMembers.removeAt(index);
            ibChatMembers.refresh();
          }
        }
      }
      ibChatMembers.sort((a, b) {
        return a.member.role.compareTo(b.member.role);
      });
    });

    _chatSub =
        IbChatDbService().listenToIbChatChanges(ibChat!.chatId).listen((event) {
      if (event.data() != null) ibChat = IbChat.fromJson(event.data()!);

      /// only update if is group chat
      if (ibChat!.memberCount > 2) {
        title.value = ibChat!.name;
        avatarUrl.value = ibChat!.photoUrl;
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

  Future<void> muteNotification() async {
    isMuted.value = true;
    await IbChatDbService().muteNotification(ibChat!);
    IbUtils.showSimpleSnackBar(
        msg: "Notification OFF", backgroundColor: IbColors.primaryColor);
  }

  Future<void> unMuteNotification() async {
    isMuted.value = false;
    await IbChatDbService().unMuteNotification(ibChat!);
    IbUtils.showSimpleSnackBar(
        msg: "Notification ON", backgroundColor: IbColors.primaryColor);
  }

  IbMessage buildMessage() {
    return IbMessage(
        messageId: IbUtils.getUniqueId(),
        content: txtController.text.trim(),
        senderUid: IbUtils.getCurrentUid()!,
        readUids: [IbUtils.getCurrentUid()!],
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

class IbChatMemberModel {
  IbChatMember member;
  IbUser user;

  IbChatMemberModel({required this.member, required this.user});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbChatMemberModel &&
          runtimeType == other.runtimeType &&
          member == other.member;

  @override
  int get hashCode => member.hashCode;
}
