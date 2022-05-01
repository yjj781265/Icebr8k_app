import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_circle_join_request.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class CircleInfoController extends GetxController {
  final Rx<IbChat> rxIbChat;
  final hasInvite = false.obs;
  final memberScoreMap = <IbUser, double>{}.obs;
  final isLoading = true.obs;
  final TextEditingController editingController = TextEditingController();

  CircleInfoController(this.rxIbChat);

  @override
  Future<void> onInit() async {
    super.onInit();
    final ibChat = await IbChatDbService().queryChat(rxIbChat.value.chatId);
    if (ibChat == null) {
      return;
    }
    rxIbChat.value = ibChat;
    await initMemberMap();
    hasInvite.value = await IbUserDbService().isCircleInviteSent(
        chatId: ibChat.chatId, recipientId: IbUtils.getCurrentUid() ?? '');
  }

  @override
  void onClose() {
    super.onClose();
    editingController.dispose();
  }

  Future<void> initMemberMap() async {
    final first16Uids = rxIbChat.value.memberUids.take(16);
    for (final String uid in first16Uids) {
      final IbUser? user;
      if (IbCacheManager().getIbUser(uid) == null) {
        user = await IbUserDbService().queryIbUser(uid);
      } else {
        user = IbCacheManager().getIbUser(uid);
      }

      if (user != null) {
        final double compScore = await IbUtils.getCompScore(uid: user.id);
        memberScoreMap[user] = compScore;
      }
    }

    isLoading.value = false;
  }

  Future<void> joinCircle() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'Joining...'));

    try {
      final chat = await IbChatDbService().queryChat(rxIbChat.value.chatId);
      if (chat != null &&
          chat.memberUids.contains(
            IbUtils.getCurrentUid(),
          )) {
        Get.back(closeOverlays: true);
        Get.to(() =>
            ChatPage(Get.put(ChatPageController(ibChat: rxIbChat.value))));
      } else {
        await IbChatDbService().addChatMember(
            member: IbChatMember(
                chatId: rxIbChat.value.chatId,
                uid: IbUtils.getCurrentUid()!,
                role: IbChatMember.kRoleMember));
        await IbChatDbService().uploadMessage(IbMessage(
            messageId: IbUtils.getUniqueId(),
            content:
                '${IbUtils.getCurrentIbUser()!.username} joined the circle',
            senderUid: IbUtils.getCurrentUid()!,
            readUids: [IbUtils.getCurrentUid()!],
            messageType: IbMessage.kMessageTypeAnnouncement,
            chatRoomId: chat!.chatId));
        Get.back(closeOverlays: true);
        Get.to(() =>
            ChatPage(Get.put(ChatPageController(ibChat: rxIbChat.value))));
      }
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(title: "Error", subtitle: e.toString()));
    }
  }

  Future<void> sendJoinCircleRequest() async {
    try {
      if (IbUtils.getCurrentIbUser() == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Request failed, can not find current Icebr8k user',
            backgroundColor: IbColors.errorRed);
        return;
      }

      final request = IbCircleJoinRequest(
          id: IbUtils.getUniqueId(),
          timestamp: Timestamp.now(),
          text: editingController.text.trim(),
          uid: IbUtils.getCurrentUid()!,
          title:
              '${IbUtils.getCurrentIbUser()?.username} requests to join the circle',
          avatarUrl: IbUtils.getCurrentIbUser()!.avatarUrl);
      await IbChatDbService()
          .updateCircleRequest(chat: rxIbChat.value, request: request);
      IbUtils.showSimpleSnackBar(
          msg: 'Request Sent', backgroundColor: IbColors.accentColor);
    } catch (e) {
      print(e);
      Get.dialog(IbDialog(
        title: "Error",
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }
}
