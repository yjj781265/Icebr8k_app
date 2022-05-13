import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/ib_answer.dart';
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

  Future<void> setUpStreams() async {
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

    _ibUserSub = IbUserDbService()
        .listenToIbUserChanges(IbUtils.getCurrentFbUser()!.uid)
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
          final compScore = await IbUtils.getCompScore(uid: id);
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
        .listenToUserPublicAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) async {
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
      //refresh compScore
      for (final item in friends) {
        final compScore = await IbUtils.getCompScore(uid: item.user.id);
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

  Future<void> onFriendListRefresh() async {
    /// refresh friend list
    for (final item in friends) {
      final user = await IbUserDbService().queryIbUser(item.user.id);
      if (user == null) {
        continue;
      }
      final compScore =
          await IbUtils.getCompScore(uid: user.id, isRefresh: true);
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
    isMuted = ibChat.mutedUids.contains(IbUtils.getCurrentUid());
    if (!ibChat.isCircle) {
      final list =
          avatars.where((element) => element.id != IbUtils.getCurrentUid());
      if (list.isEmpty) {
        isBlocked = false;
      } else {
        isBlocked = IbUtils.getCurrentIbUser()!
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
