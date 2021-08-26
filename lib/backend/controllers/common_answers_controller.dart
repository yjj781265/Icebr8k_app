import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// uid: not current user uid
class CommonAnswersController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  final String uid;

  CommonAnswersController(this.uid);

  @override
  Future<void> onInit() async {
    final List<IbAnswer> commonAnswers =
        await IbUtils.getCommonAnswersQ(IbUtils.getCurrentUid()!, uid);
    for (final answer in commonAnswers) {
      final q =
          await IbQuestionDbService().querySingleQuestion(answer.questionId);
      ibQuestions.add(q);
    }

    super.onInit();
  }
}
