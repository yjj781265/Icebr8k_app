import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
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
      {required String chatRoomId, required String messageId}) {
    return _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
        .doc(messageId)
        .set({
      'readUids': FieldValue.arrayUnion([IbUtils.getCurrentUid()])
    }, SetOptions(merge: true));
  }

  Future<void> addTypingUid({required String chatId}) async {
    return _collectionRef.doc(chatId).update({
      'isTypingUids': FieldValue.arrayUnion([IbUtils.getCurrentUid()])
    });
  }

  Future<void> removeTypingUid({required String chatId}) async {
    return _collectionRef.doc(chatId).update({
      'isTypingUids': FieldValue.arrayRemove([IbUtils.getCurrentUid()])
    });
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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToIbMemberChanges(
      String chatId) {
    return _collectionRef
        .doc(chatId)
        .collection(_kMemberSubCollection)
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToIbChatChanges(
      String chatId) {
    return _collectionRef.doc(chatId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToOneToOneChat() {
    return _collectionRef
        .where('memberCount', isEqualTo: 2)
        .where('isCircle', isEqualTo: false)
        .where('messageCount', isGreaterThan: 0)
        .where('memberUids', arrayContains: IbUtils.getCurrentUid())
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToCircles() {
    return _collectionRef
        .where('isCircle', isEqualTo: true)
        .where('memberUids', arrayContains: IbUtils.getCurrentUid())
        .snapshots();
  }

  Future<int> queryUnreadCount({required IbChat ibChat}) async {
    final _snapshot1 = await _collectionRef
        .doc(ibChat.chatId)
        .collection(_kMessageSubCollection)
        .orderBy('timestamp')
        .where('readUids', arrayContains: IbUtils.getCurrentUid())
        .limitToLast(1)
        .get();

    if (_snapshot1.size == 0) {
      return ibChat.messageCount;
    }

    final _snapshot2 = await _collectionRef
        .doc(ibChat.chatId)
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

  Future<void> addChatMember({required IbChatMember member}) async {
    member.joinTimestamp = FieldValue.serverTimestamp();
    return _collectionRef
        .doc(member.chatId)
        .collection(_kMemberSubCollection)
        .doc(member.uid)
        .set(member.toJson(), SetOptions(merge: true));
  }

  Future<void> updateChatMember({required IbChatMember member}) async {
    return _collectionRef
        .doc(member.chatId)
        .collection(_kMemberSubCollection)
        .doc(member.uid)
        .set(member.toJson(), SetOptions(merge: true));
  }

  Future<void> removeChatMember({required IbChatMember member}) async {
    return _collectionRef
        .doc(member.chatId)
        .collection(_kMemberSubCollection)
        .doc(member.uid)
        .delete();
  }

  Future<void> addIbChat(IbChat ibChat, {bool isEdit = false}) async {
    if (!isEdit) {
      ibChat.createdAtTimestamp = FieldValue.serverTimestamp();
    }

    await _collectionRef
        .doc(ibChat.chatId)
        .set(ibChat.toJson(), SetOptions(merge: true));
  }

  Future<void> muteNotification(IbChat ibChat) async {
    ibChat.createdAtTimestamp = FieldValue.serverTimestamp();
    await _collectionRef.doc(ibChat.chatId).update({
      'mutedUids': FieldValue.arrayUnion([IbUtils.getCurrentUid()])
    });
  }

  Future<void> unMuteNotification(IbChat ibChat) async {
    ibChat.createdAtTimestamp = FieldValue.serverTimestamp();
    await _collectionRef.doc(ibChat.chatId).update({
      'mutedUids': FieldValue.arrayRemove([IbUtils.getCurrentUid()])
    });
  }

  /// will delete chat doc and its sub collections and medias
  Future<void> leaveChatRoom(String chatRoomId) async {
    await _collectionRef.doc(chatRoomId).delete();
    final messageSnapShot = await _collectionRef
        .doc(chatRoomId)
        .collection(_kMessageSubCollection)
        .get();
    for (final doc in messageSnapShot.docs) {
      final message = IbMessage.fromJson(doc.data());
      try {
        if (message.messageType == IbMessage.kMessageTypePic &&
            message.content.contains('http')) {
          IbStorageService().deleteFile(message.content);
        }
      } catch (e) {
        print(e);
        continue;
      }
      _collectionRef
          .doc(chatRoomId)
          .collection(_kMessageSubCollection)
          .doc(doc.id)
          .delete();
    }

    final memberSnapShot = await _collectionRef
        .doc(chatRoomId)
        .collection(_kMemberSubCollection)
        .get();
    for (final doc in memberSnapShot.docs) {
      try {
        _collectionRef
            .doc(chatRoomId)
            .collection(_kMemberSubCollection)
            .doc(doc.id)
            .delete();
      } catch (e) {
        print(e);
        continue;
      }
    }
  }

  Future<IbChat?> queryOneToOneIbChat(String uid) async {
    final List<String> uids = [IbUtils.getCurrentUid()!, uid];
    uids.sort();
    final snapshot = await _collectionRef
        .where('isCircle', isEqualTo: false)
        .where('memberUids', isEqualTo: uids)
        .where('memberCount', isEqualTo: 2)
        .get();
    if (snapshot.size == 0) {
      return null;
    }

    return IbChat.fromJson(snapshot.docs.first.data());
  }

  Future<IbChat?> queryChat(String chatId) async {
    final snapshot = await _collectionRef.doc(chatId).get();
    if (!snapshot.exists) {
      return null;
    }

    return IbChat.fromJson(snapshot.data()!);
  }
}
