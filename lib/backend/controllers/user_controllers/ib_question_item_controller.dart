import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_tag_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';
import 'chat_tab_controller.dart';

class IbQuestionItemController extends GetxController {
  final Rx<IbQuestion> rxIbQuestion;
  Timer? _timer;
  final voted = false.obs;
  final isAnswering = false.obs;
  final bool isSample;

  /// for compare two users answers
  final List<IbAnswer>? ibAnswers;
  final RxBool rxIsExpanded;

  /// show the picked option from multiple people
  final showComparison = false.obs;

  /// if user already answered, pass the answer here
  Rx<IbAnswer>? rxIbAnswer;
  final answeredUsername = ''.obs;
  final liked = false.obs;
  final commented = false.obs;
  final selectedChoiceId = ''.obs;
  final title = ''.obs;
  final avatarUrl = ''.obs;
  final compScore = 0.0.obs;
  final resultMap = <IbChoice, double>{}.obs;
  final RxList<IbTag> ibTags = <IbTag>[].obs;
  final sharedCircles = <ChatTabItem>[].obs;

  //start
  // variables for poll stat main page
  final RxMap<IbChoice, Set<IbUser>> choiceUserMap =
      <IbChoice, Set<IbUser>>{}.obs;
  //end

  /// vote count for each choice id
  RxMap<String, int> countMap = <String, int>{}.obs;

  /// flag for closed poll
  final isPollClosed = false.obs;

  IbUser? creatorUser;

  IbQuestionItemController({
    required this.rxIbQuestion,
    required this.rxIsExpanded,
    this.isSample = false,
    this.ibAnswers,
  });

  @override
  Future<void> onInit() async {
    await initData();
    super.onInit();
  }

  Future<void> initData() async {
    countMap.clear();
    ibTags.clear();
    resultMap.clear();
    choiceUserMap.clear();
    showComparison.value = ibAnswers != null && ibAnswers!.isNotEmpty;

    /// query question poll creator user info
    creatorUser =
        await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);

