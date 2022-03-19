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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatPageController extends GetxController {
  IbChat? ibChat;
  final String recipientId;
  final isLoading = true.obs;
  final showOptions = false.obs;
  final messages = <String>[
    'chid',
    'afdas;fjda;slfj',
    'dfahlkfasfjdl;asjf;as',
    'fdafasf',
    'Hello there',
    "Hello Rae",
    "Hello Jay",
    "I love ramen :)"
  ].obs;
  final avatarUrl = ''.obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  late StreamSubscription _messageSub;
  final isSending = false.obs;
  bool isInit = true;
  final isInChat = true.obs;
  final isGroupChat = false.obs;
  DocumentSnapshot<Map<String, dynamic>>? lastDocumentSnapshot;
  final txtController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  ChatPageController({this.ibChat, this.recipientId = ''});

  @override
  Future<void> onInit() async {
    await initData();
    super.onInit();
  }

  @override
  void onReady() {}

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

    isLoading.value = false;
  }

  Future<void> sendMessage(IbMessage ibMessage) async {}
}
