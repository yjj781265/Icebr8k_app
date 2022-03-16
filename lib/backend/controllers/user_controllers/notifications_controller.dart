import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class NotificationController extends GetxController {
  late StreamSubscription ibNotificationsStream;
  final ibNotifications = <IbNotification>[].obs;

  @override
  Future<void> onInit() async {
    _initIbNotificationStream();
    super.onInit();
  }

  void _initIbNotificationStream() {
    ibNotificationsStream =
        IbUserDbService().listenToIbNotifications().listen((event) {
      for (final docChange in event.docChanges) {
        if (docChange.doc.data() == null) {
          continue;
        }

        print('NotificationController ${docChange.type}');

        final IbNotification n = IbNotification.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          ibNotifications.add(n);
        }

        if (docChange.type == DocumentChangeType.modified) {
          final int index =
              ibNotifications.indexWhere((element) => element.id == n.id);
          if (index != 1) {
            ibNotifications[index] = n;
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          ibNotifications.removeWhere((element) => element.id == n.id);
        }
      }
    });
  }

  Future<void> acceptFr(IbNotification ibNotification) async {
    await IbUserDbService().removeNotification(ibNotification);
    await IbUserDbService().addFriend(IbFriend(
        status: IbFriend.kFriendshipStatusAccepted,
        friendUid: ibNotification.senderId,
        timestampInMs: DateTime.now().millisecondsSinceEpoch));
  }

  Future<void> declineFr(IbNotification ibNotification) async {
    await IbUserDbService().removeNotification(ibNotification);
  }
}
