import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbStorageService {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static final IbStorageService _storageService = IbStorageService._();

  factory IbStorageService() => _storageService;
  IbStorageService._();

  Future<String?> uploadAndRetrieveImgUrl(String filePath) async {
    final File file = File(filePath);
    final String fileName = IbUtils.getUniqueName();
    final String refString = 'images/$fileName.png';

    try {
      await _firebaseStorage.ref(refString).putFile(file);
      final String downloadURL =
          await _firebaseStorage.ref(refString).getDownloadURL();
      return downloadURL;
    } on FirebaseException catch (e) {
      print('uploadAndRetrieveImgUrl ${e.message}');
      return null;
    }
  }

  Future<void> deleteFile(String url) async {
    await _firebaseStorage.refFromURL(url).delete();
  }
}
