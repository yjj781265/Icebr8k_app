import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';

import '../models/ib_user.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> _ibUsersMap = {};
  final Map<String, IbTag> _ibTagMap = {};
  final Map<String, List<IbAnswer>> _ibAnswersMap = {};
  final List<IbQuestion> _ibQuestionList = [];

  factory IbCacheManager() => _manager;

  IbCacheManager._();

  void cacheIbUser(IbUser? user) {
    if (user == null) {
      return;
    }
    _ibUsersMap[user.id] = user;
  }

  IbUser? getIbUser(String uid) {
    return _ibUsersMap[uid];
  }

  void cacheIbTag(IbTag? tag) {
    if (tag == null) {
      return;
    }
    _ibTagMap[tag.text] = tag;
  }

  IbTag? getIbTag(String tagId) {
    return _ibTagMap[tagId];
  }

  void cacheIbAnswers(
      {required String uid, required List<IbAnswer> ibAnswers}) {
    _ibAnswersMap[uid] = ibAnswers;
  }

  void cacheSingleIbAnswer({required String uid, required IbAnswer ibAnswer}) {
    final List<IbAnswer> list = _ibAnswersMap[uid] ?? [];
    final int index = list.indexWhere((element) =>
        element.uid == ibAnswer.uid &&
        element.questionId == ibAnswer.questionId);
    if (index != -1) {
      list[index] = ibAnswer;
    } else {
      list.add(ibAnswer);
    }
    _ibAnswersMap[uid] = list;
  }

  void cacheSingleIbQuestion(IbQuestion ibQuestion) {
    if (_ibQuestionList.contains(ibQuestion)) {
      return;
    }
    _ibQuestionList.add(ibQuestion);
  }

  IbQuestion? getIbQuestion(String questionId) {
    final int index =
        _ibQuestionList.indexWhere((element) => element.id == questionId);
    if (index == -1) {
      return null;
    }

    return _ibQuestionList[index];
  }

  void removeSingleIbAnswer({required String uid, required IbAnswer ibAnswer}) {
    final List<IbAnswer> list = _ibAnswersMap[uid] ?? [];
    final int index = list.indexWhere((element) =>
        element.uid == ibAnswer.uid &&
        element.questionId == ibAnswer.questionId);
    if (index != -1) {
      list.removeAt(index);
    }
    _ibAnswersMap[uid] = list;
  }

  List<IbAnswer>? getIbAnswers(String uid) {
    return _ibAnswersMap[uid];
  }
}
