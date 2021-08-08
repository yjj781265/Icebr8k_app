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

  Future<void> uploadQuestion(IbQuestion question) {
    print('uploadQuestion $question');
    return _collectionRef
        .doc(question.id)
        .set(question.toJson(), SetOptions(merge: true));
  }

  Future<IbQuestion?> queryQuestion(String questionId) async {
    final snapshot = await _collectionRef.doc(questionId).get();
    if (snapshot.exists && snapshot.data() != null) {
      return IbQuestion.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryQuestions({
    required int limit,
    DocumentSnapshot? lastDoc,
  }) {
    if (lastDoc == null) {
      return _collectionRef.orderBy('createdTimeInMs').limit(limit).get();
    }
    return _collectionRef
        .orderBy('createdTimeInMs')
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
  }

  Future<int> queryTotalQuestionSize() async {
    final _snapshot = await _collectionRef.get();
    return _snapshot.size;
  }

  Future<List<String>> queryAnsweredQuestions(String uid) async {
    final List<String> _list = [];
    final _snapshot =
        await _db.collectionGroup('Answers').where('uid', isEqualTo: uid).get();

    for (final element in _snapshot.docs) {
      _list.add(element['questionId'].toString());
    }
    print("answered question list size ${_list.length}");
    return _list;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAnsweredQuestionsChange(
      String uid) {
    final _snapshots =
        _db.collectionGroup('Answers').where('uid', isEqualTo: uid).snapshots();
    return _snapshots;
  }

  Future<List<IbAnswer>> queryUserAnswers(String uid) async {
    final List<IbAnswer> answers = [];
    final _snapshot =
        await _db.collectionGroup('Answers').where('uid', isEqualTo: uid).get();
    for (final doc in _snapshot.docs) {
      answers.add(IbAnswer.fromJson(doc.data()));
    }
    print("answers list size ${answers.length}");
    return answers;
  }

  Future<String?> queryAnswer(String uid, String questionId) async {
    final _snapshot = await _collectionRef
        .doc(questionId)
        .collection('Answers')
        .doc(uid)
        .get();
    if (!_snapshot.exists) {
      return null;
    }

    return _snapshot['answer'].toString();
  }

  Future<void> answerQuestion(
      {required String answer,
      required String questionId,
      required String uid}) {
    return _collectionRef.doc(questionId).collection('Answers').doc(uid).set({
      'uid': uid,
      'questionId': questionId,
      'answer': answer,
      'timeStampInMs': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  Future<int> queryPollSize(String questionId) async {
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
