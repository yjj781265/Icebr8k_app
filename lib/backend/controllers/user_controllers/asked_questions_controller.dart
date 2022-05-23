import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';

import '../../services/user_services/ib_question_db_service.dart';

class AskedQuestionsController extends GetxController {
  final String uid;
  final isLoading = true.obs;
  final createdQuestions = <IbQuestion>[].obs;
  final bool showPublicOnly;
  DocumentSnapshot? lastDoc;

  AskedQuestionsController(this.uid, {this.showPublicOnly = true});

  @override
  Future<void> onInit() async {
    final snapshot = await IbQuestionDbService()
        .queryAskedQuestions(uid: uid, publicOnly: showPublicOnly);
    lastDoc = snapshot.size == 0 ? null : snapshot.docs.last;
    for (final doc in snapshot.docs) {
      createdQuestions.add(IbQuestion.fromJson(doc.data()));
    }
    isLoading.value = false;
    super.onInit();
  }

  Future<void> loadMore() async {
    final snapshot = await IbQuestionDbService().queryAskedQuestions(
        uid: uid, lastDoc: lastDoc, publicOnly: showPublicOnly);
    lastDoc = snapshot.size == 0 ? null : snapshot.docs.last;
    for (final doc in snapshot.docs) {
      final IbQuestion ibQuestion = IbQuestion.fromJson(doc.data());
      createdQuestions.addIf(
          !createdQuestions.contains(ibQuestion), ibQuestion);
    }
  }
}
