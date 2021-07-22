import 'dart:math';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbQuestionItemController extends GetxController {
  final selectedChoice = ''.obs;
  final isVoted = false.obs;
  final voteBtnTrKey = 'vote'.obs;
  final submitBtnTrKey = 'submit'.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final IbQuestion ibQuestion;
  final height = 300.0.obs;
  final width = 300.0.obs;
  final _answeredList = <String>[];
  final resultMap = <String, double>{};
  bool isSample = false;
  DateTime _lastResultUpdatedTime = DateTime.now();

  IbQuestionItemController(this.ibQuestion);

  @override
  Future<void> onInit() async {
    print('IbQuestionItemController init');
    super.onInit();
    final IbUser? ibUser =
        await IbUserDbService().queryIbUser(ibQuestion.creatorId);
    if (ibUser != null) {
      username.value = ibUser.username;
      avatarUrl.value = ibUser.avatarUrl;
    }
    //TODO REMOVE THIS ONCE IT CONNECTED TO DATABASE
    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      _generateAnsweredList();
      _initResultMap();
    } else {
      selectedChoice.value = '1';
    }

    return;
  }

  @override
  void onClose() {
    print('IbQuestionItemController onClose');
    super.onClose();
  }

  void updateSelected(String choice) {
    if (!ibQuestion.choices.contains(choice)) {
      return;
    }

    if (isVoted.isTrue) {
      return;
    }

    if (selectedChoice.value == choice) {
      selectedChoice.value = '';
      return;
    }

    selectedChoice.value = choice;
    _calculateResult(choice);
  }

  void _calculateResult(String answer) {
    double _result = 0.0;
    final double _pollSize = _answeredList.length.toDouble();
    double _counter = 0;
    for (final String str in _answeredList) {
      if (str == answer) {
        _counter++;
      }
    }
    _result = _counter / _pollSize;
    resultMap.putIfAbsent(answer, () => _result);
  }

  Future<void> onVote() async {
    if (isVoted.value) {
      return;
    }
    voteBtnTrKey.value = 'voting';
    await IbQuestionDbService().answerQuestion(
        answer: selectedChoice.value,
        questionId: ibQuestion.id,
        uid: Get.find<AuthController>().firebaseUser!.uid);
    isVoted.value = true;
    voteBtnTrKey.value = 'voted';
  }

  void reset() {
    selectedChoice.value = '';
    isVoted.value = false;
    voteBtnTrKey.value = 'vote';
  }

  Future<void> submit() async {
    if (submitBtnTrKey.value == 'submitted') {
      return;
    }
    submitBtnTrKey.value = 'submitting';
    await IbQuestionDbService().uploadQuestion(ibQuestion);
    submitBtnTrKey.value = 'submitted';
  }

  void _generateAnsweredList() {
    final rng = Random();
    for (int i = 0; i < 100; i++) {
      if (rng.nextInt(10) % 2 == 0) {
        _answeredList.add(ibQuestion.choices[0]);
      } else {
        _answeredList.add(ibQuestion.choices[1]);
      }
    }
  }

  void _initResultMap() {
    for (final String choice in ibQuestion.choices) {
      _calculateResult(choice);
    }
  }

  void updateResult() {
    if (DateTime.now().difference(_lastResultUpdatedTime).inMilliseconds >=
        IbConfig.kUpdateResultMinCadenceInMillis) {
      print(
          'update result diff ${DateTime.now().difference(_lastResultUpdatedTime).inMilliseconds}');
      _lastResultUpdatedTime = DateTime.now();
    }
  }

  @override
  void onReady() {
    print('IbQuestionItemController ready');
  }
}
