import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../services/user_services/ib_question_db_service.dart';

class AnsweredQuestionController extends GetxController {
  final refreshController = RefreshController();
  final answeredQs = <AnsweredQuestionItem>[].obs;
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
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(ibAnswer.questionId);
      if (question != null) {
        answeredQs.add(
            AnsweredQuestionItem(ibQuestion: question, ibAnswer: ibAnswer));
      }
    }
    isLoading.value = false;
    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }

    final snapshot = await IbQuestionDbService()
        .queryAnsweredQuestions(uid, lastDoc: lastDoc);
    lastDoc = snapshot.size == 0 ? null : snapshot.docs.last;
    for (final doc in snapshot.docs) {
      final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(ibAnswer.questionId);
      if (question != null) {
        answeredQs.add(
            AnsweredQuestionItem(ibQuestion: question, ibAnswer: ibAnswer));
      }
    }

    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }

    refreshController.loadComplete();
  }
}

class AnsweredQuestionItem {
  IbQuestion ibQuestion;
  IbAnswer ibAnswer;

  AnsweredQuestionItem({required this.ibQuestion, required this.ibAnswer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnsweredQuestionItem &&
          runtimeType == other.runtimeType &&
          ibQuestion.id == other.ibQuestion.id;

  @override
  int get hashCode => ibQuestion.id.hashCode;

  @override
  String toString() {
    final String str = '${ibQuestion.question} : ${ibAnswer.choiceId}';
    return str;
  }
}
