import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
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
  final title = 'text only'.obs;
  final choiceList = <IbChoice>[].obs;
  final picChoiceList = <IbChoice>[].obs;
  final picList = <IbChoice>[].obs;
  final scaleEndPoints = <IbChoice>[].obs;
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

    if (questionType == IbQuestion.kMultipleChoicePic) {
      final IbChoice item = picChoiceList.removeAt(oldIndex);
      picChoiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }

    final IbChoice item = scaleEndPoints.removeAt(oldIndex);
    scaleEndPoints.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
  }

  bool isChoiceDuplicated(String text) {
    if (IbQuestion.kScale == questionType) {
      for (final IbChoice choice in scaleEndPoints) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    } else if (IbQuestion.kMultipleChoice == questionType) {
      for (final IbChoice choice in choiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    } else if (IbQuestion.kMultipleChoicePic == questionType) {
      for (final IbChoice choice in picChoiceList) {
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
    final String id = IbUtils.getUniqueId();
    if (questionType == IbQuestion.kScale) {
      final _controller = IbQuestionItemController(
          rxIbQuestion: IbQuestion(
            question: question.trim(),
            id: id,
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            endpoints: scaleEndPoints,
            choices: _generateScaleChoiceList(),
          ).obs,
          isSample: true,
          isExpandable: true,
          disableAvatarOnTouch: true);
      _controller.isExpanded.value = false;
      Get.to(
        () => ReviewQuestionPage(
          itemController: Get.put(_controller, tag: 'sample_$id'),
        ),
      );
      return;
    }

    if (questionType == IbQuestion.kMultipleChoice) {
      final _controller = IbQuestionItemController(
          rxIbQuestion: IbQuestion(
            question: question.trim(),
            id: id,
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: _generateScaleChoiceList(),
          ).obs,
          isSample: true,
          isExpandable: true,
          disableAvatarOnTouch: true);
      _controller.isExpanded.value = false;
      Get.to(
        () => ReviewQuestionPage(
          itemController: Get.put(_controller, tag: 'sample_$id'),
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
