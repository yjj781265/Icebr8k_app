import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  List<IbQuestion> _answeredQuestions = [];
  late DocumentSnapshot? lastDocSnapShot;
  final isLoading = true.obs;
  final id = 'tCH8AIqRxWM0eEQcmlnniUIfo6F3';

  @override
  Future<void> onInit() async {
    await _initIbQuestions();
    _answeredQuestions = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    ibQuestions.removeWhere((element) => _answeredQuestions.contains(element));
    isLoading.value = false;
    super.onInit();
  }

  Future<void> _initIbQuestions() async {
    final snapshot = await IbQuestionDbService().queryQuestions(limit: 8);

    if (snapshot.docs.isNotEmpty) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(!ibQuestions.contains(ibQuestion), ibQuestion);
      }
    } else {
      lastDocSnapShot = null;
    }
  }

  Future<void> loadMoreQuestions() async {
    isLoading.value = true;
    _answeredQuestions = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    final snapshot = await IbQuestionDbService()
        .queryQuestions(limit: 8, lastDoc: lastDocSnapShot);
    if (snapshot.docs.isNotEmpty) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(
            !ibQuestions.contains(ibQuestion) &&
                !_answeredQuestions.contains(ibQuestion),
            ibQuestion);
      }
      print('IbQuestionController: loadMoreQuestions');
    } else {
      print(
          'IbQuestionController: loadMoreQuestions no more questions to load');
    }
    isLoading.value = false;
  }
}
