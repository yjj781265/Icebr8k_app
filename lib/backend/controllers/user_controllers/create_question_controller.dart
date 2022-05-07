import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:showcaseview/showcaseview.dart';

import 'ib_question_item_controller.dart';

class CreateQuestionController extends GetxController {
  final questionType = IbQuestion.kMultipleChoice.obs;
  final TextEditingController questionEditController = TextEditingController();
  final TextEditingController descriptionEditController =
      TextEditingController();
  final title = 'text only'.obs;
  // list for mc tab
  final choiceList = <IbChoice>[].obs;
  // list for mc pic tab
  final picChoiceList = <IbChoice>[].obs;
  final picList = <IbChoice>[].obs;
  final scaleEndPoints = <IbChoice>[].obs;

  final picMediaList = <IbMedia>[].obs;
  final videoMediaList = <IbMedia>[].obs;
  final extLinkList = <String>[].obs;

  final ibTagModels = <IbTagModel>[].obs;
  final filePath = ''.obs;
  final isCustomTagSelected = false.obs;
  final pickedTags = <IbTag>[].obs;
  List<ChatTabItem> pickedCircles;
  final bool isPublic;
  final bool isCircleOnly;

  CreateQuestionController(
      {this.pickedCircles = const [],
      this.isPublic = true,
      this.isCircleOnly = false});

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  void swapIndex(int oldIndex, int newIndex) {
    if (questionType.value == IbQuestion.kMultipleChoice) {
      final IbChoice item = choiceList.removeAt(oldIndex);
      choiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }

    if (questionType.value == IbQuestion.kMultipleChoicePic) {
      final IbChoice item = picChoiceList.removeAt(oldIndex);
      picChoiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }

    final IbChoice item = scaleEndPoints.removeAt(oldIndex);
    scaleEndPoints.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
  }

  bool isChoiceDuplicated(String text) {
    if (IbQuestion.kMultipleChoice == questionType.value) {
      for (final IbChoice choice in choiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    } else if (IbQuestion.kMultipleChoicePic == questionType.value) {
      for (final IbChoice choice in picChoiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    } else if (questionType.contains('sc')) {
      return true;
    }

    return false;
  }

  void validQuestion(BuildContext context) {
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
        onPositiveTap: () {
          Get.back();
          if (!IbLocalDataService()
              .retrieveBoolValue(StorageKey.pickTagForQuestionBool)) {
            ShowCaseWidget.of(context)!
                .startShowCase([IbShowCaseManager.kPickTagForQuestionKey]);
          }
        },
      ));
      return;
    }
    if (questionType.value == IbQuestion.kMultipleChoice &&
        choiceList.length < 2) {
      Get.dialog(IbDialog(
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          showNegativeBtn: false,
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType.value == IbQuestion.kMultipleChoicePic &&
        picChoiceList.length < 2) {
      Get.dialog(IbDialog(
          showNegativeBtn: false,
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType.value == IbQuestion.kMultipleChoicePic) {
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

    IbUtils.hideKeyboard();
    final String id = IbUtils.getUniqueId();
    final question = IbQuestion(
        question: questionEditController.text.trim(),
        description: descriptionEditController.text.trim(),
        id: id,
        sharedFriendUids:
            isPublic ? IbUtils.getCurrentIbUserUnblockedFriendsId() : [],
        isPublic: isPublic,
        isCircleOnly: isCircleOnly,
        tags: pickedTags.map((element) => element.text).toList(),
        creatorId: IbUtils.getCurrentUid()!,
        medias: picMediaList.toSet().union(videoMediaList.toSet()).toList(),
        choices: _getIbChoices(),
        questionType: questionType.value,
        askedTimeInMs: DateTime.now().millisecondsSinceEpoch);
    Get.to(
      () => ReviewQuestionPage(
        itemController: Get.put(
          IbQuestionItemController(
              rxIbQuestion: question.obs,
              rxIsExpanded: true.obs,
              isSample: true)
            ..sharedCircles.addAll(pickedCircles),
        ),
      ),
    );
  }

  List<IbChoice> _getIbChoices() {
    if (questionType.value == IbQuestion.kMultipleChoice) {
      return choiceList;
    }
    if (questionType.value == IbQuestion.kMultipleChoicePic) {
      return picChoiceList;
    }

    if (questionType.value.contains('sc')) {
      return _generateScaleChoiceList();
    }
    return [];
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
