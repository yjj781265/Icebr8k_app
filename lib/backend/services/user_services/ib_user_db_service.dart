import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../managers/ib_cache_manager.dart';

class IbUserDbService {
  static final _ibUserService = IbUserDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUserCollection = 'IbUsers${DbConfig.dbSuffix}';
  static const _kNotificationSubCollection =
      'IbNotifications${DbConfig.dbSuffix}';
  static const _kFriendSubCollection = 'IbFriends${DbConfig.dbSuffix}';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbUserDbService() => _ibUserService;
  IbUserDbService._() {
    _db.settings = const Settings(persistenceEnabled: false);
    _collectionRef = _db.collection(_kUserCollection);
  }

  Future<void> registerNewUser(IbUser _ibUser) {
    _ibUser.joinTime = FieldValue.serverTimestamp();
    print('IbUserDbService registerNewUser');
    return _collectionRef
        .doc(_ibUser.id)
        .set(_ibUser.toJson(), SetOptions(merge: true));
  }

  Future<String> queryUserNotes(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();
    return snapshot.data()!['note'].toString();
  }

  Future<void> updateIbUser(IbUser _ibUser) {
    print('updateIbUser');
    return _collectionRef
        .doc(_ibUser.id)
        .set(_ibUser.toJson(), SetOptions(merge: true));
  }

  Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _collectionRef
        .where('username', isEqualTo: username.toLowerCase())
        .get();
    print(
        'isUsernameTaken , found  ${snapshot.size} user with username ${username.toLowerCase()}');
    return snapshot.size >= 1;
  }

  Future<void> updateEmoPics(
      {required List<IbEmoPic> emoPics, required String uid}) {
    return _collectionRef.doc(uid).set(
        {'emoPics': emoPics.map((e) => e.toJson()).toList()},
        SetOptions(merge: true));
  }

  Stream<IbUser> listenToIbUserChanges(String uid) {
    return _collectionRef.doc(uid).snapshots().map((event) {
      return IbUser.fromJson(event.data() ?? {});
    });
  }

  Future<IbUser?> queryIbUser(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    final IbUser user = IbUser.fromJson(snapshot.data()!);
    IbCacheManager().cacheIbUser(user);
    return user;
  }

  Future<void> sendFriendRequest(IbNotification n) async {
    //my sub collection
    await _collectionRef
        .doc(n.recipientId)
        .collection(_kNotificationSubCollection)
        .doc(n.id)
        .set(n.toJson(), SetOptions(merge: true));
  }

  Future<bool> isFriendRequestSent(String friendId) async {
    final snapshot = await _collectionRef
        .doc(friendId)
        .collection(_kNotificationSubCollection)
        .where('type', isEqualTo: IbNotification.kFriendRequest)
        .where('senderId', isEqualTo: IbUtils.getCurrentUid())
        .where('recipientId', isEqualTo: friendId)
        .get();
    return snapshot.size > 0;
  }

  Future<IbNotification?> isFriendRequestWaitingForMeForApproval(
      String friendId) async {
    final snapshot = await _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kNotificationSubCollection)
        .where('type', isEqualTo: IbNotification.kFriendRequest)
        .where('senderId', isEqualTo: friendId)
        .where('recipientId', isEqualTo: IbUtils.getCurrentUid())
        .get();
    if (snapshot.size == 0) {
      return null;
    }
    return IbNotification.fromJson(snapshot.docs.first.data());
  }

  Future<void> addFriend(String friendUid) async {
    await _collectionRef.doc(IbUtils.getCurrentUid()).update({
      'friendUids': FieldValue.arrayUnion([friendUid])
    });

    await _collectionRef.doc(friendUid).update({
      'friendUids': FieldValue.arrayUnion([IbUtils.getCurrentUid()])
    });
  }

  Future<void> removeFriend(String friendUid) async {
    await _collectionRef.doc(IbUtils.getCurrentUid()).update({
      'friendUids': FieldValue.arrayRemove([friendUid])
    });
    await _collectionRef.doc(IbUtils.getCurrentUid()).update({
      'blockedFriendUids': FieldValue.arrayRemove([friendUid])
    });

    await _collectionRef.doc(friendUid).update({
      'friendUids': FieldValue.arrayRemove([IbUtils.getCurrentUid()])
    });
    await _collectionRef.doc(friendUid).update({
      'blockedFriendUids': FieldValue.arrayRemove([IbUtils.getCurrentUid()])
    });
  }

  Future<void> blockFriend(String friendUid) async {
    await _collectionRef.doc(IbUtils.getCurrentUid()).update({
      'blockedFriendUids': FieldValue.arrayUnion([friendUid])
    });
  }

  Future<void> unblockFriend(String friendUid) async {
    await _collectionRef.doc(IbUtils.getCurrentUid()).update({
      'blockedFriendUids': FieldValue.arrayRemove([friendUid])
    });
  }

  Future<void> removeNotification(IbNotification n) async {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kNotificationSubCollection)
        .doc(n.id)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToIbNotifications() {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kNotificationSubCollection)
        .orderBy('timestampInMs', descending: true)
        .snapshots();
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final String? userId = IbUtils.getCurrentUid();
    if (userId == null) {
      return;
    }

    await _collectionRef.doc(userId).set({
      'cloudMsgToken': token,
    }, SetOptions(merge: true));
  }

  Future<void> removeTokenFromDatabase() async {
    // Assume user is logged in for this example
    final String? userId = IbUtils.getCurrentUid();
    if (userId == null) {
      return;
    }

    await _collectionRef.doc(userId).set({
      'cloudMsgToken': null,
    }, SetOptions(merge: true));
  }

  Future<String?> retrieveTokenFromDatabase(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }
    return snapshot['cloudMsgToken'] as String?;
  }
}
