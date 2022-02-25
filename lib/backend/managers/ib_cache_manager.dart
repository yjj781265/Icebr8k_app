import 'package:icebr8k/backend/models/ib_answer.dart';

import '../models/ib_user.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> ibUsersMap = {};
  final Map<String, IbAnswer> ibAnswerMap = {};

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

  void cacheIbAnswer(IbAnswer? ibAnswer) {
    if (ibAnswer == null) {
      return;
    }
    ibAnswerMap[ibAnswer.uid] = ibAnswer;
  }

  IbAnswer? getIbAnswer(String uid) {
    return ibAnswerMap[uid];
  }
}
