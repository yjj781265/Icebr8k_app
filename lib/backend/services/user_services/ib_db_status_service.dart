import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/db_config.dart';

class IbDbStatusService {
  static final _ibDbStatusService = IbDbStatusService._();
  static final _db = FirebaseFirestore.instance;
  static const _kCollection = 'DbStatus';

  factory IbDbStatusService() => _ibDbStatusService;
  IbDbStatusService._();

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToStatus() {
    return _db.collection(_kCollection).doc(DbConfig.dbSuffix).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> queryStatus() {
    return _db.collection(_kCollection).doc(DbConfig.dbSuffix).get();
  }
}
