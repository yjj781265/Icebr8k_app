import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_settings.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../../frontend/ib_config.dart';
import '../../managers/ib_cache_manager.dart';

class IbUserDbService {
  static final _ibUserService = IbUserDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUserCollection = 'IbUsers${DbConfig.dbSuffix}';
  static const _kProfileLikesSubCollection =
      'IbProfileLikes${DbConfig.dbSuffix}';
  static const _kNotificationSubCollection =
      'IbNotifications${DbConfig.dbSuffix}';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbUserDbService() => _ibUserService;
  IbUserDbService._() {
    _db.settings = const Settings(persistenceEnabled: false);
    _collectionRef = _db.collection(_kUserCollection);
  }

  Future<void> registerNewUser(IbUser _ibUser) {
    _ibUser.joinTime = FieldValue.serverTimestamp();
    _ibUser.settings = IbSettings();
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

  Future<void> updateCurrentIbUserPremium(bool isActive) {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .update({'isPremium': isActive});
  }

  Future<void> updateIbUserNotificationCount(int count) async {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .update({'notificationCount': count});
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

  Future<void> followTag({required String tag}) {
    return _collectionRef.doc(IbUtils.getCurrentUid()).set({
      'tags': FieldValue.arrayUnion([tag])
    }, SetOptions(merge: true));
  }

  Future<void> unfollowTag({required String tag}) {
    return _collectionRef.doc(IbUtils.getCurrentUid()).set({
      'tags': FieldValue.arrayRemove([tag])
    }, SetOptions(merge: true));
  }

  Stream<IbUser> listenToIbUserChanges(String uid) {
    return _collectionRef.doc(uid).snapshots().map((event) {
      return IbUser.fromJson(event.data() ?? {});
    });
  }

  /// returned IbUser result will cached locally via IbCacheManager
  Future<IbUser?> queryIbUser(String uid) async {
    try {
      final snapshot = await _collectionRef.doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final IbUser user = IbUser.fromJson(snapshot.data()!);
      IbCacheManager().cacheIbUser(user);
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// send an alert message in the app, will appear under Alert tab
  Future<void> sendAlertNotification(IbNotification n) async {
    //my sub collection
    await _collectionRef
        .doc(n.recipientId)
        .collection(_kNotificationSubCollection)
        .doc(n.id)
        .set(n.toJson(), SetOptions(merge: true));
  }

  Future<IbNotification?> querySentFriendRequest(String friendId) async {
    final snapshot = await _collectionRef
        .doc(friendId)
        .collection(_kNotificationSubCollection)
        .where('type', isEqualTo: IbNotification.kFriendRequest)
        .where('senderId', isEqualTo: IbUtils.getCurrentUid())
        .where('recipientId', isEqualTo: friendId)
        .get();
    if (snapshot.size == 0) {
      return null;
    }
    return IbNotification.fromJson(snapshot.docs.first.data());
  }

  Future<bool> isCircleInviteSent(
      {required String chatId, required String recipientId}) async {
    final snapshot = await _collectionRef
        .doc(recipientId)
        .collection(_kNotificationSubCollection)
        .where('type', isEqualTo: IbNotification.kCircleInvite)
        .where('url', isEqualTo: chatId)
        .get();
    return snapshot.size > 0;
  }

  Future<List<IbNotification>> isCircleRequestSent(
      {required String chatId}) async {
    final list = <IbNotification>[];
    final snapshot = await _db
        .collectionGroup(_kNotificationSubCollection)
        .where('type', isEqualTo: IbNotification.kCircleRequest)
        .where('senderId', isEqualTo: IbUtils.getCurrentUid())
        .where('url', isEqualTo: chatId)
        .get();
    for (final doc in snapshot.docs) {
      list.add(IbNotification.fromJson(doc.data()));
    }

    return list;
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
        .doc(n.recipientId)
        .collection(_kNotificationSubCollection)
        .doc(n.id)
        .delete();
  }

  /// this will only listen to last 64 notifications
  Stream<QuerySnapshot<Map<String, dynamic>>> listenToNewIbNotifications() {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kNotificationSubCollection)
        .where('recipientId', isEqualTo: IbUtils.getCurrentUid())
        .orderBy('timestamp', descending: true)
        .limit(64)
        .snapshots();
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    final String? userId = IbUtils.getCurrentUid();
    if (userId == null) {
      return;
    }

    await _collectionRef.doc(userId).update(
        {'fcmToken': token, 'fcmTokenTimestamp': FieldValue.serverTimestamp()});
  }

  Future<void> removeTokenFromDatabase() async {
    // Assume user is logged in for this example
    final String? userId = IbUtils.getCurrentUid();
    if (userId == null) {
      return;
    }
    final snapshot = await _collectionRef.doc(userId).get();
    if (!snapshot.exists) {
      return;
    }

    await _collectionRef.doc(userId).update(
      {
        'fcmToken': '',
      },
    );
  }

  Future<String> retrieveTokenFromDatabase(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();

    if (!snapshot.exists) {
      return '';
    }
    return snapshot['fcmToken'] as String;
  }

  Future<void> updateCurrentUserPosition(GeoPoint geoPoint) async {
    if (IbUtils.getCurrentUid() != null) {
      await _collectionRef.doc(IbUtils.getCurrentUid()).update({
        'geoPoint': geoPoint,
        'lastLocationTimestampInMs': Timestamp.now().millisecondsSinceEpoch
      });
    }
  }

  static const String userNameFieldName = "username";
  Future<String?> queryUserIdFromUserName(String userName) async {
    final snapshot = await _collectionRef
        .where(userNameFieldName, isEqualTo: userName)
        .get();
    if (snapshot.size == 0) {
      return null;
    }
    return snapshot.docs.first.data()["id"] as String;
  }

  static const String intentionIndex = "intentions";
  Future<void> updateUserIntention(List<String> intentions) async {
    return _collectionRef
        .doc(IbUtils.getCurrentUid())
        .update({intentionIndex: intentions});
  }

  Future<void> clearLocation() async {
    return _collectionRef.doc(IbUtils.getCurrentUid()).update(
        {'geoPoint': const GeoPoint(0, 0), 'lastLocationTimestampInMs': -1});
  }

  Future<void> likeProfile(String userId) async {
    if (userId == IbUtils.getCurrentUid()) {
      return;
    }

    await _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kProfileLikesSubCollection)
        .doc(userId)
        .set({
      'isLiked': true,
      'likerId': IbUtils.getCurrentUid(),
      'likeId': userId,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  /// return -1 if timestamp is null or not found
  Future<int> lastLikedTimestampInMs(String userId) async {
    if (userId == IbUtils.getCurrentUid()) {
      return -1;
    }
    try {
      final snapshot = await _collectionRef
          .doc(IbUtils.getCurrentUid())
          .collection(_kProfileLikesSubCollection)
          .doc(userId)
          .get();
      if (snapshot.data() == null || !snapshot.exists) {
        return -1;
      }
      return (snapshot.data()!['timestamp'] as Timestamp)
          .millisecondsSinceEpoch;
    } catch (e) {
      print('lastLikedTimestampInMs: $e');
      return -1;
    }
  }

  Future<void> dislikeProfile(String userId) async {
    if (userId == IbUtils.getCurrentUid()) {
      return;
    }

    await _collectionRef
        .doc(IbUtils.getCurrentUid())
        .collection(_kProfileLikesSubCollection)
        .doc(userId)
        .set({
      'isLiked': false,
      'likerId': IbUtils.getCurrentUid(),
      'likeId': userId,
      'timestamp': FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  Future<bool> isProfileLiked(
      {required String user1Id, required String user2Id}) async {
    try {
      final snapshot = await _collectionRef
          .doc(user1Id)
          .collection(_kProfileLikesSubCollection)
          .doc(user2Id)
          .get();

      if (snapshot.data() == null || !snapshot.exists) {
        return false;
      }

      return snapshot.data()!['isLiked'] as bool;
    } catch (e) {
      print('isProfileLiked $e');
      return false;
    }
  }

  Future<bool> isProfileLikedNotificationSent(
      {required String recipientId}) async {
    try {
      final snapshot = await _collectionRef
          .doc(recipientId)
          .collection(_kNotificationSubCollection)
          .where('type', isEqualTo: IbNotification.kProfileLiked)
          .where('senderId', isEqualTo: IbUtils.getCurrentUid())
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('isProfileLikedNotificationSent $e');
      return false;
    }
  }

  Future<bool> isProfileBingo(
      {required String user1Id, required String user2Id}) async {
    try {
      final user1Liked =
          await isProfileLiked(user1Id: user1Id, user2Id: user2Id);
      final user2Liked =
          await isProfileLiked(user1Id: user2Id, user2Id: user1Id);
      return user2Liked && user1Liked;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryProfileLikedUsers(
      {DocumentSnapshot? lastDoc}) async {
    return _db
        .collectionGroup(_kProfileLikesSubCollection)
        .where('likeId', isEqualTo: IbUtils.getCurrentUid())
        .where('isLiked', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(IbConfig.kPerPage)
        .get();
  }
}
