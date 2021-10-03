import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_pages/screen_one.dart';
import 'package:icebr8k/frontend/ib_pages/screen_three.dart';
import 'package:icebr8k/frontend/ib_pages/screen_two.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class SetUpController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AutoScrollController autoScrollController = AutoScrollController();
  final pages = <Widget>[].obs;
  final ibQuestions = <IbQuestion>[].obs;
  final answeredCounter = 0.obs;
  final isUsernameValid = false.obs;
  final username = ''.obs;
  final name = ''.obs;
  final isUsernameFirstTime = true.obs;
  final isNameFirstTime = true.obs;
  final isNameValid = false.obs;
  final nameErrorTrKey = ''.obs;
  final usernameErrorTrKey = ''.obs;
  final avatarFilePath = ''.obs;
  final currentPageIndex = 0.obs;
  final totalPageSize = 0.obs;
  final isLoading = true.obs;
  late StreamSubscription myAnsweredQStream;

  @override
  Future<void> onInit() async {
    final bool isUserNameMissing =
        await IbUserDbService().isUsernameMissing(IbUtils.getCurrentUid()!);
    final bool isAvatarUrlMissing =
        await IbUserDbService().isAvatarUrlMissing(IbUtils.getCurrentUid()!);
    ibQuestions.value = await IbUserDbService()
        .queryUnAnsweredFirst8Q(IbUtils.getCurrentUid()!);

    if (isUserNameMissing) {
      pages.add(ScreenOne());
    }

    if (isAvatarUrlMissing) {
      pages.add(ScreenTwo());
    }

    if (ibQuestions.isNotEmpty) {
      pages.add(ScreenThree());
    }

    totalPageSize.value = pages.length;

    myAnsweredQStream = Get.find<MyAnsweredQuestionsController>()
        .broadcastStream
        .listen((event) {
      _handleSetupPageScreenThree(event);
    });

    isLoading.value = false;

    print("SetUpController: init ");
    super.onInit();
  }

  void _handleSetupPageScreenThree(
      final QuerySnapshot<Map<String, dynamic>> event) {
    if (!Get.isRegistered<SetUpController>()) {
      return;
    }
    for (final docChange in event.docChanges) {
      final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
      if (docChange.type == DocumentChangeType.added &&
          ibQuestions
                  .indexWhere((element) => element.id == ibAnswer.questionId) !=
              -1) {
        answeredCounter.value = answeredCounter.value + 1;
        print(
            'updating SetUpController answeredCounter to ${answeredCounter.value}');
      }
    }
  }

  @override
  void onClose() {
    print("SetUpController: close ");
    myAnsweredQStream.cancel();
    super.onClose();
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
      handlePageTransition();
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
      handlePageTransition();
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

  void handlePageTransition() {
    if (totalPageSize.value == (currentPageIndex.value + 1)) {
      Get.offAll(() => HomePage(), binding: HomeBinding());
    } else {
      autoScrollController.scrollToIndex(currentPageIndex.value + 1);
      currentPageIndex.value = currentPageIndex.value + 1;
    }
    return;
  }
}
