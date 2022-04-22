import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'main_page_controller.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  final avatarUrl = ''.obs;
  double _lastOffset = 0;
  final double hideShowNavBarSensitivity = 10;
  final trendingList = <IbQuestion>[].obs;
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  RefreshController refreshController = RefreshController(initialRefresh: true);

  late StreamSubscription ibUserSub;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
    ibUserSub =
        Get.find<MainPageController>().ibUserBroadcastStream.listen((ibUser) {
      avatarUrl.value = ibUser.avatarUrl;
    });

    scrollController.addListener(() {
      if (scrollController.offset > _lastOffset &&
          scrollController.offset - _lastOffset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().hideNavBar();
      } else if (scrollController.offset < _lastOffset &&
          _lastOffset - scrollController.offset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().showNavBar();
      }
      _lastOffset = scrollController.offset;
    });
  }

  Future<void> onRefresh() async {
    refreshController.resetNoData();
    trendingList.clear();
    lastDoc = null;
    try {
      final snapshot = await IbQuestionDbService().queryTrendingQuestions();
      for (final doc in snapshot.docs) {
        trendingList.add(IbQuestion.fromJson(doc.data()));
      }

      trendingList.sort((a, b) => b.points.compareTo(a.points));

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.first;
        final lastQuestion = trendingList
            .firstWhereOrNull((element) => element.id == lastDoc!.id);
        if (lastQuestion == null) {
          refreshController.refreshCompleted();
          return;
        }
        final snap = await IbQuestionDbService()
            .queryIbQuestions(askedTimeInMs: lastQuestion.askedTimeInMs);

        for (final doc in snap.docs) {
          trendingList.add(IbQuestion.fromJson(doc.data()));
          lastDoc = doc;
        }
      }
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.loadFailed();
      print(e);
    }
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }

    final lastQuestion =
        trendingList.firstWhereOrNull((element) => element.id == lastDoc!.id);
    if (lastQuestion == null) {
      refreshController.loadNoData();
      return;
    }
    try {
      final snap = await IbQuestionDbService()
          .queryIbQuestions(askedTimeInMs: lastQuestion.askedTimeInMs);
      if (snap.docs.isEmpty) {
        refreshController.loadNoData();
        return;
      }

      for (final doc in snap.docs) {
        trendingList.add(IbQuestion.fromJson(doc.data()));
        lastDoc = doc;
      }
      refreshController.loadComplete();
    } catch (e) {
      refreshController.loadFailed();
    }
  }
}
