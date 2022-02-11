import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../managers/ib_cache_manager.dart';
import 'ib_question_db_service.dart';

class IbUserDbService {
  static final _ibUserService = IbUserDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUserCollection = 'IbUsers${DbConfig.dbSuffix}';
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

  Future<void> loginIbUser({required String uid, required int loginTimeInMs}) {
    print('loginIbUser');
    return _collectionRef
        .doc(uid)
        .update({'loginTimeInMs': loginTimeInMs, 'id': uid});
  }

  Future<String?> queryIbUserStatus(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }
    try {
      return snapshot['status'].toString();
    } on Exception catch (e) {
      return null;
    }
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
    return !snapshot.exists ||
        snapshot.data()!['username'] == null ||
        snapshot['username'] == '';
  }

  Future<bool> isAvatarUrlMissing(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();
    return !snapshot.exists ||
        snapshot.data()!['avatarUrl'] == null ||
        snapshot['avatarUrl'] == '';
  }

  Future<List<IbQuestion>> queryUnAnsweredFirst8Q(String uid) async {
    List<String> questionIds = [];
    final _controller = Get.find<MyAnsweredQuestionsController>();
    final List<IbQuestion> questions =
        await IbQuestionDbService().queryIcebr8kQ();
    if (_controller.isLoaded.isTrue && _controller.ibAnswers.isNotEmpty) {
      for (final IbAnswer ibAnswer in _controller.ibAnswers) {
        questionIds.add(ibAnswer.questionId);
      }
    } else {
      questionIds = await IbQuestionDbService().queryAnsweredQuestionIds(uid);
    }

    questions.removeWhere((element) => questionIds.contains(element.id));
    return questions;
  }

  Future<void> updateAvatarUrl({required String url, required String uid}) {
    return _collectionRef.doc(uid).update({'avatarUrl': url});
  }

  /// update username of current IbUser, it will convert to all lower case
  Future<void> updateUsername({required String username, required String uid}) {
    return _collectionRef.doc(uid).set(
        {'username': username.trim().toLowerCase()}, SetOptions(merge: true));
  }

  Future<void> updateName({required String name, required String uid}) {
    return _collectionRef
        .doc(uid)
        .set({'name': name.trim()}, SetOptions(merge: true));
  }

  Future<void> updateCoverPhotoUrl(
      {required String photoUrl, required String uid}) {
    return _collectionRef
        .doc(uid)
        .set({'coverPhotoUrl': photoUrl}, SetOptions(merge: true));
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

    final IbUser user = IbUser.fromJson(snapshot.data()!);
    IbCacheManager().cacheIbUser(user);
    return user;
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

  Future<int> queryIbUserAnsweredSize(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();

    if (!snapshot.exists || snapshot.data()!['answeredSize'] == null) {
      print('queryIbUserAnsweredSize legacy method');
      final list = await IbQuestionDbService().queryAnsweredQuestionIds(uid);
      return list.length;
    }
    print('queryIbUserAnsweredSize new method');
    return snapshot.data()!['answeredSize'] as int;
  }

  Future<int> queryIbUserAskedSize(String uid) async {
    final snapshot = await _collectionRef.doc(uid).get();

    if (!snapshot.exists || snapshot.data()!['askedSize'] == null) {
      print('queryIbUserAskedSize legacy method');
      final snapshot =
          await IbQuestionDbService().queryAskedQuestions(uid: uid);
      return snapshot.size;
    }
    print('queryIbUserAskedSize new method');
    return snapshot.data()!['askedSize'] as int;
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
        .doc(IbUtils.getCurrentUid())
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
