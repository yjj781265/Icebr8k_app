import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionItemController extends GetxController {
  final IbQuestion ibQuestion;
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
  final bool isExpandable;
  final bool isSample;
  final bool disableAvatarOnTouch;

  late RxBool isRxExpanded;
  final bool isExpanded;

  /// if user already answered, pass the answer here
  IbAnswer? ibAnswer;
  final totalPolled = 0.obs;
  final selectedChoice = ''.obs;
  final resultMap = <String, double>{}.obs;

  IbQuestionItemController(
      {required this.ibQuestion,
      this.isExpanded = true,
      this.isExpandable = false,
      this.isSample = false,
      this.disableAvatarOnTouch = false,
      this.ibAnswer});

  @override
  Future<void> onInit() async {
    isRxExpanded = isExpanded.obs;

    /// check if user has already answered this question
    ibAnswer ??= await IbQuestionDbService()
        .queryIbAnswer(IbUtils.getCurrentUid()!, ibQuestion.id);

    if (ibAnswer != null) {
      votedDateTime.value =
          DateTime.fromMillisecondsSinceEpoch(ibAnswer!.answeredTimeInMs);
    }

    selectedChoice.value = ibAnswer == null
        ? ibQuestion.questionType == IbQuestion.kMultipleChoice
            ? ''
            : '1'
        : ibAnswer!.answer;
    showResult.value = ibAnswer != null;

    /// query question author user info
    ibUser = await IbUserDbService().queryIbUser(ibQuestion.creatorId);

    if (ibUser != null) {
      /// populate title ..etc
      title.value = ibUser!.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(ibQuestion.askedTimeInMs));
      avatarUrl.value = ibUser!.avatarUrl;
    }

    /// only calculate result for Mc question at start, Sc question will
    /// calculate its result when user click on show result button
    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      calculateResult();
    }

    totalPolled.value =
        await IbQuestionDbService().queryPollSize(ibQuestion.id);

    isLoading.value = false;
    super.onInit();
  }

  Future<void> calculateResult() async {
    isCalculating.value = true;
    totalPolled.value =
        await IbQuestionDbService().queryPollSize(ibQuestion.id);

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      for (final choice in ibQuestion.choices) {
        final int size = await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: choice);

        final double result = (size.toDouble()) / (totalPolled.toDouble());
        resultMap[choice] = result;
      }

      ///scale question has answers from 1 to 5
    } else if (ibQuestion.questionType == IbQuestion.kScale) {
      for (int i = 1; i <= 5; i++) {
        final int size = await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: i.toString());

        if (size != 0) {
          final double result = (size.toDouble()) / (totalPolled.toDouble());
          resultMap[i.toString()] = result;
        }
      }
    }
    isCalculating.value = false;
  }

  Future<void> onVote() async {
    if (showResult.isTrue) {
      return;
    }

    if (selectedChoice.value.isEmpty) {
      return;
    }

    isAnswering.value = true;
    final IbAnswer ibAnswer = IbAnswer(
        answer: selectedChoice.value,
        answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
        askedTimeInMs: ibQuestion.askedTimeInMs,
        uid: IbUtils.getCurrentUid()!,
        questionId: ibQuestion.id,
        questionType: ibQuestion.questionType);

    await IbQuestionDbService().answerQuestion(ibAnswer);

    await calculateResult();
    votedDateTime.value = DateTime.now();
    isAnswering.value = false;
    showResult.value = true;
  }

  Future<void> onSubmit() async {
    isAnswering.value = true;
    await IbQuestionDbService().uploadQuestion(ibQuestion);
    isAnswering.value = false;
    Navigator.of(Get.context!).popUntil((route) => route.isFirst);
    IbUtils.showSimpleSnackBar(
        msg: 'Question submitted successfully',
        backgroundColor: IbColors.accentColor);
  }
}
