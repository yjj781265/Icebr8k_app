import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

import 'auth_controller.dart';

class IbCreateQuestionController extends GetxController {
  String questionType = IbQuestion.kMultipleChoice;
  late TextEditingController? questionEditController;
  late TextEditingController? descriptionEditController;
  final choiceList = <IbChoice>[].obs;
  final scaleEndPoints = <String>[].obs;
  final ibTagCheckBoxModels = <IbTagCheckBoxModel>[].obs;
  final filePath = ''.obs;
  String question = '';
  String description = '';
  final isCustomTagSelected = false.obs;
  final tags = [
    'General 🤔',
    'Food & Drink 🌭 ',
    'Entertainment 📽️',
    'Sports ⚽',
    'Nature 🌳',
    'Photography 📸 ',
    'Animal 🐕',
    'Science 🔬 ',
    'Funny 😂',
    'Love ❤ ',
    'Fashion 👚 ',
    'Literature 📖 ',
    'Technology 🤖'
  ].obs;

  final pickedTags = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    tags.sort();
    for (final element in tags) {
      ibTagCheckBoxModels
          .add(IbTagCheckBoxModel(tag: element, selected: false.obs));
    }
  }

  void swapIndex(int oldIndex, int newIndex) {
    if (questionType == IbQuestion.kMultipleChoice) {
      final IbChoice item = choiceList.removeAt(oldIndex);
      choiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }
    final String item = scaleEndPoints.removeAt(oldIndex);
    scaleEndPoints.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
  }

  bool isChoiceDuplicated(String text) {
    if (IbQuestion.kScale == questionType) {
      return scaleEndPoints.contains(text.trim());
    } else if (IbQuestion.kMultipleChoice == questionType) {
      for (final IbChoice choice in choiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    }

    return false;
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

    if (questionType == IbQuestion.kScale && scaleEndPoints.length != 2) {
      Get.dialog(IbSimpleDialog(
          message: 'sc_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
      return;
    }

    IbUtils.hideKeyboard();

    if (questionType == IbQuestion.kScale) {
      Get.to(
        () => ReviewQuestionPage(
          question: IbQuestion(
            question: question.trim(),
            id: IbUtils.getUniqueId(),
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            endpoints: scaleEndPoints,
            choices: _generateScaleChoiceList(),
          ),
        ),
      );
      return;
    }

    if (questionType == IbQuestion.kMultipleChoice) {
      Get.to(
        () => ReviewQuestionPage(
          question: IbQuestion(
            question: question.trim(),
            id: IbUtils.getUniqueId(),
            creatorId: IbUtils.getCurrentUid()!,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: choiceList,
          ),
        ),
      );
      return;
    }
  }

  List<IbChoice> _generateScaleChoiceList() {
    final List<IbChoice> choices = [];
    for (int i = 1; i < 6; i++) {
      choices.add(
          IbChoice(content: i.toString(), choiceId: IbUtils.getUniqueId()));
    }
    return choices;
  }

  void reset() {
    question = '';
    description = '';
    choiceList.clear();
    scaleEndPoints.clear();

    if (questionEditController != null) {
      questionEditController!.clear();
    }

    if (descriptionEditController != null) {
      descriptionEditController!.clear();
    }
  }
}

class IbTagCheckBoxModel {
  String tag;
  RxBool selected;

  IbTagCheckBoxModel({required this.tag, required this.selected});
}
