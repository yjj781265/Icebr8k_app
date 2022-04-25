import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/comment_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../frontend/ib_colors.dart';
import '../../services/user_services/ib_question_db_service.dart';

class ReplyController extends GetxController {
  final replyItems = <CommentItem>[].obs;
  final creatorId = ''.obs;
  final isQuestionAnonymous = false.obs;
  final FocusNode node = FocusNode();
  final int kPerPageMax = 16;
  final count = 0.obs;
  final CommentItem commentItem;
  final isLoading = false.obs;
  final isAddingReply = false.obs;
  String notifyUid = '';
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();

  ReplyController({required this.commentItem});

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    count.value = commentItem.ibComment.replies.length;
    notifyUid = commentItem.user.id;
    commentItem.ibComment.replies.sort((a, b) =>
        (a.timestamp as Timestamp).compareTo(b.timestamp as Timestamp));

    editingController.addListener(() {
      if (editingController.text.isEmpty) {
        notifyUid = '';
      }
    });

    for (final item in commentItem.ibComment.replies.take(kPerPageMax)) {
      final user = await retrieveUser(item);
      if (user == null) {
        continue;
      }

      final ibAnswer = await retrieveIbAnswer(item);
      replyItems
          .add(CommentItem(ibComment: item, user: user, ibAnswer: ibAnswer));
    }

    /// add parent comment to the top
    replyItems.insert(0, commentItem);

    final q = await IbQuestionDbService()
        .querySingleQuestion(commentItem.ibComment.questionId);
    creatorId.value = q == null ? '' : q.creatorId;
    if (q == null) {
      isQuestionAnonymous.value = false;
    } else {
      isQuestionAnonymous.value = q.isAnonymous;
    }
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    final currentIndex =
        commentItem.ibComment.replies.indexOf(replyItems.last.ibComment);
    if (currentIndex == -1 ||
        commentItem.ibComment.replies.length == currentIndex + 1) {
      refreshController.loadNoData();
      return;
    } else {
      try {
        final nextIndex = currentIndex + 1;
        final endIndex =
            (currentIndex + kPerPageMax) > commentItem.ibComment.replies.length
                ? commentItem.ibComment.replies.length
                : currentIndex + kPerPageMax;

        for (int i = nextIndex; i < endIndex; i++) {
          final item = commentItem.ibComment.replies[i];
          final user = await retrieveUser(item);
          if (user == null) {
            continue;
          }

          final ibAnswer = await retrieveIbAnswer(item);
          replyItems.add(
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
        parentId: commentItem.ibComment.commentId,
        notifyUid: notifyUid.isEmpty ? commentItem.user.id : notifyUid,
        uid: IbUtils.getCurrentUid()!,
        questionId: commentItem.ibComment.questionId,
        content: text.trim(),
        type: type,
        timestamp: Timestamp.now());

    try {
      await IbQuestionDbService().addReply(ibComment);
      final user = await retrieveUser(ibComment);
      if (user == null) {
        return;
      }
      final ibAnswer = await retrieveIbAnswer(ibComment);
      editingController.clear();

      /// add the new reply to the list
      final newItem =
          CommentItem(ibComment: ibComment, user: user, ibAnswer: ibAnswer);
      replyItems.add(newItem);

      /// update comment controller
      final index =
          Get.find<CommentController>().commentItems.indexOf(commentItem);
      if (index != -1) {
        count.value++;
        commentItem.ibComment.replies.add(newItem.ibComment);
        Get.find<CommentController>().commentItems[index] = commentItem;
        Get.find<CommentController>().commentItems.refresh();
        IbUtils.showSimpleSnackBar(
            msg: 'Reply added!', backgroundColor: IbColors.accentColor);
      }
    } catch (e) {
      print(e);
    } finally {
      IbUtils.hideKeyboard();
      isAddingReply.value = false;
    }
  }

  Future<IbAnswer?> retrieveIbAnswer(IbComment comment) async {
    final IbAnswer? ibAnswer;
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
      return ibAnswers.firstWhereOrNull(
          (element) => element.questionId == comment.questionId);
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
