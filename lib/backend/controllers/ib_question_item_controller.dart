import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_tag_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionItemController extends GetxController {
  final Rx<IbQuestion> rxIbQuestion;
  final showResult = false.obs;
  final isAnswering = false.obs;
  final isSubmitting = false.obs;
  final controllerId = IbUtils.getUniqueId();

  ///user who created the question
  IbUser? ibUser;

  /// voted timestamp in dateTime
  final votedDateTime = DateTime.now().obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  final avatarUrl = ''.obs;
  final bool isSample;
  final bool isLocalFile;
  final bool disableAvatarOnTouch;
  final bool showMyAnswer;
  final bool disableChoiceOnTouch;
  final RxBool rxIsExpanded;

  /// if user already answered, pass the answer here
  Rx<IbAnswer>? myRxIbAnswer;
  final answeredUsername = ''.obs;
  final totalPolled = 0.obs;
  final likes = 0.obs;
  final dislikes = 0.obs;
  final liked = false.obs;
  final disliked = false.obs;
  final comments = 0.obs;
  final commented = false.obs;
  final totalTags = 0.obs;
  final selectedChoiceId = ''.obs;
  final resultMap = <String, int>{}.obs;
  final List<IbTag> ibTags = [];

  IbQuestionItemController(
      {required this.rxIbQuestion,
      required this.rxIsExpanded,
      this.isSample = false,
      this.disableChoiceOnTouch = false,
      this.disableAvatarOnTouch = false,
      this.isLocalFile = false,
      this.myRxIbAnswer,
      this.showMyAnswer = false});

  @override
  Future<void> onInit() async {
    /// query question author user info
    ibUser = await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);

    if (myRxIbAnswer == null) {
      /// query my answer to this question
      final myAnswer = await IbQuestionDbService()
          .queryIbAnswer(IbUtils.getCurrentUid()!, rxIbQuestion.value.id);

      if (myAnswer != null) {
        myRxIbAnswer = myAnswer.obs;
        selectedChoiceId.value = myRxIbAnswer!.value.choiceId;
        myRxIbAnswer!.refresh();
      }
    }

    showResult.value = myRxIbAnswer != null;

    if (ibUser != null) {
      /// populate title ..etc
      title.value = ibUser!.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(
              rxIbQuestion.value.askedTimeInMs));
      avatarUrl.value = ibUser!.avatarUrl;
    }

    await generateIbTags();
    await generatePollStats();
    totalTags.value = rxIbQuestion.value.tagIds.length;
    likes.value = rxIbQuestion.value.likes;
    super.onInit();
  }

  Future<void> generateIbTags() async {
    for (final String id in rxIbQuestion.value.tagIds) {
      final IbTag? tag = await IbTagDbService().retrieveIbTag(id);
      if (tag != null) {
        ibTags.add(tag);
      }
    }
  }

  Future<void> generatePollStats() async {
    int counter = 0;
    resultMap.value = await IbUtils.getChoiceCountMap(rxIbQuestion.value.id);
    for (final int i in resultMap.values) {
      counter = counter + i;
    }
    totalPolled.value = counter;
  }

  Future<void> onVote() async {
    if (selectedChoiceId.value.isEmpty) {
      return;
    }
    if (myRxIbAnswer != null &&
        selectedChoiceId.value == myRxIbAnswer!.value.choiceId) {
      return;
    }

    isAnswering.value = true;
    final IbAnswer tempAnswer = IbAnswer(
        choiceId: selectedChoiceId.value,
        answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
        askedTimeInMs: rxIbQuestion.value.askedTimeInMs,
        uid: IbUtils.getCurrentUid()!,
        questionId: rxIbQuestion.value.id,
        questionType: rxIbQuestion.value.questionType);

    await IbQuestionDbService().answerQuestion(tempAnswer);

    if (myRxIbAnswer != null) {
      await IbQuestionDbService().updatePollSize(
          questionId: rxIbQuestion.value.id,
          oldChoiceId: myRxIbAnswer!.value.choiceId,
          newChoiceId: selectedChoiceId.value);
    } else {
      await IbQuestionDbService().increasePollSize(
          questionId: rxIbQuestion.value.id, choiceId: selectedChoiceId.value);
    }

    myRxIbAnswer = (await IbQuestionDbService()
            .queryIbAnswer(IbUtils.getCurrentUid()!, rxIbQuestion.value.id))!
        .obs;
    myRxIbAnswer!.refresh();

    IbLocalStorageService().removeUnAnsweredIbQid(rxIbQuestion.value.id);
    generatePollStats();
    showResult.value = true;
    isAnswering.value = false;
  }

  Future<void> onSubmit() async {
    isSubmitting.value = true;
    if (isLocalFile &&
        rxIbQuestion.value.choices.isNotEmpty &&
        (rxIbQuestion.value.questionType == IbQuestion.kPic ||
            rxIbQuestion.value.questionType == IbQuestion.kMultipleChoicePic)) {
      for (final ibChoice in rxIbQuestion.value.choices) {
        if (ibChoice.url != null && ibChoice.url!.isNotEmpty) {
          final String? url =
              await IbStorageService().uploadAndRetrieveImgUrl(ibChoice.url!);
          if (url != null) {
            ibChoice.url = url;
          } else {
            IbUtils.showSimpleSnackBar(
                msg:
                    'Failed to upload images, ensure you have internet connection',
                backgroundColor: IbColors.errorRed);
          }
        } else {
          continue;
        }
      }
    }

    if (rxIbQuestion.value.tagIds.isNotEmpty) {
      for (int i = 0; i < rxIbQuestion.value.tagIds.length; i++) {
        final String id = await IbTagDbService()
            .uploadTagAndReturnId(rxIbQuestion.value.tagIds[i]);
        rxIbQuestion.value.tagIds[i] = id;
      }
    }

    await IbQuestionDbService().uploadQuestion(rxIbQuestion.value);
    isSubmitting.value = false;
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    IbUtils.showSimpleSnackBar(
        msg: 'Question submitted successfully',
        backgroundColor: IbColors.accentColor);
  }

  Future<void> updateLike() async {
    liked.value = !liked.value;
    if (liked.isTrue) {
      likes.value++;
    } else {
      likes.value--;
    }

    if (disliked.isTrue && liked.isTrue) {
      disliked.value = false;
      dislikes.value--;
    }
  }

  Future<void> updateDislike() async {
    disliked.value = !disliked.value;
    if (disliked.isTrue) {
      dislikes.value++;
    } else {
      dislikes.value--;
    }

    if (liked.isTrue && disliked.isTrue) {
      liked.value = false;
      likes.value--;
    }
  }
}
