import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../db_config.dart';

class IbTagDbService {
  static final _ibTagDbService = IbTagDbService._();
  static final _db = FirebaseFirestore.instance;
  static const _kTagCollection = 'IbTags${DbConfig.dbSuffix}';

  factory IbTagDbService() => _ibTagDbService;

  IbTagDbService._();

  Future<String> uploadTagAndReturnId(String text) async {
    final snapshot = await _db
        .collection(_kTagCollection)
        .where('text', isEqualTo: text.trim())
        .get();
    if (snapshot.size == 0) {
      final IbTag ibTag = IbTag(
          questionCount: 1,
          text: text.trim(),
          id: IbUtils.getUniqueId(),
          creatorId: IbUtils.getCurrentUid()!);
      await _db
          .collection(_kTagCollection)
          .doc(ibTag.id)
          .set(ibTag.toJson(), SetOptions(merge: true));
      return ibTag.id;
    } else {
      final DocumentReference reference = snapshot.docs.first.reference;
      await reference.update({'questionCount': FieldValue.increment(1)});
      final tag = IbTag.fromJson(snapshot.docs.first.data());
      return tag.id;
    }
  }

  Future<IbTag?> retrieveIbTag(String tagId) async {
    final snapshot = await _db.collection(_kTagCollection).doc(tagId).get();

    if (snapshot.exists) {
      return IbTag.fromJson(snapshot.data()!);
    }
    return null;
  }

  Future<List<IbTag>> retrieveTrendingIbTags() async {
    final snapshot = await _db
        .collection(_kTagCollection)
        .orderBy('questionCount', descending: true)
        .limit(8)
        .get();
    final list = <IbTag>[];
    if (snapshot.size == 0) {
      return list;
    }

    for (final element in snapshot.docs) {
      list.add(IbTag.fromJson(element.data()));
    }

    return list;
  }
}
