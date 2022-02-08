import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../services/user_services/ib_question_db_service.dart';

class ReplyController extends GetxController {
  final CommentItem replyComment;
  final CommentController commentController;
  late List<IbComment> sortedCommentList;
  final replies = <CommentItem?>[].obs;
  final replyCounts = 0.obs;
  final likes = 0.obs;
  final isLiked = false.obs;
  final isAddingReply = false.obs;
  final int kMaxPerPage = 8;
  int _nextIndex = 0;
  final isLoading = true.obs;
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  final FocusNode focusNode = FocusNode();

  ReplyController(
      {required this.replyComment, required this.commentController});

  @override
  Future<void> onInit() async {
    super.onInit();
    likes.value = replyComment.ibComment.likes;
    isLiked.value = replyComment.isLiked;
    replyCounts.value = replyComment.ibComment.replies.length;
    await _initReplies();
  }

  Future<void> _initReplies() async {
    isLoading.value = true;
    late List<IbComment> subList;
    sortedCommentList = replyComment.ibComment.replies;
    sortedCommentList.sort((a, b) {
      return b.timestampInMs.compareTo(a.timestampInMs);
    });
    if (sortedCommentList.length > kMaxPerPage) {
      subList = sortedCommentList.sublist(0, kMaxPerPage);
    } else {
      subList = sortedCommentList;
    }
    for (final IbComment ibComment in subList) {
      final IbUser? user = await commentController.retrieveUser(ibComment);
      final IbAnswer? ibAnswer =
          await commentController.retrieveIbAnswer(ibComment);
      if (user == null) {
        continue;
      }
      final CommentItem item =
          CommentItem(ibComment: ibComment, user: user, ibAnswer: ibAnswer);
      replies.add(item);
    }
    replies.sort((a, b) {
      if (a != null && b != null) {
        return b.ibComment.timestampInMs.compareTo(a.ibComment.timestampInMs);
      }
      return 0;
    });

    _nextIndex = subList.isEmpty ? subList.length : subList.length;
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (_nextIndex == replyComment.ibComment.replies.length) {
      refreshController.loadNoData();
      return;
    }

    try {
      late List<IbComment> subList;
      final endIndex = _nextIndex + kMaxPerPage >= sortedCommentList.length
          ? sortedCommentList.length
          : _nextIndex + kMaxPerPage;
      subList = sortedCommentList.sublist(_nextIndex, endIndex);
      for (final IbComment ibComment in subList) {
        final IbUser? user = await commentController.retrieveUser(ibComment);
        final IbAnswer? ibAnswer =
            await commentController.retrieveIbAnswer(ibComment);
        if (user == null) {
          continue;
        }
        final CommentItem item =
            CommentItem(ibComment: ibComment, user: user, ibAnswer: ibAnswer);
        if (replies.contains(item)) {
          continue;
        }
        replies.add(item);
      }
      replies.sort((a, b) {
        if (a != null && b != null) {
          return b.ibComment.timestampInMs.compareTo(a.ibComment.timestampInMs);
        }
        return 0;
      });
      _nextIndex = endIndex;
      refreshController.loadComplete();
    } catch (e) {
      print(e);
      refreshController.loadFailed();
    }
  }

  Future<void> addReply({required String text, required String type}) async {
    if (text.trim().isEmpty) {
      return;
    }
    isAddingReply.value = true;
    final IbComment reply = IbComment(
        commentId: IbUtils.getUniqueId(),
        uid: IbUtils.getCurrentUid()!,
        questionId: replyComment.ibComment.questionId,
        content: text.trim(),
        type: type,
        timestampInMs: DateTime.now().millisecondsSinceEpoch);
    final user = IbUtils.getCurrentIbUser();

    if (user != null) {
      try {
        final IbAnswer? ibAnswer =
            await commentController.retrieveIbAnswer(reply);
        await IbQuestionDbService().addReply(
            questionId: replyComment.ibComment.questionId,
            commentId: replyComment.ibComment.commentId,
            reply: reply);
        final item =
            CommentItem(ibComment: reply, user: user, ibAnswer: ibAnswer);
        replies.insert(0, item);
        replyCounts.value++;
        replies.sort((a, b) {
          if (a != null && b != null) {
            return b.ibComment.timestampInMs
                .compareTo(a.ibComment.timestampInMs);
          }
          return 0;
        });
        commentController.updateFirstThreeReplies(
            reply: item, originCommentId: replyComment.ibComment.commentId);
        editingController.clear();
        isAddingReply.value = false;
        IbUtils.hideKeyboard();
        IbUtils.showSimpleSnackBar(
            msg: 'Reply added!', backgroundColor: IbColors.accentColor);
      } catch (e) {
        IbUtils.showSimpleSnackBar(
            msg: 'Fail to add a reply $e!', backgroundColor: IbColors.errorRed);
      }
    }
  }
}
