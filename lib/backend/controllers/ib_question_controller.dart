import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  List<IbQuestion> answeredQuestions = [];
  late DocumentSnapshot? lastDocSnapShot;
  final isLoading = true.obs;
  final id = 'tCH8AIqRxWM0eEQcmlnniUIfo6F3';

  @override
  Future<void> onInit() async {
    await _initIbQuestions();
    answeredQuestions = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    ibQuestions.removeWhere((element) => answeredQuestions.contains(element));
    isLoading.value = false;
    super.onInit();
  }

  Future<void> _initIbQuestions() async {
    final snapshot = await IbQuestionDbService().queryQuestions(limit: 4);
    if (snapshot.size > 0) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(!ibQuestions.contains(ibQuestion), ibQuestion);
      }
    } else {
      lastDocSnapShot = null;
    }
  }

  Future<void> addQuestion() async {
    if (lastDocSnapShot == null) {
      return;
    }
    print('add more question');
    answeredQuestions = await IbQuestionDbService()
        .queryAnsweredQuestions(Get.find<AuthController>().firebaseUser!.uid);
    final snapshot = await IbQuestionDbService()
        .queryQuestions(limit: 4, lastDoc: lastDocSnapShot);
    if (snapshot.size > 0) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(
            !ibQuestions.contains(ibQuestion) &&
                !answeredQuestions.contains(ibQuestion),
            ibQuestion);
      }
    } else {
      lastDocSnapShot = null;
    }
  }
}
