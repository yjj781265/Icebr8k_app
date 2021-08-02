import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  List<String> _answeredQuestionIds = [];
  late DocumentSnapshot? lastDocSnapShot;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    await loadQuestions();
    super.onInit();
  }

  Future<void> loadQuestions() async {
    isLoading.value = true;
    _answeredQuestionIds = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    final int loopCount = (_answeredQuestionIds.length.toDouble() / 10).ceil();

    if (loopCount == 0) {
      _queryQuestionsFromDB([]);
      return;
    }

    int counter = 0;
    print('total loop count $loopCount');
    while (counter != loopCount) {
      if (counter == (loopCount - 1)) {
        print('last loop $ibQuestions');
        final List<String> ids = _answeredQuestionIds.sublist(
            counter * 10, _answeredQuestionIds.length);
        _queryQuestionsFromDB(ids);
        counter++;
      } else {
        final start = counter * 10;
        final end = start + 10;
        final List<String> ids = _answeredQuestionIds.sublist(start, end);
        _queryQuestionsFromDB(ids);
        counter++;
        print(ibQuestions);
      }
    }
    isLoading.value = false;
  }

  Future<void> _queryQuestionsFromDB(List<String> answeredQuestionIds) async {
    final snapshot = await IbQuestionDbService()
        .queryQuestions(limit: 8, answeredQuestionIds: answeredQuestionIds);

    if (snapshot.docs.isNotEmpty) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(
            !ibQuestions.contains(ibQuestion) &&
                !_answeredQuestionIds.contains(ibQuestion.id),
            ibQuestion);
      }
    } else {
      lastDocSnapShot = null;
    }
  }
}