    if (creatorUser != null) {
      title.value = creatorUser!.username;
      avatarUrl.value = creatorUser!.avatarUrl;
      compScore.value = await IbUtils.getCompScore(uid: creatorUser!.id);
    }
    if (!isSample) {
      if (rxIbAnswer == null) {
        /// query my answer to this question
        final myAnswer = await IbQuestionDbService().querySingleIbAnswer(
            IbUtils.getCurrentUid()!, rxIbQuestion.value.id);
        if (myAnswer != null) {
          rxIbAnswer = myAnswer.obs;
          selectedChoiceId.value = rxIbAnswer!.value.choiceId;
          rxIbAnswer!.refresh();
        }
      } else {
        selectedChoiceId.value = rxIbAnswer!.value.choiceId;
      }

      voted.value = rxIbAnswer != null;

      commented.value =
          await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
      liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
      await _generateIbTags();
      await generatePollStats();
      await _generateChoiceUserMap();
      _setUpCountDownTimer();
      isPollClosed.value = DateTime.now().millisecondsSinceEpoch >
              rxIbQuestion.value.endTimeInMs &&
          rxIbQuestion.value.endTimeInMs > 0;

      /// flag for enabling user to open result page
      voted.value = rxIbAnswer != null || isPollClosed.value;
    }
  }

  /// refresh poll result, comments, likes,
  Future<void> refreshStats() async {
    countMap.clear();
    resultMap.clear();
    final q =
        await IbQuestionDbService().querySingleQuestion(rxIbQuestion.value.id);
    if (q != null) {
      rxIbQuestion.value = q;
      rxIbQuestion.refresh();
    }
    commented.value =
        await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
    liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
    await generatePollStats();
  }

  @override
  void onClose() {
    super.onClose();
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
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

  Future<void> _generateIbTags() async {
    ibTags.clear();
    for (final String id in rxIbQuestion.value.tags) {
      if (IbCacheManager().getIbTag(id) != null) {
        ibTags.add(IbCacheManager().getIbTag(id)!);
      } else {
        final IbTag? tag = await IbTagDbService().retrieveIbTag(id);
        if (tag != null) {
          ibTags.add(tag);
        }
      }
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

  Future<void> generatePollStats() async {
    if (rxIbQuestion.value.pollSize == 0) {
      return;
    }

    if (countMap.isEmpty) {
      countMap.value = await _getChoiceCountMap();
    }

    for (final IbChoice ibChoice in rxIbQuestion.value.choices) {
      resultMap[ibChoice] = double.parse(
          ((countMap[ibChoice.choiceId] ?? 0).toDouble() /
                  rxIbQuestion.value.pollSize)
              .toStringAsFixed(1));
    }
  }

  Future<void> _generateChoiceUserMap() async {
    choiceUserMap.clear();
    for (final IbChoice choice in rxIbQuestion.value.choices) {
      final snapshot = await IbQuestionDbService().queryIbAnswers(
          choiceId: choice.choiceId,
          questionId: rxIbQuestion.value.id,
          limit: 4);
      final List<IbAnswer> ibAnswers = [];
      for (final doc in snapshot.docs) {
        ibAnswers.add(IbAnswer.fromJson(doc.data()));
      }

      final Set<IbUser> users = {};

      for (final IbAnswer answer in ibAnswers) {
        final user = await retrieveUser(answer.uid);
        users.addIf(user != null, user!);
      }
      choiceUserMap[choice] = users;
    }
  }

  Future<void> onVote({bool isPublic = true}) async {
    // don't let user vote if poll is closed
    if (rxIbQuestion.value.endTimeInMs <
            DateTime.now().millisecondsSinceEpoch &&
        rxIbQuestion.value.endTimeInMs > 0) {
      return;
    }

    if (selectedChoiceId.value.isEmpty) {
      return;
    }

    if (rxIbAnswer != null &&
        rxIbAnswer!.value.isPublic == isPublic &&
        selectedChoiceId.value == rxIbAnswer!.value.choiceId) {
      return;
    }

    if (isAnswering.value) {
      return;
    }

    isAnswering.value = true;

    try {
      final IbAnswer ibAnswer = IbAnswer(
          choiceId: selectedChoiceId.value,
          isPublic: isPublic,
          edited: rxIbAnswer != null,
          answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
          askedTimeInMs: rxIbQuestion.value.askedTimeInMs,
          uid: IbUtils.getCurrentUid()!,
          questionId: rxIbQuestion.value.id,
          questionType: rxIbQuestion.value.questionType);
      await IbQuestionDbService().answerQuestion(ibAnswer);

      if (isPublic) {
        IbUtils.showSimpleSnackBar(
            msg: 'Answered publicly 📢',
            backgroundColor: IbColors.primaryColor);
      } else {
        IbUtils.showSimpleSnackBar(
            msg: 'Answered anonymously 🕵️', backgroundColor: Colors.black);
      }

      if (rxIbAnswer != null) {
        ///decrement old countMap;
        final int decrementedCount =
            (countMap[rxIbAnswer!.value.choiceId] ?? 0) - 1;
        countMap[rxIbAnswer!.value.choiceId] =
            decrementedCount < 0 ? 0 : decrementedCount;
        rxIbAnswer!.value = ibAnswer;
      } else {
        rxIbAnswer = ibAnswer.obs;
        rxIbQuestion.value.pollSize++;
      }

      final int incrementedCount = (countMap[ibAnswer.choiceId] ?? 0) + 1;
      countMap[ibAnswer.choiceId] = incrementedCount;

      await generatePollStats();
      await _generateChoiceUserMap();
      voted.value = true;
    } catch (e) {
      voted.value = false;
      IbUtils.showSimpleSnackBar(
          msg: "Failed to vote $e", backgroundColor: IbColors.errorRed);
    } finally {
      if (creatorUser != null) {
        compScore.value = await IbUtils.getCompScore(uid: creatorUser!.id);
      }
      isAnswering.value = false;
      rxIbAnswer!.refresh();
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
}
