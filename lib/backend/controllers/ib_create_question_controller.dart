import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

import 'auth_controller.dart';

class IbCreateQuestionController extends GetxController {
  String questionType = IbQuestion.kMultipleChoice;
  late TextEditingController? questionEditController;
  late TextEditingController? descriptionEditController;
  final choiceList = <String>[].obs;
  final scaleChoiceList = <String>[].obs;
  final filePath = ''.obs;
  String question = '';
  String description = '';

  void swapIndex(int oldIndex, int newIndex) {
    if (questionType == IbQuestion.kMultipleChoice) {
      final String item = choiceList.removeAt(oldIndex);
      choiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }
    final String item = scaleChoiceList.removeAt(oldIndex);
    scaleChoiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
  }

  List<String> _getChoiceList() {
    if (questionType == IbQuestion.kMultipleChoice) {
      return choiceList;
    }
    return scaleChoiceList;
  }

  void validQuestion() {
    if (question.trim().isEmpty) {
      Get.dialog(
          IbSimpleDialog(message: 'question_empty'.tr, positiveBtnTrKey: 'ok'));
      return;
    }
    if (questionType == IbQuestion.kMultipleChoice && choiceList.length < 2) {
      Get.dialog(IbSimpleDialog(
          message: 'mc_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
      return;
    }

    if (questionType == IbQuestion.kScale && scaleChoiceList.length != 2) {
      Get.dialog(IbSimpleDialog(
          message: 'sc_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
      return;
    }

    IbUtils.hideKeyboard();
    Get.to(() => ReviewQuestionPage(
        question: IbQuestion(
            question: question.trim(),
            id: IbUtils.getUniqueName(),
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: _getChoiceList())));
  }

  void reset() {
    question = '';
    description = '';
    choiceList.clear();
    scaleChoiceList.clear();

    if (questionEditController != null) {
      questionEditController!.clear();
    }

    if (descriptionEditController != null) {
      descriptionEditController!.clear();
    }
  }
}
