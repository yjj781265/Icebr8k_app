import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  DocumentSnapshot? lastDocSnapShot;
  late StreamSubscription questionSub;
  final isLoading = true.obs;

  @override
  Future<void> onInit() async {
    lastDocSnapShot = await IbQuestionDbService()
        .queryLastAnsweredQ(IbUtils.getCurrentUid()!);
    questionSub = IbQuestionDbService()
        .listenToIbQuestionsChange(lastDoc: lastDocSnapShot)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbQuestion ibQuestion =
            IbQuestion.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          print('new questions');
          ibQuestions.addIf(!ibQuestions.contains(ibQuestion), ibQuestion);
        }

        if (docChange.type == DocumentChangeType.removed) {
          ibQuestions.remove(ibQuestion);
        }

        if (docChange.type == DocumentChangeType.modified) {
          if (ibQuestions.contains(ibQuestion)) {
            ibQuestions[ibQuestions.indexOf(ibQuestion)] = ibQuestion;
          }
        }
      }
      if (isLoading.isTrue && event.docs.isNotEmpty) {
        lastDocSnapShot = event.docs.last;
      }

      isLoading.value = false;
    });
    super.onInit();
  }

  @override
  void onClose() {
    questionSub.cancel();
    super.onClose();
  }

  Future<void> queryQuestionsFromDb() async {
    final snapshot = await IbQuestionDbService()
        .queryQuestions(limit: 3, lastDoc: lastDocSnapShot);

    if (snapshot.docs.isNotEmpty) {
      lastDocSnapShot = snapshot.docs[snapshot.size - 1];
      for (final docSnapShot in snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(docSnapShot.data());
        ibQuestions.addIf(!ibQuestions.contains(ibQuestion), ibQuestion);
      }
    }
  }

  Future<void> refreshQuestions() async {
    print(' IbQuestionController refreshQuestions');
    isLoading.value = true;
    ibQuestions.clear();
    await queryQuestionsFromDb();
    isLoading.value = false;
  }
}
