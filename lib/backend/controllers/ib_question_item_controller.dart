import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

enum CardState {
  init,
  picked, // user made a selection but haven't submitted the question
  processing,
  submitted,
}

class IbQuestionItemController extends GetxController {
  final selectedChoice = ''.obs;
  final voteBtnTrKey = 'vote'.obs;
  final submitBtnTrKey = 'submit'.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final IbQuestion ibQuestion;
  final height = 300.0.obs;
  final width = 350.0.obs;
  final currentState = CardState.init.obs;
  final resultMap = <String, double>{};
  bool isSample = false;

  IbQuestionItemController(this.ibQuestion);

  @override
  Future<void> onInit() async {
    super.onInit();
    currentState.value = isSample ? CardState.picked : CardState.init;

    final IbUser? ibUser =
        await IbUserDbService().queryIbUser(ibQuestion.creatorId);
    if (ibUser != null) {
      username.value = ibUser.username;
      avatarUrl.value = ibUser.avatarUrl;
    }

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      selectedChoice.value = '';
    } else {
      selectedChoice.value = '1';
      currentState.value = CardState.picked;
    }
    return;
  }

  void updateSelected(String choice) {
    if (!ibQuestion.choices.contains(choice)) {
      return;
    }

    if (currentState.value == CardState.submitted) {
      return;
    }

    if (selectedChoice.value == choice) {
      selectedChoice.value = '';
      currentState.value = CardState.init;
      return;
    }

    selectedChoice.value = choice;
    if (choice.isNotEmpty) {
      currentState.value = CardState.picked;
    }
  }

  Future<void> _calculateResult(
      {required String answer, required double totalPollSize}) async {
    double _result = 0.0;
    final double _answerPollSize = (await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: answer))
        .toDouble();
    _result = _answerPollSize / totalPollSize;
    resultMap.update(answer, (_) => _result, ifAbsent: () => _result);
  }

  Future<void> onVote() async {
    if (currentState.value == CardState.submitted ||
        selectedChoice.value.isEmpty) {
      return;
    }
    voteBtnTrKey.value = 'voting';
    await IbQuestionDbService().answerQuestion(
        answer: selectedChoice.value,
        questionId: ibQuestion.id,
        uid: Get.find<AuthController>().firebaseUser!.uid);

    await _initResultMap();
    currentState.value = CardState.submitted;
    voteBtnTrKey.value = ibQuestion.questionType == IbQuestion.kMultipleChoice
        ? 'voted'
        : 'show_result';
  }

  // submit new question
  Future<void> submit() async {
    if (currentState.value == CardState.picked) {
      currentState.value = CardState.processing;
      submitBtnTrKey.value = 'submitting';
      await IbQuestionDbService().uploadQuestion(ibQuestion);
      currentState.value = CardState.submitted;
      submitBtnTrKey.value = 'submitted';
      Navigator.of(Get.context!).popUntil((route) => route.isFirst);
      IbUtils.showSimpleSnackBar(
          msg: 'Question submitted successfully',
          backgroundColor: IbColors.accentColor);
    }
  }

  Future<void> _initResultMap() async {
    final double _pollSize =
        (await IbQuestionDbService().queryPollSize(ibQuestion.id)).toDouble();

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      for (final String choice in ibQuestion.choices) {
        await _calculateResult(answer: choice, totalPollSize: _pollSize);
      }
    } else {
      // if user is the only one answered this SC question, there is no need to query result from database, showing 100% directly
      if (_pollSize == 1) {
        resultMap.update(selectedChoice.value, (_) => 1, ifAbsent: () => 1);
        return;
      }

      for (int i = 1; i <= 5; i++) {
        await _calculateResult(answer: i.toString(), totalPollSize: _pollSize);
      }
    }
  }
}
