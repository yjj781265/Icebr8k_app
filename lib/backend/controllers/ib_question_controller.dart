import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  List<String> _answeredQuestionIds = [];
  DocumentSnapshot? lastDocSnapShot;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    await loadFirst8Q();
    super.onInit();
  }

  Future<void> loadFirst8Q() async {
    final int total = await IbQuestionDbService().queryTotalQuestionSize();
    _answeredQuestionIds = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    print('there are $total questions in DB, '
        'user has answered ${_answeredQuestionIds.length} questions');

    if (total == _answeredQuestionIds.length) {
      isLoading.value = false;
      return;
    }
    await _queryQuestionsFromDb();
    final int targetSize = (total - _answeredQuestionIds.length) > 8
        ? 8
        : total - _answeredQuestionIds.length;
    if (ibQuestions.length < targetSize) {
      loadFirst8Q();
    }

    isLoading.value = false;
    print('init question size ${ibQuestions.length}');
  }

  Future<void> loadQuestions() async {
    await _queryQuestionsFromDb();
  }

  Future<void> _queryQuestionsFromDb() async {
    final snapshot = await IbQuestionDbService()
        .queryQuestions(limit: 3, lastDoc: lastDocSnapShot);

    if (snapshot.docs.isNotEmpty) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(
            !ibQuestions.contains(ibQuestion) &&
                !_answeredQuestionIds.contains(ibQuestion.id),
            ibQuestion);
      }
    }
    print('ibQuestions size ${ibQuestions.length}');
  }

  Future<void> refreshQuestions() async {
    isLoading.value = true;
    lastDocSnapShot = null;
    ibQuestions.clear();
    await loadFirst8Q();
  }
}
