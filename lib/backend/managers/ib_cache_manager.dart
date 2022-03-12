import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';

import '../models/ib_user.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> _ibUsersMap = {};
  final Map<String, IbTag> _ibTagMap = {};
  final Map<String, List<IbAnswer>> _ibAnswersMap = {};

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
    _ibTagMap[tag.id] = tag;
  }

  IbTag? getIbTag(String tagId) {
    return _ibTagMap[tagId];
  }

  void cacheIbAnswers(
      {required String uid, required List<IbAnswer> ibAnswers}) {
    _ibAnswersMap[uid] = ibAnswers;
  }

  List<IbAnswer>? getIbAnswers(String uid) {
    return _ibAnswersMap[uid];
  }
}
