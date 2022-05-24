import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'main_page_controller.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  double _lastOffset = 0;
  late StreamSubscription first8Sub;
  final double hideShowNavBarSensitivity = 10;
  bool canHideNavBar = true;
  final trendingList = <IbQuestion>[].obs;
  final forYourList = <IbQuestion>[].obs;
  final first8List = <IbQuestion>[].obs;
  final first8Map = <String, bool>{};
  final categories = ['Trending', 'For You'];
  final selectedCategory = 'For You'.obs;
  final isLocked = true.obs;
  final isLoading = true.obs;

  DocumentSnapshot<Map<String, dynamic>>? lastFriendQuestionDoc;
  DocumentSnapshot<Map<String, dynamic>>? lastTagDoc;
  DocumentSnapshot<Map<String, dynamic>>? lastTrendingDoc;
  RefreshController refreshController = RefreshController();

  StreamSubscription? ibUserSub;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController.addListener(() {
      if (!canHideNavBar) {
        return;
      }
      if (scrollController.offset > _lastOffset &&
          scrollController.offset - _lastOffset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().hideNavBar();
      } else if (scrollController.offset < _lastOffset &&
          _lastOffset - scrollController.offset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().showNavBar();
      }
      _lastOffset = scrollController.offset;
    });

    determineFeatureIsLocked().then((value) async => {await onRefresh()});
  }

  Future<void> onRefresh({bool refreshStats = false}) async {
    Get.find<MainPageController>().showNavBar();
    if (isLocked.isTrue) {
      return;
    }

    if (selectedCategory.value == categories[0]) {
      await _loadTrending(refreshStats: refreshStats);
    } else {
      await _loadForYou(refreshStats: refreshStats);
    }
  }

  Future<void> determineFeatureIsLocked() async {
    Get.find<MainPageController>().showNavBar();
    forYourList.clear();
    first8List.value = await IbQuestionDbService().queryFirst8();
    for (final q in first8List) {
      final flag = await IbQuestionDbService()
          .isQuestionAnswered(uid: IbUtils.getCurrentUid()!, questionId: q.id);
      first8Map[q.id] = flag;
      if (!flag) {
        forYourList.add(q);
      }
    }
    isLocked.value = first8Map.length == 8 && first8Map.values.contains(false);
    if (isLocked.isTrue) {
      first8Sub = IbQuestionDbService()
          .listenToUseAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
          .listen((event) async {
        for (final docChange in event.docChanges) {
          if (docChange.type == DocumentChangeType.added) {
            if (docChange.doc.data() != null) {
              final IbAnswer answer = IbAnswer.fromJson(docChange.doc.data()!);
              if (first8Map.containsKey(answer.questionId)) {
                first8Map[answer.questionId] = true;
              }
            }
          }
        }

        isLocked.value =
            first8Map.length == 8 && first8Map.values.contains(false);
        print('determineFeatureIsLocked stream $isLocked');
        if (isLocked.isFalse) {
          await first8Sub.cancel();
          onRefresh();
        }
      });
    }
    isLoading.value = false;
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
      canHideNavBar = trendingList.length > 6;
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
      if (IbUtils.getCurrentIbUser()!.tags.isNotEmpty) {
        final snapshot = await IbQuestionDbService()
            .queryFollowedTagsQuestions(tags: IbUtils.getCurrentIbUser()!.tags);
        for (final doc in snapshot.docs) {
          forYourList.add(IbQuestion.fromJson(doc.data()));
          lastTagDoc = doc;
        }
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
      canHideNavBar = forYourList.length > 6;
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
        if (IbUtils.getCurrentIbUser()!.tags.isNotEmpty) {
          final snap = await IbQuestionDbService().queryFollowedTagsQuestions(
              tags: IbUtils.getCurrentIbUser()!.tags);
          for (final doc in snap.docs) {
            tempList.addIf(
                forYourList.indexWhere((element) => element.id == doc.id) == -1,
                IbQuestion.fromJson(doc.data()));
            lastTagDoc = doc;
          }
        }

        final snap2 = await IbQuestionDbService()
            .queryFriendsQuestions(lastDoc: lastTagDoc);

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
