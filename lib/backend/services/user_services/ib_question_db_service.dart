import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../db_config.dart';

class IbQuestionDbService {
  static final _ibQuestionDbService = IbQuestionDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kQuestionCollection = 'IbQuestions${DbConfig.dbSuffix}';
  static const _kAnswerCollectionGroup = 'Answers${DbConfig.dbSuffix}';
  static const _kLikesCollectionGroup = 'Likes${DbConfig.dbSuffix}';
  static const _kCommentCollectionGroup = 'Comments${DbConfig.dbSuffix}';
  static const _kCommentLikesCollectionGroup =
      'Comments-Likes${DbConfig.dbSuffix}';

  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbQuestionDbService() => _ibQuestionDbService;

  IbQuestionDbService._() {
    _db.settings = const Settings(persistenceEnabled: false);
    _collectionRef = _db.collection(_kQuestionCollection);
  }

  Future<void> uploadQuestion(IbQuestion question) async {
    print('uploadQuestion $question');
    await _collectionRef
        .doc(question.id)
        .set(question.toJson(), SetOptions(merge: true));
  }

  Future<void> addChoice(
      {required String questionId, required IbChoice ibChoice}) async {
    await _collectionRef.doc(questionId).update({
      'choices': FieldValue.arrayUnion([ibChoice.toJson()])
    });
  }

  Future<int> queryDailyCurrentUserPollsCount() async {
    final int timestamp24HrAgoInMs = Timestamp.now().millisecondsSinceEpoch -
        const Duration(hours: 24).inMilliseconds;
    final snapshot = await _collectionRef
        .where('creatorId', isEqualTo: IbUtils().getCurrentUid())
        .where(
          'askedTimeInMs',
          isGreaterThanOrEqualTo: timestamp24HrAgoInMs,
        )
        .limit(4)
        .orderBy('askedTimeInMs', descending: true)
        .get();
    return snapshot.docs.length;
  }

  Future<List<IbQuestion>> queryFirst8() async {
    final uid = await IbUserDbService().queryUserIdFromUserName('icebr8k');
    final snapshot = await _collectionRef
        .where('creatorId', isEqualTo: uid)
        .limit(8)
        .orderBy('askedTimeInMs', descending: false)
        .get();
    if (snapshot.size == 0) {
      return [];
    }

    return snapshot.docs.map((e) => IbQuestion.fromJson(e.data())).toList();
  }

