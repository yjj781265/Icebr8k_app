import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../db_config.dart';

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

  Future<IbQuestion?> querySingleQuestion(String questionId) async {
    print('querySingleQuestion $questionId');
    final snapshot = await _collectionRef.doc(questionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return IbQuestion.fromJson(snapshot.data()!);
  }

  Future<List<IbQuestion>> queryIcebr8kQ() async {
    final snapshot = await _collectionRef
        .where('creatorId', isEqualTo: 'tCH8AIqRxWM0eEQcmlnniUIfo6F3')
        .orderBy('askedTimeInMs')
        .limit(8)
        .get();

    final List<IbQuestion> list = [];
    for (final doc in snapshot.docs) {
      list.add(IbQuestion.fromJson(doc.data()));
    }

    return list;
  }

  /// query all question this uid asked
  Future<QuerySnapshot<Map<String, dynamic>>> queryAskedQuestions({
    int limit = -1,
    required String uid,
    DocumentSnapshot? lastDoc,
  }) {
    if (limit == -1) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .get();
    }

    if (lastDoc == null) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .limit(limit)
          .get();
    }
    return _collectionRef
        .orderBy('askedTimeInMs', descending: true)
        .startAfterDocument(lastDoc)
        .where('creatorId', isEqualTo: uid)
        .limit(limit)
        .get();
  }

  Future<int> queryTotalQuestionSize() async {
    final _snapshot = await _collectionRef.get();
    return _snapshot.size;
  }

  Future<List<String>> queryAnsweredQuestionIds(String uid) async {
    final List<String> _list = [];
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .where('uid', isEqualTo: uid)
        .get();

    for (final element in _snapshot.docs) {
      _list.add(element['questionId'].toString());
    }
    return _list;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryAnsweredQuestions(String uid,
      {DocumentSnapshot? lastDoc, int limit = 8}) {
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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAnsweredQuestionsChange(
      String uid,
      {DocumentSnapshot? lastDoc,
      int? limit}) {
    late Query<Map<String, dynamic>> query;
    if (limit == null && lastDoc == null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true);
    } else if (limit != null && lastDoc == null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .limit(limit)
          .orderBy('answeredTimeInMs', descending: true);
    } else if (limit == null && lastDoc != null) {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .startAfterDocument(lastDoc);
    } else if (limit != null && lastDoc != null) {
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
          .orderBy('answeredTimeInMs', descending: true);
    }

    return query.snapshots();
  }

  Future<IbAnswer?> queryLatestAnsweredQ(String uid) async {
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .limit(1)
        .where('uid', isEqualTo: uid)
        .orderBy('askedTimeInMs', descending: true)
        .get();
    if (_snapshot.docs.isEmpty) {
      return null;
    }

    return IbAnswer.fromJson(_snapshot.docs.first.data());
  }

  Future<IbAnswer?> queryFirstAnsweredQ(String uid) async {
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .limit(1)
        .where('uid', isEqualTo: uid)
        .orderBy('askedTimeInMs', descending: false)
        .get();
    if (_snapshot.docs.isEmpty) {
      return null;
    }

    return IbAnswer.fromJson(_snapshot.docs.first.data());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToUserAskedQuestionsChange(
      String uid,
      {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _collectionRef
          .where('creatorId', isEqualTo: uid)
          .orderBy('askedTimeInMs', descending: true)
          .limit(8);
    } else {
      query = _collectionRef
          .where('creatorId', isEqualTo: uid)
          .orderBy('askedTimeInMs', descending: true)
          .startAfterDocument(lastDoc)
          .limit(8);
    }

    return query.snapshots();
  }

  /// load questions for question tab
  Future<List<IbQuestion>> queryIbQuestions(int limit,
      {int? timestamp, bool isGreaterThan = true}) async {
    late QuerySnapshot<Map<String, dynamic>> snapshot;

    if (timestamp == null) {
      snapshot = await _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .limit(limit)
          .get();
    } else if (isGreaterThan) {
      snapshot = await _collectionRef
          .where('askedTimeInMs', isGreaterThan: timestamp)
          .orderBy('askedTimeInMs', descending: true)
          .limit(limit)
          .get();
    } else {
      snapshot = await _collectionRef
          .where('askedTimeInMs', isLessThan: timestamp)
          .orderBy('askedTimeInMs', descending: true)
          .limit(limit)
          .get();
    }

    final list = <IbQuestion>[];

    for (final doc in snapshot.docs) {
      list.add(IbQuestion.fromJson(doc.data()));
    }

    return list;
  }

  Future<List<IbAnswer>> queryUserAnswers(String uid) async {
    final List<IbAnswer> answers = [];
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .where('uid', isEqualTo: uid)
        .get();
    for (final doc in _snapshot.docs) {
      answers.add(IbAnswer.fromJson(doc.data()));
    }
    return answers;
  }

  Future<IbAnswer?> queryIbAnswer(String uid, String questionId) async {
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

  Future<void> answerQuestion(IbAnswer ibAnswer) async {
    await _collectionRef
        .doc(ibAnswer.questionId)
        .collection(_kAnswerCollectionGroup)
        .doc(ibAnswer.uid)
        .set(ibAnswer.toJson(), SetOptions(merge: true));
  }

  Future<void> increasePollSize(
      {required String questionId, required String choiceId}) async {
    await _collectionRef
        .doc(questionId)
        .set({choiceId: FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> updatePollSize(
      {required String questionId,
      required String oldChoiceId,
      required String newChoiceId}) async {
    await _collectionRef.doc(questionId).set({
      newChoiceId: FieldValue.increment(1),
      oldChoiceId: FieldValue.increment(-1)
    }, SetOptions(merge: true));
  }

  Future<int> queryPollSize(String questionId) async {
    final _snapshot = await _collectionRef.doc(questionId).get();

    if (!_snapshot.exists ||
        _snapshot.data() == null ||
        _snapshot.data()!['pollSize'] == 0) {
      print('queryPollSize legacy method');
      final _snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kAnswerCollectionGroup)
          .get();
      return _snapshot.size;
    }

    print('queryPollSize new method');

    return _snapshot.data()!['pollSize'] as int;
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

    await _collectionRef
        .doc(questionId)
        .set({'likes': FieldValue.increment(1)}, SetOptions(merge: true));
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

    await _collectionRef
        .doc(questionId)
        .set({'likes': FieldValue.increment(-1)}, SetOptions(merge: true));
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

  /// comments sub collections query and listeners

  Future<void> addComment(IbComment comment) async {
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .set(comment.toJson(), SetOptions(merge: true));

    await _collectionRef
        .doc(comment.questionId)
        .set({'comments': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  Future<void> likeComment(IbComment comment) async {
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .set({'likes': FieldValue.increment(1)}, SetOptions(merge: true));
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

    final tempComment = IbComment.fromJson(snapshot.data()!);

    if (tempComment.likes == 0) {
      return;
    }

    if (tempComment.likes < 0) {
      await _collectionRef
          .doc(tempComment.questionId)
          .collection(_kCommentCollectionGroup)
          .doc(tempComment.commentId)
          .set({'likes': 0}, SetOptions(merge: true));
      return;
    }

    await _collectionRef
        .doc(tempComment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(tempComment.commentId)
        .set({'likes': FieldValue.increment(-1)}, SetOptions(merge: true));
    await _collectionRef
        .doc(tempComment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(tempComment.commentId)
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
    QuerySnapshot<Map<String, dynamic>> snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('timestampInMs', descending: true)
        .limit(8)
        .get();

    if (lastSnap != null) {
      snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('timestampInMs', descending: true)
          .startAfterDocument(lastSnap)
          .limit(8)
          .get();
    }
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryTopComments(
      String questionId,
      {DocumentSnapshot<Map<String, dynamic>>? lastSnap}) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('likes', descending: true)
        .limit(8)
        .get();

    if (lastSnap != null) {
      snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('likes', descending: true)
          .startAfterDocument(lastSnap)
          .limit(8)
          .get();
    }

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

  Future<void> addReply(
      {required String questionId,
      required String commentId,
      required IbComment reply}) async {
    await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .doc(commentId)
        .set({
      'replies': FieldValue.arrayUnion([reply.toJson()])
    }, SetOptions(merge: true));
  }

  Future<void> removeReply(
      {required String questionId,
      required String commentId,
      required IbComment reply}) async {
    await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .doc(commentId)
        .set({
      'replies': FieldValue.arrayRemove([reply.toJson()])
    }, SetOptions(merge: true));
  }
}
