import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class NotificationController extends GetxController {
  late StreamSubscription ibNotificationsStream;
  final MainPageController _mainPageController = Get.find();
  final items = <NotificationItem>[].obs;

  @override
  Future<void> onInit() async {
    _initIbNotificationStream();
    super.onInit();
  }

  @override
  void onClose() {
    ibNotificationsStream.cancel();
    super.onClose();
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
          _onNotificationAdded(n);
        }

        if (docChange.type == DocumentChangeType.modified) {
          _onNotificationModified(n);
        }

        if (docChange.type == DocumentChangeType.removed) {
          _onNotificationRemoved(n);
        }
      }
      items.sort((a, b) =>
          b.notification.timestampInMs.compareTo(a.notification.timestampInMs));
      items.refresh();
    });
  }

  Future<void> _onNotificationAdded(IbNotification notification) async {
    final item = NotificationItem(notification: notification);
    if (notification.type == IbNotification.kGroupInvite) {
      final IbChat? chat = await IbChatDbService().queryChat(notification.id);
      item.ibChat = chat;
      if (chat != null) {
        items.add(item);
      }
      if (_mainPageController.currentIndex.value != 4 && !notification.isRead) {
        IbUtils.showSimpleSnackBar(
            msg: item.notification.title,
            backgroundColor: IbColors.primaryColor);
      }
    } else if (notification.type == IbNotification.kFriendRequest) {
      items.add(item);
      if (_mainPageController.currentIndex.value != 4 && !notification.isRead) {
        IbUtils.showSimpleSnackBar(
            msg: '${item.notification.title} ${'sent_you_a_friend_request'.tr}',
            backgroundColor: IbColors.primaryColor);
      }
    }
  }

  Future<void> _onNotificationModified(IbNotification notification) async {
    final int index = items
        .indexWhere((element) => element.notification.id == notification.id);

    if (index != -1) {
      items[index].notification = notification;
      if (notification.type == IbNotification.kGroupInvite) {
        final IbChat? chat = await IbChatDbService().queryChat(notification.id);
        items[index].ibChat = chat;
      }
    }
  }

  Future<void> _onNotificationRemoved(IbNotification notification) async {
    final int index = items
        .indexWhere((element) => element.notification.id == notification.id);
    if (index != -1) {
      items.removeAt(index);
    }
  }

  Future<void> acceptFr(IbNotification ibNotification) async {
    try {
      await IbUserDbService().addFriend(ibNotification.senderId);
      await IbUserDbService().removeNotification(ibNotification);
      IbUtils.showSimpleSnackBar(
          msg: 'Friend request accepted',
          backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to accept friend request $e',
          backgroundColor: IbColors.errorRed);
    }
  }

  Future<void> declineFr(IbNotification ibNotification) async {
    try {
      await IbUserDbService().removeNotification(ibNotification);
      IbUtils.showSimpleSnackBar(
          msg: 'Friend request declined',
          backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to decline request $e',
          backgroundColor: IbColors.accentColor);
    }
  }
}

class NotificationItem {
  IbNotification notification;
  IbChat? ibChat;

  NotificationItem({required this.notification, this.ibChat});
}
