import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../services/user_services/ib_chat_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

/// controller for the Social tab in Homepage
class SocialTabController extends GetxController {
  Map<String, IbUser> ibUserMap = {};
  final oneToOneChats = <ChatTabItem>[].obs;
  final circles = <ChatTabItem>[].obs;
  final currentIndex = 0.obs;
  late StreamSubscription _oneToOneSub;
  late StreamSubscription _circleSub;
  final isLoadingCircles = true.obs;
  final isLoadingChat = true.obs;
  final totalUnread = 0.obs;
  final friends = <IbUser>[].obs;
  final RefreshController friendListRefreshController = RefreshController();
  final ScrollController scrollController = ScrollController();
  late StreamSubscription ibUserSub;
  late StreamSubscription ibPublicAnswerSub;
  final isFriendListLoading = true.obs;

  @override
  Future<void> onInit() async {
    await initFriendList();
    _oneToOneSub =
        IbChatDbService().listenToOneToOneChat().listen((event) async {
      for (final docChange in event.docChanges) {
        print('ChatTabController 1-1 ${docChange.type}');
        final IbChat ibChat = IbChat.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          final item = await _buildItem(ibChat);
          oneToOneChats.add(item);
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = oneToOneChats
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            final item = await _buildItem(ibChat);
            oneToOneChats[index] = item;
          }
        } else {
          final index = oneToOneChats
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            oneToOneChats.removeAt(index);
          }
        }

        oneToOneChats.sort((a, b) {
          if (a.ibChat.lastMessage == null || b.ibChat.lastMessage == null) {
            return a.ibChat.name.compareTo(b.ibChat.name);
          }
          return (b.ibChat.lastMessage!.timestamp as Timestamp)
              .compareTo(a.ibChat.lastMessage!.timestamp as Timestamp);
        });
        calculateTotalUnread();
        oneToOneChats.refresh();
      }
      isLoadingChat.value = false;
    });

    _circleSub = IbChatDbService().listenToCircles().listen((event) async {
      for (final docChange in event.docChanges) {
        final IbChat ibChat = IbChat.fromJson(docChange.doc.data()!);
        print('ChatTabController circle ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          final item = await _buildItem(ibChat);
          circles.add(item);
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = circles
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            final item = await _buildItem(ibChat);
            circles[index] = item;
          }
        } else {
          final index = circles
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            circles.removeAt(index);
          }
        }

        circles.sort((a, b) {
          if (a.ibChat.lastMessage == null || b.ibChat.lastMessage == null) {
            return a.ibChat.name.compareTo(b.ibChat.name);
          }
          return (b.ibChat.lastMessage!.timestamp as Timestamp)
              .compareTo(a.ibChat.lastMessage!.timestamp as Timestamp);
        });
        calculateTotalUnread();
        circles.refresh();
      }
      isLoadingCircles.value = false;
    });

    await Future.delayed(const Duration(milliseconds: 3000), () {
      isLoadingCircles.value = false;
      isLoadingChat.value = false;
    });

    super.onInit();
  }

  Future<ChatTabItem> _buildItem(IbChat ibChat) async {
    final List<String> uids = ibChat.memberUids
        .where((element) => element != IbUtils.getCurrentUid())
        .toList();
    final List<IbUser> avatarUsers = [];
    IbUser? lastMsgUser;
    String title = '';
    final int max = uids.length > 4 ? 4 : uids.length;

    for (int i = 0; i < max; i++) {
      final String uid = uids[i];
      final IbUser? user;
      if (IbCacheManager().getIbUser(uid) == null) {
        user = await IbUserDbService().queryIbUser(uid);
      } else {
        user = IbCacheManager().getIbUser(uid);
      }

      if (user != null) {
        title = '$title${user.username} ';
        avatarUsers.add(user);
      }
    }

    if (ibChat.lastMessage != null) {
      lastMsgUser =
          await IbUserDbService().queryIbUser(ibChat.lastMessage!.senderUid);
    }

    if (ibChat.name.isNotEmpty) {
      title = ibChat.name;
    }

    final int unReadCount =
        await IbChatDbService().queryUnreadCount(ibChat: ibChat);

    final ChatTabItem item = ChatTabItem(
      avatars: avatarUsers,
      lastMessageUser: lastMsgUser,
      ibChat: ibChat,
      unReadCount: unReadCount,
      title: title,
    );

    return item;
  }

  Future<void> initFriendList() async {
    for (final String id in IbUtils.getCurrentIbUser()!.friendUids) {
      IbUser? user;
      if (IbCacheManager().getIbUser(id) == null) {
        user = await IbUserDbService().queryIbUser(id);
      } else {
        user = IbCacheManager().getIbUser(id);
      }

      if (user == null) {
        continue;
      }
      friends.add(user);
    }

    friends.sort((a, b) => a.username.compareTo(b.username));
    isFriendListLoading.value = false;

    ibUserSub = Get.find<MainPageController>()
        .ibUserBroadcastStream
        .listen((ibUser) async {
      friends.clear();
      for (final String id in ibUser.friendUids) {
        IbUser? user;
        if (IbCacheManager().getIbUser(id) == null) {
          user = await IbUserDbService().queryIbUser(id);
        } else {
          user = IbCacheManager().getIbUser(id);
        }

        if (user == null) {
          continue;
        }
        friends.add(user);
      }
      friends.sort((a, b) => a.username.compareTo(b.username));
      isFriendListLoading.value = false;
    });

    ibPublicAnswerSub = IbQuestionDbService()
        .listenToUserPublicAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.removed) {
          IbCacheManager().removeSingleIbAnswer(
              uid: IbUtils.getCurrentUid()!, ibAnswer: ibAnswer);
        } else {
          IbCacheManager().cacheSingleIbAnswer(
              uid: IbUtils.getCurrentUid()!, ibAnswer: ibAnswer);
        }
      }

      /// refresh friend list
      for (final user in friends) {
        if (Get.isRegistered<FriendItemController>(tag: user.username)) {
          Get.find<FriendItemController>(tag: user.username).refreshItem(false);
        }
      }
    });
  }

  Future<void> onFriendListRefresh() async {
    isFriendListLoading.value = true;
    friends.clear();

    /// refresh friend list
    for (final String id in IbUtils.getCurrentIbUser()!.friendUids) {
      IbUser? user;
      user = await IbUserDbService().queryIbUser(id);
      IbCacheManager().cacheIbUser(user);

      if (user == null) {
        continue;
      }
      friends.add(user);
    }

    for (final user in friends) {
      if (Get.isRegistered<FriendItemController>(tag: user.username)) {
        Get.find<FriendItemController>(tag: user.username).refreshItem(true);
      }
    }
    friends.sort((a, b) => a.username.compareTo(b.username));
    friendListRefreshController.refreshCompleted();
    isFriendListLoading.value = false;
  }

  void calculateTotalUnread() {
    totalUnread.value = 0;
    for (final item in oneToOneChats) {
      totalUnread.value += item.unReadCount;
    }

    for (final item in circles) {
      totalUnread.value += item.unReadCount;
    }
  }

  @override
  Future<void> onClose() async {
    await _oneToOneSub.cancel();
    await _circleSub.cancel();
    await ibPublicAnswerSub.cancel();
    await ibUserSub.cancel();
    friendListRefreshController.dispose();

    super.onClose();
  }
}

class ChatTabItem {
  IbChat ibChat;
  String title;
  List<IbUser> avatars;
  IbUser? lastMessageUser;
  bool isMuted = false;
  int unReadCount;

  ChatTabItem({
    required this.avatars,
    required this.ibChat,
    required this.unReadCount,
    required this.title,
    required this.lastMessageUser,
  }) {
    isMuted = ibChat.mutedUids.contains(IbUtils.getCurrentUid());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTabItem &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
