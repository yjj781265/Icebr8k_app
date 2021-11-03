import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class DifferentAnswersController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  final String uid;
  late List<IbAnswer> uncommonAnswers;
  IbAnswer? lastIbAnswer;
  DifferentAnswersController(this.uid);
  final int kPaginationMax = 8;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    uncommonAnswers = await IbUtils.getUncommonAnswersQ(uid);

    if (uncommonAnswers.length <= kPaginationMax) {
      for (final answer in uncommonAnswers) {
        final q =
            await IbQuestionDbService().querySingleQuestion(answer.questionId);
        if (q == null) {
          continue;
        }
        ibQuestions.add(q);
      }
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    } else {
      for (int i = 0; i < kPaginationMax; i++) {
        final q = await IbQuestionDbService()
            .querySingleQuestion(uncommonAnswers[i].questionId);
        if (q == null) {
          continue;
        }
        ibQuestions.add(q);
      }
      lastIbAnswer = uncommonAnswers[kPaginationMax - 1];
      ibQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    }

    isLoading.value = false;
    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastIbAnswer == null) {
      return;
    }

    final int index = uncommonAnswers.indexOf(lastIbAnswer!);

    if (index == uncommonAnswers.length - 1) {
      lastIbAnswer = null;
      return;
    }

    final int endIndex = (uncommonAnswers.length - index) > kPaginationMax
        ? (index + kPaginationMax)
        : uncommonAnswers.length;
    for (int i = index + 1; i < endIndex; i++) {
      final q = await IbQuestionDbService()
          .querySingleQuestion(uncommonAnswers[i].questionId);
      if (q == null) {
        continue;
      }
      ibQuestions.add(q);
    }
    lastIbAnswer = uncommonAnswers[endIndex - 1];
  }

  IbAnswer? retrieveAnswer(String questionId) {
    final int index = uncommonAnswers
        .indexWhere((element) => element.questionId == questionId);
    if (index == -1) {
      return null;
    }
    return uncommonAnswers[index];
  }
}
