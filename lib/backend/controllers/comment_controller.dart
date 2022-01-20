import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentController extends GetxController {
  final comments = <CommentItem?>[].obs;
  final FocusNode focusNode = FocusNode();
  final List<String> dropDownOptions = ['Top Comments', 'Newest First'];
  final currentOption = 'Top Comments'.obs;
  final Map<String, IbAnswer> answerMap = {};
  final hintText = 'Add a creative comment here'.obs;
  final replyCommentId = ''.obs;
  final isLoading = true.obs;
  final IbQuestion ibQuestion;
  final commentCount = 0.obs;
  final sortByDate = true.obs;
  final isAddingComment = false.obs;
  final TextEditingController editingController = TextEditingController();
  final RefreshController refreshController = RefreshController();
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  CommentController(this.ibQuestion);

  @override
  Future<void> onInit() async {
    super.onInit();
    commentCount.value = ibQuestion.comments;
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
      snapshot = await IbQuestionDbService().queryTopComments(ibQuestion.id);
    } else {
      snapshot = await IbQuestionDbService().queryNewestComments(ibQuestion.id);
    }

    for (final doc in snapshot.docs) {
      tempList.add(IbComment.fromJson(doc.data()));
    }

    lastSnap = tempList.isEmpty ? null : snapshot.docs.last;

    for (final comment in tempList) {
      final IbUser? user;
      final IbAnswer? ibAnswer;

      user = await retrieveUser(comment);
      ibAnswer = await retrieveIbAnswer(comment);
      if (user == null) {
        continue;
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
    comments.refresh();
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    try {
      QuerySnapshot<Map<String, dynamic>>? snapshot;
      final List<IbComment> tempList = [];
      if (lastSnap != null && currentOption.value == dropDownOptions[0]) {
        snapshot = await IbQuestionDbService()
            .queryTopComments(ibQuestion.id, lastSnap: lastSnap);
      } else if (lastSnap != null &&
          currentOption.value == dropDownOptions[1]) {
        snapshot = await IbQuestionDbService()
            .queryNewestComments(ibQuestion.id, lastSnap: lastSnap);
      }

      if (snapshot != null &&
          snapshot.docs.isNotEmpty &&
          lastSnap != snapshot.docs.last) {
        lastSnap = snapshot.docs.last;
        for (final doc in snapshot.docs) {
          tempList.add(IbComment.fromJson(doc.data()));
        }

        for (final comment in tempList) {
          final IbUser? user;
          final IbAnswer? ibAnswer;

          user = await retrieveUser(comment);
          ibAnswer = await retrieveIbAnswer(comment);

          if (user == null) {
            continue;
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
          .queryIbAnswer(comment.uid, comment.questionId);
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
      await IbQuestionDbService().addComment(ibComment);
      final IbAnswer? ibAnswer = await IbQuestionDbService()
          .queryIbAnswer(ibComment.uid, ibComment.questionId);
      editingController.clear();
      comments.insert(
          0,
          CommentItem(
              ibComment: ibComment,
              user: IbUtils.getCurrentIbUser()!,
              ibAnswer: ibAnswer));

      updateCommentCount();
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
      List<IbComment> replies) async {
    late List<IbComment> firstThreeList;
    final List<CommentItem> replyItems = [];
    replies.sort((a, b) => b.timestampInMs.compareTo(a.timestampInMs));

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
    itemController.commented.value = true;
    itemController.rxIbQuestion.refresh();
  }

  void updateFirstThreeReplies(
      {required CommentItem reply, required String originCommentId}) {
    final CommentItem? item = comments.firstWhere((element) {
      if (element != null) {
        return element.ibComment.commentId == originCommentId;
      }
      return false;
    });

    if (item != null) {
      item.firstThreeReplies.add(reply);
      item.firstThreeReplies.sort((a, b) =>
          b.ibComment.timestampInMs.compareTo(a.ibComment.timestampInMs));
      item.firstThreeReplies = item.firstThreeReplies.sublist(
          0,
          item.firstThreeReplies.length > 3
              ? 3
              : item.firstThreeReplies.length);
      item.ibComment.replies.add(reply.ibComment);
      comments.refresh();
    }
  }

  void sortList() {
    if (currentOption.value == dropDownOptions[1]) {
      comments.sort((a, b) {
        if (a != null && b != null) {
          return b.ibComment.timestampInMs.compareTo(a.ibComment.timestampInMs);
        }
        return 0;
      });
    } else {
      comments.sort((a, b) {
        if (a != null && b != null) {
          return b.ibComment.likes.compareTo(a.ibComment.likes);
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
