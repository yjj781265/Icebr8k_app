import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

import 'ib_question_item_controller.dart';

class AnsweredQuestionController extends GetxController {
  late StreamSubscription myAnsweredQuestionsSub;
  final myAnsweredQuestions = <AnsweredQuestionItem>[].obs;
  final isLoading = true.obs;
  DocumentSnapshot? lastDoc;
  final String uid;

  AnsweredQuestionController(this.uid);

  @override
  Future<void> onInit() async {
    myAnsweredQuestionsSub = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(uid, limit: 8)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        final IbQuestion? ibQuestion = await IbQuestionDbService()
            .querySingleQuestion(ibAnswer.questionId);
        if (ibQuestion == null) {
          continue;
        }

        final AnsweredQuestionItem item =
            AnsweredQuestionItem(ibQuestion: ibQuestion, ibAnswer: ibAnswer);

        if (docChange.type == DocumentChangeType.added) {
          myAnsweredQuestions.addIf(!myAnsweredQuestions.contains(item), item);
          print('added new answered question');
        }

        if (docChange.type == DocumentChangeType.modified) {
          if (myAnsweredQuestions.contains(item)) {
            myAnsweredQuestions[myAnsweredQuestions.indexOf(item)] = item;
            print('modified answered question');
            Get.find<IbQuestionItemController>(tag: 'answered_${ibQuestion.id}')
                .selectedChoice
                .value = ibAnswer.answer;
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          myAnsweredQuestions.remove(item);
          print('remove new answered question');
        }
      }

      /// prevent loadMore function to load from the start
      if (isLoading.isTrue && event.docs.isNotEmpty) {
        lastDoc = event.docs.last;
      }

      isLoading.value = false;
      myAnsweredQuestions.sort(
        (a, b) =>
            b.ibAnswer.answeredTimeInMs.compareTo(a.ibAnswer.answeredTimeInMs),
      );
    });
    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      print('AnsweredQuestionController no more');
      return;
    }
    print('AnsweredQuestionController loadMore');
    final _snapshot = await IbQuestionDbService()
        .queryAnsweredQuestions(uid, lastDoc: lastDoc);

    if (_snapshot.docs.isNotEmpty) {
      lastDoc = _snapshot.docs.last;
      print('AnsweredQuestionController last doc is ${lastDoc!.data()}');
      for (final doc in _snapshot.docs) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
        final IbQuestion? ibQuestion = await IbQuestionDbService()
            .querySingleQuestion(ibAnswer.questionId);
        if (ibQuestion == null) {
          continue;
        }
        final AnsweredQuestionItem item =
            AnsweredQuestionItem(ibQuestion: ibQuestion, ibAnswer: ibAnswer);
        myAnsweredQuestions.addIf(!myAnsweredQuestions.contains(item), item);
      }
      myAnsweredQuestions.sort(
        (a, b) =>
            b.ibAnswer.answeredTimeInMs.compareTo(a.ibAnswer.answeredTimeInMs),
      );
    } else {
      lastDoc = null;
    }
  }

  @override
  void dispose() {
    myAnsweredQuestionsSub.cancel();
    super.dispose();
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
    final String str = '${ibQuestion.question} : ${ibAnswer.answer}';
    return str;
  }
}
