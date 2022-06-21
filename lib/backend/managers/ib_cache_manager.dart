import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';

import '../models/ib_user.dart';
import '../models/icebreaker_models/ib_collection.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> _ibUsersMap = {};
  final Map<String, IbTag> _ibTagMap = {};
  final Map<String, List<IbAnswer>> _ibAnswersMap = {};
  final List<IbQuestion> _ibQuestionList = [];
  final List<IbCollection> _ibCollectionList = [];

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

  /// this will cache the answer to the list in ibAnswersMap base on the uid
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

  void cacheIbCollection(IbCollection ibCollection) {
    if (_ibCollectionList.contains(ibCollection)) {
      return;
    }
    _ibCollectionList.add(ibCollection);
  }

  IbCollection? retrieveIbCollection(String collectionId) {
    final index =
        _ibCollectionList.indexWhere((element) => element.id == collectionId);

    if (index != -1) {
      return _ibCollectionList[index];
    }

    return null;
  }

  Icebreaker? retrieveIcebreaker({required String icebreakerId}) {
    for (final ibCollection in _ibCollectionList) {
      final index = ibCollection.icebreakers
          .indexWhere((element) => element.id == icebreakerId);
      if (index != -1) {
        return ibCollection.icebreakers[index];
      }
    }
    return null;
  }

  IbQuestion? getIbQuestion(String questionId) {
    final int index =
        _ibQuestionList.indexWhere((element) => element.id == questionId);
    if (index == -1) {
      return null;
    }

    return _ibQuestionList[index];
  }

  /// this will remove the answer to the list in ibAnswersMap base on the uid
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
