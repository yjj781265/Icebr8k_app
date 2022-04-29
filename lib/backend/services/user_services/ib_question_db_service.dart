import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
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

  Future<void> removeQuestion(IbQuestion question) async {
    print('removeQuestion $question');
    await _collectionRef.doc(question.id).delete();
  }

  Future<IbQuestion?> querySingleQuestion(String questionId) async {
    print('querySingleQuestion $questionId');
    if (questionId.isEmpty) {
      return null;
    }
    final snapshot = await _collectionRef.doc(questionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return IbQuestion.fromJson(snapshot.data()!);
  }

  /// query all question this uid asked, public question (no Anonymous question) by default
  Future<QuerySnapshot<Map<String, dynamic>>> queryAskedQuestions({
    int limit = 8,
    bool publicOnly = true,
    required String uid,
    DocumentSnapshot? lastDoc,
  }) {
    if (lastDoc == null && publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('isAnonymous', isEqualTo: false)
          .where('creatorId', isEqualTo: uid)
          .where('isPublic', isEqualTo: true)
          .limit(limit)
          .get();
    }
    if (lastDoc != null && publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .where('isAnonymous', isEqualTo: false)
          .where('isPublic', isEqualTo: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();
    }

    if (lastDoc != null && !publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .startAfterDocument(lastDoc)
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
      {DocumentSnapshot? lastDoc, int limit = 8}) async {
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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToComments(
      String questionId,
      {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestamp', descending: true)
          .limit(8);
    } else {
      query = _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDoc)
          .limit(8);
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

  /// Icebr8k algorithm for loading trending question
  /// - loading public questions order by points during last 72 hrs;
  /// then load the rest order by asc time;
  Future<QuerySnapshot<Map<String, dynamic>>> queryTrendingQuestions(
      {int limit = 16}) async {
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
      {DocumentSnapshot? lastDoc, int limit = 16}) async {
    if (lastDoc != null) {
      return _collectionRef
          .where('sharedFriendUids',
              arrayContains: IbUtils.getCurrentUid() ?? '')
          .orderBy('askedTimeInMs', descending: true)
          .startAfterDocument(lastDoc)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .where('sharedFriendUids', arrayContains: IbUtils.getCurrentUid() ?? '')
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryFollowedTagsQuestions(
      {DocumentSnapshot? lastDoc, int limit = 16}) async {
    final List<String> followedTags = IbUtils.getCurrentIbUser() == null
        ? []
        : IbUtils.getCurrentIbUser()!.tags;
    followedTags.shuffle();
    final tenTags = followedTags.take(10).toList();
    if (lastDoc != null) {
      return _collectionRef
          .where('tags', arrayContainsAny: tenTags)
          .orderBy('askedTimeInMs', descending: true)
          .limit(limit)
          .startAfterDocument(lastDoc)
          .get();
    }

    return _collectionRef
        .where('tags', arrayContainsAny: tenTags)
        .orderBy('askedTimeInMs', descending: true)
        .limit(limit)
        .get();
  }

  /// query public ibQuestions in chronological order
  Future<QuerySnapshot<Map<String, dynamic>>> queryIbQuestions(
      {int limit = 16, required int askedTimeInMs}) async {
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
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(uid)
        .get();
    if (!_snapshot.exists) {
      return null;
    }

    return IbAnswer.fromJson(_snapshot.data()!);
  }

  /// get list of PUBLIC ibAnswers with the same choice id but different user id
  Future<QuerySnapshot<Map<String, dynamic>>> queryIbAnswers(
      {required String choiceId,
      required String questionId,
      int limit = 8,
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

    IbCacheManager()
        .cacheSingleIbAnswer(uid: IbUtils.getCurrentUid()!, ibAnswer: ibAnswer);
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

  Future<bool> isQuestionAnswered(
      {required String uid, required String questionId}) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(uid)
        .get();
    return _snapshot.exists;
  }

  Future<bool> isLiked(String questionId) async {
    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kLikesCollectionGroup)
        .doc(IbUtils.getCurrentUid())
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
        .doc(IbUtils.getCurrentUid())
        .set(
      {
        'uid': IbUtils.getCurrentUid(),
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
        .doc(IbUtils.getCurrentUid())
        .delete();
  }

  Future<void> eraseAllAnsweredQuestions(String uid) async {
    print('eraseAllAnsweredQuestions');
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .where('uid', isEqualTo: uid)
        .get();
    for (final doc in _snapshot.docs) {
      final questionId = doc.data()['questionId'].toString();
      await _collectionRef
          .doc(questionId)
          .collection(_kAnswerCollectionGroup)
          .doc(uid)
          .delete();
    }
  }

  Future<void> eraseSingleAnsweredQuestions(
      String uid, String questionId) async {
    return _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(uid)
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
        .doc(IbUtils.getCurrentUid())
        .set({
      'uid': IbUtils.getCurrentUid()!,
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
        .doc(IbUtils.getCurrentUid())
        .delete();
  }

  Future<bool> isCommentLiked(IbComment ibComment) async {
    final snapshot = await _collectionRef
        .doc(ibComment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(ibComment.commentId)
        .collection(_kCommentLikesCollectionGroup)
        .doc(IbUtils.getCurrentUid())
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
          .limit(8)
          .get();
      return snapshot;
    }

    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('timestamp', descending: true)
        .limit(8)
        .get();
    return snapshot;
  }

  Future<bool> isCommented(String questionId) async {
    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .where('uid', isEqualTo: IbUtils.getCurrentUid())
        .get();

    return snapshot.size >= 1;
  }

  Future<void> copyCollection(String collection1, String collection2) async {
    final snapshot = await _db.collection(collection1).get();
    for (final doc in snapshot.docs) {
      await _db.collection(collection2).doc(doc.id).set(doc.data());
    }
  }
}
