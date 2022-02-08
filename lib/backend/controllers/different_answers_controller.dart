import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../services/user_services/ib_question_db_service.dart';

class DifferentAnswersController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  late List<String> _uncommonQuestionIds;
  final String uid;
  late List<IbAnswer> _uncommonAnswers;
  int lastIndex = 0;
  DifferentAnswersController(this.uid);
  final int kPaginationMax = 8;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    _uncommonAnswers = await IbUtils.getUncommonAnswersQ(uid);
    final questionIdMap = <String, IbAnswer>{};

    for (final IbAnswer answer in _uncommonAnswers) {
      questionIdMap[answer.questionId] = answer;
    }
    _uncommonQuestionIds = questionIdMap.keys.toList();

    if (_uncommonQuestionIds.length <= kPaginationMax) {
      for (final id in _uncommonQuestionIds) {
        final q = await IbQuestionDbService().querySingleQuestion(id);
        if (q == null || ibQuestions.contains(q)) {
          continue;
        }
        ibQuestions.add(q);
      }
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    } else {
      for (int i = 0; i < kPaginationMax; i++) {
        final q = await IbQuestionDbService()
            .querySingleQuestion(_uncommonQuestionIds[i]);
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
    if (lastIndex == 0 || lastIndex == _uncommonQuestionIds.length - 1) {
      return;
    }

    final int endIndex =
        (_uncommonQuestionIds.length - lastIndex) > kPaginationMax
            ? (lastIndex + kPaginationMax)
            : _uncommonQuestionIds.length;
    for (int i = lastIndex + 1; i < endIndex; i++) {
      final q = await IbQuestionDbService()
          .querySingleQuestion(_uncommonQuestionIds[i]);

      if (q == null || ibQuestions.contains(q)) {
        continue;
      }

      ibQuestions.add(q);
    }
    lastIndex = endIndex - 1;
  }

  List<IbAnswer> retrieveAnswers(String questionId) {
    return _uncommonAnswers
        .where((element) => element.questionId == questionId)
        .toList();
  }
}
