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

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      selectedChoice.value = '';
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
  }

  Future<void> _calculateResult(
      {required String answer, required double totalPollSize}) async {
    double _result = 0.0;
    final double _answerPollSize = (await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: answer))
        .toDouble();
    print('$answer, $_answerPollSize');
    _result = _answerPollSize / totalPollSize;
    resultMap.update(answer, (_) => _result, ifAbsent: () => _result);
  }

  Future<void> onVote() async {
    if (isVoted.value || selectedChoice.value.isEmpty) {
      return;
    }
    voteBtnTrKey.value = 'voting';
    await IbQuestionDbService().answerQuestion(
        answer: selectedChoice.value,
        questionId: ibQuestion.id,
        uid: Get.find<AuthController>().firebaseUser!.uid);

    await _initResultMap();
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

  Future<void> _initResultMap() async {
    final double _pollSize =
        (await IbQuestionDbService().queryPollSize(ibQuestion.id)).toDouble();

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      for (final String choice in ibQuestion.choices) {
        await _calculateResult(answer: choice, totalPollSize: _pollSize);
      }
    } else {
      for (int i = 1; i <= 5; i++) {
        await _calculateResult(answer: i.toString(), totalPollSize: _pollSize);
      }
    }
    print(resultMap);
  }

  Future<void> updateResult() async {
    if (DateTime.now().difference(_lastResultUpdatedTime).inMilliseconds >=
            IbConfig.kUpdateResultMinCadenceInMillis &&
        isVoted.isTrue &&
        !isSample) {
      _lastResultUpdatedTime = DateTime.now();
      await _initResultMap();
      print('updateResult for ${ibQuestion.question}');
    }
  }
}
