import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

class IbUserService {
  static final _ibUserService = IbUserService._();

  factory IbUserService() => _ibUserService;
  IbUserService._();

  Future<DocumentReference<Map<String, dynamic>>> addUser(IbUser _user) {
    return FirebaseFirestore.instance.collection('Users').add(_user.toJson());
  }
}
