import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_report.dart';

class IbReportDbService {
  static final IbReportDbService _service = IbReportDbService._();
  static final _db = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _collectionRef;
  static const _kReportCollection = 'IbReports';

  factory IbReportDbService() => _service;

  IbReportDbService._() {
    _collectionRef = _db.collection(_kReportCollection);
  }

  Future<void> addReport(IbReport ibReport) async {
    ibReport.timestamp = FieldValue.serverTimestamp();
    _collectionRef
        .doc(ibReport.id)
        .set(ibReport.toJson(), SetOptions(merge: true));
  }

  Future<void> removeReport(IbReport ibReport) async {
    _collectionRef.doc(ibReport.id).delete();
  }
}
