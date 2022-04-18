import 'package:get_storage/get_storage.dart';

class IbLocalDataService {
  final _box = GetStorage();
  static final _ibLocalStorageService = IbLocalDataService._();

  factory IbLocalDataService() => _ibLocalStorageService;
  IbLocalDataService._();

  bool retrieveBoolValue(StorageKey key) {
    final bool value = _box.read(key.toString()) ?? false;
    return value;
  }

  bool retrieveCustomBoolValue(String key) {
    final bool value = _box.read(key) ?? false;
    return value;
  }

  String retrieveStringValue(StorageKey key) {
    final String value = _box.read(key.toString()) ?? '';
    return value;
  }

  void updateBoolValue({required StorageKey key, required bool value}) {
    _box.write(key.toString(), value);
  }

  void updateCustomBoolValue({required String key, required bool value}) {
    _box.write(key, value);
  }

  void updateStringValue({required StorageKey key, required String value}) {
    _box.write(key.toString(), value);
  }

  void removeKey(StorageKey key) {
    _box.remove(key.toString());
  }
}

enum StorageKey {
  rememberLoginEmailBool,
  isDarkModeBool,
  isLocSharingOnBool,
  loginEmailString,
  pickAnswerForQuizBool,
  pickTagForQuestionBool,
}
