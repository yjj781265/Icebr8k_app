import 'dart:math';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbQuestionItemController extends GetxController {
  final selectedChoice = ''.obs;
  final isVoted = false.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final IbQuestion ibQuestion;
  final _answeredList = <String>[];
  final resultMap = <String, double>{};
  DateTime _lastResultUpdatedTime = DateTime.now();

  IbQuestionItemController(this.ibQuestion);

  @override
  Future<void> onInit() async {
    print('IbQuestionItemController init');
    super.onInit();
    final IbUser? ibUser =
        await IbUserDbService().queryIbUser('NvpFOtXWoiVdctRgVHRy2EFxs0O2');
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

  void onVote() {
    isVoted.value = true;
  }

  void reset() {
    selectedChoice.value = '';
    isVoted.value = false;
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
