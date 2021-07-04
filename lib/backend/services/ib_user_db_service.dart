import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

class IbUserService {
  static final _ibUserService = IbUserService._();
  static final _db = FirebaseFirestore.instance;
  static const _kUserCollection = 'IbUsers';
  late CollectionReference<Map<String, dynamic>> _collectionRef;

  factory IbUserService() => _ibUserService;
  IbUserService._() {
    _collectionRef = _db.collection(_kUserCollection);
  }

  Future<void> loginNewIbUser(IbUser _ibUser) {
    print('loginNewIbUser');
    return _collectionRef.doc(_ibUser.id).set(_ibUser.toJson());
  }

  Future<void> loginIbUser({required String uid, required int loginTimeInMs}) {
    print('loginIbUser');
    return _collectionRef.doc(uid).update({'loginTimeInMs': loginTimeInMs});
  }

  Future<void> signOutIbUser(String _uid) {
    print('signOutIbUser');
    return _collectionRef.doc(_uid).update({'isOnline': false});
  }

  Future<bool> isIbUserExist(String _uid) async {
    final snapshot = await _collectionRef.doc(_uid).get();
    final bool isExist = snapshot.exists;
    print('isIbUserExist $isExist');
    return isExist;
  }
}
