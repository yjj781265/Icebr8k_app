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
  final FocusNode focusNode = FocusNode();
  final Map<String, IbAnswer> answerMap = {};
  final hintText = 'Add a creative comment here'.obs;
  final replyCommentId = ''.obs;
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
    editingController.addListener(() {
      if (editingController.text.isEmpty) {
        hintText.value = 'Add a creative comment here';
        replyCommentId.value = '';
      }
    });

    commentCount.value = ibQuestion.comments;
    final tempList =
        await IbQuestionDbService().queryNewestComments(ibQuestion.id);

    for (final comment in tempList) {
      final IbUser? user;
      final IbAnswer? ibAnswer;

      user = await _retrieveUser(comment);
      if (user == null) {
        continue;
      }

      /// cache ibAnswer
      if (answerMap[comment.uid] == null) {
        ibAnswer = await IbQuestionDbService()
            .queryIbAnswer(comment.uid, comment.questionId);
        if (ibAnswer != null) {
          answerMap[comment.uid] = ibAnswer;
        }
      } else {
        ibAnswer = answerMap[comment.uid];
      }
      final isLiked = await IbQuestionDbService().isCommentLiked(comment);

      /// retrieve first three replies if available
      final List<CommentItem> replies =
          await _retrieveFirstThreeReplies(comment.replies);
      comments.add(CommentItem(
          ibComment: comment,
          user: user,
          firstThreeReplies: replies,
          ibAnswer: ibAnswer,
          isLiked: isLiked));
    }
    sortList();
    isLoading.value = false;
  }

  Future<IbUser?> _retrieveUser(IbComment comment) async {
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

    final IbComment ibComment = IbComment(
        commentId: IbUtils.getUniqueId(),
        uid: IbUtils.getCurrentUid()!,
        questionId: ibQuestion.id,
        content: text.trim(),
        type: type,
        timestampInMs: DateTime.now().millisecondsSinceEpoch);
    try {
      isAddingComment.value = true;

      /// add a reply if replyCommentId is valid
      if (replyCommentId.isNotEmpty) {
        final user = await _retrieveUser(ibComment);
        if (user != null) {
          final CommentItem? item = comments.firstWhere((element) {
            if (element != null &&
                element.ibComment.commentId == replyCommentId.value) {
              return true;
            }
            return false;
          });
          final IbAnswer? ibAnswer = await IbQuestionDbService()
              .queryIbAnswer(ibComment.uid, ibComment.questionId);
          await IbQuestionDbService().addReply(
              questionId: ibQuestion.id,
              commentId: replyCommentId.value,
              reply: ibComment);
          item!.ibComment.replies.add(ibComment);
          item.firstThreeReplies.add(CommentItem(
              ibComment: ibComment, user: user, ibAnswer: ibAnswer));
          item.firstThreeReplies.sort((a, b) {
            return b.ibComment.timestampInMs
                .compareTo(a.ibComment.timestampInMs);
          });
          item.firstThreeReplies = item.firstThreeReplies.sublist(
              0,
              item.firstThreeReplies.length >= 3
                  ? 3
                  : item.firstThreeReplies.length);
        }
        editingController.clear();
        IbUtils.showSimpleSnackBar(
            msg: 'Adding a reply successfully!',
            backgroundColor: IbColors.accentColor);
        comments.refresh();
        return;
      }

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
      IbUtils.showSimpleSnackBar(
          msg: 'Adding a comment successfully!',
          backgroundColor: IbColors.accentColor);
    } on Exception catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Adding a comment failed $e',
          backgroundColor: IbColors.errorRed);
    } finally {
      isAddingComment.value = false;
    }
  }

  Future<List<CommentItem>> _retrieveFirstThreeReplies(
      List<IbComment> replies) async {
    late List<IbComment> firstThreeList;
    final List<CommentItem> replyItems = [];

    if (replies.length >= 3) {
      firstThreeList = replies.sublist(0, 3);
    } else {
      firstThreeList = replies;
    }

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
            .queryIbAnswer(reply.uid, reply.questionId);
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
  List<CommentItem> firstThreeReplies;
  bool isLiked;
  IbUser user;
  IbAnswer? ibAnswer;

  CommentItem(
      {required this.ibComment,
      required this.user,
      this.isLiked = false,
      this.firstThreeReplies = const [],
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
