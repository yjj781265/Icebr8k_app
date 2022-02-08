import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../services/user_services/ib_question_db_service.dart';

/// uid: not current user uid
class CommonAnswersController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  late List<String> _commonQuestionIds;
  late List<IbAnswer> _commonAnswers;
  final String uid;
  int lastIndex = 0;
  final int kPaginationMax = 8;
  final isLoading = true.obs;

  CommonAnswersController(this.uid);
  @override
  Future<void> onInit() async {
    _commonAnswers = await IbUtils.getCommonAnswersQ(uid);
    final questionIdMap = <String, IbAnswer>{};
    for (final IbAnswer answer in _commonAnswers) {
      questionIdMap[answer.questionId] = answer;
    }
    _commonQuestionIds = questionIdMap.keys.toList();

    if (_commonQuestionIds.length <= kPaginationMax) {
      for (final questionId in questionIdMap.keys) {
        final q = await IbQuestionDbService().querySingleQuestion(questionId);
        if (q == null || ibQuestions.contains(q)) {
          continue;
        }
        ibQuestions.add(q);
      }
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    } else {
      for (int i = 0; i < kPaginationMax; i++) {
        final q = await IbQuestionDbService()
            .querySingleQuestion(_commonQuestionIds[i]);
        if (q == null || ibQuestions.contains(q)) {
          continue;
        }
        ibQuestions.add(q);
      }
      lastIndex = kPaginationMax - 1;
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    }
    isLoading.value = false;
    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastIndex == 0 || lastIndex == _commonQuestionIds.length - 1) {
      return;
    }

    final int endIndex =
        (_commonQuestionIds.length - lastIndex) > kPaginationMax
            ? (lastIndex + kPaginationMax)
            : _commonQuestionIds.length;
    for (int i = lastIndex + 1; i < endIndex; i++) {
      final q = await IbQuestionDbService()
          .querySingleQuestion(_commonQuestionIds[i]);
      if (q == null || ibQuestions.contains(q)) {
        continue;
      }
      ibQuestions.add(q);
    }
    lastIndex = endIndex - 1;
  }

  List<IbAnswer> retrieveAnswers(String questionId) {
    return _commonAnswers
        .where((element) => element.questionId == questionId)
        .toList();
  }
}
