import 'package:cloud_firestore/cloud_firestore.dart';
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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToIbCollectionChange() {
    return _collectionRef.snapshots();
  }
}
