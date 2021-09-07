import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

class EditProfileController extends GetxController {
  final birthdatePickerInstructionKey = ''.obs;
  final birthdateInMs = 0.obs;
  final readableBirthdate = ''.obs;

  Future<void> updateAvatarUrl(String _filePath) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'uploading...'),
        barrierDismissible: false);

    final String? photoUrl =
        await IbStorageService().uploadAndRetrieveImgUrl(_filePath);

    if (photoUrl == null) {
      Get.back();
      return;
    }

    await IbUserDbService()
        .updateAvatarUrl(url: photoUrl, uid: IbUtils.getCurrentUid()!);
    Get.back();
  }

  Future<void> updateUserInfo(IbUser ibUser) async {
    Get.back();
    Get.dialog(
        IbSimpleDialog(message: 'updating'.tr, positiveBtnTrKey: 'ok'.tr));
    await IbUserDbService().updateIbUser(ibUser);
    Get.back();
  }
}
