import 'package:cloud_firestore/cloud_firestore.dart';

class IbApiKeysService {
  static final IbApiKeysService _apiKeyService = IbApiKeysService._();
  static final _db = FirebaseFirestore.instance;
  factory IbApiKeysService() => _apiKeyService;
  IbApiKeysService._();

  /// will return empty string on error
  Future<String> queryGooglePlacesApiKey() async {
    try {
      final snapshot =
          await _db.collection('ApiKeys').doc('google-places-api').get();
      return snapshot.data()!['key'].toString();
    } catch (e) {
      print(e);
    }
    return '';
  }
}
