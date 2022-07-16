import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../managers/Ib_analytics_manager.dart';
import '../../services/user_services/ib_local_data_service.dart';
import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

class IbQuestionItemController extends GetxController {
  final Rx<IbQuestion> rxIbQuestion;
  Rx<IbChoice> rxNewChoice = IbChoice(choiceId: '', content: '').obs;
  Timer? _timer;
  final voted = false.obs;
  final isAnswering = false.obs;
  final RxBool rxIsSample;

  /// for compare two users answers
  final List<IbAnswer> ibAnswers;
  IbAnswer? myAnswer;
  final RxBool rxIsExpanded;

  /// show the picked option from multiple people
  final showComparison = false.obs;
  final answeredUsername = ''.obs;
  final liked = false.obs;
  final commented = false.obs;
  final selectedChoiceId = ''.obs;
  final title = ''.obs;
  final avatarUrl = ''.obs;
  final compScore = 0.0.obs;
  final resultMap = <IbChoice, double>{}.obs;
  final sharedCircles = <ChatTabItem>[].obs;
  final RxBool isShowCase;

  //start
  // variables for poll stat main page
  final RxMap<IbChoice, Set<IbUser>> choiceUserMap =
      <IbChoice, Set<IbUser>>{}.obs;
  final RxList<IbUser> friendVotedList = <IbUser>[].obs;
  //end

  /// vote count for each choice id
  RxMap<String, int> countMap = <String, int>{}.obs;

  /// flag for closed poll
  final isPollClosed = false.obs;

  IbUser? creatorUser;

  /// Global keys for showcase
  final GlobalKey expandShowCaseKey = GlobalKey();
  final GlobalKey voteOptionsShowCaseKey = GlobalKey();
  final GlobalKey quizShowCaseKey = GlobalKey();

  IbQuestionItemController({
    required this.rxIbQuestion,
    required this.rxIsExpanded,
    required this.rxIsSample,
    required this.isShowCase,
    this.ibAnswers = const [],
  });

  @override
  Future<void> onReady() async {
    await initData();
    if (isShowCase.isTrue &&
        !IbLocalDataService()
            .retrieveBoolValue(StorageKey.pollExpandShowCaseBool)) {
      ShowCaseWidget.of(expandShowCaseKey.currentContext!)
          .startShowCase([expandShowCaseKey]);
    }
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  Future<void> initData() async {
    countMap.clear();
    resultMap.clear();
    choiceUserMap.clear();
    showComparison.value = ibAnswers.isNotEmpty;

    /// query question poll creator user info
    creatorUser =
        await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);

    if (creatorUser != null) {
      title.value = creatorUser!.username;
      avatarUrl.value = creatorUser!.avatarUrl;
      compScore.value = await IbUtils().getCompScore(uid: creatorUser!.id);
    }
    if (rxIsSample.isFalse) {
      commented.value =
          await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
      liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
      await _getMyAnswerAndDeterminedPollCloseStatus();
      await _generatePollStats();
      await _generateChoiceUserMap();
      await _getFriendVotedList();
      _setUpCountDownTimer();
    }
  }

  /// refresh poll result, comments, likes,
  Future<void> refreshStats() async {
    commented.value =
        await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
    liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
    await _generatePollStats();
    await _generateChoiceUserMap();
    await _getMyAnswerAndDeterminedPollCloseStatus();
    await _getFriendVotedList();
  }

  Future<void> addChoice(IbChoice choice) async {
    final bool isDuplicated = rxIbQuestion.value.choices
        .where((element) => element.content == choice.content)
        .isNotEmpty;
    if (isDuplicated) {
      IbUtils().showSimpleSnackBar(
          msg: "This choice already exists.",
          backgroundColor: IbColors.primaryColor);
      return;
    }

    if (rxIbQuestion.value.questionType == QuestionType.multipleChoicePic) {
      if (choice.url == null ||
          choice.url!.isEmpty ||
          choice.content == null ||
          choice.content!.isEmpty) {
        Get.dialog(IbDialog(
            subtitle: 'mc_pic_question_not_valid'.tr,
            showNegativeBtn: false,
            title: 'Error',
            positiveTextKey: 'ok'));
        return;
      }
    }

    IbUtils().showSimpleSnackBar(
        msg: "Adding a new choice...", backgroundColor: IbColors.primaryColor);
    if (choice.url != null && !choice.url!.contains('http')) {
      final String? url = await IbStorageService()
          .uploadAndRetrieveImgUrl(filePath: choice.url!);
      if (url == null) {
        IbUtils().showSimpleSnackBar(
            msg: 'Failed to upload images...',
            backgroundColor: IbColors.errorRed);
        return;
      } else {
        choice.url = url;
      }
    }

    await IbQuestionDbService()
        .addChoice(questionId: rxIbQuestion.value.id, ibChoice: choice);

    await refreshStats();
    rxNewChoice.value = IbChoice(choiceId: '', content: '');
    rxNewChoice.refresh();
    IbUtils().showSimpleSnackBar(
        msg: "New choice added", backgroundColor: IbColors.accentColor);
  }

