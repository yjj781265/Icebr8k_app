import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

class EditProfileController extends GetxController {
  final birthdatePickerInstructionKey = ''.obs;
  final birthdateInMs = 0.obs;
  final readableBirthdate = ''.obs;
  final username = ''.obs;
  final isUsernameValid = false.obs;
  final isUsernameFirstTime = true.obs;
  final usernameErrorTrKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    username.value = Get.find<HomeController>().currentIbUsername.value;
  }

  Future<void> validateUsername() async {
    final bool isValid =
        GetUtils.isUsername(username.value.trim().toLowerCase());
    isUsernameFirstTime.value = false;

    if (username.value.trim().toLowerCase() ==
        Get.find<HomeController>().currentIbUsername.value) {
      usernameErrorTrKey.value = '';
      isUsernameValid.value = true;
      return;
    }

    if (username.value.isEmpty) {
      usernameErrorTrKey.value = 'field_is_empty';
      isUsernameValid.value = false;
      return;
    }

    if (username.value.length < IbConfig.kUsernameMinLength) {
      usernameErrorTrKey.value = '3_characters_error';
      isUsernameValid.value = false;
      return;
    }

    if (!isValid) {
      usernameErrorTrKey.value = "username_not_valid";
      isUsernameValid.value = false;
      return;
    }

    if (await IbUserDbService().isUsernameTaken(username.value)) {
      usernameErrorTrKey.value = 'username_exist_error';
      isUsernameValid.value = false;
      return;
    }

    usernameErrorTrKey.value = '';
    isUsernameValid.value = true;
    return;
  }

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
    await validateUsername();
    if (isUsernameValid.isFalse) {
      Get.dialog(IbSimpleDialog(
        message: '$usernameErrorTrKey'.tr,
        positiveBtnTrKey: 'ok',
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(
      messageTrKey: 'updating',
    ));
    await IbUserDbService().updateIbUser(ibUser);
    Get.back(closeOverlays: true);
    IbUtils.showSimpleSnackBar(
        msg: 'Profile updated successfully',
        backgroundColor: IbColors.accentColor);
  }
}
