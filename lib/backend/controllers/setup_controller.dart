import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

class SetupController extends GetxController {
  final TextEditingController birthdateTeController = TextEditingController();
  final TextEditingController fNameTeController = TextEditingController();
  final TextEditingController lNameTeController = TextEditingController();
  final TextEditingController usernameTeController = TextEditingController();
  final gender = ''.obs;
  final genderSelections = [false, false, false].obs;
  final birthdateInMs = DateTime.now().millisecondsSinceEpoch.obs;
  final emoPics = <IbEmoPic>[].obs;
  final avatarUrl = ''.obs;

  void onGenderSelect(int index) {
    for (int i = 0; i < genderSelections.length; i++) {
      if (i == index) {
        continue;
      }
      genderSelections[i] = false;
    }
    genderSelections[index] = !genderSelections[index];
    gender.value = IbUser.kGenders[index];
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
  }
}
