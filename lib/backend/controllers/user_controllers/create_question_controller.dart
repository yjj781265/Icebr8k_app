import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_tag_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:showcaseview/showcaseview.dart';

import 'ib_question_item_controller.dart';

class CreateQuestionController extends GetxController {
  final questionType = QuestionType.multipleChoice.obs;
  final IbQuestion? ibQuestion;
  final TextEditingController questionEditController = TextEditingController();
  final TextEditingController descriptionEditController =
      TextEditingController();
  late TabController tabController;
  final title = 'text only'.obs;
  // list for mc tab
  final choiceList = <IbChoice>[].obs;
  // list for mc pic tab
  final picChoiceList = <IbChoice>[].obs;
  final picList = <IbChoice>[].obs;
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
      this.ibQuestion,
      this.isPublic = true,
      this.isCircleOnly = false});

  @override
  Future<void> onReady() async {
    await preFillInfo();
    super.onReady();
  }

  Future<void> preFillInfo() async {
    if (ibQuestion == null) {
      return;
    }

    picMediaList.value = ibQuestion!.medias;
    questionEditController.text = ibQuestion!.question;
    descriptionEditController.text = ibQuestion!.description;

    for (final text in ibQuestion!.tags) {
      final tag = await IbTagDbService().retrieveIbTag(text);
      if (tag != null) {
        pickedTags.add(tag);
      }
    }

    if (ibQuestion!.questionType == QuestionType.multipleChoicePic) {
      tabController.index = 1;
      picChoiceList.value = ibQuestion!.choices;
    }

    if (ibQuestion!.questionType == QuestionType.multipleChoice) {
      tabController.index = 0;
      choiceList.value = ibQuestion!.choices;
    }
  }

  void swapIndex(int oldIndex, int newIndex) {
    if (questionType.value == QuestionType.multipleChoice) {
      final IbChoice item = choiceList.removeAt(oldIndex);
      choiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }

    if (questionType.value == QuestionType.multipleChoicePic) {
      final IbChoice item = picChoiceList.removeAt(oldIndex);
      picChoiceList.insert(oldIndex < newIndex ? newIndex - 1 : newIndex, item);
      return;
    }
  }

  bool isChoiceDuplicated(String text) {
    if (QuestionType.multipleChoice == questionType.value) {
      for (final IbChoice choice in choiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
    } else if (QuestionType.multipleChoicePic == questionType.value) {
      for (final IbChoice choice in picChoiceList) {
        if (text.trim() == choice.content) {
          return true;
        }
      }
      return false;
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
    if (questionType.value == QuestionType.multipleChoice &&
        choiceList.length < 2) {
      Get.dialog(IbDialog(
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          showNegativeBtn: false,
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType.value == QuestionType.multipleChoicePic &&
        picChoiceList.length < 2) {
      Get.dialog(IbDialog(
          showNegativeBtn: false,
          subtitle: 'mc_question_not_valid'.tr,
          title: 'Error',
          positiveTextKey: 'ok'));
      return;
    }

    if (questionType.value == QuestionType.multipleChoicePic) {
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
    if (questionType.value == QuestionType.multipleChoice) {
      return choiceList;
    }
    if (questionType.value == QuestionType.multipleChoicePic) {
      return picChoiceList;
    }

    if (questionType.value.toString().contains('sc')) {
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
