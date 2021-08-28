import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class ChatTabController extends GetxController {
  Map<String, IbUser> ibUserMap = {};
  final chatTabItems = <ChatTabItem>[].obs;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _streamSubscription;
  final isLoading = true.obs;
  final totalUnread = 0.obs;

  @override
  void onInit() {
    _streamSubscription = IbChatDbService()
        .listenToChatRoomChanges(IbUtils.getCurrentUid()!)
        .listen((event) async {
      print('there are ${event.docs.length} rooms');

      for (final docChange in event.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final item = await getChatTabItemFromDocChange(docChange);
          chatTabItems.addIf(!chatTabItems.contains(item), item);
          print('add ${item.chatRoomId}');
        }

        if (docChange.type == DocumentChangeType.modified) {
          final item = await getChatTabItemFromDocChange(docChange);
          if (chatTabItems.contains(item)) {
            chatTabItems[chatTabItems.indexOf(item)] = item;
            print('modified ${item.chatRoomId}');
          }
        }

        if (docChange.type == DocumentChangeType.removed) {
          final item = await getChatTabItemFromDocChange(docChange);
          if (chatTabItems.contains(item)) {
            chatTabItems.remove(item);
            print('removed ${item.chatRoomId}');
          }
        }
        chatTabItems.sort((a, b) {
          if (a.ibMessage.timestamp != null && b.ibMessage.timestamp != null) {
            final Timestamp timestamp1 = a.ibMessage.timestamp as Timestamp;
            final Timestamp timestamp2 = b.ibMessage.timestamp as Timestamp;
            return timestamp2.compareTo(timestamp1);
          }
          return b.title.compareTo(a.title);
        });
      }
      getTotalUnread();
      isLoading.value = false;
    });
    super.onInit();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    super.onClose();
  }

  void getTotalUnread() {
    totalUnread.value = 0;
    for (final ChatTabItem item in chatTabItems) {
      totalUnread.value = totalUnread.value + item.unReadCount;
    }
  }

  Future<ChatTabItem> getChatTabItemFromDocChange(
      DocumentChange<Map<String, dynamic>> docChange) async {
    final String chatRoomId = docChange.doc.data()!['chatRoomId'].toString();
    final IbMessage _lastMessage = IbMessage.fromJson(
        docChange.doc.data()!['lastMessage'] as Map<String, dynamic>);
    final List<String> uids =
        (docChange.doc.data()!['memberUids'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
    await cacheAvatarUrls(uids);
    final int unReadCount = await IbChatDbService().queryUnreadCount(
        chatRoomId: chatRoomId, uid: IbUtils.getCurrentUid()!);
    print('unReadCount $unReadCount');
    final ChatTabItem item = ChatTabItem(
        controller: this,
        chatRoomId: chatRoomId,
        ibMessage: _lastMessage,
        unReadCount: unReadCount,
        memberUids: uids);
    return item;
  }

  Future<void> removeChatItem(ChatTabItem item) async {
    await IbChatDbService().removeChatRoom(item.chatRoomId);
  }

  Future<void> cacheAvatarUrls(List<String> uids) async {
    for (final String uid in uids) {
      if (ibUserMap.containsKey(uid)) {
        continue;
      }
      final IbUser? ibUser = await IbUserDbService().queryIbUser(uid);
      if (ibUser != null) {
        ibUserMap.addIf(!ibUserMap.containsKey(uid), uid, ibUser);
      }
    }
  }
}

class ChatTabItem {
  String chatRoomId;
  String title = '';
  List<String> memberUids;
  IbUser? ibUser;
  IbMessage ibMessage;
  int unReadCount;
  String avatarUrl = '';
  ChatTabController controller;

  ChatTabItem(
      {required this.controller,
      required this.chatRoomId,
      this.title = '',
      required this.ibMessage,
      required this.memberUids,
      required this.unReadCount,
      this.avatarUrl = ''}) {
    if (memberUids.isNotEmpty &&
        memberUids.length == 2 &&
        memberUids.contains(IbUtils.getCurrentUid())) {
      final List<String> tempArr = [];
      tempArr.addAll(memberUids);
      tempArr.remove(IbUtils.getCurrentUid());
      ibUser = controller.ibUserMap[tempArr.first];
      title = controller.ibUserMap[tempArr.first]!.username.toString();
      avatarUrl = controller.ibUserMap[tempArr.first]!.avatarUrl.toString();
    } else {
      // handle group chat info here
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTabItem &&
          runtimeType == other.runtimeType &&
          chatRoomId == other.chatRoomId;

  @override
  int get hashCode => chatRoomId.hashCode;
}
