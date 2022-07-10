import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';

import 'ib_question_item_controller.dart';

class QuestionMainController extends GetxController {
  late StreamSubscription questionSub;
  IbQuestionItemController itemController;

  QuestionMainController(this.itemController);

  @override
  void onInit() {
    questionSub = IbQuestionDbService()
        .listenToIbQuestionChange(itemController.rxIbQuestion.value.id)
        .listen((event) {
      if (!event.exists) {
        Get.back(closeOverlays: true);
      }
    });
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    await questionSub.cancel();
    super.onClose();
  }
}
