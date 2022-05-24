import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/ib_chat_models/ib_chat.dart';

class MyProfileController extends GetxController {
  final circles = <IbChat>[].obs;
  final asks = <IbQuestion>[].obs;
  final RefreshController askedRefreshController = RefreshController();
  late StreamSubscription asksSub;
  DocumentSnapshot? lastAskDoc;

  MyProfileController();

  @override
  Future<void> onInit() async {
    super.onInit();
    circles.value =
        await IbChatDbService().queryUserCircles(IbUtils.getCurrentUid()!);
    asksSub = IbQuestionDbService()
        .listenToAskedQuestions(IbUtils.getCurrentUid()!)
        .listen((event) {
      for (final docChange in event.docChanges) {
        if (docChange.doc.data() == null) {
          continue;
        }
        final IbQuestion q = IbQuestion.fromJson(docChange.doc.data()!);

        switch (docChange.type) {
          case DocumentChangeType.added:
            asks.add(q);
            lastAskDoc = docChange.doc;
            break;

          case DocumentChangeType.modified:
            final index = asks.indexWhere((element) => element.id == q.id);
            if (index != -1) {
              asks[index] = q;
            }
            break;
          case DocumentChangeType.removed:
            final index = asks.indexWhere((element) => element.id == q.id);
            if (index != -1) {
              asks.removeAt(index);
            }
            break;
        }
        print("askSub ${docChange.type}");
      }

      asks.refresh();
      print(asks.map((element) => element.question));
    });
  }

  Future<void> onLoadMore() async {
    if (lastAskDoc == null) {
      askedRefreshController.loadNoData();
      return;
    }

    final snapshot = await IbQuestionDbService().queryAskedQuestions(
        uid: IbUtils.getCurrentUid()!, lastDoc: lastAskDoc, publicOnly: false);

    asks.addAll(
        snapshot.docs.map((e) => IbQuestion.fromJson(e.data())).toList());
    if (snapshot.docs.isEmpty) {
      askedRefreshController.loadNoData();
      return;
    }
    askedRefreshController.loadComplete();
  }

  @override
  Future<void> onClose() async {
    await asksSub.cancel();
  }
}
