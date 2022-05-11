import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'main_page_controller.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  double _lastOffset = 0;
  final double hideShowNavBarSensitivity = 10;
  final trendingList = <IbQuestion>[].obs;
  final forYourList = <IbQuestion>[].obs;
  final categories = ['Trending', 'For You'];
  final selectedCategory = 'For You'.obs;
  final isLoading = true.obs;

  DocumentSnapshot<Map<String, dynamic>>? lastFriendQuestionDoc;
  DocumentSnapshot<Map<String, dynamic>>? lastTagDoc;
  DocumentSnapshot<Map<String, dynamic>>? lastTrendingDoc;
  RefreshController refreshController = RefreshController();

  late StreamSubscription ibUserSub;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
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

    await onRefresh();
    isLoading.value = false;
  }

  Future<void> onRefresh({bool refreshStats = false}) async {
    if (selectedCategory.value == categories[0]) {
      _loadTrending(refreshStats: refreshStats);
    } else {
      _loadForYou(refreshStats: refreshStats);
    }
  }

  Future<void> _loadTrending({bool refreshStats = false}) async {
    refreshController.resetNoData();
    trendingList.clear();
    try {
      isLoading.value = true;
      final snapshot = await IbQuestionDbService().queryTrendingQuestions();

      for (final doc in snapshot.docs) {
        trendingList.addIf(
            trendingList.indexWhere((element) => element.id == doc.id) == -1,
            IbQuestion.fromJson(doc.data()));
      }

      trendingList.sort((a, b) => b.points.compareTo(a.points));

      final snap = await IbQuestionDbService().queryIbQuestions(
          askedTimeInMs: Timestamp.now().millisecondsSinceEpoch);

      final tempList = <IbQuestion>[];
      for (final doc in snap.docs) {
        tempList.addIf(
            trendingList.indexWhere((element) => element.id == doc.id) == -1,
            IbQuestion.fromJson(doc.data()));
        lastTrendingDoc = doc;
      }

      tempList.sort((a, b) => b.points.compareTo(a.points));

      trendingList.addAll(tempList);

      refreshController.refreshCompleted();
      isLoading.value = false;

      if (refreshStats) {
        await _refreshQuestionItemControllers();
      }
    } catch (e) {
      refreshController.loadFailed();
      print(e);
      isLoading.value = false;
    }
  }

  Future<void> _loadForYou({bool refreshStats = false}) async {
    refreshController.resetNoData();
    forYourList.clear();
    lastTagDoc = null;
    isLoading.value = true;
    try {
      final snapshot = await IbQuestionDbService().queryFollowedTagsQuestions();

      for (final doc in snapshot.docs) {
        forYourList.add(IbQuestion.fromJson(doc.data()));
        lastTagDoc = doc;
      }

      final snapshot2 = await IbQuestionDbService().queryFriendsQuestions();
      for (final doc in snapshot2.docs) {
        forYourList.addIf(
            forYourList.indexWhere((element) => element.id == doc.id) == -1,
            IbQuestion.fromJson(doc.data()));
        lastFriendQuestionDoc = doc;
      }

      forYourList.shuffle();
      refreshController.refreshCompleted();
      isLoading.value = false;

      if (refreshStats) {
        await _refreshQuestionItemControllers();
      }
    } catch (e) {
      refreshController.loadFailed();
      print(e);
      isLoading.value = false;
    }
  }

  Future<void> _refreshQuestionItemControllers() async {
    if (selectedCategory.value == categories[0]) {
      for (final q in trendingList) {
        if (Get.isRegistered<IbQuestionItemController>(tag: q.id)) {
          await Get.find<IbQuestionItemController>(tag: q.id).refreshStats();
        }
      }
      return;
    }

    for (final q in forYourList) {
      if (Get.isRegistered<IbQuestionItemController>(tag: q.id)) {
        await Get.find<IbQuestionItemController>(tag: q.id).refreshStats();
      }
    }
  }

  Future<void> loadMore() async {
    if (selectedCategory.value == categories[0]) {
      if (lastTrendingDoc == null) {
        refreshController.loadNoData();
        return;
      }

      final lastQuestion = trendingList
          .firstWhereOrNull((element) => element.id == lastTrendingDoc!.id);
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
          lastTrendingDoc = doc;
        }
        refreshController.loadComplete();
      } catch (e) {
        refreshController.loadFailed();
      }
    }
    if (selectedCategory.value == categories[1]) {
      if (lastTagDoc == null && lastFriendQuestionDoc == null) {
        refreshController.loadNoData();
        return;
      }

      try {
        final tempList = <IbQuestion>[];
        final snap = await IbQuestionDbService()
            .queryFollowedTagsQuestions(lastDoc: lastTagDoc);
        final snap2 = await IbQuestionDbService()
            .queryFriendsQuestions(lastDoc: lastTagDoc);

        for (final doc in snap.docs) {
          tempList.addIf(
              forYourList.indexWhere((element) => element.id == doc.id) == -1,
              IbQuestion.fromJson(doc.data()));
          lastTagDoc = doc;
        }

        for (final doc in snap2.docs) {
          tempList.addIf(
              forYourList.indexWhere((element) => element.id == doc.id) == -1,
              IbQuestion.fromJson(doc.data()));
          lastTagDoc = doc;
        }

        if (tempList.isEmpty) {
          refreshController.loadNoData();
          lastTagDoc = null;
          lastFriendQuestionDoc = null;
          return;
        }

        tempList.shuffle();
        forYourList.addAll(tempList);

        refreshController.loadComplete();
      } catch (e) {
        refreshController.loadFailed();
      }
    }
  }
}
