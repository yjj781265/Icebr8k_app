import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_pages/review_page.dart';
import 'package:icebr8k/frontend/ib_pages/setup_pages/setup_page_three.dart';
import 'package:icebr8k/frontend/ib_pages/setup_pages/setup_page_two.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import '../services/user_services/ib_storage_service.dart';
import '../services/user_services/ib_user_db_service.dart';

class SetupController extends GetxController {
  final TextEditingController birthdateTeController = TextEditingController();
  final TextEditingController fNameTeController = TextEditingController();
  final TextEditingController lNameTeController = TextEditingController();
  final TextEditingController usernameTeController = TextEditingController();
  final TextEditingController bioTeController = TextEditingController();
  final gender = ''.obs;
  final genderSelections = [false, false, false].obs;
  final birthdateInMs = DateTime.now().millisecondsSinceEpoch.obs;
  final emoPics = <IbEmoPic>[].obs;
  final avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emoPics.add(IbEmoPic(
        url: '', emoji: "😃", id: IbUtils.getUniqueId(), description: "Happy"));
    emoPics.add(
      IbEmoPic(
          url: '', emoji: "☹", id: IbUtils.getUniqueId(), description: "Sad"),
    );
    emoPics.add(IbEmoPic(
        url: '', emoji: "😱", id: IbUtils.getUniqueId(), description: 'Wow'));
  }

  void updateEmoPic(IbEmoPic emoPic) {
    if (!emoPics.contains(emoPic)) {
      return;
    }

    emoPics[emoPics.indexOf(emoPic)] = emoPic;
    emoPics.refresh();
  }

  void onGenderSelect(int index) {
    for (int i = 0; i < genderSelections.length; i++) {
      if (i == index) {
        continue;
      }
      genderSelections[i] = false;
    }
    genderSelections[index] = !genderSelections[index];
    if (genderSelections[index]) {
      gender.value = IbUser.kGenders[index];
    } else {
      gender.value = '';
    }
  }

  void validatePageOne() {
    if (fNameTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "First name is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (birthdateTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Birthdate is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (gender.value.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Gender is not picked",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    print('Setup Page One is valid!');
    Get.to(() => SetupPageTwo(this));
  }

  Future<void> validatePageTwo() async {
    for (final emoPic in emoPics) {
      if (emoPic.url.isEmpty) {
        Get.dialog(IbDialog(
          title: 'Missing Info',
          subtitle:
              "You forgot to take a pic for your ${emoPic.description} face",
          showNegativeBtn: false,
          positiveTextKey: 'ok',
        ));
        return;
      }
    }
    print('Setup Page Two is valid!');
    Get.to(() => SetupPageThree(this));
  }

  Future<void> validatePageThree() async {
    if (avatarUrl.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Avatar is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (!GetUtils.isUsername(usernameTeController.text.trim())) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username is not valid",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (bioTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Bio is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (bioTeController.text.trim().length < 30) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Bio needs to be at least 30 characters long",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'),
        barrierDismissible: false);
    if (await IbUserDbService()
        .isUsernameTaken(usernameTeController.text.trim())) {
      Get.back();
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username is taken, try a different username",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    } else {
      print('Setup Page Three is valid!');
      try {
        final String? url =
            await IbStorageService().uploadAndRetrieveImgUrl(avatarUrl.value);
        if (url == null) {
          throw Exception('failed to upload message');
        }

        for (final emoPic in emoPics) {
          final emoPicUrl =
              await IbStorageService().uploadAndRetrieveImgUrl(emoPic.url);

          if (emoPicUrl == null) {
            throw Exception('failed to upload message');
          }
          emoPic.url = emoPicUrl;
        }
        final IbUser user = IbUser(
            id: IbUtils.getCurrentUid()!,
            avatarUrl: url,
            email: IbUtils.getCurrentFbUser()!.email ?? '',
            status: IbUser.kUserStatusPending,
            fName: fNameTeController.text.trim(),
            lName: lNameTeController.text.trim(),
            username: usernameTeController.text.trim(),
            gender: gender.value,
            birthdateInMs: birthdateInMs.value,
            bio: bioTeController.text.trim(),
            emoPics: emoPics);
        await IbUserDbService().registerNewUser(user);
        Get.back();
        Get.offAll(() => ReviewPage());
      } catch (e) {
        Get.back();
        Get.dialog(const IbDialog(
          title: 'Error',
          subtitle: "Failed to upload images..",
          showNegativeBtn: false,
        ));
      }
    }
  }
}