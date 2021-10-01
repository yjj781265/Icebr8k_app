import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class MyAnsweredQuestionsController extends GetxController {
  late StreamSubscription myAnsweredQStream;
  final Stream<QuerySnapshot<Map<String, dynamic>>> broadcastStream =
      IbQuestionDbService()
          .listenToAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
          .asBroadcastStream();
  List<IbAnswer> ibAnswers = <IbAnswer>[];
  final isLoaded = false.obs;

  @override
  void onInit() {
    isLoaded.value = false;
    print("MyAnsweredQuestionsController init");
    super.onInit();
    myAnsweredQStream = broadcastStream.listen((event) {
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
    }, onDone: () {
      isLoaded.value = true;
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
