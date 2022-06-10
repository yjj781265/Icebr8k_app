import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';

import '../../models/ib_chat_models/ib_message.dart';

class IbAdminDbService {
  static final _ibAdminDbService = IbAdminDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUsersCollection = 'IbUsers${DbConfig.dbSuffix}';
  static const _kFeedbackCollection = 'Feedbacks${DbConfig.dbSuffix}';
  static const _kIcebreakerCollection = 'Icebreakers';

  factory IbAdminDbService() => _ibAdminDbService;

  IbAdminDbService._();

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToPendingApplications() {
    return _db
        .collection(_kUsersCollection)
        .where('status', isEqualTo: IbUser.kUserStatusPending)
        .orderBy('joinTime')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToIcebreakerCollection() {
    return _db
        .collection(_kIcebreakerCollection)
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> addIcebreakerCollection(IbCollection ibCollection) async {
    return _db
        .collection(_kIcebreakerCollection)
        .doc(ibCollection.id)
        .set(ibCollection.toJson(), SetOptions(merge: true));
  }

  Future<void> removeIcebreakerCollection(IbCollection ibCollection) async {
    return _db.collection(_kIcebreakerCollection).doc(ibCollection.id).delete();
  }

  Future<void> updateUserStatus(
      {required String status, required String uid, String note = ''}) async {
    if (status == IbUser.kUserStatusRejected) {
      _db
          .collection(_kUsersCollection)
          .doc(uid)
          .update({'status': status, 'note': note, 'username': ''});
    } else {
      _db
          .collection(_kUsersCollection)
          .doc(uid)
          .update({'status': status, 'note': note});
    }
  }

  Future<void> deleteAllEmoPics(IbUser user) async {
    for (final IbEmoPic emoPic in user.emoPics) {
      await IbStorageService().deleteFile(emoPic.url);
    }
    await _db
        .collection(_kUsersCollection)
        .doc(user.id)
        .update({'emoPics': <IbEmoPic>[]});
  }

  Future<void> deleteAvatarUrl(IbUser user) async {
    await IbStorageService().deleteFile(user.avatarUrl);
  }

  Future<void> addFeedback(IbMessage message) async {
    message.timestamp = Timestamp.now();
    await _db.collection(_kFeedbackCollection).doc(message.chatRoomId).set({
      'feedbacks': FieldValue.arrayUnion([message.toJson()])
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToSingleFeedbacks(
      String chatId) {
    return _db.collection(_kFeedbackCollection).doc(chatId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToAllFeedbacks() {
    return _db.collection(_kFeedbackCollection).snapshots();
  }

  Future<void> sendStatusEmail(
      {required String email,
      required String fName,
      required String status,
      String note = ""}) async {
    final Map<String, dynamic> payload = {
      'fName': fName,
      'status': status,
      'email': email,
      'note': note,
    };
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendStatusEmail');
    await callable.call(payload);
  }
}
