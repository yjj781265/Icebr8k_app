import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';

class IbCloudMessagingService extends GetConnect {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final IbCloudMessagingService _ibCloudMessagingService =
      IbCloudMessagingService._();
  static const String kNotificationTypeChat = 'chat';
  static const String kNotificationTypeRequest = 'request';
  static const String kNotificationTypeQuestion = 'question';

  factory IbCloudMessagingService() => _ibCloudMessagingService;

  IbCloudMessagingService._();

  Future init() async {
    final NotificationSettings settings = await _fcm.requestPermission();
    print(
        'User granted notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final String? token = await _fcm.getToken();

      if (token != null) {
        print('cloud messaging token is $token');
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

  Future<void> removeMyToken() async {
    await _fcm.deleteToken();
    await IbUserDbService().removeTokenFromDatabase();
  }

  Future<String?> retrieveToken(String uid) async {
    return IbUserDbService().retrieveTokenFromDatabase(uid);
  }

  /// @param type: use IbCloudMessagingService notification constant string
  Future<void> sendNotification(
      {required List<String> tokens,
      required String title,
      String? imageUrl,
      String? chatRoomId,
      required String body,
      required String type}) async {
    if (IbCloudMessagingService.kNotificationTypeChat == type &&
        chatRoomId == null) {
      print('chatRoom Id is null or empty');
      return;
    }

    final Map<String, String> data = {};
    data['type'] = type;

    if (chatRoomId != null) {
      data['chatRoomId'] = chatRoomId;
    }

    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('pushNotification');
    final result = await callable.call({
      'tokens': tokens,
      'body': body,
      'badge': 0,
      "title": title,
      "imageUrl": imageUrl,
      "data": data
    });
    print('${tokens.length} tokens, sent ${result.data}');
  }
}
