import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class CommentController extends GetxController {
  final comments = <CommentItem?>[null].obs;
  final Map<String, IbAnswer> answerMap = {};
  final isLoading = true.obs;
  final IbQuestion ibQuestion;
  final commentCount = 0.obs;
  final sortByDate = true.obs;
  final isAddingComment = false.obs;
  final TextEditingController editingController = TextEditingController();
  CommentController(this.ibQuestion);

  @override
  Future<void> onInit() async {
    super.onInit();
    commentCount.value = ibQuestion.comments;
    final tempList =
        await IbQuestionDbService().queryNewestComments(ibQuestion.id);

    for (final comment in tempList) {
      final IbUser? user;
      final IbAnswer? ibAnswer;
      if (IbCacheManager().getIbUser(comment.uid) == null) {
        user = await IbUserDbService().queryIbUser(comment.uid);
      } else {
        user = IbCacheManager().getIbUser(comment.uid);
      }

      if (user == null) {
        continue;
      }

      if (answerMap[comment.uid] == null) {
        ibAnswer = await IbQuestionDbService()
            .queryIbAnswer(comment.uid, comment.questionId);
        if (ibAnswer != null) {
          answerMap[comment.uid] = ibAnswer;
        }
      } else {
        ibAnswer = answerMap[comment.uid];
      }

      comments
          .add(CommentItem(ibComment: comment, user: user, ibAnswer: ibAnswer));
    }
    sortList();
    isLoading.value = false;
  }

  Future<void> addComment({required String text, required String type}) async {
    final IbComment ibComment = IbComment(
        commentId: IbUtils.getUniqueId(),
        uid: IbUtils.getCurrentUid()!,
        questionId: ibQuestion.id,
        content: text,
        type: IbComment.kCommentTypeText,
        timestampInMs: DateTime.now().millisecondsSinceEpoch);
    try {
      isAddingComment.value = true;
      await IbQuestionDbService().addComment(ibComment);
      final IbAnswer? ibAnswer = await IbQuestionDbService()
          .queryIbAnswer(ibComment.uid, ibComment.questionId);
      editingController.clear();
      comments.add(CommentItem(
          ibComment: ibComment,
          user: IbUtils.getCurrentIbUser()!,
          ibAnswer: ibAnswer));

      updateCommentCount();

      sortList();
    } on Exception catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Adding comment failed $e', backgroundColor: IbColors.errorRed);
    } finally {
      isAddingComment.value = false;
    }
  }

  void updateCommentCount() {
    commentCount.value++;
    final IbQuestionItemController itemController =
        Get.find(tag: "${ibQuestion.id}${IbUtils.getCurrentUid()}");
    itemController.comments.value = commentCount.value;
    itemController.rxIbQuestion.value.comments = commentCount.value;
    itemController.rxIbQuestion.refresh();
  }

  void sortList() {
    if (sortByDate.isTrue) {
      comments.sort((a, b) {
        if (a != null && b != null) {
          return b.ibComment.timestampInMs.compareTo(a.ibComment.timestampInMs);
        }
        return 0;
      });
    }
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to remove like on a comment, $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      comments.refresh();
    }
  }

  @override
  void dispose() {
    editingController.dispose();
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
          ibComment.commentId == other.ibComment.commentId;

  @override
  int get hashCode => ibComment.hashCode;
}
