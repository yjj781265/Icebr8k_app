import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/services/ib_tag_db_service.dart';
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
  final ibTagModels = <IbTagModel>[].obs;
  final filePath = ''.obs;
  String question = '';
  String description = '';
  final isCustomTagSelected = false.obs;
  final pickedTags = <String>[].obs;

  @override
  Future<void> onReady() async {
    super.onReady();
    await initTrendingTags();
  }

  Future<void> initTrendingTags() async {
    final List<IbTag> ibTags = await IbTagDbService().retrieveTrendingIbTags();
    for (final tag in ibTags) {
      ibTagModels.add(IbTagModel(tag: tag, selected: false));
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

    if (pickedTags.isEmpty) {
      Get.dialog(IbSimpleDialog(message: 'no_tag'.tr, positiveBtnTrKey: 'ok'));
      return;
    }
    if (questionType == IbQuestion.kMultipleChoice && choiceList.length < 2) {
      Get.dialog(IbSimpleDialog(
          message: 'mc_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
      return;
    }

    if (questionType == IbQuestion.kMultipleChoicePic &&
        picChoiceList.length < 2) {
      Get.dialog(IbSimpleDialog(
          message: 'mc_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
      return;
    }

    if (questionType == IbQuestion.kMultipleChoicePic) {
      for (final IbChoice ibChoice in picChoiceList) {
        if (ibChoice.url == null ||
            ibChoice.url!.isEmpty ||
            ibChoice.content == null ||
            ibChoice.content!.isEmpty) {
          Get.dialog(IbSimpleDialog(
              message: 'mc_pic_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
          return;
        }
      }
    }

    if (questionType == IbQuestion.kPic) {
      if (picList.length < 2) {
        Get.dialog(IbSimpleDialog(
            message: 'pic_question_not_valid_min'.tr, positiveBtnTrKey: 'ok'));
        return;
      }

      for (final IbChoice ibChoice in picList) {
        if (ibChoice.url == null || ibChoice.url!.isEmpty) {
          Get.dialog(IbSimpleDialog(
              message: 'pic_question_not_valid'.tr, positiveBtnTrKey: 'ok'));
          return;
        }
      }
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
          tagIds: pickedTags,
          questionType: questionType.trim(),
          askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
          endpoints: scaleEndPoints,
          choices: _generateScaleChoiceList(),
        ).obs,
        isSample: true,
        disableAvatarOnTouch: true,
        rxIsExpanded: true.obs,
      );
      Get.to(
        () => ReviewQuestionPage(
          itemController: Get.put(_controller, tag: 'sample_$id'),
        ),
      );
      return;
    }

    if (questionType == IbQuestion.kMultipleChoicePic) {
      final _controller = IbQuestionItemController(
          rxIbQuestion: IbQuestion(
            question: question.trim(),
            id: id,
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            tagIds: pickedTags,
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: picChoiceList,
          ).obs,
          isSample: true,
          isLocalFile: true,
          rxIsExpanded: true.obs,
          disableAvatarOnTouch: true);
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
            tagIds: pickedTags,
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: choiceList,
          ).obs,
          isSample: true,
          rxIsExpanded: true.obs,
          disableAvatarOnTouch: true);
      Get.to(
        () => ReviewQuestionPage(
          itemController: Get.put(_controller, tag: 'sample_$id'),
        ),
      );
      return;
    }

    if (questionType == IbQuestion.kPic) {
      final _controller = IbQuestionItemController(
          rxIbQuestion: IbQuestion(
            question: question.trim(),
            id: id,
            tagIds: pickedTags,
            creatorId: Get.find<AuthController>().firebaseUser!.uid,
            description: description.trim(),
            questionType: questionType.trim(),
            askedTimeInMs: DateTime.now().millisecondsSinceEpoch,
            choices: picList,
          ).obs,
          isSample: true,
          rxIsExpanded: true.obs,
          isLocalFile: true,
          disableAvatarOnTouch: true);
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

class IbTagModel {
  IbTag tag;
  bool selected;

  IbTagModel({required this.tag, required this.selected});
}
