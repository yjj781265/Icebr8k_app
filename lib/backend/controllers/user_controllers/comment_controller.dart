import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../managers/ib_cache_manager.dart';
import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';
import 'ib_question_item_controller.dart';

class CommentController extends GetxController {
  final IbQuestionItemController itemController;
  final FocusNode focusNode = FocusNode();
  final hintText = 'Add a creative comment here'.obs;
  final isLoading = true.obs;
  final isAddingComment = false.obs;
  final commentItems = <CommentItem>[].obs;
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  late StreamSubscription commentSub;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;

  CommentController({
    required this.itemController,
  });

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadList();
  }

  @override
  void onClose() {
    super.onClose();
    commentSub.cancel();
  }

  Future<void> loadList() async {
    isLoading.value = true;
    if (isLoading.isTrue) {
      /// add top three comments on top
      final snapshot = await IbQuestionDbService()
          .queryTopThreeComments(itemController.rxIbQuestion.value.id);
      final List<CommentItem> temp = [];
      for (final doc in snapshot.docs) {
        final IbComment comment = IbComment.fromJson(doc.data());
        if (commentItems.indexWhere((element) =>
                element.ibComment.commentId == comment.commentId) ==
            -1) {
          final user = await retrieveUser(comment);
          if (user != null) {
            final ibAnswer = await retrieveIbAnswer(comment);
            final isLiked = await IbQuestionDbService().isCommentLiked(comment);
            temp.add(CommentItem(
                ibComment: comment,
                user: user,
                ibAnswer: ibAnswer,
                isLiked: isLiked));
          }
        }
      }
      commentItems.insertAll(0, temp);

      /// add all my comments first on top
      final myCommentSnap = await IbQuestionDbService()
          .queryAllMyComments(itemController.rxIbQuestion.value.id);
      final List<CommentItem> myComments = [];
      for (final doc in myCommentSnap.docs) {
        final IbComment comment = IbComment.fromJson(doc.data());
        if (commentItems.indexWhere((element) =>
                element.ibComment.commentId == comment.commentId) ==
            -1) {
          final user = await retrieveUser(comment);
          if (user != null) {
            final ibAnswer = await retrieveIbAnswer(comment);
            final isLiked = await IbQuestionDbService().isCommentLiked(comment);
            myComments.add(CommentItem(
                ibComment: comment,
                user: user,
                ibAnswer: ibAnswer,
                isLiked: isLiked));
          }
        }
      }
      myComments.sort((a, b) => (b.ibComment.timestamp as Timestamp)
          .compareTo(a.ibComment.timestamp as Timestamp));
      commentItems.insertAll(0, myComments);
    }

    commentSub = IbQuestionDbService()
        .listenToComments(itemController.rxIbQuestion.value.id)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        print(docChange.type);
        final IbComment comment = IbComment.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          /// insert to index 0 for new comment added after init load
          if (commentItems.indexWhere((element) =>
                      element.ibComment.commentId == comment.commentId) ==
                  -1 &&
              isLoading.isFalse) {
            final user = await retrieveUser(comment);
            if (user != null) {
              final ibAnswer = await retrieveIbAnswer(comment);
              final isLiked =
                  await IbQuestionDbService().isCommentLiked(comment);
              commentItems.insert(
                  0,
                  CommentItem(
                      ibComment: comment,
                      user: user,
                      ibAnswer: ibAnswer,
                      isLiked: isLiked));
              final int newCount =
                  itemController.rxIbQuestion.value.comments + 1;
              await _updateParentQuestionCommentCount(newCount);
            }
            return;
          }

          if (commentItems.indexWhere((element) =>
                  element.ibComment.commentId == comment.commentId) ==
              -1) {
            final user = await retrieveUser(comment);
            if (user != null) {
              final ibAnswer = await retrieveIbAnswer(comment);
              final isLiked =
                  await IbQuestionDbService().isCommentLiked(comment);
              commentItems.add(CommentItem(
                  ibComment: comment,
                  user: user,
                  ibAnswer: ibAnswer,
                  isLiked: isLiked));
            }
          }
        }

        if (docChange.type == DocumentChangeType.modified) {
          print('modified');
          await Future.delayed(
              const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
              () {
            final index = commentItems.indexWhere(
                (element) => element.ibComment.commentId == comment.commentId);
            if (index != -1) {
              commentItems[index].ibComment = comment;
            }
          });
        }

        if (docChange.type == DocumentChangeType.removed) {
          final index = commentItems.indexWhere(
              (element) => element.ibComment.commentId == comment.commentId);
          if (index != -1) {
            commentItems.removeAt(index);
          }
        }
      }

      commentItems.refresh();

      if (isLoading.isTrue && event.docs.isNotEmpty) {
        lastSnap = event.docs.last;
      }
      isLoading.value = false;
    });
  }

  Future<void> loadMore() async {
    if (lastSnap == null) {
      refreshController.loadNoData();
      return;
    }

    try {
      final snapshot = await IbQuestionDbService().queryNewestComments(
          itemController.rxIbQuestion.value.id,
          lastSnap: lastSnap);
      for (final doc in snapshot.docs) {
        final IbComment comment = IbComment.fromJson(doc.data());
        if (commentItems.indexWhere((element) =>
                element.ibComment.commentId == comment.commentId) ==
            -1) {
          final user = await retrieveUser(comment);
          if (user != null) {
            final ibAnswer = await retrieveIbAnswer(comment);
            final isLiked = await IbQuestionDbService().isCommentLiked(comment);
            commentItems.add(CommentItem(
                ibComment: comment,
                user: user,
                ibAnswer: ibAnswer,
                isLiked: isLiked));
          }
        }
        lastSnap = doc;
        refreshController.loadComplete();
      }

      if (snapshot.docs.isEmpty) {
        refreshController.loadNoData();
        lastSnap = null;
      }
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  Future<IbAnswer?> retrieveIbAnswer(IbComment comment) async {
    IbAnswer? ibAnswer;
    final ibAnswers = IbCacheManager().getIbAnswers(comment.uid);

    if (ibAnswers == null || ibAnswers.isEmpty) {
      ibAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(comment.uid, comment.questionId);
      if (ibAnswer != null) {
        IbCacheManager()
            .cacheSingleIbAnswer(uid: comment.uid, ibAnswer: ibAnswer);
      }
      return ibAnswer;
    } else {
      ibAnswer = ibAnswers.firstWhereOrNull(
          (element) => element.questionId == comment.questionId);
      ibAnswer ??= await IbQuestionDbService()
          .querySingleIbAnswer(comment.uid, comment.questionId);
      if (ibAnswer != null) {
        IbCacheManager()
            .cacheSingleIbAnswer(uid: comment.uid, ibAnswer: ibAnswer);
      }
      return ibAnswer;
    }
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

  Future<void> addComment({required String text, required String type}) async {
    if (text.trim().isEmpty) {
      return;
    }
    isAddingComment.value = true;
    final IbComment ibComment = IbComment(
        commentId: IbUtils.getUniqueId(),
        notifyUid: itemController.rxIbQuestion.value.creatorId,
        uid: IbUtils.getCurrentUid()!,
        questionId: itemController.rxIbQuestion.value.id,
        content: text.trim(),
        type: type,
        timestamp: FieldValue.serverTimestamp());
    try {
      await IbQuestionDbService().addComment(ibComment);
      editingController.clear();
      IbUtils.showSimpleSnackBar(
          msg: 'Comment added!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Adding a comment failed $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      IbUtils.hideKeyboard();
      isAddingComment.value = false;
    }
  }

  Future<void> _updateParentQuestionCommentCount(int count) async {
    print('_updateParentQuestionCommentCount $count');
    await itemController.refreshStats();

    ///update item controller comments if available
    itemController.rxIbQuestion.value.comments = count;
    itemController.rxIbQuestion.refresh();
  }

  Future<void> likeComment(CommentItem commentItem) async {
    if (commentItem.isLiked) {
      return;
    }

    try {
      await IbQuestionDbService().likeComment(commentItem.ibComment);
      commentItem.ibComment.likes++;
      commentItem.isLiked = true;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to like a comment, $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      commentItems.refresh();
    }
  }

  Future<void> dislikeComment(CommentItem commentItem) async {
    if (!commentItems.contains(commentItem) || !commentItem.isLiked) {
      return;
    }
    try {
      await IbQuestionDbService().dislikeComment(commentItem.ibComment);
      commentItem.ibComment.likes--;
      commentItem.ibComment.likes =
          commentItem.ibComment.likes <= 0 ? 0 : commentItem.ibComment.likes;
      commentItem.isLiked = false;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to remove like on a comment, $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      commentItems.refresh();
    }
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
  bool isLiked;
  IbUser user;
  IbAnswer? ibAnswer;

  CommentItem(
      {required this.ibComment,
      required this.user,
      this.isLiked = false,
      this.ibAnswer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentItem &&
          runtimeType == other.runtimeType &&
          ibComment == other.ibComment &&
          isLiked == other.isLiked &&
          user == other.user &&
          ibAnswer == other.ibAnswer;

  @override
  int get hashCode =>
      ibComment.hashCode ^ isLiked.hashCode ^ user.hashCode ^ ibAnswer.hashCode;
}
