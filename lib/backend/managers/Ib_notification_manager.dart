import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class IbNotificationManager {
  static final IbNotificationManager _manager = IbNotificationManager._();
  factory IbNotificationManager() => _manager;
  IbNotificationManager._();

  Future<void> init() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      print('fcm token return null value!!');
    } else {
      await FirebaseMessaging.instance
          .subscribeToTopic('Users${DbConfig.dbSuffix}');
      await IbUserDbService().saveTokenToDatabase(fcmToken);
    }
  }
}
