import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/comment_controller.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../frontend/ib_colors.dart';
import '../../models/ib_question.dart';
import '../../services/user_services/ib_question_db_service.dart';

class ReplyController extends GetxController {
  final creatorId = ''.obs;
  final isQuestionAnonymous = false.obs;
  final FocusNode node = FocusNode();
  final int kPerPageMax = 16;
  final count = 0.obs;
  IbComment? parentComment;
  final IbQuestion ibQuestion;
  final comments = <CommentItem>[].obs;
  final String parentCommentId;
  final isLoading = false.obs;
  final isAddingReply = false.obs;
  String notifyUid = '';
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();

  ReplyController({required this.parentCommentId, required this.ibQuestion});

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    editingController.addListener(() {
      if (editingController.text.isEmpty) {
        notifyUid = '';
      }
    });
    parentComment = await IbQuestionDbService().queryComment(parentCommentId);
    if (parentComment == null) {
      isLoading.value = false;
      return;
    }

    final ibAnswer = await retrieveIbAnswer(parentComment!);
    final user = await retrieveUser(parentComment!);
    if (user == null) {
      return;
    }
    final parentCommentItem =
        CommentItem(ibComment: parentComment!, user: user, ibAnswer: ibAnswer);
    comments.add(parentCommentItem);
    parentComment!.replies.sort((a, b) =>
        (a.timestamp as Timestamp).compareTo(b.timestamp as Timestamp));

    for (final item in parentComment!.replies.take(kPerPageMax)) {
      final user = await retrieveUser(item);
      if (user == null) {
        continue;
      }

      final ibAnswer = await retrieveIbAnswer(item);
      comments
          .add(CommentItem(ibComment: item, user: user, ibAnswer: ibAnswer));
    }

    final q = await IbQuestionDbService()
        .querySingleQuestion(parentComment!.questionId);
    creatorId.value = q == null ? '' : q.creatorId;
    if (q == null) {
      isQuestionAnonymous.value = false;
    } else {
      isQuestionAnonymous.value = q.isAnonymous;
    }
    isLoading.value = false;
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager()
        .logScreenView(className: 'ReplyController', screenName: 'ReplyPage');
  }

  Future<void> loadMore() async {
    final currentIndex =
        parentComment!.replies.indexOf(comments.last.ibComment);
    if (currentIndex == -1 ||
        parentComment!.replies.length == currentIndex + 1) {
      refreshController.loadNoData();
      return;
    } else {
      try {
        final nextIndex = currentIndex + 1;
        final endIndex =
            (currentIndex + kPerPageMax) > parentComment!.replies.length
                ? parentComment!.replies.length
                : currentIndex + kPerPageMax;

        for (int i = nextIndex; i < endIndex; i++) {
          final item = parentComment!.replies[i];
          final user = await retrieveUser(item);
          if (user == null) {
            continue;
          }

          final ibAnswer = await retrieveIbAnswer(item);
          comments.add(
              CommentItem(ibComment: item, user: user, ibAnswer: ibAnswer));
        }
        refreshController.loadComplete();
      } catch (e) {
        print(e);
        refreshController.loadFailed();
      }
    }
  }

  Future<void> addReply({required String text, required String type}) async {
    if (text.trim().isEmpty) {
      return;
    }
    isAddingReply.value = true;

    final IbComment ibComment = IbComment(
        commentId: IbUtils.getUniqueId(),
        parentId: parentCommentId,
        notifyUid: notifyUid.isEmpty ? parentComment!.uid : notifyUid,
        uid: IbUtils.getCurrentUid()!,
        questionId: parentComment!.questionId,
        content: text.trim(),
        type: type,
        timestamp: Timestamp.now());

    try {
      await IbQuestionDbService().addReply(ibComment);
      if (ibComment.notifyUid != IbUtils.getCurrentUid()!) {
        await IbUserDbService().sendAlertNotification(IbNotification(
            id: ibComment.commentId,
            body: '',
            type: IbNotification.kPollCommentReply,
            timestamp: Timestamp.now(),
            senderId: IbUtils.getCurrentUid()!,
            recipientId: ibComment.notifyUid,
            url: ibComment.parentId ?? ""));
      }

      final user = await retrieveUser(ibComment);
      if (user == null) {
        return;
      }
      final ibAnswer = await retrieveIbAnswer(ibComment);
      editingController.clear();

      /// add the new reply to the list
      final newItem =
          CommentItem(ibComment: ibComment, user: user, ibAnswer: ibAnswer);
      comments.add(newItem);
      IbUtils.showSimpleSnackBar(
          msg: 'Reply added!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      print(e);
    } finally {
      IbUtils.hideKeyboard();
      isAddingReply.value = false;
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
}
