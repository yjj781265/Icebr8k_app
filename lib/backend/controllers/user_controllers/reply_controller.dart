import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../services/user_services/ib_question_db_service.dart';
import 'comment_controller.dart';

class ReplyController extends GetxController {
  final Rx<CommentItem> rxCommentItem;
  final CommentController commentController;
  final replies = <CommentItem>[].obs;

  /// the Uid a reply is replying to
  final replyUid = ''.obs;
  final likes = 0.obs;
  final isLiked = false.obs;
  final replyCount = 0.obs;
  final isAddingReply = false.obs;
  final hintText = 'Add a creative reply here'.obs;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  final isLoading = true.obs;
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  final FocusNode focusNode = FocusNode();

  ReplyController(
      {required this.rxCommentItem, required this.commentController});

  @override
  Future<void> onInit() async {
    super.onInit();
    likes.value = rxCommentItem.value.ibComment.likes;
    isLiked.value = rxCommentItem.value.isLiked;
    replyCount.value = rxCommentItem.value.ibComment.replies;
    replyUid.value = rxCommentItem.value.ibComment.uid;
    await _initData();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    final snapshot = await IbQuestionDbService().queryReplies(
      questionId: rxCommentItem.value.ibComment.questionId,
      commentId: rxCommentItem.value.ibComment.commentId,
    );

    for (final doc in snapshot.docs) {
      final IbComment ibComment = IbComment.fromJson(doc.data());
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

    if (snapshot.docs.isNotEmpty) {
      lastSnap = snapshot.docs.last;
    }
    _updateParentComment();

    isLoading.value = false;
  }

  Future<void> loadMore() async {
    try {
      if (lastSnap != null) {
        final snapshot = await IbQuestionDbService().queryReplies(
            questionId: rxCommentItem.value.ibComment.questionId,
            commentId: rxCommentItem.value.ibComment.commentId,
            lastSnap: lastSnap,
            limit: 16);

        for (final doc in snapshot.docs) {
          final IbComment ibComment = IbComment.fromJson(doc.data());
          final IbUser? user = await commentController.retrieveUser(ibComment);
          final IbAnswer? ibAnswer =
              await commentController.retrieveIbAnswer(ibComment);
          if (user == null) {
            continue;
          }
          final CommentItem item =
              CommentItem(ibComment: ibComment, user: user, ibAnswer: ibAnswer);
          replies.addIf(!replies.contains(item), item);
        }

        if (snapshot.docs.isNotEmpty) {
          lastSnap = snapshot.docs.last;
          refreshController.loadComplete();
        } else {
          lastSnap = null;
          refreshController.loadNoData();
          return;
        }
      }
      refreshController.loadNoData();
    } catch (e) {
      print(e);
      refreshController.loadFailed();
    }
  }

  void _updateParentComment() {
    rxCommentItem.value.replies = replies;
    commentController.updateCommentItem(rxCommentItem.value);
  }

  Future<void> addReply({required String text, required String type}) async {
    if (text.trim().isEmpty) {
      return;
    }
    isAddingReply.value = true;
    final IbComment reply = IbComment(
        commentId: rxCommentItem.value.ibComment.commentId,
        replyId: IbUtils.getUniqueId(),
        uid: IbUtils.getCurrentUid()!,
        questionId: rxCommentItem.value.ibComment.questionId,
        content: text.trim(),
        type: type,
        timestampInMs: DateTime.now().millisecondsSinceEpoch,
        notifyUid: replyUid.value);
    final user = IbUtils.getCurrentIbUser();

    if (user != null) {
      try {
        final IbAnswer? ibAnswer =
            await commentController.retrieveIbAnswer(reply);
        await IbQuestionDbService().addReply(
            questionId: rxCommentItem.value.ibComment.questionId,
            commentId: rxCommentItem.value.ibComment.commentId,
            reply: reply);
        final item =
            CommentItem(ibComment: reply, user: user, ibAnswer: ibAnswer);
        replies.insert(0, item);
        rxCommentItem.value.ibComment.replies++;
        replyCount.value = rxCommentItem.value.ibComment.replies;
        _updateParentComment();
        editingController.clear();
        isAddingReply.value = false;
        IbUtils.hideKeyboard();
        IbUtils.showSimpleSnackBar(
            msg: 'Reply added!', backgroundColor: IbColors.accentColor);
      } catch (e) {
        IbUtils.showSimpleSnackBar(
            msg: 'Fail to add a reply $e!', backgroundColor: IbColors.errorRed);
      } finally {
        focusNode.requestFocus();
        replyUid.value = rxCommentItem.value.ibComment.uid;
        hintText.value = 'Add a creative reply here';
      }
    }
  }
}
