import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class NotificationController extends GetxController {
  late StreamSubscription ibNotificationsStream;
  final ibNotifications = <IbNotification>[];

  @override
  Future<void> onInit() async {
    _initIbNotificationStream();
    super.onInit();
  }

  void _initIbNotificationStream() {
    ibNotificationsStream =
        IbUserDbService().listenToIbNotifications().listen((event) {
      for (final docChange in event.docChanges) {
        print(docChange.type);
        if (docChange.type == DocumentChangeType.added) {}

        if (docChange.type == DocumentChangeType.modified) {}

        if (docChange.type == DocumentChangeType.removed) {}
      }
    });
  }
}
