import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
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
    }
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

    if (photoUrl.isNotEmpty && !photoUrl.contains('http')) {
      final String? url = await IbStorageService().uploadAndRetrieveImgUrl(
          filePath: photoUrl.value,
          oldUrl: ibChat == null ? '' : ibChat!.photoUrl);
      if (url == null) {
        Get.back();
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to upload image', backgroundColor: IbColors.errorRed);
        return;
      }
      photoUrl.value = url;
    }

    try {
      if (ibChat != null) {
        ibChat!.name = titleTxtController.text.trim();
        ibChat!.photoUrl = photoUrl.value;
        ibChat!.description = descriptionController.text.trim();
        ibChat!.welcomeMsg = welcomeMsgController.text.trim();
        ibChat!.isPublicCircle = isPublicCircle.value;
        await IbChatDbService().addIbChat(ibChat!, isEdit: ibChat != null);
      } else {
        final IbChat ibChat2 = IbChat(
            chatId: IbUtils.getUniqueId(),
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
              uid: IbUtils.getCurrentUid()!,
              role: IbChatMember.kRoleLeader),
        );
        for (final IbUser user in invitees) {
          final n = IbNotification(
              id: ibChat2.chatId,
              title:
                  'Group invite from ${IbUtils.getCurrentIbUser()!.username}',
              subtitle: '',
              type: IbNotification.kGroupInvite,
              timestampInMs: DateTime.now().millisecondsSinceEpoch,
              senderId: IbUtils.getCurrentUid()!,
              recipientId: user.id,
              avatarUrl: IbUtils.getCurrentIbUser()!.avatarUrl);
          await IbUserDbService().sendAlertNotification(n);
        }
      }

      Get.back(closeOverlays: true);
      if (ibChat != null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Circle info updated', backgroundColor: IbColors.accentColor);
      } else {
        IbUtils.showSimpleSnackBar(
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
}
