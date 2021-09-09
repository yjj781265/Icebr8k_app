import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class MyAnsweredQuestionsController extends GetxService {
  late StreamSubscription myAnsweredQStream;
  List<IbAnswer> ibAnswers = <IbAnswer>[];

  @override
  void onInit() {
    super.onInit();
    myAnsweredQStream = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          print('MyAnsweredQuestionsController added');
          ibAnswers.addIf(!ibAnswers.contains(ibAnswer), ibAnswer);
        } else if (docChange.type == DocumentChangeType.removed) {
          final int index = ibAnswers.indexOf(ibAnswer);
          if (index != -1) {
            print('MyAnsweredQuestionsController removed');
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
    myAnsweredQStream.cancel();
    super.onClose();
  }
}