  /// retrieve single IbQuestion and cache locally via IbCacheManager
  Future<IbQuestion?> querySingleQuestion(String questionId) async {
    print('querySingleQuestion $questionId');
    try {
      if (questionId.isEmpty) {
        return null;
      }
      final snapshot = await _collectionRef.doc(questionId).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final q = IbQuestion.fromJson(snapshot.data()!);
      IbCacheManager().cacheSingleIbQuestion(q);
      return q;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  /// query all question this uid asked, public question (no Anonymous question) by default
  Future<QuerySnapshot<Map<String, dynamic>>> queryAskedQuestions({
    int limit = IbConfig.kPerPage,
    bool publicOnly = true,
    required String uid,
    int? lastAskedTimeInMs,
  }) {
    if (lastAskedTimeInMs == null && publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('isAnonymous', isEqualTo: false)
          .where('creatorId', isEqualTo: uid)
          .where('isPublic', isEqualTo: true)
          .limit(limit)
          .get();
    }
    if (lastAskedTimeInMs != null && publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .where('isAnonymous', isEqualTo: false)
          .where('isPublic', isEqualTo: true)
          .where('askedTimeInMs', isLessThan: lastAskedTimeInMs)
          .limit(limit)
          .get();
    }

    if (lastAskedTimeInMs != null && !publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .where('askedTimeInMs', isLessThan: lastAskedTimeInMs)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .orderBy('askedTimeInMs', descending: true)
        .where('creatorId', isEqualTo: uid)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryAnsweredQuestions(String uid,
      {DocumentSnapshot? lastDoc, int limit = IbConfig.kPerPage}) async {
    late Query<Map<String, dynamic>> query;
    if (lastDoc != null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .limit(limit)
          .startAfterDocument(lastDoc);
    } else {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .limit(limit);
    }
    return query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listenToUserPublicAnsweredQuestionsChange(String uid,
          {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .where('isAnonymous', isEqualTo: false);
    } else {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .where('isAnonymous', isEqualTo: false)
          .startAfterDocument(lastDoc);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listenToUseAnsweredQuestionsChange(String uid,
          {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid);
    } else {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .startAfterDocument(lastDoc);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAskedQuestions(String uid,
      {int? lastAskedTimeInMs}) {
    late Query<Map<String, dynamic>> query;
    if (lastAskedTimeInMs == null) {
      query = _collectionRef
          .where('creatorId', isEqualTo: uid)
          .orderBy('askedTimeInMs', descending: true)
          .limit(IbConfig.kPerPage);
    } else {
      query = _collectionRef
          .where('creatorId', isEqualTo: uid)
          .where('askedTimeInMs', isLessThan: lastAskedTimeInMs)
          .orderBy('askedTimeInMs', descending: true)
          .limit(IbConfig.kPerPage);
    }

    return query.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToComments(
      String questionId,
      {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestamp', descending: true)
          .limit(IbConfig.kPerPage);
    } else {
      query = _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDoc)
          .limit(IbConfig.kPerPage);
    }

    return query.snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryTopThreeComments(
      String questionId) async {
    return _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .where('likes', isGreaterThanOrEqualTo: 1)
        .orderBy('likes', descending: true)
        .limit(3)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryAllMyComments(
      String questionId) async {
    print('queryAllMyComments');
    return _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .where('uid', isEqualTo: IbUtils().getCurrentUid())
        .get();
  }

  /// Icebr8k algorithm for loading trending question
  /// loading public questions order by points during last 72 hrs;
  /// then load the rest order by asc time;
  Future<QuerySnapshot<Map<String, dynamic>>> queryTrendingQuestions(
      {int limit = IbConfig.kPerPage}) async {
    final int minTimestampInMs = DateTime.now().millisecondsSinceEpoch -
        const Duration(days: 3).inMilliseconds;

    return _collectionRef
        .where('isPublic', isEqualTo: true)
        .where('askedTimeInMs', isGreaterThanOrEqualTo: minTimestampInMs)
        .orderBy('askedTimeInMs', descending: false)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryFriendsQuestions(
      {DocumentSnapshot? lastDoc, int limit = IbConfig.kPerPage}) async {
    if (lastDoc != null) {
      return _collectionRef
          .where('sharedFriendUids',
              arrayContains: IbUtils().getCurrentUid() ?? '')
          .orderBy('askedTimeInMs', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .where('sharedFriendUids',
            arrayContains: IbUtils().getCurrentUid() ?? '')
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryFollowedTagsQuestions(
      {DocumentSnapshot? lastDoc,
      int limit = IbConfig.kPerPage,
      required List<String> tags}) async {
    tags.shuffle();
    final eightTags = tags.take(8).toList();
    if (lastDoc != null) {
      return _collectionRef
          .where('tags', arrayContainsAny: eightTags)
          .where('isPublic', isEqualTo: true)
          .orderBy('askedTimeInMs', descending: true)
          .limit(limit)
          .startAfterDocument(lastDoc)
          .get();
    }

    return _collectionRef
        .where('tags', arrayContainsAny: eightTags)
        .where('isPublic', isEqualTo: true)
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  /// query public ibQuestions in chronological order
  Future<QuerySnapshot<Map<String, dynamic>>> queryIbQuestions(
      {int limit = IbConfig.kPerPage, required int askedTimeInMs}) async {
    return _collectionRef
        .where('isPublic', isEqualTo: true)
        .where('askedTimeInMs', isLessThan: askedTimeInMs)
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  /// query public ibQuestions in chronological order
  Future<QuerySnapshot<Map<String, dynamic>>> queryTagIbQuestions({
    int limit = 16,
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    required String text,
  }) async {
    if (lastDoc != null) {
      return _collectionRef
          .where('isPublic', isEqualTo: true)
          .where('tags', arrayContains: text)
          .orderBy('askedTimeInMs', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .where('isPublic', isEqualTo: true)
        .where('tags', arrayContains: text)
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  /// query all the ibAnswers from a user, this might be time consuming
  Future<List<IbAnswer>> queryUserAnswers(String uid) async {
    final List<IbAnswer> answers = [];
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .where('uid', isEqualTo: uid)
        .where('isAnonymous', isEqualTo: false)
        .limit(IbConfig.kUserAnswersQueryLimit)
        .get();
    for (final doc in _snapshot.docs) {
      try {
        answers.add(IbAnswer.fromJson(doc.data()));
      } catch (e) {
        print(e);
        continue;
      }
    }
    return answers;
  }

  Future<IbAnswer?> querySingleIbAnswer(String uid, String questionId) async {
    try {
      final _snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kAnswerCollectionGroup)
          .doc(uid)
          .get();
      if (!_snapshot.exists) {
        return null;
      }

      return IbAnswer.fromJson(_snapshot.data()!);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// get list of PUBLIC ibAnswers with the same choice id but different user id
  Future<QuerySnapshot<Map<String, dynamic>>> queryIbAnswers(
      {required String choiceId,
      required String questionId,
      int limit = IbConfig.kPerPage,
      DocumentSnapshot<Map<String, dynamic>>? lastSnap}) async {
    if (lastSnap != null) {
      return _collectionRef
          .doc(questionId)
          .collection(_kAnswerCollectionGroup)
          .where('choiceId', isEqualTo: choiceId)
          .where('isAnonymous', isEqualTo: false)
          .orderBy('answeredTimeInMs', descending: true)
          .startAfterDocument(lastSnap)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .where('isAnonymous', isEqualTo: false)
        .where('choiceId', isEqualTo: choiceId)
        .orderBy('answeredTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  Future<void> answerQuestion(IbAnswer ibAnswer) async {
    await _collectionRef
        .doc(ibAnswer.questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(ibAnswer.uid)
        .set(ibAnswer.toJson(), SetOptions(merge: true));

    IbCacheManager().cacheSingleIbAnswer(
        uid: IbUtils().getCurrentUid()!, ibAnswer: ibAnswer);
  }

  Future<int> querySpecificAnswerPollSize(
      {required String questionId, required String choiceId}) async {
    final _snapshot = await _collectionRef.doc(questionId).get();
    if (_snapshot.exists &&
        _snapshot.data() != null &&
        _snapshot.data()![choiceId] != null) {
      return _snapshot.data()![choiceId] as int;
    }
    return 0;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToIbQuestionsChange(
      int timestamp) {
    return _collectionRef
        .where('askedTimeInMs', isGreaterThan: timestamp)
        .orderBy('askedTimeInMs', descending: true)
        .limit(8)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToIbQuestionChange(
      String questionId) {
    return _collectionRef.doc(questionId).snapshots();
  }

  Future<bool> isQuestionAnswered(
      {required String uid, required String questionId}) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(uid)
        .get(const GetOptions(source: Source.server));
    return _snapshot.exists;
  }

  Future<bool> isLiked(String questionId) async {
    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .get();

    return snapshot.exists;
  }

  Future<void> updateLikes(String questionId) async {
    if (await isLiked(questionId)) {
      return;
    }
    await _collectionRef
        .doc(questionId)
        .collection(_kLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .set(
      {
        'uid': IbUtils().getCurrentUid(),
        'timestampInMs': DateTime.now().millisecondsSinceEpoch,
        'questionId': questionId,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeLikes(String questionId) async {
    if (!await isLiked(questionId)) {
      return;
    }
    await _collectionRef
        .doc(questionId)
        .collection(_kLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .delete();
  }

  Future<void> addComment(IbComment comment) async {
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .set(comment.toJson(), SetOptions(merge: true));
  }

  Future<void> addReply(IbComment comment) async {
    if (comment.parentId == null || comment.parentId!.isEmpty) {
      return;
    }
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.parentId)
        .update({
      'replies': FieldValue.arrayUnion([comment.toJson()])
    });
  }

  Future<void> likeComment(IbComment comment) async {
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .collection(_kCommentLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .set({
      'uid': IbUtils().getCurrentUid(),
      'commentId': comment.commentId,
      'questionId': comment.questionId
    });
  }

  Future<void> dislikeComment(IbComment comment) async {
    final snapshot = await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .get();

    if (!snapshot.exists) {
      return;
    }

    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .collection(_kCommentLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .delete();
  }

  Future<bool> isCommentLiked(IbComment ibComment) async {
    final snapshot = await _collectionRef
        .doc(ibComment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(ibComment.commentId)
        .collection(_kCommentLikesCollectionGroup)
        .doc(IbUtils().getCurrentUid())
        .get();
    return snapshot.exists;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryNewestComments(
      String questionId,
      {DocumentSnapshot<Map<String, dynamic>>? lastSnap}) async {
    if (lastSnap != null) {
      final snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastSnap)
          .limit(IbConfig.kPerPage)
          .get();
      return snapshot;
    }

    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('timestamp', descending: true)
        .limit(IbConfig.kPerPage)
        .get();
    return snapshot;
  }

  Future<bool> isCommented(String questionId) async {
    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .where('uid', isEqualTo: IbUtils().getCurrentUid())
        .get();

    return snapshot.size >= 1;
  }

  Future<IbComment?> queryComment(String commentId) async {
    print('queryComment');
    try {
      final snapshot = await _db
          .collectionGroup(_kCommentCollectionGroup)
          .where('commentId', isEqualTo: commentId)
          .get();
      if (snapshot.size == 0) {
        return null;
      }
      return IbComment.fromJson(snapshot.docs.first.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteSingleIbAnswer(IbAnswer ibAnswer) async {
    try {
      await _collectionRef
          .doc(ibAnswer.questionId)
          .collection(_kAnswerCollectionGroup)
          .doc(ibAnswer.uid)
          .delete();
    } catch (e) {
      print('deleteSingleIbAnswer $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    final snapshot1 = await _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .get();

    /// delete all answers
    for (final doc in snapshot1.docs) {
      await doc.reference.delete();
    }

    final snapshot2 = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .get();

    /// delete all comments and it's likes
    for (final doc in snapshot2.docs) {
      final commentLikesSnapshot =
          await doc.reference.collection(_kCommentLikesCollectionGroup).get();
      for (final commentLikesDoc in commentLikesSnapshot.docs) {
        await commentLikesDoc.reference.delete();
      }
      await doc.reference.delete();
    }

    final snapshot3 = await _collectionRef
        .doc(questionId)
        .collection(_kLikesCollectionGroup)
        .get();

    /// delete all likes
    for (final doc in snapshot3.docs) {
      await doc.reference.delete();
    }
    // delete the top node and medias
    final snapshot4 = await _collectionRef.doc(questionId).get();
    final q = IbQuestion.fromJson(snapshot4.data()!);
    for (final media in q.medias) {
      await IbStorageService().deleteFile(media.url);
    }

    for (final choice in q.choices) {
      if (choice.url != null && choice.url!.isURL) {
        await IbStorageService().deleteFile(choice.url!);
      }
    }
    await snapshot4.reference.delete();
  }

  Future<void> copyCollection(String collection1, String collection2) async {
    final snapshot = await _db.collection(collection1).get();
    for (final doc in snapshot.docs) {
      await _db.collection(collection2).doc(doc.id).set(doc.data());
    }
  }
}
