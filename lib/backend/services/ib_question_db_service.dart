import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_question.dart';

class IbQuestionDbService {
  static final _ibQuestionDbService = IbQuestionDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kQuestionCollection = 'IbQuestions';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbQuestionDbService() => _ibQuestionDbService;

  IbQuestionDbService._() {
    _collectionRef = _db.collection(_kQuestionCollection);
  }

  Future<void> uploadQuestion(IbQuestion question) {
    print('uploadQuestion $question');
    return _collectionRef
        .doc(question.id)
        .set(question.toJson(), SetOptions(merge: true));
  }

  Future<List<IbQuestion>> queryQuestions(
      {required String creatorId, required int limit}) async {
    final List<IbQuestion> _list = [];
    final _snapshot = await _collectionRef
        .where('creatorId', isEqualTo: creatorId)
        .limit(limit)
        .get();

    for (final element in _snapshot.docs) {
      _list.add(IbQuestion.fromJson(element.data()));
    }
    print("question list size ${_list.length}");
    return _list;
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
    });
  }
}
