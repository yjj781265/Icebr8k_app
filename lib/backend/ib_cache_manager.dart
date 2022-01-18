import 'models/ib_user.dart';

class IbCacheManager {
  static final IbCacheManager _manager = IbCacheManager._();
  final Map<String, IbUser> ibUsersMap = {};

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
}
