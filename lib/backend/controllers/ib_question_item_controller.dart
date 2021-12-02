import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionItemController extends GetxController {
  final Rx<IbQuestion> rxIbQuestion;
  final showResult = false.obs;
  final isAnswering = false.obs;
  final isCalculating = false.obs;

  /// this flag is for sc question only
  final isLoading = false.obs;

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
  IbAnswer? ibAnswer;
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
  final resultMap = <String, double>{}.obs;

  IbQuestionItemController(
      {required this.rxIbQuestion,
      required this.rxIsExpanded,
      this.isSample = false,
      this.disableChoiceOnTouch = false,
      this.disableAvatarOnTouch = false,
      this.isLocalFile = false,
      this.showMyAnswer = false,
      this.ibAnswer});

  @override
  Future<void> onInit() async {
    /// query question author user info
    ibUser = await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);

    if (ibUser != null) {
      /// populate title ..etc
      title.value = ibUser!.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(
              rxIbQuestion.value.askedTimeInMs));
      avatarUrl.value = ibUser!.avatarUrl;
    }

    calculateResult(rxIbQuestion.value);

    totalPolled.value = rxIbQuestion.value.pollSize;
    totalTags.value = rxIbQuestion.value.tagIds.length;
    likes.value = rxIbQuestion.value.likes;

    isLoading.value = false;
    super.onInit();
  }

  Future<void> calculateResult(IbQuestion ibQuestion) async {
    print("calculateResult for ${ibQuestion.question}");
    /* isCalculating.value = true;
    int pollSize = 0;
    if (ibQuestion.statMap == null) {
      return;
    }
    for (final element in ibQuestion.statMap!.values) {
      pollSize = pollSize + element;
    }

    if (pollSize == 0) {
      return;
    }

    totalPolled.value = pollSize;
    if (IbQuestion.kScale == ibQuestion.questionType) {
      for (int i = 1; i < 6; i++) {
        final int size = ibQuestion.statMap![i.toString()] ?? 0;
        if (size == 0) {
          continue;
        }
        final double result = (size.toDouble()) / (pollSize.toDouble());
        resultMap[i.toString()] = result;
      }
    } else {
      for (final choice in ibQuestion.choices) {
        final int size = ibQuestion.statMap![choice] ?? 0;
        final double result = (size.toDouble()) / (pollSize.toDouble());
        resultMap[choice] = result;
      }
    }
    await determineUserAnswer();
    isCalculating.value = false;
    isAnswering.value = false;*/
  }

  Future<void> determineUserAnswer() async {
    /// check if user has already answered this question
    ibAnswer ??= await IbQuestionDbService()
        .queryIbAnswer(IbUtils.getCurrentUid()!, rxIbQuestion.value.id);

    if (ibAnswer != null) {
      votedDateTime.value =
          DateTime.fromMillisecondsSinceEpoch(ibAnswer!.answeredTimeInMs);
      answeredUsername.value =
          (await IbUserDbService().queryIbUser(ibAnswer!.uid))!.username;
    }
    selectedChoiceId.value = ibAnswer == null
        ? rxIbQuestion.value.questionType == IbQuestion.kMultipleChoice
            ? ''
            : '1'
        : ibAnswer!.choiceId;
    showResult.value = ibAnswer != null;
  }

  Future<void> onVote() async {
    if (showResult.isTrue) {
      return;
    }

    if (selectedChoiceId.value.isEmpty) {
      return;
    }

    determineUserAnswer();

    if (ibAnswer != null) {
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
    IbLocalStorageService().removeUnAnsweredIbQid(rxIbQuestion.value.id);
    rxIbQuestion.value.pollSize++;
    // final int size = ibQuestion.statMap![tempAnswer.answer] ?? 0;
    // ibQuestion.statMap![tempAnswer.answer] = size + 1;
    await calculateResult(rxIbQuestion.value);
    updateQuestionTab();
  }

  Future<void> onSubmit() async {
    isAnswering.value = true;
    await IbQuestionDbService().uploadQuestion(rxIbQuestion.value);
    isAnswering.value = false;
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    IbUtils.showSimpleSnackBar(
        msg: 'Question submitted successfully',
        backgroundColor: IbColors.accentColor);
  }

  Future<void> updateQuestionTab() async {
    if (Get.isRegistered<IbQuestionItemController>(
        tag: rxIbQuestion.value.id)) {
      await Get.find<IbQuestionItemController>(tag: rxIbQuestion.value.id)
          .calculateResult(rxIbQuestion.value);
    }
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
