import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class CircleSettingsController extends GetxController {
  final TextEditingController titleTxtController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController welcomeMsgController = TextEditingController();
  final bool isAbleToEdit;
  final photoUrl = ''.obs;
  final photoInit = ''.obs;
  final invitees = <IbUser>[].obs;
  final isPublicCircle = true.obs;
  IbChat? ibChat;

  CircleSettingsController({this.ibChat, this.isAbleToEdit = true});

  @override
  void onInit() {
    super.onInit();
    titleTxtController.addListener(
      () {
        if (titleTxtController.text.trim().isNotEmpty) {
          photoInit.value = titleTxtController.text[0];
        } else {
          photoInit.value = '';
        }
      },
    );

    if (ibChat != null) {
      photoUrl.value = ibChat!.photoUrl;
      titleTxtController.text = ibChat!.name;
      descriptionController.text = ibChat!.description;
      welcomeMsgController.text = ibChat!.welcomeMsg;
      isPublicCircle.value = ibChat!.isPublicCircle;
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'CircleSettingsController', screenName: 'CircleSettings');
  }

  Future<void> onCreateCircle() async {
    if (titleTxtController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing info',
        subtitle: 'Circle needs a name',
        showNegativeBtn: false,
      ));
      return;
    }

    if (ibChat != null) {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'update'));
    } else {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'Creating a new circle'));
    }

    if (ibChat != null &&
        photoUrl.value != ibChat!.photoUrl &&
        !ibChat!.photoUrl.contains('.gif') &&
        ibChat!.photoUrl.contains('http')) {
      await IbStorageService().deleteFile(ibChat!.photoUrl);
    }

    if (!photoUrl.value.contains('http') && !photoUrl.value.contains('.gif')) {
      final String? url = await IbStorageService()
          .uploadAndRetrieveImgUrl(filePath: photoUrl.value);
      photoUrl.value = url ?? '';
    }

    try {
      ///edit circle
      if (ibChat != null) {
        final String circleUpdateInfo = _generateUpdateCircleString();
        ibChat!.name = titleTxtController.text.trim();
        ibChat!.photoUrl = photoUrl.value;
        ibChat!.description = descriptionController.text.trim();
        ibChat!.welcomeMsg = welcomeMsgController.text.trim();
        ibChat!.isPublicCircle = isPublicCircle.value;
        await IbChatDbService().addIbChat(ibChat!, isEdit: ibChat != null);
        if (circleUpdateInfo.isNotEmpty) {
          await IbChatDbService().uploadMessage(IbMessage(
              messageId: IbUtils().getUniqueId(),
              readUids: [IbUtils().getCurrentUid()!],
              content:
                  '${IbUtils().getCurrentIbUser()!.username} updated following circle info $circleUpdateInfo',
              messageType: IbMessage.kMessageTypeAnnouncement,
              senderUid: IbUtils().getCurrentUid()!,
              chatRoomId: ibChat!.chatId));
        }

        Get.back(closeOverlays: true);
        IbUtils().showSimpleSnackBar(
            msg: 'Circle info updated', backgroundColor: IbColors.accentColor);

        ///create new circle
      } else {
        final IbChat ibChat2 = IbChat(
            chatId: IbUtils().getUniqueId(),
            photoUrl: photoUrl.value,
            name: titleTxtController.text.trim(),
            description: descriptionController.text.trim(),
            isCircle: true,
            isPublicCircle: isPublicCircle.value,
            welcomeMsg: welcomeMsgController.text.trim());

        await IbChatDbService().addIbChat(ibChat2);
        await IbChatDbService().addChatMember(
          member: IbChatMember(
              chatId: ibChat2.chatId,
              uid: IbUtils().getCurrentUid()!,
              role: IbChatMember.kRoleLeader),
        );
        for (final IbUser user in invitees) {
          final n = IbNotification(
              id: IbUtils().getUniqueId(),
              body: '',
              type: IbNotification.kCircleInvite,
              timestamp: FieldValue.serverTimestamp(),
              senderId: IbUtils().getCurrentUid()!,
              recipientId: user.id,
              url: ibChat2.chatId);
          final bool isSent = await IbUserDbService()
              .isCircleInviteSent(chatId: ibChat2.chatId, recipientId: user.id);
          if (isSent) {
            print('invite already sent');
            continue;
          }
          await IbUserDbService().sendAlertNotification(n);
        }
        Get.back(closeOverlays: true);
        IbUtils().showSimpleSnackBar(
            msg: 'Circle created', backgroundColor: IbColors.accentColor);
      }
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }

  String _generateUpdateCircleString() {
    String str = '';
    if (ibChat == null) {
      return str;
    }

    if (ibChat!.name != titleTxtController.text.trim()) {
      str = '$str\n - Circle Name';
    }
    if (ibChat!.photoUrl != photoUrl.value) {
      str = '$str\n - Circle Avatar';
    }

    if (ibChat!.description != descriptionController.text.trim()) {
      str = '$str\n - Circle Description';
    }

    if (ibChat!.welcomeMsg != welcomeMsgController.text.trim()) {
      str = '$str\n - Circle Welcome Message';
    }

    if (ibChat!.isPublicCircle != isPublicCircle.value) {
      str = '$str\n - Circle Privacy';
    }
    return str;
  }
}
