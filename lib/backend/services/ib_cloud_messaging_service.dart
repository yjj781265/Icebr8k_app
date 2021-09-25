import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';

class IbCloudMessagingService extends GetConnect {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final IbCloudMessagingService _ibCloudMessagingService =
      IbCloudMessagingService._();

  factory IbCloudMessagingService() => _ibCloudMessagingService;

  IbCloudMessagingService._();

  Future init() async {
    final NotificationSettings settings = await _fcm.requestPermission();
    print(
        'User granted notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final String? token = await _fcm.getToken();

      if (token != null) {
        await IbUserDbService().saveTokenToDatabase(token);
        // Any time the token refreshes, store this in the database too.
        FirebaseMessaging.instance.onTokenRefresh
            .listen(IbUserDbService().saveTokenToDatabase);
      }

      FirebaseMessaging.onMessage.listen((message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    }
  }
}
