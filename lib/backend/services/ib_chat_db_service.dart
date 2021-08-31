import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbChatDbService {
  static final _ibChatDbService = IbChatDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kChatRoomCollection = 'IbChatRooms';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbChatDbService() => _ibChatDbService;

  IbChatDbService._() {
    _db.settings = const Settings(persistenceEnabled: true);
    _collectionRef = _db.collection(_kChatRoomCollection);
  }

  Future<void> updateReadUidArray(
      {required String chatRoomId,
      required String messageId,
      required List<String> uids}) {
    return _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .doc(messageId)
        .set(
            {'readUids': FieldValue.arrayUnion(uids)}, SetOptions(merge: true));
  }

  Future<void> updateInChatUidArray(
      {required String chatRoomId, required List<String> uids}) {
    return _collectionRef.doc(chatRoomId).set(
        {'inChatUids': FieldValue.arrayUnion(uids)}, SetOptions(merge: true));
  }

  Future<void> removeInChatUidArray(
      {required String chatRoomId, required List<String> uids}) {
    return _collectionRef.doc(chatRoomId).set(
        {'inChatUids': FieldValue.arrayRemove(uids)}, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToMessageChanges(
      String chatRoomId) {
    return _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .limitToLast(16)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToChatRoomChanges(
      String uid) {
    return _collectionRef.where('memberUids', arrayContains: uid).snapshots();
  }

  Future<int> queryUnreadCount(
      {required String chatRoomId, required String uid}) async {
    final _snapshot1 = await _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp')
        .where('readUids', arrayContains: uid)
        .limitToLast(1)
        .get();

    if (_snapshot1.size == 0) {
      return 1;
    }

    final _snapshot2 = await _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp')
        .startAfterDocument(_snapshot1.docs.last)
        .get();
    return _snapshot2.size;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> queryMessages(
      {required String chatRoomId,
      required DocumentSnapshot<Map<String, dynamic>> snapshot}) {
    return _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(snapshot)
        .limit(16)
        .get();
  }

  Future<void> uploadMessage(IbMessage ibMessage,
      {List<String>? memberUids}) async {
    if (memberUids != null) {
      await createChatRoom(
          chatRoomId: ibMessage.chatRoomId,
          memberUids: memberUids,
          lastMessage: ibMessage);
    }
    await _collectionRef
        .doc(ibMessage.chatRoomId)
        .collection('Messages')
        .doc(ibMessage.messageId)
        .set(ibMessage.toJson(), SetOptions(merge: true));

    await _collectionRef.doc(ibMessage.chatRoomId).set({
      'lastMessage': ibMessage.toJson(),
    }, SetOptions(merge: true));
  }

  Future<void> createChatRoom(
      {required String chatRoomId,
      required List<String> memberUids,
      required IbMessage lastMessage}) async {
    final _snapshot = await _collectionRef.doc(chatRoomId).get();

    if (_snapshot.exists) {
      print('createChatRoom $chatRoomId existed');
      return;
    }

    memberUids.sort();

    await _collectionRef.doc(chatRoomId).set({
      'memberUids': memberUids,
      'chatRoomId': chatRoomId,
      'createdTimestampInMs': DateTime.now().millisecondsSinceEpoch,
      'lastMessage': lastMessage.toJson(),
    }, SetOptions(merge: true));
    print('createChatRoom new room $chatRoomId');
  }

  Future<void> removeChatRoom(String chatRoomId) {
    return _collectionRef.doc(chatRoomId).delete();
  }

  Future<String> getChatRoomId(List<String> uids) async {
    uids.sort();
    print('getChatRoomId $uids');
    final _snapshot =
        await _collectionRef.where('memberUids', isEqualTo: uids).get();

    if (_snapshot.docs.isEmpty) {
      print(
          'getChatRoomId could not find existed chat room, creating a new one');
      return IbUtils.getUniqueName();
    }

    if (_snapshot.size > 1) {
      throw UnimplementedError('found more than 1 chat room');
    }
    return _snapshot.docs.first.data()['chatRoomId'].toString();
  }
}