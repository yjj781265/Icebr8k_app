import 'package:icebr8k/backend/services/user_services/ib_api_keys_service.dart';

class IbApiKeysManager {
  static final IbApiKeysManager _manager = IbApiKeysManager._();
  factory IbApiKeysManager() => _manager;
  IbApiKeysManager._();
  static String kGooglePlacesApiKey = '';
  static String kTypeSenseSearchApiKey = '';
  static String kTypeSenseNode = '';

  Future<void> init() async {
    kGooglePlacesApiKey = await IbApiKeysService().queryGooglePlacesApiKey();
    kTypeSenseSearchApiKey =
        await IbApiKeysService().queryTypeSenseSearchApiKey();
    kTypeSenseNode = await IbApiKeysService().queryTypeSenseNodeAddress();
  }
}
