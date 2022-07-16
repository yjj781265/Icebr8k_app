import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../managers/Ib_analytics_manager.dart';
import '../../services/user_services/ib_question_db_service.dart';
import 'ib_question_item_controller.dart';

class QuestionResultDetailPageController extends GetxController {
  final IbQuestionItemController itemController;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  final RefreshController refreshController = RefreshController();
  final results = <ResultItemUserModel>[].obs;
  final IbChoice ibChoice;
  final isLoading = false.obs;

  QuestionResultDetailPageController(
      {required this.itemController, required this.ibChoice});

  @override
  Future<void> onInit() async {
    super.onInit();
    _initData();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'QuestionResultDetailPageController',
        screenName: 'QuestionResultDetailPage');
  }

  Future<void> _initData() async {
    isLoading.value = true;
    results.clear();
    try {
      /// add friends answers first if Available
      final unBlockedUids = IbUtils().getCurrentIbUserUnblockedFriendsId();
      final temp = <ResultItemUserModel>[];
      for (final uid in unBlockedUids) {
        final answers = IbCacheManager().getIbAnswers(uid) ?? [];
        final answer = answers.firstWhereOrNull(
            (element) => element.choiceId == ibChoice.choiceId);
        if (answer == null) {
          continue;
        } else {
          late IbUser? ibUser;
          if (IbCacheManager().getIbUser(uid) == null) {
            ibUser = await IbUserDbService().queryIbUser(uid);
            IbCacheManager().cacheIbUser(ibUser);
          } else {
            ibUser = IbCacheManager().getIbUser(uid);
          }

          if (ibUser == null) {
            continue;
          }
          final double compScore = await IbUtils().getCompScore(uid: uid);
          temp.add(ResultItemUserModel(
              user: ibUser,
              compScore: compScore,
              answeredTimestampInMs: answer.answeredTimeInMs));
          temp.sort((a, b) => b.compScore.compareTo(a.compScore));
        }
      }
      final snapshot = await IbQuestionDbService().queryIbAnswers(
          choiceId: ibChoice.choiceId,
          questionId: itemController.rxIbQuestion.value.id);

      for (final doc in snapshot.docs) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
        final double compScore =
            await IbUtils().getCompScore(uid: ibAnswer.uid);
        if (temp.indexWhere((element) => element.user.id == ibAnswer.uid) !=
            -1) {
          continue;
        }

        late IbUser? ibUser;
        if (IbCacheManager().getIbUser(ibAnswer.uid) == null) {
          ibUser = await IbUserDbService().queryIbUser(ibAnswer.uid);
          IbCacheManager().cacheIbUser(ibUser);
        } else {
          ibUser = IbCacheManager().getIbUser(ibAnswer.uid);
        }

        if (ibUser == null) {
          continue;
        }

        results.add(ResultItemUserModel(
            user: ibUser,
            compScore: compScore,
            answeredTimestampInMs: ibAnswer.answeredTimeInMs));
      }

      if (snapshot.docs.isNotEmpty) {
        lastSnap = snapshot.docs.last;
      }

      results.sort((a, b) => b.compScore.compareTo(a.compScore));
      results.insertAll(0, temp);
    } catch (e) {
      IbUtils().showSimpleSnackBar(
          msg: "Failed to load results $e", backgroundColor: IbColors.errorRed);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (lastSnap == null) {
      refreshController.loadNoData();
      return;
    }
    if (lastSnap != null) {
      try {
        final snapshot = await IbQuestionDbService().queryIbAnswers(
            lastSnap: lastSnap,
            choiceId: ibChoice.choiceId,
            questionId: itemController.rxIbQuestion.value.id);

        for (final doc in snapshot.docs) {
          final IbAnswer ibAnswer = IbAnswer.fromJson(doc.data());
          if (results
                  .indexWhere((element) => element.user.id == ibAnswer.uid) !=
              -1) {
            continue;
          }
          final double compScore =
              await IbUtils().getCompScore(uid: ibAnswer.uid);
          late IbUser? ibUser;
          if (IbCacheManager().getIbUser(ibAnswer.uid) == null) {
            ibUser = await IbUserDbService().queryIbUser(ibAnswer.uid);
            IbCacheManager().cacheIbUser(ibUser);
          } else {
            ibUser = IbCacheManager().getIbUser(ibAnswer.uid);
          }

          if (ibUser == null) {
            continue;
          }
          results.add(ResultItemUserModel(
              user: ibUser,
              compScore: compScore,
              answeredTimestampInMs: ibAnswer.answeredTimeInMs));
        }

        if (snapshot.docs.isNotEmpty) {
          lastSnap = snapshot.docs.last;
          refreshController.loadComplete();
        } else {
          lastSnap = null;
          refreshController.loadNoData();
        }
      } catch (e) {
        refreshController.loadFailed();
      } finally {
        results.sort((a, b) => b.compScore.compareTo(a.compScore));
      }
    }
  }
}

class ResultItemUserModel {
  IbUser user;
  double compScore;
  int answeredTimestampInMs;

  ResultItemUserModel(
      {required this.user,
      required this.compScore,
      required this.answeredTimestampInMs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultItemUserModel &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}
