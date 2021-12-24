import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AskedQuestionsController extends GetxController {
  final String uid;
  final isLoading = true.obs;
  final createdQuestions = <IbQuestion>[].obs;

  late StreamSubscription _userAskedQStream;
  final refreshController = RefreshController();
  DocumentSnapshot? lastDoc;

  AskedQuestionsController(this.uid);

  @override
  void onInit() {
    super.onInit();
    _userAskedQStream = IbQuestionDbService()
        .listenToUserAskedQuestionsChange(uid)
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

      createdQuestions.removeWhere((element) => element.isAnonymous);

      createdQuestions
          .sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
      isLoading.value = false;
    });
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }
    final _snapshot = await IbQuestionDbService()
        .queryAskedQuestions(limit: 8, uid: uid, lastDoc: lastDoc);
    if (_snapshot.docs.isNotEmpty) {
      lastDoc = _snapshot.docs.last;
      print('CreatedQuestionController last doc is ${lastDoc!.data()}');

      for (final doc in _snapshot.docs) {
        final IbQuestion ibQuestion = IbQuestion.fromJson(doc.data());
        createdQuestions.addIf(
            !createdQuestions.contains(ibQuestion) && !ibQuestion.isAnonymous,
            ibQuestion);
      }
    } else {
      lastDoc = null;
    }

    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }
    refreshController.loadComplete();
  }

  Future<void> updateItems() async {
    print('AskedQuestionsController updateItems');
    for (final item in createdQuestions) {
      final tag = 'asked_${item.id}';
      if (Get.isRegistered<IbQuestionItemController>(tag: tag)) {
        final ibQuestion =
            await IbQuestionDbService().querySingleQuestion(item.id);
        if (ibQuestion != null) {
          /*  Get.find<IbQuestionItemController>(tag: tag)
              .calculateResult(ibQuestion);*/
        }
      }
    }
  }

  @override
  void onClose() {
    _userAskedQStream.cancel();
    super.onClose();
  }
}
