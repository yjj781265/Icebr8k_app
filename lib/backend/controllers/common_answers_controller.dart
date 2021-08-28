import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// uid: not current user uid
class CommonAnswersController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  final String uid;
  late List<IbAnswer> commonAnswers;
  IbAnswer? lastIbAnswer;
  CommonAnswersController(this.uid);
  final int kPaginationMax = 8;

  @override
  Future<void> onInit() async {
    commonAnswers =
        await IbUtils.getCommonAnswersQ(IbUtils.getCurrentUid()!, uid);

    if (commonAnswers.length <= kPaginationMax) {
      for (final answer in commonAnswers) {
        final q =
            await IbQuestionDbService().querySingleQuestion(answer.questionId);
        ibQuestions.add(q);
      }
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    } else {
      for (int i = 0; i < kPaginationMax; i++) {
        final q = await IbQuestionDbService()
            .querySingleQuestion(commonAnswers[i].questionId);
        ibQuestions.add(q);
      }
      lastIbAnswer = commonAnswers[kPaginationMax - 1];
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    }

    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastIbAnswer == null) {
      return;
    }

    final int index = commonAnswers.indexOf(lastIbAnswer!);

    if (index == commonAnswers.length - 1) {
      lastIbAnswer = null;
      return;
    }

    final int endIndex = (commonAnswers.length - index) > kPaginationMax
        ? (index + kPaginationMax)
        : commonAnswers.length;
    for (int i = index + 1; i < endIndex; i++) {
      final q = await IbQuestionDbService()
          .querySingleQuestion(commonAnswers[i].questionId);
      ibQuestions.add(q);
    }
    lastIbAnswer = commonAnswers[endIndex - 1];
    ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
  }
}
