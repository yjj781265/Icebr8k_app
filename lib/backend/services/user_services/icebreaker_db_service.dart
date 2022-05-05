import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';

class IcebreakerDbService {
  static final IcebreakerDbService _service = IcebreakerDbService._();
  static final _db = FirebaseFirestore.instance;
  final String _kIcebreakerCollection = 'Icebreakers';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IcebreakerDbService() => _service;

  IcebreakerDbService._() {
    _collectionRef = _db.collection(_kIcebreakerCollection);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToIcebreakerChange(
      IbCollection ibCollection) {
    return _collectionRef.doc(ibCollection.id).snapshots();
  }

  Future<List<IbCollection>> queryIbCollections() async {
    final List<IbCollection> collections = [];

    final snapshot = await _collectionRef.get();
    for (final doc in snapshot.docs) {
      collections.add(IbCollection.fromJson(doc.data()));
      IbCacheManager().cacheIbCollection(IbCollection.fromJson(doc.data()));
    }
    return collections;
  }

  /// query IbCollection and cache locally via IbCacheManager
  Future<IbCollection?> queryIbCollection(String collectionId) async {
    final snapshot = await _collectionRef.doc(collectionId).get();
    if (snapshot.exists) {
      final collection = IbCollection.fromJson(snapshot.data()!);
      IbCacheManager().cacheIbCollection(collection);
    }
    return null;
  }
}
