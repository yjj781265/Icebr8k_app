import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../managers/Ib_analytics_manager.dart';
import '../../models/ib_chat_models/ib_chat.dart';

class MyProfileController extends GetxController {
  final circles = <IbChat>[].obs;
  final asks = <IbQuestion>[].obs;
  final RefreshController askedRefreshController = RefreshController();
  late StreamSubscription asksSub;
  late StreamSubscription circleSub;
  DocumentSnapshot? lastAskDoc;

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager().logScreenView(
        className: 'MyProfileController', screenName: 'MyProfilePage');
    super.onReady();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    circleSub = IbChatDbService().listenToCircles().listen((event) {
      for (final docChange in event.docChanges) {
        if (docChange.doc.data() == null) {
          continue;
        }
        final ibChat = IbChat.fromJson(docChange.doc.data()!);

        switch (docChange.type) {
          case DocumentChangeType.added:
            circles.add(ibChat);
            break;
          case DocumentChangeType.modified:
            final int index = circles
                .indexWhere((element) => element.chatId == ibChat.chatId);
            if (index != -1) {
              circles[index] = ibChat;
            }
            break;
          case DocumentChangeType.removed:
            final int index = circles
                .indexWhere((element) => element.chatId == ibChat.chatId);
            if (index != -1) {
              circles.removeAt(index);
            }
            break;
        }
      }
    });
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
      asks.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
      asks.refresh();
    });
  }

  Future<void> onLoadMore() async {
    if (asks.isEmpty) {
      askedRefreshController.loadNoData();
      return;
    }
    final snapshot = await IbQuestionDbService().queryAskedQuestions(
        uid: IbUtils.getCurrentUid()!,
        lastAskedTimeInMs: asks.last.askedTimeInMs,
        publicOnly: false);
    if (snapshot.docs.isEmpty) {
      askedRefreshController.loadNoData();
      return;
    }

    asks.addAll(
        snapshot.docs.map((e) => IbQuestion.fromJson(e.data())).toList());

    asks.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    asks.refresh();

    askedRefreshController.loadComplete();
  }

  @override
  Future<void> onClose() async {
    await asksSub.cancel();
    await circleSub.cancel();
  }
}
