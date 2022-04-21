import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  static const _kCommentRepliesCollectionGroup =
      'Comments-Replies${DbConfig.dbSuffix}';
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

  Future<List<IbQuestion>> queryFirst8() async {
    final snapshot = await _db.collection('First8${DbConfig.dbSuffix}').get();

    final List<IbQuestion> list = [];
    for (final doc in snapshot.docs) {
      list.add(IbQuestion.fromJson(doc.data()));
    }

    return list;
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
          .where('privacyBounds', arrayContains: IbQuestion.kPrivacyBoundPublic)
          .limit(limit)
          .get();
    }
    if (lastDoc != null && publicOnly) {
      return _collectionRef
          .orderBy('askedTimeInMs', descending: true)
          .where('creatorId', isEqualTo: uid)
          .where('isAnonymous', isEqualTo: false)
          .where('privacyBounds', arrayContains: IbQuestion.kPrivacyBoundPublic)
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
          .where('isPublic', isEqualTo: true);
    } else {
      query = _db
          .collectionGroup(_kAnswerCollectionGroup)
          .where('uid', isEqualTo: uid)
          .where('isPublic', isEqualTo: true)
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
      try {
        list.add(IbQuestion.fromJson(doc.data()));
      } catch (e) {
        print(e);
        continue;
      }
    }

    return list;
  }

  /// query all the ibAnswers from a user, this might be time consuming
  Future<List<IbAnswer>> queryUserAnswers(String uid) async {
    final List<IbAnswer> answers = [];
    final _snapshot = await _db
        .collectionGroup(_kAnswerCollectionGroup)
        .where('uid', isEqualTo: uid)
        .where('isPublic', isEqualTo: true)
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
          .where('isPublic', isEqualTo: true)
          .orderBy('answeredTimeInMs', descending: true)
          .startAfterDocument(lastSnap)
          .limit(limit)
          .get();
    }

    return _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .where('isPublic', isEqualTo: true)
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

  /// comments sub collections query and listeners

  Future<void> addComment(IbComment comment) async {
    await _collectionRef
        .doc(comment.questionId)
        .collection(_kCommentCollectionGroup)
        .doc(comment.commentId)
        .set(comment.toJson(), SetOptions(merge: true));
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
          .orderBy('timestampInMs', descending: true)
          .startAfterDocument(lastSnap)
          .limit(8)
          .get();
      return snapshot;
    }

    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('timestampInMs', descending: true)
        .limit(8)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryTopComments(
      String questionId,
      {DocumentSnapshot<Map<String, dynamic>>? lastSnap}) async {
    if (lastSnap != null) {
      final snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .orderBy('likes', descending: true)
          .startAfterDocument(lastSnap)
          .limit(8)
          .get();
      return snapshot;
    }

    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .orderBy('likes', descending: true)
        .limit(8)
        .get();
    return snapshot;
  }

  /// return replies of a comment in reversed chronological order
  Future<QuerySnapshot<Map<String, dynamic>>> queryReplies(
      {required String questionId,
      required String commentId,
      int limit = 8,
      DocumentSnapshot<Map<String, dynamic>>? lastSnap}) async {
    if (lastSnap != null) {
      final snapshot = await _collectionRef
          .doc(questionId)
          .collection(_kCommentCollectionGroup)
          .doc(commentId)
          .collection(_kCommentRepliesCollectionGroup)
          .orderBy('timestampInMs', descending: true)
          .startAfterDocument(lastSnap)
          .limit(limit)
          .get();
      return snapshot;
    }

    final snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .doc(commentId)
        .collection(_kCommentRepliesCollectionGroup)
        .orderBy('timestampInMs', descending: true)
        .limit(limit)
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

  Future<void> addReply(
      {required String questionId,
      required String commentId,
      required IbComment reply}) async {
    await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .doc(commentId)
        .collection(_kCommentRepliesCollectionGroup)
        .doc(reply.replyId)
        .set(reply.toJson(), SetOptions(merge: true));
  }

  Future<void> removeReply(
      {required String questionId,
      required String commentId,
      required IbComment reply}) async {
    await _collectionRef
        .doc(questionId)
        .collection(_kCommentCollectionGroup)
        .doc(commentId)
        .collection(_kCommentRepliesCollectionGroup)
        .doc(reply.commentId)
        .delete();
  }

  Future<void> copyCollection(String collection1, String collection2) async {
    final snapshot = await _db.collection(collection1).get();
    for (final doc in snapshot.docs) {
      await _db.collection(collection2).doc(doc.id).set(doc.data());
    }
  }
}
