import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SetUpController extends GetxController {
  late LiquidController liquidController;
  final isUsernameValid = false.obs;
  final username = ''.obs;
  final name = ''.obs;
  final isUsernameFirstTime = true.obs;
  final isNameFirstTime = true.obs;
  final isNameValid = false.obs;
  final nameErrorTrKey = ''.obs;
  final usernameErrorTrKey = ''.obs;
  final avatarFilePath = ''.obs;
  final currentPage = 0.obs;
  final isKeyBoardVisible = false.obs;
  final _keyboardVisibilityController = KeyboardVisibilityController();

  @override
  void onInit() {
    super.onInit();
    // Subscribe to keyboard state changes
    _keyboardVisibilityController.onChange.listen((bool visible) {
      print('Keyboard visibility update. Is visible: $visible');
      isKeyBoardVisible.value = visible;
    });

    debounce(
      username,
      (_) => validateUsername(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );

    debounce(
      name,
      (_) => _validateName(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
  }

  Future<void> validateUsername() async {
    final bool isValid = GetUtils.isUsername(username.value.toLowerCase());
    isUsernameFirstTime.value = false;
    if (username.value.isEmpty) {
      usernameErrorTrKey.value = 'field_is_empty';
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

  void _validateName() {
    isNameFirstTime.value = false;
    isNameValid.value = name.value.isNotEmpty;
    print('validating name ${isNameValid.value}');

    if (name.value.isEmpty) {
      nameErrorTrKey.value = 'field_is_empty';
      return;
    }

    nameErrorTrKey.value = '';
  }

  bool _validateEverything() {
    if (isUsernameValid.isFalse && username.value.isEmpty) {
      Get.dialog(IbSimpleDialog(
        message: 'username_empty'.tr,
        positiveBtnTrKey: 'ok',
        actionButtons: [
          TextButton(
              onPressed: () {
                Get.back();
                liquidController.jumpToPage(page: 0);
              },
              child: Text('to_previous_page'.tr))
        ],
      ));
      return false;
    }
    if (isUsernameValid.isFalse) {
      Get.dialog(IbSimpleDialog(
        message: 'username_not_valid'.tr,
        positiveBtnTrKey: 'ok',
        actionButtons: [
          TextButton(
              onPressed: () {
                Get.back();
                liquidController.jumpToPage(page: 0);
              },
              child: Text('to_previous_page'.tr))
        ],
      ));
      return false;
    }

    if (avatarFilePath.value.isEmpty) {
      Get.dialog(IbSimpleDialog(
        message: 'avatar_empty'.tr,
        positiveBtnTrKey: 'ok',
      ));
      return false;
    }

    if (isNameValid.isFalse) {
      Get.dialog(
        IbSimpleDialog(
          message: 'nameErrorTrKey'.tr,
          positiveBtnTrKey: 'ok',
          actionButtons: [
            TextButton(
                onPressed: () {
                  Get.back();
                  liquidController.jumpToPage(page: 0);
                },
                child: Text('to_previous_page'.tr))
          ],
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> updateUsernameAndAvatarUrl(String _filePath) async {
    if (!_validateEverything()) {
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'),
        barrierDismissible: false);
    final String? avatarUrl =
        await IbStorageService().uploadAndRetrieveImgUrl(_filePath);
    if (avatarUrl == null) {
      Get.back();
      Get.dialog(
          IbSimpleDialog(message: 'fail_try_again'.tr, positiveBtnTrKey: 'ok'));
    } else {
      if (Get.find<AuthController>().firebaseUser != null) {
        try {
          await IbUserDbService().updateAvatarUrl(
              url: avatarUrl,
              uid: Get.find<AuthController>().firebaseUser!.uid);
          await IbUserDbService().updateUsername(
              username: username.value,
              uid: Get.find<AuthController>().firebaseUser!.uid);
          await IbUserDbService().updateName(
              name: name.value,
              uid: Get.find<AuthController>().firebaseUser!.uid);
        } on FirebaseException catch (e) {
          Get.back();
          Get.dialog(
              IbSimpleDialog(message: e.message!, positiveBtnTrKey: 'ok'));
        }
        Get.back();
        Get.offAll(() => HomePage());
      } else {
        Get.back();
        Get.dialog(const IbSimpleDialog(
            message: 'uid is not found, because user is signed out',
            positiveBtnTrKey: 'ok'));
        print('uid is not found, because user signed out');
      }
    }
  }
}
