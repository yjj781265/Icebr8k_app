import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_chat_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

/// controller for the Chat tab in Homepage
class ChatTabController extends GetxController {
  Map<String, IbUser> ibUserMap = {};
  final oneToOneChats = <ChatTabItem>[].obs;
  final circles = <ChatTabItem>[].obs;
  late StreamSubscription _oneToOneSub;
  late StreamSubscription _circleSub;
  final isLoadingCircles = true.obs;
  final isLoadingChat = true.obs;
  final totalUnread = 0.obs;

  @override
  Future<void> onInit() async {
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
          final item = await _buildItem(ibChat);
          oneToOneChats[index] = item;
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
  void onClose() {
    _oneToOneSub.cancel();
    _circleSub.cancel();
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
}
