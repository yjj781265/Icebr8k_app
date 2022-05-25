import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
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
  final requests = <IbNotification>[].obs;
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
    await initMemberScoreMap();
    hasInvite.value = await IbUserDbService().isCircleInviteSent(
        chatId: ibChat.chatId, recipientId: IbUtils.getCurrentUid() ?? '');
    requests.value =
        await IbUserDbService().isCircleRequestSent(chatId: ibChat.chatId);
    isLoading.value = false;
  }

  @override
  void onClose() {
    super.onClose();
    editingController.dispose();
  }

  Future<void> initMemberScoreMap() async {
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

      if (requests.isNotEmpty) {
        IbUtils.showSimpleSnackBar(
            msg: 'Request Sent', backgroundColor: IbColors.accentColor);
        return;
      }

      final list =
          await IbChatDbService().queryChatMembers(rxIbChat.value.chatId);

      for (final member in list) {
        if (member.role == IbChatMember.kRoleLeader ||
            member.role == IbChatMember.kRoleAssistant) {
          final IbNotification n = IbNotification(
              id: IbUtils.getUniqueId(),
              body: editingController.text,
              timestamp: FieldValue.serverTimestamp(),
              url: rxIbChat.value.chatId,
              type: IbNotification.kCircleRequest,
              senderId: IbUtils.getCurrentIbUser()!.id,
              recipientId: member.uid);
          await IbUserDbService().sendAlertNotification(n);
        }
      }

      requests.value = await IbUserDbService()
          .isCircleRequestSent(chatId: rxIbChat.value.chatId);

      IbUtils.showSimpleSnackBar(
          msg: 'Request Sent', backgroundColor: IbColors.accentColor);
    } catch (e) {
      Get.dialog(IbDialog(
        title: "Error",
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }

  Future<void> cancelCircleRequest() async {
    try {
      if (IbUtils.getCurrentIbUser() == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Request failed, can not find current Icebr8k user',
            backgroundColor: IbColors.errorRed);
        return;
      }

      if (requests.isNotEmpty) {
        for (final request in requests) {
          await IbUserDbService().removeNotification(request);
        }
      }
      IbUtils.showSimpleSnackBar(
          msg: 'Request Canceled', backgroundColor: IbColors.primaryColor);
    } catch (e) {
      Get.dialog(IbDialog(
        title: "Error",
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }
}
