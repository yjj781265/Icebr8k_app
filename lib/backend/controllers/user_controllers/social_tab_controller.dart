import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../frontend/ib_colors.dart';
import '../../../frontend/ib_config.dart';
import '../../models/ib_answer.dart';
import '../../models/ib_chat_models/ib_message.dart';
import '../../services/user_services/ib_chat_db_service.dart';
import '../../services/user_services/ib_question_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

/// controller for the Social tab in Homepage
class SocialTabController extends GetxController {
  final oneToOneChats = <ChatTabItem>[].obs;
  final circles = <ChatTabItem>[].obs;
  final currentIndex = 0.obs;
  List<String> lastFriendUids = <String>[];
  late StreamSubscription _oneToOneSub;
  late StreamSubscription _circleSub;
  late StreamSubscription _ibUserSub;
  late StreamSubscription _ibPublicAnswerSub;
  final isLoadingCircles = true.obs;
  final isLoadingChat = true.obs;
  final isFriendListLoading = true.obs;
  final totalUnread = 0.obs;
  final friends = <FriendItem>[].obs;
  final RefreshController friendListRefreshController = RefreshController();
  final ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    await setUpStreams();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'SocialTabController', screenName: 'SocialTab');
  }

  Future<void> setUpStreams() async {
    _oneToOneSub =
        IbChatDbService().listenToOneToOneChat().listen((event) async {
      for (final docChange in event.docChanges) {
        print('ChatTabController 1-1 ${docChange.type}');
        final IbChat ibChat = IbChat.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          final item = await _buildItem(ibChat);
          if (item.avatars.isEmpty) {
            continue;
          }
          oneToOneChats.add(item);
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = oneToOneChats
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            final item = await _buildItem(ibChat);
            _showChatNotification(oldItem: oneToOneChats[index], item: item);
            oneToOneChats[index] = item;
            calculateTotalUnread();
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
        oneToOneChats.refresh();
      }
      calculateTotalUnread();
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
            _showChatNotification(oldItem: circles[index], item: item);
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
        circles.refresh();
      }
      calculateTotalUnread();
      isLoadingCircles.value = false;
    });

    _ibUserSub = IbUserDbService()
        .listenToIbUserChanges(IbUtils().getCurrentFbUser()!.uid)
        .listen((event) async {
      if (_listEquals(list1: lastFriendUids, list2: event.friendUids)) {
        return;
      }
      lastFriendUids = event.friendUids;
      friends.clear();
      for (final String id in event.friendUids) {
        IbUser? user;
        if (IbCacheManager().getIbUser(id) == null) {
          user = await IbUserDbService().queryIbUser(id);
        } else {
          user = IbCacheManager().getIbUser(id);
        }

        if (user == null) {
          continue;
        }
        final index = friends.indexWhere((element) => element.user.id == id);
        if (index == -1) {
          final compScore = await IbUtils().getCompScore(uid: id);
          friends.add(FriendItem(user: user, compScore: compScore));
        } else {
          friends[index].user = user;
        }
      }
      friends.value = friends.toSet().toList();
      friends.sort((a, b) => b.compScore.compareTo(a.compScore));
      friends.refresh();
      isFriendListLoading.value = false;
    });

    _ibPublicAnswerSub = IbQuestionDbService()
        .listenToUserPublicAnsweredQuestionsChange(IbUtils().getCurrentUid()!)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.removed) {
          IbCacheManager().removeSingleIbAnswer(
              uid: IbUtils().getCurrentUid()!, ibAnswer: ibAnswer);
        } else {
          IbCacheManager().cacheSingleIbAnswer(
              uid: IbUtils().getCurrentUid()!, ibAnswer: ibAnswer);
        }
      }
      //refresh compScore
      for (final item in friends) {
        final compScore = await IbUtils().getCompScore(uid: item.user.id);
        item.compScore = compScore;
      }
      friends.sort((a, b) => b.compScore.compareTo(a.compScore));
      friends.refresh();
    });

    await Future.delayed(const Duration(milliseconds: 3000), () {
      isLoadingCircles.value = false;
      isLoadingChat.value = false;
      isFriendListLoading.value = false;
    });
  }

  bool _listEquals({required List<String> list1, required List<String> list2}) {
    list1.sort();
    list2.sort();
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }

  Future<ChatTabItem> _buildItem(IbChat ibChat) async {
    final List<String> uids = ibChat.memberUids
        .where((element) => element != IbUtils().getCurrentUid())
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
      } else {
        continue;
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

  Future<void> onFriendListRefresh() async {
    /// refresh friend list
    for (final item in friends) {
      final user = await IbUserDbService().queryIbUser(item.user.id);
      if (user == null) {
        print('user is null remove from friends');
        await IbUserDbService().removeFriend(item.user.id);
        continue;
      }
      final compScore =
          await IbUtils().getCompScore(uid: user.id, isRefresh: true);
      item.user = user;
      item.compScore = compScore;
    }
    friends.sort((a, b) => b.compScore.compareTo(a.compScore));
    friends.refresh();
    friendListRefreshController.refreshCompleted();
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

  void _showChatNotification(
      {required ChatTabItem oldItem, required ChatTabItem item}) {
    /* // if (item.lastMessageUser == null ||
    //     item.ibChat.lastMessage == null ||
    //     item.ibChat.lastMessage!.senderUid == IbUtils().getCurrentUid()) {
    //   return;
    // }
    //
    // if (oldItem.ibChat.lastMessage != null &&
    //     oldItem.ibChat.lastMessage!.content ==
    //         item.ibChat.lastMessage!.content) {
    //   return;
    // }
    // GetSnackBar notification = const GetSnackBar();
    //
    // if (!item.ibChat.isCircle) {
    //   notification = GetSnackBar(
    //     snackPosition: SnackPosition.TOP,
    //     duration: const Duration(seconds: 3),
    //     margin: const EdgeInsets.only(left: 8, right: 8, top: 16),
    //     borderRadius: IbConfig.kCardCornerRadius,
    //     icon: IbUserAvatar(
    //       avatarUrl: item.lastMessageUser!.avatarUrl,
    //       radius: 16,
    //     ),
    //     titleText: Text(
    //       item.ibChat.name.isEmpty
    //           ? item.lastMessageUser!.username
    //           : item.ibChat.name,
    //       style: const TextStyle(fontWeight: FontWeight.bold),
    //     ),
    //     messageText: buildSubtitle(item),
    //     backgroundColor: Theme.of(Get.context!).backgroundColor,
    //   );
    // } else {
    //   notification = GetSnackBar(
    //     borderRadius: IbConfig.kCardCornerRadius,
    //     duration: const Duration(seconds: 3),
    //     snackPosition: SnackPosition.TOP,
    //     margin: const EdgeInsets.only(left: 8, right: 8, top: 16),
    //     icon: buildCircleAvatar(item, size: 16),
    //     titleText: Text(
    //         item.ibChat.name.isEmpty
    //             ? item.lastMessageUser!.username
    //             : item.ibChat.name,
    //         style: const TextStyle(fontWeight: FontWeight.bold)),
    //     messageText: buildSubtitle(item),
    //     backgroundColor: Theme.of(Get.context!).backgroundColor,
    //   );
    // }
    //
    // if (Get.isRegistered<ChatPageController>(tag: item.ibChat.chatId) ||
    //     Get.isRegistered<ChatPageController>(tag: item.lastMessageUser!.id) ||
    //     item.ibChat.mutedUids.contains(IbUtils().getCurrentUid())) {
    //   return;
    // } else {
    //   Get.showSnackbar(notification);
    // }*/
    return;
  }

  Widget buildCircleAvatar(ChatTabItem item, {double size = 24}) {
    if (Get.context == null) {
      return const SizedBox();
    }
    if (item.ibChat.photoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: IbColors.lightGrey,
        radius: size,
        child: Text(
          item.ibChat.name[0],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(Get.context!).indicatorColor,
              fontSize: size,
              fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return IbUserAvatar(
        radius: size,
        avatarUrl: item.ibChat.photoUrl,
      );
    }
  }

  Widget buildSubtitle(ChatTabItem item) {
    if (item.ibChat.lastMessage == null) {
      return const SizedBox();
    }
    if (item.ibChat.isTypingUids.isNotEmpty &&
        IbUtils().getCurrentIbUser() != null &&
        IbUtils().isPremiumMember()) {
      return const Text(
        'someone is typing...',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: IbConfig.kSecondaryTextSize,
            fontStyle: FontStyle.italic,
            color: IbColors.lightGrey),
      );
    }

    final String messageType = item.ibChat.lastMessage!.messageType;
    switch (messageType) {
      case IbMessage.kMessageTypeAnnouncement:
        return Text(
          item.ibChat.lastMessage!.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              fontSize: IbConfig.kSecondaryTextSize,
              color: IbColors.accentColor),
        );
      case IbMessage.kMessageTypeText:
        return Text(
          '${item.lastMessageUser == null || !item.ibChat.isCircle ? '' : '${item.lastMessageUser!.username}: '}${item.ibChat.lastMessage!.content}',
          style: TextStyle(
              fontSize: IbConfig.kSecondaryTextSize,
              fontWeight:
                  item.unReadCount <= 0 ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case IbMessage.kMessageTypePic:
        return Text(
          '${item.lastMessageUser == null || !item.ibChat.isCircle ? '' : '${item.lastMessageUser!.username}: '}[IMAGE]',
          style: TextStyle(
              fontSize: IbConfig.kSecondaryTextSize,
              fontWeight:
                  item.unReadCount <= 0 ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case IbMessage.kMessageTypePoll:
        return Text(
          '${item.lastMessageUser == null || !item.ibChat.isCircle ? '' : '${item.lastMessageUser!.username}: '}[POLL]',
          style: TextStyle(
              fontSize: IbConfig.kSecondaryTextSize,
              fontWeight:
                  item.unReadCount <= 0 ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case IbMessage.kMessageTypeIcebreaker:
        return Text(
          '${item.lastMessageUser == null || !item.ibChat.isCircle ? '' : '${item.lastMessageUser!.username}: '}[ICEBREAKER]',
          style: TextStyle(
              fontSize: IbConfig.kSecondaryTextSize,
              fontWeight:
                  item.unReadCount <= 0 ? FontWeight.normal : FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Future<void> onClose() async {
    await _oneToOneSub.cancel();
    await _circleSub.cancel();
    await _ibUserSub.cancel();
    await _ibPublicAnswerSub.cancel();
    friendListRefreshController.dispose();

    super.onClose();
  }
}

class FriendItem {
  IbUser user;
  double compScore;

  FriendItem({
    required this.user,
    required this.compScore,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendItem &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          compScore == other.compScore;

  @override
  int get hashCode => user.hashCode ^ compScore.hashCode;
}

class ChatTabItem {
  IbChat ibChat;
  String title;
  List<IbUser> avatars;
  IbUser? lastMessageUser;
  bool isMuted = false;
  bool isBlocked = false;
  int unReadCount;

  ChatTabItem({
    required this.avatars,
    required this.ibChat,
    required this.unReadCount,
    required this.title,
    required this.lastMessageUser,
  }) {
    isMuted = ibChat.mutedUids.contains(IbUtils().getCurrentUid());
    if (!ibChat.isCircle) {
      final list =
          avatars.where((element) => element.id != IbUtils().getCurrentUid());
      if (list.isEmpty) {
        isBlocked = false;
      } else {
        isBlocked = IbUtils()
            .getCurrentIbUser()!
            .blockedFriendUids
            .contains(list.first.id);
      }
    } else {
      isBlocked = false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTabItem &&
          runtimeType == other.runtimeType &&
          ibChat == other.ibChat &&
          title == other.title &&
          avatars == other.avatars &&
          lastMessageUser == other.lastMessageUser &&
          isMuted == other.isMuted &&
          isBlocked == other.isBlocked &&
          unReadCount == other.unReadCount;

  @override
  int get hashCode =>
      ibChat.hashCode ^
      title.hashCode ^
      avatars.hashCode ^
      lastMessageUser.hashCode ^
      isMuted.hashCode ^
      isBlocked.hashCode ^
      unReadCount.hashCode;
}
