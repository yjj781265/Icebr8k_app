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
      required List<String> uids}) async {
    await _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .doc(messageId)
        .set(
            {'readUids': FieldValue.arrayUnion(uids)}, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToMessageChanges(
      String chatRoomId) {
    return _collectionRef
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> uploadMessage(IbMessage ibMessage,
      {List<String>? memberUids}) async {
    if (memberUids != null) {
      await createChatRoom(
          chatRoomId: ibMessage.chatRoomId, memberUids: memberUids);
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
      {required String chatRoomId, required List<String> memberUids}) async {
    final _snapshot = await _collectionRef.doc(chatRoomId).get();
    if (_snapshot.exists) {
      print('createChatRoom $chatRoomId existed');
      return;
    }

    memberUids.sort();
    await _collectionRef.doc(chatRoomId).set({
      'memberUids': memberUids,
      'chatRoomId': chatRoomId,
      'createdTimestampInMs': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
    print('createChatRoom new room $chatRoomId');
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
