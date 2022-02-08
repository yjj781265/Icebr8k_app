import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

class IbAdminService {
  static final _ibAdminDbService = IbAdminService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUsersCollection = 'IbUsers${DbConfig.dbSuffix}';

  factory IbAdminService() => _ibAdminDbService;

  IbAdminService._();

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToPendingApplications() {
    return _db
        .collection(_kUsersCollection)
        .where('status', isEqualTo: IbUser.kUserStatusPending)
        .orderBy('joinTime')
        .snapshots();
  }
}
