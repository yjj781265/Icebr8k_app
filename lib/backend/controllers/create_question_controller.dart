import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

class CreateQuestionController extends GetxController {
  String questionType = IbQuestion.kMultipleChoice;
  final TextEditingController questionEditController = TextEditingController();
  final TextEditingController descriptionEditController =
      TextEditingController();
  final title = 'text only'.obs;

  final choiceList = <IbChoice>[].obs;
  final picChoiceList = <IbChoice>[].obs;
  final picList = <IbChoice>[].obs;
  final scaleEndPoints = <IbChoice>[].obs;

  final picMediaList = <String>[].obs;
  final videoMediaList = <String>[].obs;
  final extLinkList = <String>[].obs;
  GeoFirePoint? geoFirePoint;

  final ibTagModels = <IbTagModel>[].obs;
  final filePath = ''.obs;
  final isCustomTagSelected = false.obs;
  final pickedTags = <IbTag>[].obs;

  @override
  Future<void> onReady() async {
    super.onReady();
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
    if (questionEditController.text.trim().isEmpty) {
      Get.dialog(IbDialog(
          title: 'Error',
          showNegativeBtn: false,
          subtitle: 'question_empty'.tr,
          positiveTextKey: 'ok'));
      return;
    }

    if (pickedTags.isEmpty) {
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: 'no_tag'.tr,
        positiveTextKey: 'ok',
        showNegativeBtn: false,
      ));
      return;
    }
    if (questionType == IbQuestion.kMultipleChoice && choiceList.length < 2) {
      Get.dialog(IbDialog(
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          showNegativeBtn: false,
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType == IbQuestion.kMultipleChoicePic &&
        picChoiceList.length < 2) {
      Get.dialog(IbDialog(
          showNegativeBtn: false,
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType == IbQuestion.kMultipleChoicePic) {
      for (final IbChoice ibChoice in picChoiceList) {
        if (ibChoice.url == null ||
            ibChoice.url!.isEmpty ||
            ibChoice.content == null ||
            ibChoice.content!.isEmpty) {
          Get.dialog(IbDialog(
              subtitle: 'mc_pic_question_not_valid'.tr,
              showNegativeBtn: false,
              title: 'Error',
              positiveTextKey: 'ok'));
          return;
        }
      }
    }

    if (questionType == IbQuestion.kPic) {
      if (picList.length < 2) {
        Get.dialog(IbDialog(
            subtitle: 'pic_question_not_valid_min'.tr,
            title: 'Error',
            showNegativeBtn: false,
            positiveTextKey: 'ok'));
        return;
      }

      for (final IbChoice ibChoice in picList) {
        if (ibChoice.url == null || ibChoice.url!.isEmpty) {
          Get.dialog(IbDialog(
            subtitle: 'pic_question_not_valid'.tr,
            positiveTextKey: 'ok',
            title: 'Error',
            showNegativeBtn: false,
          ));
          return;
        }
      }
    }

    if (questionType == IbQuestion.kScale && scaleEndPoints.length != 2) {
      Get.dialog(IbDialog(
          subtitle: 'sc_question_not_valid'.tr,
          title: 'Error',
          showNegativeBtn: false,
          positiveTextKey: 'ok'));
      return;
    }

    IbUtils.hideKeyboard();
    final String id = IbUtils.getUniqueId();
    final question = IbQuestion(
        question: questionEditController.text.trim(),
        description: descriptionEditController.text.trim(),
        id: id,
        tagIds: pickedTags.map((element) => element.text).toList(),
        creatorId: IbUtils.getCurrentUid()!,
        choices: choiceList,
        questionType: questionType,
        askedTimeInMs: DateTime.now().millisecondsSinceEpoch);
    Get.to(() => ReviewQuestionPage(
        itemController: Get.put(IbQuestionItemController(
            rxIbQuestion: question.obs,
            rxIsExpanded: true.obs,
            isSample: true))));
  }

  List<IbChoice> _generateScaleChoiceList() {
    final List<IbChoice> choices = [];
    for (int i = 1; i < 6; i++) {
      choices.add(
          IbChoice(content: i.toString(), choiceId: IbUtils.getUniqueId()));
    }
    return choices;
  }
}

class IbTagModel {
  IbTag tag;
  bool selected;

  IbTagModel({required this.tag, required this.selected});
}
