import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../db_config.dart';

class IbTagDbService {
  static final _ibTagDbService = IbTagDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kTagCollection = 'IbTags${DbConfig.dbSuffix}';

  factory IbTagDbService() => _ibTagDbService;

  IbTagDbService._();

  Future<String> uploadTagAndReturnId(String text) async {
    final snapshot = await _db
        .collection(_kTagCollection)
        .where('text', isEqualTo: text)
        .get();
    if (snapshot.size == 0) {
      final IbTag tag = IbTag(
          text: text,
          id: IbUtils.getUniqueId(),
          creatorId: IbUtils.getCurrentUid()!);
      tag.timestamp = FieldValue.serverTimestamp();
      await _db.collection(_kTagCollection).doc(tag.id).set(
            tag.toJson(),
            SetOptions(merge: true),
          );
      return tag.id;
    } else {
      return snapshot.docs.first.id;
    }
  }

  Future<IbTag?> retrieveIbTag(String tagId) async {
    final snapshot = await _db.collection(_kTagCollection).doc(tagId).get();

    if (snapshot.exists) {
      return IbTag.fromJson(snapshot.data()!);
    }
    return null;
  }

  /// find if there are any tags in the database with the same text, if so return its id, otherwise generate a new one
  Future<String> retrieveIbTagId(String text) async {
    final snapshot = await _db
        .collection(_kTagCollection)
        .where('text', isEqualTo: text.trim())
        .get();

    if (snapshot.size == 0) {
      return IbUtils.getUniqueId();
    }
    return snapshot.docs.first.id;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> retrieveTrendingIbTags(
      {DocumentSnapshot? lastDocSnapshot}) async {
    if (lastDocSnapshot != null) {
      return _db
          .collection(_kTagCollection)
          .orderBy('questionCount', descending: true)
          .startAfterDocument(lastDocSnapshot)
          .limit(16)
          .get();
    }

    final snapshot = await _db
        .collection(_kTagCollection)
        .orderBy('questionCount', descending: true)
        .limit(24)
        .get();
    return snapshot;
  }
}
