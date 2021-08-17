import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class MyProfileController extends GetxController {
  final myAnsweredQuestions = <AnsweredQuestionItem>[].obs;
  final isLoading = true.obs;
  late StreamSubscription myAnsweredQuestionsSub;

  @override
  void onInit() {
    myAnsweredQuestionsSub = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        final IbQuestion ibQuestion =
            await IbQuestionDbService().queryQuestion(ibAnswer.questionId);
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
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          myAnsweredQuestions.remove(item);
          print('remove new answered question');
        }
      }
      isLoading.value = false;
      myAnsweredQuestions.sort((a, b) =>
          b.ibAnswer.timeStampInMs.compareTo(a.ibAnswer.timeStampInMs));
    });
    super.onInit();
  }

  @override
  void onClose() {
    myAnsweredQuestionsSub.cancel();
    super.onClose();
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
  int get hashCode => ibQuestion.id.hashCode ^ ibAnswer.questionId.hashCode;
}
