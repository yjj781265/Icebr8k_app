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
  final bool showMyAnswer;
  final bool disableChoiceOnTouch;
  final bool showActionButtons;
  final isExpanded = true.obs;

  /// if user already answered, pass the answer here
  IbAnswer? ibAnswer;
  final answeredUsername = ''.obs;
  final totalPolled = 0.obs;
  final selectedChoice = ''.obs;
  final resultMap = <String, double>{}.obs;

  IbQuestionItemController(
      {required this.ibQuestion,
      this.showActionButtons = true,
      this.isExpandable = false,
      this.isSample = false,
      this.disableChoiceOnTouch = false,
      this.disableAvatarOnTouch = false,
      this.showMyAnswer = false,
      this.ibAnswer});

  @override
  Future<void> onInit() async {
    /// query question author user info
    ibUser = await IbUserDbService().queryIbUser(ibQuestion.creatorId);

    if (ibUser != null) {
      /// populate title ..etc
      title.value = ibUser!.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(ibQuestion.askedTimeInMs));
      avatarUrl.value = ibUser!.avatarUrl;
    }

    calculateResult(ibQuestion);

    totalPolled.value = ibQuestion.pollSize;

    isLoading.value = false;
    super.onInit();
  }

  Future<void> calculateResult(IbQuestion ibQuestion) async {
    print("calculateResult for ${ibQuestion.question}");
    isCalculating.value = true;
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
    isAnswering.value = false;
  }

  Future<void> determineUserAnswer() async {
    /// check if user has already answered this question
    ibAnswer ??= await IbQuestionDbService()
        .queryIbAnswer(IbUtils.getCurrentUid()!, ibQuestion.id);

    if (ibAnswer != null) {
      votedDateTime.value =
          DateTime.fromMillisecondsSinceEpoch(ibAnswer!.answeredTimeInMs);
      answeredUsername.value =
          (await IbUserDbService().queryIbUser(ibAnswer!.uid))!.username;
    }
    selectedChoice.value = ibAnswer == null
        ? ibQuestion.questionType == IbQuestion.kMultipleChoice
            ? ''
            : '1'
        : ibAnswer!.answer;
    showResult.value = ibAnswer != null;
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
    IbLocalStorageService().removeUnAnsweredIbQid(ibQuestion.id);
    ibQuestion.pollSize++;
    final int size = ibQuestion.statMap![ibAnswer.answer] ?? 0;
    ibQuestion.statMap![ibAnswer.answer] = size + 1;
    await calculateResult(ibQuestion);
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
