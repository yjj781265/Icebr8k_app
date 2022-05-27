import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import '../../../frontend/ib_widgets/ib_dialog.dart';
import '../../db_config.dart';
import '../../models/ib_chat_models/ib_chat_member.dart';
import '../../models/ib_chat_models/ib_message.dart';
import '../../models/ib_question.dart';

class NotificationController extends GetxController {
  late StreamSubscription ibNotificationsStream;
  final items = <NotificationItem>[].obs;
  final requests = <NotificationItem>[].obs;
  final isLoading = true.obs;
  final fcm = FirebaseMessaging.instance;

  @override
  Future<void> onInit() async {
    await _sendTesterCircleInvite();
    await _initPushNotification();
    await _initData();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'NotificationController', screenName: 'AlertTab');
  }

  Future<void> _sendTesterCircleInvite() async {
    const chatId = '654c70b1-d416-48a2-8dc7-88252ffd8a71';

    /// invite user to tester circle
    final n = IbNotification(
        id: IbUtils.getUniqueId(),
        type: IbNotification.kCircleInvite,
        timestamp: FieldValue.serverTimestamp(),
        senderId: "y79vjfa5yUTN5kFRNf9uSWS7ZOs1",
        recipientId: IbUtils.getCurrentUid()!,
        url: chatId,
        body: '');
    final bool isSent = await IbUserDbService().isCircleInviteSent(
        chatId: chatId, recipientId: IbUtils.getCurrentUid()!);
    final members = await IbChatDbService().queryChatMembers(chatId);
    final isMember = members.firstWhereOrNull(
            (element) => element.uid == IbUtils.getCurrentUid()!) !=
        null;

    if (isSent || isMember) {
      print('invite already sent');
      return;
    }
    await IbUserDbService().sendAlertNotification(n);
  }

  @override
  Future<void> onClose() async {
    print('NotificationController onClose');
    await ibNotificationsStream.cancel();
    super.onClose();
  }

  Future<void> _initData() async {
    ibNotificationsStream =
        IbUserDbService().listenToNewIbNotifications().listen((event) async {
      for (final docChange in event.docChanges) {
        print('notification ${docChange.type}');
        if (docChange.doc.data() == null) {
          continue;
        }

        final IbNotification n = IbNotification.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          await _onNotificationAdded(n);
        }

        if (docChange.type == DocumentChangeType.modified) {
          await _onNotificationModified(n);
        }

        if (docChange.type == DocumentChangeType.removed) {
          await _onNotificationRemoved(n);
        }
      }

      items.sort((a, b) => (b.notification.timestamp as Timestamp)
          .compareTo(a.notification.timestamp as Timestamp));
      items.refresh();
      requests.sort((a, b) => (b.notification.timestamp as Timestamp)
          .compareTo(a.notification.timestamp as Timestamp));
      requests.refresh();
      isLoading.value = false;
    });
  }

  Future<void> _initPushNotification() async {
    final fcmToken = await fcm.getToken();
    if (fcmToken == null) {
      print('fcm token return null value!!');
    } else {
      print('fcm token is granted!');
      await fcm.subscribeToTopic('Users${DbConfig.dbSuffix}');
      await IbUserDbService().saveTokenToDatabase(fcmToken);
      await handleRemoteMessageFromTerminatedState();
      FirebaseMessaging.onMessageOpenedApp.listen((event) async {
        print(event.data);
        if (event.data['type'] == IbNotification.kChat) {
          final chatId = event.data['url'] as String;
          final ibChat = await IbChatDbService().queryChat(chatId);
          if (ibChat != null) {
            Get.to(() => ChatPage(Get.put(ChatPageController(ibChat: ibChat),
                tag: ibChat.chatId)));
          }
        }
      });
    }
  }

  Future<void> handleRemoteMessageFromTerminatedState() async {
    final message = await fcm.getInitialMessage();
    if (message != null) {
      if (message.data['type'] == IbNotification.kChat) {
        final chatId = message.data['url'] as String;
        final ibChat = await IbChatDbService().queryChat(chatId);
        if (ibChat != null) {
          Get.to(() => ChatPage(
              Get.put(ChatPageController(ibChat: ibChat), tag: ibChat.chatId)));
        }
      }
    }
  }

  Future<void> _onNotificationAdded(IbNotification notification) async {
    final senderUser =
        await IbUserDbService().queryIbUser(notification.senderId);

    if (senderUser == null) {
      return;
    }

    final item =
        NotificationItem(notification: notification, senderUser: senderUser);
    item.avatarUrl = senderUser.avatarUrl;
    if (notification.type == IbNotification.kCircleInvite ||
        notification.type == IbNotification.kCircleRequest) {
      final IbChat? chat = await IbChatDbService().queryChat(notification.url);
      item.ibChat = chat;

      if (chat != null) {
        requests.add(item);
      }
    } else if (notification.type == IbNotification.kFriendRequest) {
      requests.add(item);
    } else if (notification.type == IbNotification.kNewVote ||
        notification.type == IbNotification.kPollLike) {
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(notification.url);
      item.ibQuestion = question;
      if (question != null) {
        items.add(item);
      }
    } else if (notification.type == IbNotification.kPollComment ||
        notification.type == IbNotification.kPollCommentLike) {
      final IbComment? comment =
          await IbQuestionDbService().queryComment(notification.url);
      if (comment == null) {
        return;
      }
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(comment.questionId);

      if (question != null) {
        item.ibQuestion = question;
        item.ibComment = comment;
        items.add(item);
      }
    } else if (notification.type == IbNotification.kPollCommentReply) {
      final IbComment? comment =
          await IbQuestionDbService().queryComment(notification.url);
      if (comment == null) {
        return;
      }
      final IbComment? reply = comment.replies
          .firstWhereOrNull((element) => element.commentId == notification.id);
      if (reply == null) {
        print('reply not found');
        return;
      }
      final IbQuestion? question =
          await IbQuestionDbService().querySingleQuestion(comment.questionId);

      if (question != null) {
        item.ibQuestion = question;
        item.ibComment = reply;
        items.add(item);
      }
    } else if (notification.type == IbNotification.kFriendAccepted) {
      items.add(item);
    }
  }

  Future<void> _onNotificationModified(IbNotification notification) async {
    final int index = items
        .indexWhere((element) => element.notification.id == notification.id);
    final int index2 = requests
        .indexWhere((element) => element.notification.id == notification.id);

    if (index != -1) {
      items[index].notification = notification;
    }

    if (index2 != -1) {
      requests[index2].notification = notification;
    }
  }

  Future<void> _onNotificationRemoved(IbNotification notification) async {
    final int index = items
        .indexWhere((element) => element.notification.id == notification.id);
    final int index2 = requests
        .indexWhere((element) => element.notification.id == notification.id);
    if (index != -1) {
      items.removeAt(index);
    }

    if (index2 != -1) {
      requests.removeAt(index2);
    }
  }

  Future<void> acceptFr(IbNotification ibNotification) async {
    try {
      await IbUserDbService().addFriend(ibNotification.senderId);
      await IbUserDbService().removeNotification(ibNotification);
      await IbUserDbService().sendAlertNotification(IbNotification(
          id: IbUtils.getUniqueId(),
          body: '',
          type: IbNotification.kFriendAccepted,
          timestamp: FieldValue.serverTimestamp(),
          senderId: IbUtils.getCurrentUid()!,
          recipientId: ibNotification.senderId));
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

  Future<void> joinCircle(NotificationItem item) async {
    try {
      if (item.ibChat == null) {
        return;
      }
      Get.dialog(
          const IbLoadingDialog(messageTrKey: 'Adding new member to a circle'));
      final chat = await IbChatDbService().queryChat(item.ibChat!.chatId);
      final user = item.senderUser;
      if (chat != null &&
          chat.memberUids.contains(
            user.id,
          )) {
        Get.back();
        IbUtils.showSimpleSnackBar(
            msg: 'New circle member added',
            backgroundColor: IbColors.accentColor);
      } else {
        await IbChatDbService().addChatMember(
            member: IbChatMember(
                chatId: chat!.chatId,
                uid: user.id,
                role: IbChatMember.kRoleMember));
        await IbChatDbService().uploadMessage(IbMessage(
            messageId: IbUtils.getUniqueId(),
            content: '${user.username} joined the circle',
            senderUid: user.id,
            readUids: [user.id],
            messageType: IbMessage.kMessageTypeAnnouncement,
            chatRoomId: chat.chatId));
        await IbUserDbService().removeNotification(item.notification);
        Get.back();
        IbUtils.showSimpleSnackBar(
            msg: 'New circle member added',
            backgroundColor: IbColors.accentColor);
      }
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        title: "Error",
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }

  Future<void> clearAllNotifications() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'Clearing...'));
    final tempList = <NotificationItem>[];
    tempList.addAll(items);
    for (final item in tempList) {
      await IbUserDbService().removeNotification(item.notification);
    }
    Get.back();
  }
}

class NotificationItem {
  IbNotification notification;
  IbUser senderUser;
  String avatarUrl;
  IbChat? ibChat;
  IbQuestion? ibQuestion;
  IbComment? ibComment;

  NotificationItem(
      {required this.notification,
      required this.senderUser,
      this.ibQuestion,
      this.ibComment,
      this.ibChat,
      this.avatarUrl = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          notification == other.notification &&
          senderUser == other.senderUser &&
          avatarUrl == other.avatarUrl &&
          ibChat == other.ibChat;

  @override
  int get hashCode =>
      notification.hashCode ^
      senderUser.hashCode ^
      avatarUrl.hashCode ^
      ibChat.hashCode;
}