  void _setUpCountDownTimer() {
    if (_timer == null &&
        rxIbQuestion.value.endTimeInMs >=
            DateTime.now().millisecondsSinceEpoch &&
        DateTime.fromMillisecondsSinceEpoch(rxIbQuestion.value.endTimeInMs)
                .difference(DateTime.now())
                .inMinutes <=
            5) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (rxIbQuestion.value.endTimeInMs <
            DateTime.now().millisecondsSinceEpoch) {
          isPollClosed.value = DateTime.now().millisecondsSinceEpoch >
                  rxIbQuestion.value.endTimeInMs &&
              rxIbQuestion.value.endTimeInMs > 0;
          timer.cancel();
        }
        print('${rxIbQuestion.value.question} tick tok');
        rxIbQuestion.refresh();
      });
    }
  }

  Future<Map<String, int>> _getChoiceCountMap() async {
    final map = <String, int>{};
    for (final ibChoice in rxIbQuestion.value.choices) {
      map[ibChoice.choiceId] = await IbQuestionDbService()
          .querySpecificAnswerPollSize(
              questionId: rxIbQuestion.value.id, choiceId: ibChoice.choiceId);
    }
    return map;
  }

  Future<void> _getMyAnswerAndDeterminedPollCloseStatus() async {
    myAnswer = await IbQuestionDbService()
        .querySingleIbAnswer(IbUtils().getCurrentUid()!, rxIbQuestion.value.id);
    if (myAnswer != null) {
      selectedChoiceId.value = myAnswer!.choiceId;
    } else {
      selectedChoiceId.value = '';
    }
    isPollClosed.value = DateTime.now().millisecondsSinceEpoch >
            rxIbQuestion.value.endTimeInMs &&
        rxIbQuestion.value.endTimeInMs > 0;

    /// flag for enabling user to open result page
    voted.value = myAnswer != null || isPollClosed.value;
    voted.refresh();
  }

  Future<void> _generatePollStats() async {
    countMap.clear();
    final q =
        await IbQuestionDbService().querySingleQuestion(rxIbQuestion.value.id);
    if (q == null) {
      return;
    }

    if (countMap.isEmpty) {
      countMap.value = await _getChoiceCountMap();
    }

    for (final IbChoice ibChoice in q.choices) {
      resultMap[ibChoice] =
          (countMap[ibChoice.choiceId] ?? 0).toDouble() / q.pollSize.toDouble();
    }
    // put the popular vote on top
    q.choices.sort((a, b) =>
        (countMap[b.choiceId] ?? 0).compareTo(countMap[a.choiceId] ?? 0));
    rxIbQuestion.value = q;
    rxIbQuestion.refresh();
  }

  Future<void> _getFriendVotedList() async {
    friendVotedList.clear();
    final unBlockedUids = IbUtils().getCurrentIbUserUnblockedFriendsId();
    for (final uid in unBlockedUids) {
      final answers = IbCacheManager().getIbAnswers(uid) ?? [];
      if (answers.indexWhere(
              (element) => element.questionId == rxIbQuestion.value.id) !=
          -1) {
        final user = await retrieveUser(uid);
        if (user != null) {
          friendVotedList.add(user);
        }
      }
    }
  }

  Future<void> _generateChoiceUserMap() async {
    choiceUserMap.clear();
    const int kLimit = 4;
    final unBlockedUids = IbUtils().getCurrentIbUserUnblockedFriendsId();
    for (final IbChoice choice in rxIbQuestion.value.choices) {
      final Set<IbUser> users = {};

      /// add friends answers first if Available
      for (final uid in unBlockedUids) {
        final answers = IbCacheManager().getIbAnswers(uid) ?? [];
        final answer = answers
            .firstWhereOrNull((element) => element.choiceId == choice.choiceId);
        if (answer == null) {
          continue;
        } else {
          if (users.length >= kLimit) {
            break;
          }
          final user = await retrieveUser(answer.uid);
          if (user != null) {
            users.add(user);
          }
        }
      }
      if (users.length >= kLimit) {
        choiceUserMap[choice] = users;
      } else {
        final snapshot = await IbQuestionDbService().queryIbAnswers(
            choiceId: choice.choiceId,
            questionId: rxIbQuestion.value.id,
            limit: kLimit - users.length);
        final List<IbAnswer> ibAnswers = [];
        for (final doc in snapshot.docs) {
          ibAnswers.add(IbAnswer.fromJson(doc.data()));
        }

        for (final IbAnswer answer in ibAnswers) {
          final user = await retrieveUser(answer.uid);
          if (user != null) {
            users.add(user);
          }
        }
        choiceUserMap[choice] = users;
      }
    }
  }

  Future<void> onVote({bool isAnonymous = false}) async {
    // don't let user vote if poll is closed
    if (rxIbQuestion.value.endTimeInMs <
            DateTime.now().millisecondsSinceEpoch &&
        rxIbQuestion.value.endTimeInMs > 0) {
      return;
    }

    if (selectedChoiceId.value.isEmpty) {
      return;
    }

    if (myAnswer != null &&
        myAnswer!.isAnonymous == isAnonymous &&
        selectedChoiceId.value == myAnswer!.choiceId) {
      return;
    }

    if (isAnswering.value) {
      return;
    }

    isAnswering.value = true;

    try {
      final IbAnswer ibAnswer = IbAnswer(
          choiceId: selectedChoiceId.value,
          isAnonymous: isAnonymous,
          isPublicQuestion: rxIbQuestion.value.isPublic,
          edited: myAnswer != null,
          answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
          askedTimeInMs: rxIbQuestion.value.askedTimeInMs,
          uid: IbUtils().getCurrentUid()!,
          questionId: rxIbQuestion.value.id,
          questionType: rxIbQuestion.value.questionType);
      await IbQuestionDbService().answerQuestion(ibAnswer);

      if (!isAnonymous) {
        await IbAnalyticsManager()
            .logCustomEvent(name: 'vote', data: {'type': 'public'});
        IbUtils().showSimpleSnackBar(
            msg: 'Voted Publicly 📢', backgroundColor: IbColors.primaryColor);
      } else {
        await IbAnalyticsManager()
            .logCustomEvent(name: 'vote', data: {'type': 'anonymous'});
        IbUtils().showSimpleSnackBar(
            msg: 'Voted Anonymously 🤫', backgroundColor: Colors.black);
      }

      if (myAnswer != null) {
        ///decrement old countMap;
        final int decrementedCount = (countMap[myAnswer!.choiceId] ?? 0) - 1;
        countMap[myAnswer!.choiceId] =
            decrementedCount < 0 ? 0 : decrementedCount;
        myAnswer = ibAnswer;
      } else {
        myAnswer = ibAnswer;
        rxIbQuestion.value.pollSize++;
      }

      final int incrementedCount = (countMap[ibAnswer.choiceId] ?? 0) + 1;
      countMap[ibAnswer.choiceId] = incrementedCount;

      /// update result
      for (final IbChoice ibChoice in rxIbQuestion.value.choices) {
        resultMap[ibChoice] = (countMap[ibChoice.choiceId] ?? 0).toDouble() /
            rxIbQuestion.value.pollSize.toDouble();
      }
      // put the popular vote on top
      rxIbQuestion.value.choices.sort((a, b) =>
          (countMap[b.choiceId] ?? 0).compareTo(countMap[a.choiceId] ?? 0));
      await _generateChoiceUserMap();

      voted.value = true;
    } catch (e) {
      voted.value = false;
      IbUtils().showSimpleSnackBar(
          msg: "Failed to vote $e", backgroundColor: IbColors.errorRed);
    } finally {
      if (creatorUser != null) {
        compScore.value = await IbUtils().getCompScore(uid: creatorUser!.id);
      }
      isAnswering.value = false;
      rxIbQuestion.refresh();
      choiceUserMap.refresh();
      countMap.refresh();
    }
  }

  Future<void> updateLike() async {
    liked.value = !liked.value;
    if (liked.isTrue) {
      rxIbQuestion.value.likes++;
      await IbQuestionDbService().updateLikes(rxIbQuestion.value.id);
    } else {
      rxIbQuestion.value.likes--;
      await IbQuestionDbService().removeLikes(rxIbQuestion.value.id);
    }

    await IbAnalyticsManager()
        .logCustomEvent(name: 'liked_poll', data: {'value': liked.value});
  }

  Future<IbUser?> retrieveUser(String uid) async {
    final IbUser? user;
    if (IbCacheManager().getIbUser(uid) == null) {
      user = await IbUserDbService().queryIbUser(uid);
      IbCacheManager().cacheIbUser(user);
    } else {
      user = IbCacheManager().getIbUser(uid);
    }
    return user;
  }

  Future<void> deleteQuestion() async {
    if (rxIbQuestion.value.creatorId != IbUtils().getCurrentUid()) {
      return;
    }
    try {
      Get.dialog(
        IbDialog(
            title: 'Are you sure to delete this question?',
            subtitle: 'All votes, comments, and likes will be erased',
            onPositiveTap: () async {
              Get.back();
              Get.dialog(const IbLoadingDialog(messageTrKey: 'Deleting...'),
                  barrierDismissible: false);
              await IbQuestionDbService().deleteQuestion(rxIbQuestion.value.id);
              IbUtils().masterDeleteSingleQuestion(rxIbQuestion.value);
              Get.back();
              IbUtils().showSimpleSnackBar(
                  msg: 'Question Deleted', backgroundColor: IbColors.errorRed);
            }),
      );
    } catch (e) {
      Get.dialog(IbDialog(title: "Error", subtitle: e.toString()));
    }
  }
}
