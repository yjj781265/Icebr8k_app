import 'package:cloud_firestore/cloud_firestore.dart';

class IbApiKeysService {
  static final IbApiKeysService _apiKeyService = IbApiKeysService._();
  static final _db = FirebaseFirestore.instance;
  final String kCollection = 'Secrets';
  factory IbApiKeysService() => _apiKeyService;
  IbApiKeysService._();

  /// will return empty string on error
  Future<String> queryGooglePlacesApiKey() async {
    try {
      final snapshot =
          await _db.collection(kCollection).doc('google-places-api').get();
      if (!snapshot.exists) {
        return '';
      }
      return snapshot.data()!['key'].toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  /// will return empty string on error
  Future<String> queryTypeSenseSearchApiKey() async {
    try {
      final snapshot =
          await _db.collection(kCollection).doc('type-sense-search').get();
      if (!snapshot.exists) {
        return '';
      }
      return snapshot.data()!['key'].toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  /// will return empty string on error
  Future<String> queryRevenueCatAndroidApiKey() async {
    try {
      final snapshot =
          await _db.collection(kCollection).doc('revenue-cat-keys').get();
      if (!snapshot.exists) {
        return '';
      }
      return snapshot.data()!['android'].toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  /// will return empty string on error
  Future<String> queryRevenueCatIosApiKey() async {
    try {
      final snapshot =
          await _db.collection(kCollection).doc('revenue-cat-keys').get();
      if (!snapshot.exists) {
        return '';
      }
      return snapshot.data()!['ios'].toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  /// will return empty string on error
  Future<String> queryTypeSenseNodeAddress() async {
    try {
      final snapshot =
          await _db.collection(kCollection).doc('type-sense-node1').get();
      if (!snapshot.exists) {
        return '';
      }
      return snapshot.data()!['address'].toString();
    } catch (e) {
      print(e);
      return '';
    }
  }
}
