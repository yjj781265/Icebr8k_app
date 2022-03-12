import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CompareController extends GetxController {
  final isLoading = true.obs;
  final String title;
  final List<String> questionIds;
  final List<String> uids;
  final RefreshController refreshController = RefreshController();
  final items = <IbQuestion, List<IbAnswer>>{}.obs;

  String? lastQuestionId;

  final int kMaxPerPage = 8;

  CompareController(
      {required this.questionIds, required this.uids, required this.title});

  @override
  Future<void> onInit() async {
    super.onInit();
    for (int i = 0;
        i <
            (questionIds.length > kMaxPerPage
                ? kMaxPerPage
                : questionIds.length);
        i++) {
      lastQuestionId = questionIds[i];
      final IbQuestion? ibQuestion =
          await IbQuestionDbService().querySingleQuestion(questionIds[i]);
      if (ibQuestion == null) {
        continue;
      }

      final List<IbAnswer> ibAnswers =
          await IbUtils.getIbAnswers(uids: uids, questionId: questionIds[i]);

      if (ibAnswers.length < uids.length) {
        continue;
      }

      items[ibQuestion] = ibAnswers;
    }
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    final int index = questionIds.indexOf(lastQuestionId!);
    if (index + 1 > questionIds.length - 1) {
      lastQuestionId = null;
    }

    if (lastQuestionId == null) {
      refreshController.loadNoData();
      return;
    }

    for (int i = index + 1;
        i <
            (questionIds.length - index + 1 > kMaxPerPage
                ? index + 1 + kMaxPerPage
                : questionIds.length);
        i++) {
      lastQuestionId = questionIds[i];
      final IbQuestion? ibQuestion =
          await IbQuestionDbService().querySingleQuestion(questionIds[i]);
      if (ibQuestion == null) {
        continue;
      }

      final List<IbAnswer> ibAnswers =
          await IbUtils.getIbAnswers(uids: uids, questionId: questionIds[i]);

      if (ibAnswers.length < uids.length) {
        continue;
      }

      items[ibQuestion] = ibAnswers;
    }
    refreshController.loadComplete();
  }
}
