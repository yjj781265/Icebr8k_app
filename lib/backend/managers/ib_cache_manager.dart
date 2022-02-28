import 'package:icebr8k/backend/models/ib_answer.dart';

import '../models/ib_user.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> ibUsersMap = {};
  final Map<String, List<IbAnswer>> ibAnswersMap = {};

  factory IbCacheManager() => _manager;

  IbCacheManager._();

  void cacheIbUser(IbUser? user) {
    if (user == null) {
      return;
    }
    ibUsersMap[user.id] = user;
  }

  IbUser? getIbUser(String uid) {
    return ibUsersMap[uid];
  }

  void cacheIbAnswers(
      {required String uid, required List<IbAnswer> ibAnswers}) {
    ibAnswersMap[uid] = ibAnswers;
  }

  List<IbAnswer> getIbAnswers(String uid) {
    return ibAnswersMap[uid] ?? [];
  }
}
