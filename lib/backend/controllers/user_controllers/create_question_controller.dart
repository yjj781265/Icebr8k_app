import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_tag_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/review_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../frontend/ib_colors.dart';
import '../../../frontend/ib_widgets/ib_loading_dialog.dart';
import '../../models/ib_user.dart';
import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_storage_service.dart';

class CreateQuestionController extends GetxController {
  final questionType = QuestionType.multipleChoice.obs;
  IbQuestionItemController? itemController;
  final TextEditingController questionEditController = TextEditingController();
  final TextEditingController descriptionEditController =
      TextEditingController();
  late TabController tabController;
  final title = 'Text Only'.obs;
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
  final pickedChats = <ChatTabItem>[].obs;
  final pickedFriends = <IbUser>[].obs;
  bool isPublic;

  /// use .. operator to update pickedChats  pickedFriends list or set it separately
  CreateQuestionController({this.itemController, this.isPublic = true});

  @override
  Future<void> onReady() async {
    await preFillInfo();
    super.onReady();
  }

  Future<void> preFillInfo() async {
    if (itemController == null) {
      return;
    }
    final ibQuestion = itemController!.rxIbQuestion.value;
    picMediaList.value = ibQuestion.medias;
    questionEditController.text = ibQuestion.question;
    descriptionEditController.text = ibQuestion.description;
    isPublic = ibQuestion.isPublic;

    for (final text in ibQuestion.tags) {
      final tag = await IbTagDbService().retrieveIbTag(text);
      if (tag != null) {
        pickedTags.add(tag);
      }
    }
    for (final id in ibQuestion.sharedChatIds) {
      final ibChat = await IbChatDbService().queryChat(id);
      if (ibChat != null) {
        final item = IbUtils.getAllChatTabItems().firstWhereOrNull(
            (element) => element.ibChat.chatId == ibChat.chatId);
        if (item != null) {
          pickedChats.add(item);
        }
      }
    }

    if (ibQuestion.questionType == QuestionType.multipleChoicePic) {
      tabController.index = 1;
      picChoiceList.value = ibQuestion.choices;
    }

    if (ibQuestion.questionType == QuestionType.multipleChoice) {
      tabController.index = 0;
      choiceList.value = ibQuestion.choices;
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
    final q = IbQuestion(
        question: questionEditController.text.trim(),
        description: descriptionEditController.text.trim(),
        id: itemController == null
            ? IbUtils.getUniqueId()
            : itemController!.rxIbQuestion.value.id,
        sharedFriendUids: pickedFriends.map((element) => element.id).toList(),
        sharedChatIds:
            pickedChats.map((element) => element.ibChat.chatId).toList(),
        isPublic: isPublic,
        tags: pickedTags.map((element) => element.text).toList(),
        creatorId: IbUtils.getCurrentUid()!,
        medias: picMediaList.toSet().union(videoMediaList.toSet()).toList(),
        choices: _getIbChoices(),
        questionType: questionType.value,
        askedTimeInMs: DateTime.now().millisecondsSinceEpoch);

    if (itemController != null) {
      itemController!.rxIbQuestion.value = q;
    } else {
      itemController = Get.put(IbQuestionItemController(
          rxIsSample: true.obs, rxIbQuestion: q.obs, rxIsExpanded: true.obs));
    }

    ///IMPORTANT
    itemController!.rxIsExpanded.value = true;
    itemController!.selectedChoiceId.value = '';
    itemController!.rxIsSample.value = true;

    Get.to(
      () => ReviewQuestionPage(
        createQuestionController: this,
        itemController: itemController!,
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

  Future<void> removeMediaAtIndex(int index) async {
    if (index < 0) {
      return;
    }

    try {
      if (picMediaList[index].url.isURL &&
          picMediaList[index].url.isImageFileName) {
        Get.dialog(const IbLoadingDialog(messageTrKey: 'Deleting...'));
        await IbStorageService().deleteFile(picMediaList[index].url);
        Get.back();
      }
      picMediaList.removeAt(index);
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        title: "Error",
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }

  Future<void> submitQuestion(IbQuestion ibQuestion) async {
    if (ibQuestion.pollSize != 0) {
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: "You can't edit a question with votes",
        onPositiveTap: () {
          Navigator.of(Get.context!).popUntil((route) => route.isFirst);
        },
        showNegativeBtn: false,
      ));
      return;
    }

    //use toSet to ensure uniqueness
    ibQuestion.sharedChatIds =
        pickedChats.map((element) => element.ibChat.chatId).toSet().toList();
    ibQuestion.sharedFriendUids =
        pickedFriends.map((element) => element.id).toSet().toList();
    if (ibQuestion.isPublic) {
      ibQuestion.sharedFriendUids
          .addAll(IbUtils.getCurrentIbUserUnblockedFriendsId());
    }

    if (ibQuestion.id.isEmpty ||
        ibQuestion.tags.isEmpty ||
        ibQuestion.question.isEmpty ||
        ibQuestion.choices.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle:
            'Question is not valid, make sure all required field are filled',
        showNegativeBtn: false,
      ));
      return;
    }

    if (ibQuestion.isQuiz && ibQuestion.correctChoiceId.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: 'Quiz question needs to have a correct choice picked',
        showNegativeBtn: false,
      ));
      return;
    }

    if (ibQuestion.sharedChatIds.isEmpty &&
        ibQuestion.sharedFriendUids.isEmpty &&
        !ibQuestion.isPublic) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: 'Privacy Bounds are empty',
        showNegativeBtn: false,
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'Uploading...'),
        barrierDismissible: false);

    /// upload all url in choices
    for (final choice in ibQuestion.choices) {
      if (choice.url == null || choice.url!.contains('http')) {
        continue;
      }

      final String? url = await IbStorageService()
          .uploadAndRetrieveImgUrl(filePath: choice.url!);
      if (url == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to upload images...',
            backgroundColor: IbColors.errorRed);
        break;
      } else {
        choice.url = url;
      }
    }

    /// upload all url in medias
    for (final media in ibQuestion.medias) {
      if (media.url.contains('http')) {
        continue;
      }

      final String? url = await IbStorageService().uploadAndRetrieveImgUrl(
        filePath: media.url,
      );
      if (url == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to upload images...',
            backgroundColor: IbColors.errorRed);
        break;
      } else {
        media.url = url;
      }
    }

    /// upload all the string in tagIds
    for (final String text in ibQuestion.tags) {
      await IbTagDbService().uploadTag(text);
    }
    await IbQuestionDbService().uploadQuestion(ibQuestion);

    /// add IbMessage to selected circles
    for (final item in ibQuestion.sharedChatIds) {
      await IbChatDbService().uploadMessage(IbMessage(
          messageId: IbUtils.getUniqueId(),
          content: ibQuestion.id,
          readUids: [IbUtils.getCurrentUid()!],
          senderUid: IbUtils.getCurrentUid()!,
          messageType: IbMessage.kMessageTypePoll,
          chatRoomId: item));
    }

    Navigator.of(Get.context!).popUntil((route) => route.isFirst);

    /// DO NOT ERASE THIS LINE BELOW
    itemController!.rxIsSample.value = false;
    itemController!.rxIbQuestion.value = ibQuestion;
    itemController!.rxIbQuestion.refresh();
    print(itemController!.rxIbQuestion.value.medias);
    IbUtils.showSimpleSnackBar(
        msg: 'Question submitted successfully',
        backgroundColor: IbColors.accentColor);
  }
}

class IbTagModel {
  IbTag tag;
  bool selected;

  IbTagModel({required this.tag, required this.selected});
}
