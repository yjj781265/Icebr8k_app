import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../db_config.dart';

class IbChatDbService {
  static final _ibChatDbService = IbChatDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kChatRoomCollection = 'IbChats${DbConfig.dbSuffix}';
  static const _kMessageSubCollection = 'IbMessages${DbConfig.dbSuffix}';
  static const _kMemberSubCollection = 'IbMembers${DbConfig.dbSuffix}';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbChatDbService() => _ibChatDbService;

  IbChatDbService._() {
    _db.settings = const Settings(persistenceEnabled: false);
    _collectionRef = _db.collection(_kChatRoomCollection);
  }

  Future<void> updateReadUidArray(
      {required String chatRoomId,
      required String messageId,
      required List<String> uids}) {
    return _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
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

  /// stream of ibMessage in ascending order
  Stream<QuerySnapshot<Map<String, dynamic>>> listenToMessageChanges(
      String chatRoomId) {
    return _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
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
        .collection(_kMessageSubCollection)
        .orderBy('timestamp')
        .where('readUids', arrayContains: uid)
        .limitToLast(1)
        .get();

    // todo add cloud function
    if (_snapshot1.size == 0) {
      final snapshot =
          await _collectionRef.doc(chatRoomId).collection('Messages').get();
      return snapshot.size;
    }

    final _snapshot2 = await _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
        .orderBy('timestamp')
        .startAfterDocument(_snapshot1.docs.last)
        .get();
    return _snapshot2.size;
  }

  ///query message in descending order
  Future<QuerySnapshot<Map<String, dynamic>>> queryMessages(
      {required String chatRoomId,
      required DocumentSnapshot<Map<String, dynamic>> snapshot,
      int limit = 16}) {
    return _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(snapshot)
        .limit(limit)
        .get();
  }

  Future<void> uploadMessage(IbMessage ibMessage) async {
    ibMessage.timestamp = FieldValue.serverTimestamp();
    await _collectionRef
        .doc(ibMessage.chatRoomId)
        .collection(_kMessageSubCollection)
        .doc(ibMessage.messageId)
        .set(ibMessage.toJson(), SetOptions(merge: true));
  }

  Future<void> addMember(
      {required String chatId, required IbChatMember member}) async {
    return _collectionRef
        .doc(chatId)
        .collection(_kMemberSubCollection)
        .doc(member.uid)
        .set(member.toJson(), SetOptions(merge: true));
  }

  Future<void> addIbChat(IbChat ibChat) async {
    ibChat.createdAtTimestamp = FieldValue.serverTimestamp();
    await _collectionRef
        .doc(ibChat.chatId)
        .set(ibChat.toJson(), SetOptions(merge: true));
  }

  // todo call cloud function for this
  Future<void> removeChatRoom(String chatRoomId) async {
    await _collectionRef.doc(chatRoomId).delete();
  }

  Future<IbChat?> queryOneToOneIbChat(String uid) async {
    final List<String> uids = [IbUtils.getCurrentUid()!, uid];
    uids.sort();
    print(uids);
    final snapshot = await _collectionRef
        .where('memberUids', isEqualTo: uids)
        .where('memberCount', isEqualTo: 2)
        .get();
    if (snapshot.size == 0) {
      return null;
    }

    return IbChat.fromJson(snapshot.docs.first.data());
  }
}
