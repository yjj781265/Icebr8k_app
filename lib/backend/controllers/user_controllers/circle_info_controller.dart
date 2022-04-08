import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class CircleInfoController extends GetxController {
  final IbChat ibChat;
  final memberScoreMap = <IbUser, double>{}.obs;
  final isLoading = true.obs;

  CircleInfoController(this.ibChat);

  @override
  Future<void> onInit() async {
    super.onInit();
    await initMemberMap();
  }

  Future<void> initMemberMap() async {
    final first16Uids = ibChat.memberUids.take(16);
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
      final chat = await IbChatDbService().queryChat(ibChat.chatId);
      if (chat != null &&
          chat.memberUids.contains(
            IbUtils.getCurrentUid(),
          )) {
        Get.back(closeOverlays: true);
        Get.to(() => ChatPage(Get.put(ChatPageController(ibChat: ibChat))));
      } else {
        await IbChatDbService().addChatMember(
            member: IbChatMember(
                chatId: ibChat.chatId,
                uid: IbUtils.getCurrentUid()!,
                role: IbChatMember.kRoleMember));
        await IbChatDbService().uploadMessage(IbMessage(
            messageId: IbUtils.getUniqueId(),
            content:
                '${IbUtils.getCurrentIbUser()!.username} joined the circle',
            senderUid: IbUtils.getCurrentUid()!,
            messageType: IbMessage.kMessageTypeAnnouncement,
            chatRoomId: chat!.chatId));
        Get.back(closeOverlays: true);
        Get.to(() => ChatPage(Get.put(ChatPageController(ibChat: ibChat))));
      }
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(title: "Error", subtitle: e.toString()));
    }
  }
}
