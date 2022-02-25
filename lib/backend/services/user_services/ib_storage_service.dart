import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbStorageService {
  static final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static final IbStorageService _storageService = IbStorageService._();

  factory IbStorageService() => _storageService;
  IbStorageService._();

  Future<String?> uploadAndRetrieveImgUrl(
      {required String filePath, String oldUrl = ''}) async {
    final File file = File(filePath);
    final String fileName = IbUtils.getUniqueId();
    final String refString = 'images/$fileName.png';

    try {
      if (oldUrl.isNotEmpty) {
        await deleteFile(oldUrl);
      }
      if (filePath.isEmpty) {
        return null;
      }
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
    try {
      await _firebaseStorage.refFromURL(url).delete();
    } catch (e) {
      print('failed to remove image $e');
    }
  }
}
