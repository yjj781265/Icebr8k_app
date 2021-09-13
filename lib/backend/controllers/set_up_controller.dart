import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_quetions_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SetUpController extends GetxController {
  final LiquidController liquidController = LiquidController();
  final ibQuestions = <IbQuestion>[].obs;
  final answeredCounter = 0.obs;
  late StreamSubscription answeredQStream;
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

  @override
  Future<void> onInit() async {
    Get.lazyPut(() => MyAnsweredQuestionsController());
    ibQuestions.addAll(await IbQuestionDbService().queryIcebr8kQ());
    answeredQStream = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added &&
            ibQuestions.indexWhere(
                    (element) => element.id == ibAnswer.questionId) !=
                -1) {
          answeredCounter.value++;
        }
      }
    });
    super.onInit();
  }

  Future<void> validateScreenTwo() async {
    if (avatarFilePath.value.isEmpty) {
      Get.dialog(IbSimpleDialog(
        message: 'avatar_empty'.tr,
        positiveBtnTrKey: 'ok',
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'),
        barrierDismissible: false);
    final String? avatarUrl =
        await IbStorageService().uploadAndRetrieveImgUrl(avatarFilePath.value);
    if (Get.find<AuthController>().firebaseUser != null && avatarUrl != null) {
      try {
        await IbUserDbService().updateAvatarUrl(
            url: avatarUrl, uid: Get.find<AuthController>().firebaseUser!.uid);
      } on FirebaseException catch (e) {
        Get.back();
        Get.dialog(IbSimpleDialog(message: e.message!, positiveBtnTrKey: 'ok'));
      }
      Get.back();
      liquidController.animateToPage(page: 2);
    }
  }

  Future<void> validateScreenOne() async {
    await validateUsername();
    _validateName();

    if (isUsernameValid.isFalse) {
      Get.dialog(IbSimpleDialog(
        message: usernameErrorTrKey.value.tr,
        positiveBtnTrKey: 'ok',
      ));
      return;
    }

    if (isNameValid.isFalse) {
      Get.dialog(
        const IbSimpleDialog(
          message: 'name is empty',
          positiveBtnTrKey: 'ok',
        ),
      );
      return;
    }
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'),
        barrierDismissible: false);
    if (Get.find<AuthController>().firebaseUser != null) {
      try {
        await IbUserDbService().updateUsername(
            username: username.value.trim(),
            uid: Get.find<AuthController>().firebaseUser!.uid);
        await IbUserDbService().updateName(
            name: name.value,
            uid: Get.find<AuthController>().firebaseUser!.uid);
      } on FirebaseException catch (e) {
        Get.back();
        Get.dialog(IbSimpleDialog(message: e.message!, positiveBtnTrKey: 'ok'));
      }
      Get.back();
      liquidController.animateToPage(page: 1);
    }
  }

  Future<void> validateUsername() async {
    final bool isValid = GetUtils.isUsername(username.value.toLowerCase());
    isUsernameFirstTime.value = false;
    if (username.value.isEmpty) {
      usernameErrorTrKey.value = 'username is empty';
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

  void _validateName() {
    isNameFirstTime.value = false;
    isNameValid.value = name.value.isNotEmpty;

    if (name.value.isEmpty) {
      nameErrorTrKey.value = 'field_is_empty';
      return;
    }

    nameErrorTrKey.value = '';
  }

  Future<void> updateUsernameAndAvatarUrl(String _filePath) async {
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
        Get.offAll(() => HomePage(), binding: HomeBinding());
      } else {
        Get.back();
        Get.dialog(const IbSimpleDialog(
            message: 'uid is not found, because user is signed out',
            positiveBtnTrKey: 'ok'));
      }
    }
  }

  @override
  void onClose() {
    answeredQStream.cancel();
    super.onClose();
  }
}
