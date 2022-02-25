import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../managers/ib_cache_manager.dart';
import '../services/user_services/ib_question_db_service.dart';
import '../services/user_services/ib_user_db_service.dart';

class CommentController extends GetxController {
  final comments = <CommentItem?>[].obs;
  final FocusNode focusNode = FocusNode();
  final List<String> dropDownOptions = ['Top Comments', 'Newest First'];
  final currentOption = 'Top Comments'.obs;
  final Map<String, IbAnswer> answerMap = {};
  final hintText = 'Add a creative comment here'.obs;
  final replyCommentId = ''.obs;
  final isLoading = true.obs;
  final String questionId;
  final title = ''.obs;
  final creatorId = ''.obs;
  final questionType = ''.obs;
  final isAnonymous = false.obs;
  final choices = <IbChoice>[].obs;
  final commentCount = 0.obs;
  final sortByDate = true.obs;
  final isAddingComment = false.obs;
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  CommentController(this.questionId);

  @override
  Future<void> onInit() async {
    super.onInit();
    await initData();
  }

  Future<void> initData() async {
    final IbQuestion? ibQuestion =
        await IbQuestionDbService().querySingleQuestion(questionId);
    if (ibQuestion == null) {
      print('CommentController ibQuestion is null');
      return;
    }
    title.value = ibQuestion.question;
    creatorId.value = ibQuestion.creatorId;
    questionType.value = ibQuestion.questionType;
    choices.value = ibQuestion.choices;
    isAnonymous.value = ibQuestion.isAnonymous;
    updateParentQuestionCommentCount(ibQuestion.comments);
    await loadList(dropDownOptions[0]);
  }

  Future<void> loadList(String dropDownValue) async {
    currentOption.value = dropDownValue;
    isLoading.value = true;
    comments.clear();
    refreshController.resetNoData();
    final List<IbComment> tempList = [];
    late QuerySnapshot<Map<String, dynamic>> snapshot;
    if (dropDownValue == dropDownOptions[0]) {
      snapshot = await IbQuestionDbService().queryTopComments(questionId);
    } else {
      snapshot = await IbQuestionDbService().queryNewestComments(questionId);
    }

    for (final doc in snapshot.docs) {
      tempList.add(IbComment.fromJson(doc.data()));
    }

    lastSnap = tempList.isEmpty ? null : snapshot.docs.last;

    for (final comment in tempList) {
      final item = await _getCommentItem(comment);
      if (item == null) {
        continue;
      }
      comments.add(item);
    }
    comments.refresh();
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    try {
      QuerySnapshot<Map<String, dynamic>>? snapshot;
      final List<IbComment> tempList = [];
      if (lastSnap != null && currentOption.value == dropDownOptions[0]) {
        snapshot = await IbQuestionDbService()
            .queryTopComments(questionId, lastSnap: lastSnap);
      } else if (lastSnap != null &&
          currentOption.value == dropDownOptions[1]) {
        snapshot = await IbQuestionDbService()
            .queryNewestComments(questionId, lastSnap: lastSnap);
      }

      if (snapshot != null &&
          snapshot.docs.isNotEmpty &&
          lastSnap != snapshot.docs.last) {
        lastSnap = snapshot.docs.last;
        for (final doc in snapshot.docs) {
          tempList.add(IbComment.fromJson(doc.data()));
        }

        for (final comment in tempList) {
          final item = await _getCommentItem(comment);
          if (item == null) {
            continue;
          }
          comments.add(item);
        }
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  Future<IbAnswer?> retrieveIbAnswer(IbComment comment) async {
    /// cache ibAnswer
    final IbAnswer? ibAnswer;
    if (answerMap[comment.uid] == null) {
      ibAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(comment.uid, comment.questionId);
      if (ibAnswer != null) {
        answerMap[comment.uid] = ibAnswer;
      }
    } else {
      ibAnswer = answerMap[comment.uid];
    }
    return ibAnswer;
  }

  Future<IbUser?> retrieveUser(IbComment comment) async {
    final IbUser? user;
    if (IbCacheManager().getIbUser(comment.uid) == null) {
      user = await IbUserDbService().queryIbUser(comment.uid);
      IbCacheManager().cacheIbUser(user);
    } else {
      user = IbCacheManager().getIbUser(comment.uid);
    }
    return user;
  }

  void updateCommentItem(CommentItem commentItem) {
    if (comments.contains(commentItem)) {
      comments[comments.indexOf(commentItem)] = commentItem;
      comments.refresh();
    }
  }

  Future<void> addComment({required String text, required String type}) async {
    if (text.trim().isEmpty) {
      return;
    }

    final IbComment ibComment = IbComment(
        commentId: IbUtils.getUniqueId(),
        uid: IbUtils.getCurrentUid()!,
        questionId: questionId,
        content: text.trim(),
        type: type,
        timestampInMs: DateTime.now().millisecondsSinceEpoch);
    try {
      isAddingComment.value = true;
      await IbQuestionDbService().addComment(ibComment);
      final IbAnswer? ibAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(ibComment.uid, ibComment.questionId);
      editingController.clear();
      comments.insert(
          0,
          CommentItem(
              ibComment: ibComment,
              user: IbUtils.getCurrentIbUser()!,
              ibAnswer: ibAnswer));

      updateParentQuestionCommentCount(comments.length);
      IbUtils.showSimpleSnackBar(
          msg: 'Comment added!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Adding a comment failed $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      isAddingComment.value = false;
      IbUtils.hideKeyboard();
    }
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

  void updateParentQuestionCommentCount(int count) {
    commentCount.value = count;

    ///update item controller comments if available
    final IbQuestionItemController itemController =
        Get.find<IbQuestionItemController>(tag: questionId);
    itemController.comments.value = commentCount.value;
    itemController.rxIbQuestion.value.comments = commentCount.value;
    itemController.commented.value = true;
    itemController.rxIbQuestion.refresh();
  }

  Future<void> likeComment(CommentItem commentItem) async {
    if (!comments.contains(commentItem) || commentItem.isLiked) {
      return;
    }

    try {
      final IbComment comment =
          comments[comments.indexOf(commentItem)]!.ibComment;
      await IbQuestionDbService().likeComment(comment);
      comment.likes++;
      commentItem.isLiked = true;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to like a comment, $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      comments.refresh();
    }
  }

  Future<void> dislikeComment(CommentItem commentItem) async {
    if (!comments.contains(commentItem) || !commentItem.isLiked) {
      return;
    }
    try {
      final IbComment comment =
          comments[comments.indexOf(commentItem)]!.ibComment;
      await IbQuestionDbService().dislikeComment(comment);
      comment.likes--;
      comment.likes = comment.likes <= 0 ? 0 : comment.likes;
      commentItem.isLiked = false;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to remove like on a comment, $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      comments.refresh();
    }
  }

  Future<CommentItem?> _getCommentItem(IbComment comment) async {
    final IbUser? user;
    final IbAnswer? ibAnswer;

    user = await retrieveUser(comment);
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

  @override
  void dispose() {
    editingController.dispose();
    refreshController.dispose();
    super.dispose();
  }
}

class CommentItem {
  IbComment ibComment;
  List<CommentItem> replies;
  bool isLiked;
  IbUser user;
  IbAnswer? ibAnswer;

  CommentItem(
      {required this.ibComment,
      required this.user,
      this.isLiked = false,
      this.replies = const [],
      this.ibAnswer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentItem &&
          runtimeType == other.runtimeType &&
          ibComment.commentId == other.ibComment.commentId;

  @override
  int get hashCode => ibComment.hashCode;
}
