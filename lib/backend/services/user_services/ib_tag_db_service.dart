import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../db_config.dart';

class IbTagDbService {
  static final _ibTagDbService = IbTagDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kTagCollection = 'IbTags${DbConfig.dbSuffix}';

  factory IbTagDbService() => _ibTagDbService;

  IbTagDbService._();

  Future<void> uploadTag(String tagText) async {
    final snapshot = await _db.collection(_kTagCollection).doc(tagText).get();
    if (!snapshot.exists) {
      final IbTag tag =
          IbTag(text: tagText, creatorId: IbUtils().getCurrentUid()!);
      tag.timestamp = FieldValue.serverTimestamp();
      await _db.collection(_kTagCollection).doc(tag.text).set(
            tag.toJson(),
            SetOptions(merge: true),
          );
      print('uploadTag a new tag!');
    }
  }

  /// retrieve IbTag and cache locally
  Future<IbTag?> retrieveIbTag(String tagText) async {
    final snapshot = await _db.collection(_kTagCollection).doc(tagText).get();

    if (snapshot.exists) {
      IbCacheManager().cacheIbTag(IbTag.fromJson(snapshot.data()!));
      return IbTag.fromJson(snapshot.data()!);
    }
    return null;
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
