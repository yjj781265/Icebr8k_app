import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

class CircleSettingsController extends GetxController {
  final TextEditingController titleTxtController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController welcomeMsgController = TextEditingController();
  final photoUrl = ''.obs;
  final photoInit = ''.obs;
  final invitees = <IbUser>[].obs;
  final isPublicCircle = true.obs;

  @override
  void onInit() {
    super.onInit();
    titleTxtController.addListener(() {
      if (titleTxtController.text.trim().isNotEmpty) {
        photoInit.value = titleTxtController.text[0];
      } else {
        photoInit.value = '';
      }
    });
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
  }
}
