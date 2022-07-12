import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../managers/Ib_analytics_manager.dart';
import '../../services/user_services/ib_question_db_service.dart';

class AskedQuestionsController extends GetxController {
  final String uid;
  final isLoading = true.obs;
  final createdQuestions = <IbQuestion>[].obs;
  final RefreshController askedRefreshController = RefreshController();
  final bool showPublicOnly;

  AskedQuestionsController(this.uid, {this.showPublicOnly = true});

  @override
  Future<void> onInit() async {
    final snapshot = await IbQuestionDbService()
        .queryAskedQuestions(uid: uid, publicOnly: showPublicOnly);
    for (final doc in snapshot.docs) {
      createdQuestions.add(IbQuestion.fromJson(doc.data()));
    }
    createdQuestions.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    isLoading.value = false;
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager().logScreenView(
        className: 'AskedQuestionsController', screenName: 'AskedPage $uid ');
  }

  Future<void> loadMore() async {
    final snapshot = await IbQuestionDbService().queryAskedQuestions(
        uid: uid,
        lastAskedTimeInMs: createdQuestions.last.askedTimeInMs,
        publicOnly: showPublicOnly);
    if (snapshot.docs.isEmpty) {
      askedRefreshController.loadNoData();
      return;
    }

    for (final doc in snapshot.docs) {
      final IbQuestion ibQuestion = IbQuestion.fromJson(doc.data());
      createdQuestions.addIf(
          !createdQuestions.contains(ibQuestion), ibQuestion);
    }
    askedRefreshController.loadComplete();
  }
}
