import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../services/user_services/ib_question_db_service.dart';

class AnsweredQuestionController extends GetxController {
  final answeredQs = <IbQuestion>[].obs;
  final RefreshController refreshController = RefreshController();
  final isLoading = true.obs;
  DocumentSnapshot? lastDoc;
  final String uid;

  AnsweredQuestionController(this.uid);

  @override
  Future<void> onInit() async {
    final snapshot = await IbQuestionDbService().queryAnsweredQuestions(uid);
    lastDoc = snapshot.size == 0 ? null : snapshot.docs.last;
    for (final doc in snapshot.docs) {
      final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
      IbCacheManager()
          .cacheSingleIbAnswer(uid: ibAnswer.uid, ibAnswer: ibAnswer);
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(ibAnswer.questionId);
      if (question != null) {
        answeredQs.add(question);
      }
    }
    isLoading.value = false;
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'AnsweredQuestionController',
        screenName: 'AnsweredPage $uid ');
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }

    try {
      final snapshot = await IbQuestionDbService()
          .queryAnsweredQuestions(uid, lastDoc: lastDoc);
      lastDoc = snapshot.size == 0 ? null : snapshot.docs.last;
      for (final doc in snapshot.docs) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
        IbCacheManager()
            .cacheSingleIbAnswer(uid: ibAnswer.uid, ibAnswer: ibAnswer);
        final IbQuestion? question = await IbQuestionDbService()
            .querySingleQuestion(ibAnswer.questionId);
        if (question != null) {
          answeredQs.add(question);
        }
      }
      refreshController.loadComplete();
    } catch (e) {
      refreshController.loadFailed();
      print('AnsweredQuestionController loadMore $e');
    }
  }
}
