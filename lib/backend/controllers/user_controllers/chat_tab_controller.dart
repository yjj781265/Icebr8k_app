import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_chat_db_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

/// controller for the Chat tab in Homepage
class ChatTabController extends GetxController {
  Map<String, IbUser> ibUserMap = {};
  final oneToOneChats = <ChatTabItem>[].obs;
  final groupChats = <IbChat>[].obs;
  late StreamSubscription _oneToOneSub;
  late StreamSubscription _groupSub;
  final isLoading = true.obs;
  final totalUnread = 0.obs;

  @override
  Future<void> onInit() async {
    _oneToOneSub =
        IbChatDbService().listenToOneToOneChat().listen((event) async {
      for (final docChange in event.docChanges) {
        print('ChatTabController 1-1 ${docChange.type}');
        final IbChat ibChat = IbChat.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.added) {
          _handleIbChatNameAndPhotoUrl(ibChat);
          final int unReadCount =
              await IbChatDbService().queryUnreadCount(ibChat: ibChat);
          oneToOneChats
              .add(ChatTabItem(ibChat: ibChat, unReadCount: unReadCount));
        } else if (docChange.type == DocumentChangeType.modified) {
          _handleIbChatNameAndPhotoUrl(ibChat);
          final int unReadCount =
              await IbChatDbService().queryUnreadCount(ibChat: ibChat);
          final index = oneToOneChats
              .indexWhere((element) => element.ibChat.chatId == ibChat.chatId);
          if (index != -1) {
            oneToOneChats[index] =
                ChatTabItem(ibChat: ibChat, unReadCount: unReadCount);
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
    });

    _groupSub = IbChatDbService().listenToGroupChat().listen((event) {
      for (final docChange in event.docChanges) {
        final IbChat ibChat = IbChat.fromJson(docChange.doc.data()!);
        print('ChatTabController group ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          groupChats.add(ibChat);
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = groupChats
              .indexWhere((element) => element.chatId == ibChat.chatId);
          if (index != -1) {
            groupChats[index] = ibChat;
          }
        } else {
          final index = groupChats
              .indexWhere((element) => element.chatId == ibChat.chatId);
          if (index != -1) {
            groupChats.removeAt(index);
          }
        }

        groupChats.sort((a, b) {
          if (a.lastMessage == null || b.lastMessage == null) {
            return a.name.compareTo(b.name);
          }
          return (b.lastMessage!.timestamp as Timestamp)
              .compareTo(a.lastMessage!.timestamp as Timestamp);
        });
        groupChats.refresh();
      }
    });
    super.onInit();
  }

  Future<void> _handleIbChatNameAndPhotoUrl(IbChat ibChat) async {
    if (ibChat.memberUids.length == 2) {
      final IbUser? user;
      final uid = ibChat.memberUids
          .firstWhere((element) => element != IbUtils.getCurrentUid());

      if (IbCacheManager().getIbUser(uid) == null) {
        user = await IbUserDbService().queryIbUser(uid);
      } else {
        user = IbCacheManager().getIbUser(uid);
      }

      if (user != null && ibChat.name.isEmpty) {
        ibChat.name = user.username;
      }

      if (user != null && ibChat.photoUrl.isEmpty) {
        ibChat.photoUrl = user.avatarUrl;
      }
    }
  }

  @override
  void onClose() {
    _oneToOneSub.cancel();
    _groupSub.cancel();
    super.onClose();
  }
}

class ChatTabItem {
  IbChat ibChat;
  bool isMuted = false;
  int unReadCount;

  ChatTabItem({required this.ibChat, required this.unReadCount}) {
    isMuted = ibChat.mutedUids.contains(IbUtils.getCurrentUid());
  }
}
