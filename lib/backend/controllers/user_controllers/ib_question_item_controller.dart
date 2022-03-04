import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_tag_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';
import 'comment_controller.dart';

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
  final resultMap = <IbChoice, double>{}.obs;
  final RxList<IbTag> ibTags = <IbTag>[].obs;
  //start
  // variables for comment page
  final currentSortOption = 'Top Comments'.obs;
  final RxList<CommentItem> cachedCommentItems = <CommentItem>[].obs;
  DocumentSnapshot<Map<String, dynamic>>? lastCommentSnap;
  final RxMap<String, IbAnswer> answerMap = <String, IbAnswer>{}.obs;
  //end

  //start
  // variables for poll stat main page
  final RxMap<IbChoice, Set<IbUser>> choiceUserMap =
      <IbChoice, Set<IbUser>>{}.obs;
  //end

  /// vote count for each choice id
  RxMap<String, int> countMap = <String, int>{}.obs;

  IbQuestionItemController({
    required this.rxIbQuestion,
    required this.rxIsExpanded,
    this.isSample = false,
    this.rxIbAnswer,
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
    cachedCommentItems.clear();
    answerMap.clear();
    choiceUserMap.clear();
    showComparison.value = ibAnswers != null && ibAnswers!.isNotEmpty;

    /// query question author user info
    final ibUser =
        await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);

    if (ibUser != null) {
      title.value = ibUser.username;
      avatarUrl.value = ibUser.avatarUrl;
    }

    if (rxIbAnswer == null && !isSample) {
      /// query my answer to this question
      final myAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(IbUtils.getCurrentUid()!, rxIbQuestion.value.id);

      if (myAnswer != null) {
        rxIbAnswer = myAnswer.obs;
        selectedChoiceId.value = rxIbAnswer!.value.choiceId;
        rxIbAnswer!.refresh();
      }
    } else if (rxIbAnswer != null) {
      selectedChoiceId.value = rxIbAnswer!.value.choiceId;
    }

    voted.value = rxIbAnswer != null;

    if (!isSample) {
      commented.value =
          await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
      liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
      await _generateIbTags();
      await generatePollStats();
      await _generateCachedCommentItems();
      await _generateChoiceUserMap();
      _setUpCountDownTimer();
    }
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
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(
                    rxIbQuestion.value.endTimeInMs))
                .inMinutes <=
            5) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        rxIbQuestion.refresh();
      });
    }
  }

  Future<void> _generateIbTags() async {
    ibTags.clear();
    for (final String id in rxIbQuestion.value.tagIds) {
      final IbTag? tag = await IbTagDbService().retrieveIbTag(id);
      if (tag != null) {
        ibTags.add(tag);
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

  Future<void> _generateCachedCommentItems() async {
    cachedCommentItems.clear();
    final List<IbComment> tempList = [];
    final snapshot =
        await IbQuestionDbService().queryTopComments(rxIbQuestion.value.id);
    for (final doc in snapshot.docs) {
      tempList.add(IbComment.fromJson(doc.data()));
    }

    lastCommentSnap = tempList.isEmpty ? null : snapshot.docs.last;

    for (final comment in tempList) {
      final item = await _getCommentItem(comment);
      if (item == null) {
        continue;
      }
      cachedCommentItems.add(item);
    }
  }

  Future<void> _generateChoiceUserMap() async {
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

  Future<void> onVote() async {
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
          answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
          askedTimeInMs: rxIbQuestion.value.askedTimeInMs,
          uid: IbUtils.getCurrentUid()!,
          questionId: rxIbQuestion.value.id,
          questionType: rxIbQuestion.value.questionType);
      await IbQuestionDbService().answerQuestion(ibAnswer);
      //update choiceUserMap for result main page

      if (rxIbAnswer != null) {
        ///decrement old countMap;
        final int decrementedCount =
            (countMap[rxIbAnswer!.value.choiceId] ?? 0) - 1;
        countMap[rxIbAnswer!.value.choiceId] =
            decrementedCount < 0 ? 0 : decrementedCount;
        final Set<IbUser> updatedSet = choiceUserMap[rxIbQuestion.value.choices
                .firstWhere((element) =>
                    element.choiceId == rxIbAnswer!.value.choiceId)] ??
            <IbUser>{};
        updatedSet.remove(IbUtils.getCurrentIbUser());
        choiceUserMap[rxIbQuestion.value.choices.firstWhere(
                (element) => element.choiceId == rxIbAnswer!.value.choiceId)] =
            updatedSet;
      } else {
        rxIbQuestion.value.pollSize++;
      }

      final int incrementedCount = (countMap[ibAnswer.choiceId] ?? 0) + 1;
      countMap[ibAnswer.choiceId] = incrementedCount;

      //update choiceUserMap for result main page
      final Set<IbUser> updatedSet = choiceUserMap[rxIbQuestion.value.choices
              .firstWhere(
                  (element) => element.choiceId == ibAnswer.choiceId)] ??
          <IbUser>{};
      updatedSet.add(IbUtils.getCurrentIbUser()!);
      choiceUserMap[rxIbQuestion.value.choices
              .firstWhere((element) => element.choiceId == ibAnswer.choiceId)] =
          updatedSet;
      await generatePollStats();
      rxIbAnswer = ibAnswer.obs;
      voted.value = true;
    } catch (e) {
      voted.value = false;
      IbUtils.showSimpleSnackBar(
          msg: "Failed to vote $e", backgroundColor: IbColors.errorRed);
    } finally {
      isAnswering.value = false;
      rxIbAnswer!.refresh();
      rxIbQuestion.refresh();
      choiceUserMap.refresh();
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
      print('retrieveUser from cached');
    }
    return user;
  }

  Future<IbAnswer?> retrieveIbAnswer(IbComment comment) async {
    /// cache ibAnswer
    final IbAnswer? ibAnswer;
    if (answerMap[comment.uid] == null ||
        comment.uid == IbUtils.getCurrentUid()) {
      ibAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(comment.uid, comment.questionId);
      if (ibAnswer != null) {
        answerMap[comment.uid] = ibAnswer;
      }
    } else {
      ibAnswer = answerMap[comment.uid];
      print('retrieveIbAnswer from cache map');
    }
    return ibAnswer;
  }

  Future<List<CommentItem>> _retrieveFirstThreeReplies(
      IbComment ibComment) async {
    final List<IbComment> firstThreeList = [];
    final List<CommentItem> replyItems = [];

    final snapshot = await IbQuestionDbService().queryReplies(
        questionId: ibComment.questionId,
        commentId: ibComment.commentId,
        limit: 3);
    for (final doc in snapshot.docs) {
      firstThreeList.add(IbComment.fromJson(doc.data()));
    }
    firstThreeList.sort((a, b) => b.timestampInMs.compareTo(a.timestampInMs));

    for (final reply in firstThreeList) {
      final IbUser? user;
      final IbAnswer? ibAnswer;
      if (IbCacheManager().getIbUser(reply.uid) == null) {
        user = await IbUserDbService().queryIbUser(reply.uid);
        IbCacheManager().cacheIbUser(user);
      } else {
        user = IbCacheManager().getIbUser(reply.uid);
      }

      if (user == null) {
        continue;
      }

      /// cache ibAnswer
      if (answerMap[reply.uid] == null) {
        ibAnswer = await IbQuestionDbService()
            .querySingleIbAnswer(reply.uid, reply.questionId);
        if (ibAnswer != null) {
          answerMap[reply.uid] = ibAnswer;
        }
      } else {
        ibAnswer = answerMap[reply.uid];
      }

      replyItems
          .add(CommentItem(ibComment: reply, user: user, ibAnswer: ibAnswer));
    }

    return replyItems;
  }

  Future<CommentItem?> _getCommentItem(IbComment comment) async {
    final IbUser? user;
    final IbAnswer? ibAnswer;

    user = await retrieveUser(comment.uid);
    ibAnswer = await retrieveIbAnswer(comment);

    if (user == null) {
      return null;
    }

    final isLiked = await IbQuestionDbService().isCommentLiked(comment);

    /// retrieve first three replies if available
    final List<CommentItem> replies = await _retrieveFirstThreeReplies(comment);

    return CommentItem(
        ibComment: comment,
        user: user,
        isLiked: isLiked,
        replies: replies,
        ibAnswer: ibAnswer);
  }
}
