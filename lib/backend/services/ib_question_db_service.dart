import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';

import '../db_config.dart';

class IbQuestionDbService {
  static final _ibQuestionDbService = IbQuestionDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kQuestionCollection = 'IbQuestions${DbConfig.dbSuffix}';
  static const _kAnswerCollectionGroup = 'Answers${DbConfig.dbSuffix}';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbQuestionDbService() => _ibQuestionDbService;

  IbQuestionDbService._() {
    _db.settings = const Settings(persistenceEnabled: true);
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
      {required String questionId, required String answer}) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection(_kAnswerCollectionGroup)
        .where('answer', isEqualTo: answer)
        .get();
    return _snapshot.size;
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

  /* /// CAUTION!! for test purpose only, remove this in production
  Future<void> populateStatMap() async {
    print('populateStatMap');
    final snapshot = await _collectionRef.get();
    for (final doc in snapshot.docs) {
      final IbQuestion question = IbQuestion.fromJson(doc.data());
      if (question.questionType == IbQuestion.kScale) {
        for (int i = 1; i < 6; i++) {
          final int pollSize = await IbQuestionDbService()
              .querySpecificAnswerPollSize(
                  questionId: question.id, answer: i.toString());
          await _collectionRef.doc(question.id).set({
            'statMap': {i.toString(): pollSize}
          }, SetOptions(merge: true));
        }
      } else {
        for (final choice in question.choices) {
          final int pollSize = await IbQuestionDbService()
              .querySpecificAnswerPollSize(
                  questionId: question.id, answer: choice);
          await _collectionRef.doc(question.id).set({
            'statMap': {choice: pollSize}
          }, SetOptions(merge: true));
        }
      }
    }
  }*/
}
