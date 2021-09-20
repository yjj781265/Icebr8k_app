import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class MyAnsweredQuestionsController extends GetxController {
  late StreamSubscription myAnsweredQStream;
  List<IbAnswer> ibAnswers = <IbAnswer>[];

  @override
  void onInit() {
    print("MyAnsweredQuestionsController init");
    super.onInit();
    myAnsweredQStream = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) {
      print(
          "MyAnsweredQuestionsController total answered questions : ${event.size}");

      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          ibAnswers.addIf(!ibAnswers.contains(ibAnswer), ibAnswer);
        } else if (docChange.type == DocumentChangeType.removed) {
          final int index = ibAnswers.indexOf(ibAnswer);
          if (index != -1) {
            ibAnswers.removeAt(index);
          }
        }
      }
    });
  }

  IbAnswer? retrieveAnswer(String questionId) {
    final int index =
        ibAnswers.indexWhere((element) => element.questionId == questionId);
    if (index == -1) {
      return null;
    }
    return ibAnswers[index];
  }

  @override
  void onClose() {
    print("MyAnsweredQuestionsController onClose");
    myAnsweredQStream.cancel();
    super.onClose();
  }
}
