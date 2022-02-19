import 'package:icebr8k/backend/services/user_services/ib_api_keys_service.dart';

class IbApiKeysManager {
  IbApiKeysManager._();
  static String kGooglePlacesApiKey = '';

  static Future<void> init() async {
    kGooglePlacesApiKey = await IbApiKeysService().queryGooglePlacesApiKey();
  }
}
