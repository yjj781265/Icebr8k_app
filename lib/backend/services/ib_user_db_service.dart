import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbUserDbService {
  static final _ibUserService = IbUserDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUserCollection = 'IbUsers';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbUserDbService() => _ibUserService;
  IbUserDbService._() {
    _db.settings = const Settings(persistenceEnabled: true);
    _collectionRef = _db.collection(_kUserCollection);
  }

  Future<void> loginNewIbUser(IbUser _ibUser) {
    print('loginNewIbUser');
    return _collectionRef.doc(_ibUser.id).set(_ibUser.toJson());
  }

  Future<void> loginIbUser({required String uid, required int loginTimeInMs}) {
    print('loginIbUser');
    return _collectionRef.doc(uid).update({'loginTimeInMs': loginTimeInMs});
  }

  Future<void> signOutIbUser(String _uid) {
    print('signOutIbUser');
    return _collectionRef.doc(_uid).update({'isOnline': false});
  }

  Future<bool> isIbUserExist(String _uid) async {
    final snapshot = await _collectionRef.doc(_uid).get();
    final bool isExist = snapshot.exists;
    print('isIbUserExist $isExist');
    return isExist;
  }

  Future<bool> isUsernameTaken(String username) async {
    final snapshot = await _collectionRef
        .where('username', isEqualTo: username.toLowerCase())
        .get();
    print(
        'isUsernameTaken , found  ${snapshot.size} user with username ${username.toLowerCase()}');
    return snapshot.size >= 1;
  }

  Future<bool> isUsernameMissing(String uid) async {
    print(uid);
    final snapshot = await _collectionRef.doc(uid).get();
    print('isUsernameMissing, user with username ${snapshot['username']}');
    return snapshot['username'] == '';
  }

  Future<bool> isAvatarUrlMissing(String? uid) async {
    final snapshot = await _collectionRef.doc(uid).get();
    print('isAvatarUrlMissing, user with avatarUrl ${snapshot['avatarUrl']}');
    return snapshot['avatarUrl'] == '';
  }

  Future<void> updateAvatarUrl({required String url, required String uid}) {
    return _collectionRef.doc(uid).update({'avatarUrl': url});
  }

  /// update username of current IbUser, it will convert to all lower case
  Future<void> updateUsername({required String username, required String uid}) {
    return _collectionRef.doc(uid).update({'username': username.toLowerCase()});
  }

  Future<void> updateName({required String name, required String uid}) {
    return _collectionRef.doc(uid).update({'name': name});
  }

  Future<void> updateCoverPhotoUrl(
      {required String photoUrl, required String uid}) {
    return _collectionRef.doc(uid).update({'coverPhotoUrl': photoUrl});
  }

  Stream<IbUser?> listenToIbUserChanges(String uid) {
    return _collectionRef.doc(uid).snapshots().map((event) {
      if (event.data() == null) {
        return null;
      } else {
        return IbUser.fromJson(event.data()!);
      }
    });
  }

  Future<IbUser?> queryIbUser(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return IbUser.fromJson(snapshot.data()!);
  }

  Future<String?> queryFriendshipStatus(String myUid, String friendUid) async {
    final _snapshot = await _collectionRef
        .doc(myUid)
        .collection('Friends')
        .doc(friendUid)
        .get();
    if (!_snapshot.exists) {
      return null;
    }

    return _snapshot['status'].toString();
  }

  Future<void> sendFriendRequest(
      {required String myUid,
      required String friendUid,
      required String requestMsg}) async {
    final int timestamp = DateTime.now().millisecondsSinceEpoch;

    //my sub collection
    await _collectionRef.doc(myUid).collection('Friends').doc(friendUid).set({
      'friendUid': friendUid,
      'status': IbFriend.kFriendshipStatusRequestSent,
      'requestMsg': requestMsg.trim(),
      'timestampInMs': timestamp
    }, SetOptions(merge: true));

    //my friends sub collection
    await _collectionRef.doc(friendUid).collection('Friends').doc(myUid).set({
      'friendUid': myUid,
      'status': IbFriend.kFriendshipStatusPending,
      'requestMsg': requestMsg.trim(),
      'timestampInMs': timestamp
    }, SetOptions(merge: true));
  }

  Future<IbUser?> queryIbUserFromUsername(String username) async {
    final snapshot = await _collectionRef
        .where('username', isEqualTo: username.trim().toLowerCase())
        .get();
    if (snapshot.docs.isEmpty || snapshot.docs.length != 1) {
      return null;
    }

    return IbUser.fromJson(snapshot.docs.first.data());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToFriendRequest(
      String uid) {
    return _collectionRef
        .doc(uid)
        .collection('Friends')
        .where('status', isEqualTo: IbFriend.kFriendshipStatusPending)
        .orderBy('timestampInMs', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  Future<void> acceptFriendRequest(
      {required String friendUid, required String myUid}) async {
    await _collectionRef.doc(myUid).collection('Friends').doc(friendUid).set({
      'status': IbFriend.kFriendshipStatusAccepted,
      'timestampInMs': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
    await _collectionRef.doc(friendUid).collection('Friends').doc(myUid).set({
      'status': IbFriend.kFriendshipStatusAccepted,
      'timestampInMs': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  Future<void> rejectFriendRequest(
      {required String friendUid, required String myUid}) async {
    await _collectionRef
        .doc(myUid)
        .collection('Friends')
        .doc(friendUid)
        .delete();

    await _collectionRef
        .doc(friendUid)
        .collection('Friends')
        .doc(myUid)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToFriendList(String uid) {
    return _collectionRef
        .doc(uid)
        .collection('Friends')
        .where('status', isEqualTo: IbFriend.kFriendshipStatusAccepted)
        .orderBy('timestampInMs', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToSingleFriend(
      String friendUid) {
    return _collectionRef
        .doc(IbUtils.getCurrentUid()!)
        .collection('Friends')
        .doc(friendUid)
        .snapshots(includeMetadataChanges: true);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryFriendList(String uid) {
    return _collectionRef
        .doc(uid)
        .collection('Friends')
        .where('status', isEqualTo: IbFriend.kFriendshipStatusAccepted)
        .orderBy('timestampInMs', descending: true)
        .get();
  }
}
