import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class CreatedQuestionController extends GetxController {
  final String uid;
  final isLoading = true.obs;
  final createdQuestions = <IbQuestion>[].obs;

  late StreamSubscription _streamSubscription;
  DocumentSnapshot? lastDoc;

  CreatedQuestionController(this.uid);

  @override
  void onInit() {
    super.onInit();
    _streamSubscription = IbQuestionDbService()
        .listenToUserCreatedQuestionsChange(uid)
        .listen((event) {
      for (final docChange in event.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final IbQuestion ibQuestion =
              IbQuestion.fromJson(docChange.doc.data()!);
          createdQuestions.addIf(
              !createdQuestions.contains(ibQuestion), ibQuestion);
        }

        if (docChange.type == DocumentChangeType.modified) {
          final IbQuestion ibQuestion =
              IbQuestion.fromJson(docChange.doc.data()!);
          if (createdQuestions.contains(ibQuestion)) {
            createdQuestions[createdQuestions.indexOf(ibQuestion)] = ibQuestion;
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          final IbQuestion ibQuestion =
              IbQuestion.fromJson(docChange.doc.data()!);
          createdQuestions.remove(ibQuestion);
        }
      }

      if (isLoading.isTrue && event.docs.isNotEmpty) {
        lastDoc = event.docs.last;
      }
      isLoading.value = false;
      createdQuestions
          .sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    });
  }

  Future<void> loadMore() async {
    final _snapshot = await IbQuestionDbService()
        .queryUserQuestions(limit: 8, uid: uid, lastDoc: lastDoc);
    if (_snapshot.docs.isNotEmpty) {
      lastDoc = _snapshot.docs.last;
      print('CreatedQuestionController last doc is ${lastDoc!.data()}');

      for (final doc in _snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(doc.data());
        createdQuestions.addIf(
            !createdQuestions.contains(ibQuestion), ibQuestion);
      }

      createdQuestions
          .sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    } else {
      lastDoc = null;
    }
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }
}
