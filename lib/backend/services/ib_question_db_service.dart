import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';

class IbQuestionDbService {
  static final _ibQuestionDbService = IbQuestionDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kQuestionCollection = 'IbQuestions';
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
    final snapshot = await _collectionRef.doc(questionId).get();
    if (!snapshot.exists) {
      return null;
    }
    return IbQuestion.fromJson(snapshot.data()!);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryUserAnsweredQuestions({
    required int limit,
    required String uid,
    DocumentSnapshot? lastDoc,
  }) {
    if (lastDoc == null) {
      return _db
          .collectionGroup('Answers')
          .where('uid', isEqualTo: uid)
          .orderBy('timeStampInMs', descending: true)
          .limit(limit)
          .get();
    }
    return _db
        .collectionGroup('Answers')
        .where('uid', isEqualTo: uid)
        .startAfterDocument(lastDoc)
        .orderBy('timeStampInMs', descending: true)
        .limit(limit)
        .get();
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
    final _snapshot =
        await _db.collectionGroup('Answers').where('uid', isEqualTo: uid).get();

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
          .collectionGroup('Answers')
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .limit(limit)
          .startAfterDocument(lastDoc);
    } else {
      query = _db
          .collectionGroup('Answers')
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .limit(limit);
    }
    return query.get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAnsweredQuestionsChange(
      String uid,
      {DocumentSnapshot? lastDoc}) {
    late Query<Map<String, dynamic>> query;
    if (lastDoc == null) {
      query = _db
          .collectionGroup('Answers')
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true);
    } else {
      query = _db
          .collectionGroup('Answers')
          .where('uid', isEqualTo: uid)
          .orderBy('answeredTimeInMs', descending: true)
          .startAfterDocument(lastDoc);
    }

    return query.snapshots();
  }

  Future<IbAnswer?> queryLatestAnsweredQ(String uid) async {
    final _snapshot = await _db
        .collectionGroup('Answers')
        .limit(1)
        .where('uid', isEqualTo: uid)
        .orderBy('askedTimeInMs', descending: true)
        .get();
    if (_snapshot.docs.isEmpty) {
      return null;
    }

    return IbAnswer.fromJson(_snapshot.docs.first.data());
  }

  Future<IbAnswer?> queryLastAnsweredQ(String uid) async {
    final _snapshot = await _db
        .collectionGroup('Answers')
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
      snapshot =
          await _collectionRef.orderBy('askedTimeInMs', descending: true).get();
    } else if (isGreaterThan) {
      snapshot = await _collectionRef
          .where('askedTimeInMs', isGreaterThan: timestamp)
          .orderBy('askedTimeInMs', descending: true)
          .get();
    } else {
      snapshot = await _collectionRef
          .where('askedTimeInMs', isLessThan: timestamp)
          .orderBy('askedTimeInMs', descending: true)
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
    final _snapshot =
        await _db.collectionGroup('Answers').where('uid', isEqualTo: uid).get();
    for (final doc in _snapshot.docs) {
      answers.add(IbAnswer.fromJson(doc.data()));
    }
    return answers;
  }

  Future<IbAnswer?> queryIbAnswer(String uid, String questionId) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection('Answers')
        .doc(uid)
        .get();
    if (!_snapshot.exists) {
      return null;
    }

    return IbAnswer.fromJson(_snapshot.data()!);
  }

  Future<void> answerQuestion(IbAnswer ibAnswer) async {
    // todo add counter in parent collection show total answers count with cloud function
    await _collectionRef
        .doc(ibAnswer.questionId)
        .collection('Answers')
        .doc(ibAnswer.uid)
        .set(ibAnswer.toJson(), SetOptions(merge: true));
  }

  Future<int> queryPollSize(String questionId) async {
    // todo switch to use cloud function add counter doc
    final _snapshot =
        await _collectionRef.doc(questionId).collection('Answers').get();
    return _snapshot.size;
  }

  Future<int> querySpecificAnswerPollSize(
      {required String questionId, required String answer}) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection('Answers')
        .where('answer', isEqualTo: answer)
        .get();
    return _snapshot.size;
  }

  Future<bool> isQuestionAnswered(
      {required String uid, required String questionId}) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection('Answers')
        .doc(uid)
        .get();
    return _snapshot.exists;
  }

  Future<void> eraseAllAnsweredQuestions(String uid) async {
    print('eraseAllAnsweredQuestions');
    final _snapshot =
        await _db.collectionGroup('Answers').where('uid', isEqualTo: uid).get();
    for (final doc in _snapshot.docs) {
      final questionId = doc.data()['questionId'].toString();
      await _collectionRef
          .doc(questionId)
          .collection('Answers')
          .doc(uid)
          .delete();
    }
  }
}
