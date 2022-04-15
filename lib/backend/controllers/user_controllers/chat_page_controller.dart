import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../frontend/ib_widgets/ib_card.dart';
import '../../../frontend/ib_widgets/ib_user_avatar.dart';

class ChatPageController extends GetxController {
  IbChat? ibChat;
  final String recipientId;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isCircle = false.obs;
  final isPublicCircle = false.obs;
  final showOptions = false.obs;
  final messages = <IbMessage>[].obs;
  final urls = <String>[].obs;
  final avatarUrl = ''.obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  StreamSubscription? _messageSub;
  StreamSubscription? _memberSub;
  StreamSubscription? _chatSub;
  final isSending = false.obs;
  final isMuted = false.obs;
  final int kQueryLimit = 16;
  DocumentSnapshot<Map<String, dynamic>>? lastSnap;
  final txtController = TextEditingController();
  final TextEditingController titleTxtController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController welcomeMsgController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final RefreshController refreshController = RefreshController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ibChatMembers = <IbChatMemberModel>[].obs;
  final isTypingUsers = <IbUser>[].obs;
  final isTyping = false.obs;
  final text = ''.obs;

  ChatPageController({this.ibChat, this.recipientId = ''});
  final IbMessage loadMessage = IbMessage(
      messageId: '',
      content: 'content',
      senderUid: '',
      messageType: IbMessage.kMessageTypeLoadMore,
      chatRoomId: '');
  @override
  Future<void> onInit() async {
    await initData();

    // remove typing after 8s
    debounce(text, (value) async {
      await IbChatDbService().removeTypingUid(chatId: ibChat!.chatId);
      isTyping.value = false;
    }, time: const Duration(seconds: 8));

    txtController.addListener(() async {
      if (text.value == txtController.text) {
        return;
      }
      //detect @
      if (txtController.text.endsWith('@') &&
          txtController.text.length > text.value.length) {
        if (txtController.text.length > 1 &&
            txtController.text
                .split('')[txtController.text.length - 2]
                .isAlphabetOnly) {
          return;
        }
        showMentionList();
      }
      text.value = txtController.text;
      if (ibChat != null &&
          txtController.text.trim().isNotEmpty &&
          isTyping.isFalse) {
        isTyping.value = true;
        await IbChatDbService().addTypingUid(chatId: ibChat!.chatId);
      } else if (ibChat != null && txtController.text.isEmpty) {
        isTyping.value = false;
        await IbChatDbService().removeTypingUid(chatId: ibChat!.chatId);
      }
    });
    super.onInit();
  }

  List<String> generateMentionIds() {
    final list = <String>[];
    final uids = <String>[];
    if (isCircle.isFalse) {
      return uids;
    }

    if (txtController.text.trim().contains('@')) {
      String uid = '';
      final strArr = txtController.text.split('');
      for (final c in strArr) {
        if (c == '@') {
          uid = '';
          continue;
        }

        final StringBuffer buffer = StringBuffer(uid);
        buffer.write(c);
        uid = buffer.toString();

        if (c.trim().isEmpty || strArr.indexOf(c) == strArr.length - 1) {
          list.addIf(uid.trim().isNotEmpty, uid.trim());
          uid = '';
          continue;
        }
      }
    }
    //found the match uid of each user
    if (list.isNotEmpty) {
      for (final username in list) {
        final member = ibChatMembers.firstWhereOrNull(
            (element) => element.user.username == username.trim());
        if (member == null) {
          continue;
        }
        uids.add(member.user.id);
      }
    }

    print(uids);

    return uids;
  }

  void showMentionList() {
    if (isCircle.isFalse) {
      return;
    }
    ibChatMembers.sort((a, b) => a.user.username.compareTo(b.user.username));
    final options = IbCard(
        radius: 0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ibChatMembers
                .map((element) => ListTile(
                      onTap: () {
                        Get.back();
                        final text =
                            '${txtController.text}${element.user.username} ';
                        txtController.value = TextEditingValue(
                            text: text,
                            selection: TextSelection(
                                baseOffset: text.length,
                                extentOffset: text.length));
                      },
                      title: Text(element.user.username),
                      leading: IbUserAvatar(
                        avatarUrl: element.user.avatarUrl,
                      ),
                    ))
                .toList(),
          ),
        ));
    Get.dialog(Center(
      child: LimitedBox(maxHeight: 300, child: options),
    ));
  }

  @override
  void onClose() {
    if (_messageSub != null) {
      _messageSub!.cancel();
    }

    if (_memberSub != null) {
      _memberSub!.cancel();
    }

    if (_chatSub != null) {
      _chatSub!.cancel();
    }

    IbChatDbService().removeTypingUid(chatId: ibChat!.chatId).then((value) {
      print('Remove my typingUid');
    });
  }

  Future<void> initData() async {
    if (ibChat == null && recipientId.isEmpty) {
      return;
    }

    if (recipientId.isNotEmpty && ibChat == null) {
      print('ChatPageController looking for IbChat');
      ibChat = await IbChatDbService().queryOneToOneIbChat(recipientId);
    }
    setUpStreams();
    setUpInfo();
  }

  void setUpStreams() {
    if (ibChat == null) {
      isLoading.value = false;
      return;
    }

    ///loading messages from stream
    _messageSub = IbChatDbService()
        .listenToMessageChanges(ibChat!.chatId)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbMessage ibMessage = IbMessage.fromJson(docChange.doc.data()!);
        print('ChatPageController ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          messages.insert(0, ibMessage);
        } else if (docChange.type == DocumentChangeType.modified) {
          final int index = messages.indexOf(ibMessage);
          if (index != -1) {
            messages[index] = ibMessage;
          }
        } else {
          final int index = messages.indexOf(ibMessage);
          if (index != -1) {
            messages.removeAt(index);
          }
        }
      }

      if (event.docs.isNotEmpty) {
        lastSnap = event.docs.first;
      }

      /// update readUids
      if (messages.isNotEmpty &&
          messages.first.senderUid != IbUtils.getCurrentUid() &&
          !messages.first.readUids.contains(IbUtils.getCurrentUid())) {
        final IbMessage lastMessage = messages.first;
        await IbChatDbService().updateReadUidArray(
            chatRoomId: ibChat!.chatId, messageId: lastMessage.messageId);
      }
      isLoading.value = false;
    });

    _memberSub = IbChatDbService()
        .listenToIbMemberChanges(ibChat!.chatId)
        .listen((event) async {
      for (final docChange in event.docChanges) {
        final IbChatMember ibChatMember =
            IbChatMember.fromJson(docChange.doc.data()!);
        print('chat page controller member ${docChange.type}');
        if (docChange.type == DocumentChangeType.added) {
          IbUser? ibUser;
          if (IbCacheManager().getIbUser(ibChatMember.uid) == null) {
            ibUser = await IbUserDbService().queryIbUser(ibChatMember.uid);
          } else {
            ibUser = IbCacheManager().getIbUser(ibChatMember.uid);
          }

          if (ibUser != null) {
            final double compScore = await IbUtils.getCompScore(uid: ibUser.id);
            ibChatMembers.add(IbChatMemberModel(
                member: ibChatMember, user: ibUser, compScore: compScore));
          }
        } else if (docChange.type == DocumentChangeType.modified) {
          final index = ibChatMembers
              .indexWhere((element) => element.member.uid == ibChatMember.uid);
          if (index != -1) {
            final double compScore =
                await IbUtils.getCompScore(uid: ibChatMembers[index].user.id);
            ibChatMembers[index].member = ibChatMember;
            ibChatMembers[index].compScore = compScore;
          }
        } else {
          final index = ibChatMembers
              .indexWhere((element) => element.member.uid == ibChatMember.uid);
          if (index != -1) {
            ibChatMembers.removeAt(index);
          }
        }
      }
      setUpTypingUsers();

      ibChatMembers.sort((a, b) {
        if (a.member.role == IbChatMember.kRoleLeader &&
            (b.member.role == IbChatMember.kRoleAssistant ||
                b.member.role == IbChatMember.kRoleMember)) {
          return -1;
        }

        if ((a.member.role == IbChatMember.kRoleAssistant ||
                a.member.role == IbChatMember.kRoleMember) &&
            b.member.role == IbChatMember.kRoleLeader) {
          return 1;
        }

        if (a.member.role == IbChatMember.kRoleAssistant &&
            b.member.role == IbChatMember.kRoleMember) {
          print(3);
          return -1;
        }

        if (b.member.role == IbChatMember.kRoleAssistant &&
            a.member.role == IbChatMember.kRoleMember) {
          return 1;
        }

        return a.user.username.compareTo(b.user.username);
      });
      ibChatMembers.refresh();
    });

    _chatSub =
        IbChatDbService().listenToIbChatChanges(ibChat!.chatId).listen((event) {
      if (event.data() != null) {
        ibChat = IbChat.fromJson(event.data()!);
        setUpTypingUsers();
      }

      /// only update if is group chat
      if (ibChat!.isCircle) {
        title.value = ibChat!.name;
        avatarUrl.value = ibChat!.photoUrl;
      }
    });
  }

  void setUpTypingUsers() {
    isTypingUsers.clear();
    if (ibChat != null) {
      for (final String uid in ibChat!.isTypingUids) {
        if (uid == IbUtils.getCurrentUid()) {
          continue;
        }
        final item =
            ibChatMembers.firstWhereOrNull((element) => element.user.id == uid);
        isTypingUsers.addIf(item != null, item!.user);
      }
    }
  }

  void setUpInfo() {
    if (ibChat != null) {
      if (title.value.isEmpty) {
        title.value = ibChat!.name;
      }

      if (avatarUrl.value.isEmpty) {
        avatarUrl.value = ibChat!.photoUrl;
      }

      isMuted.value = ibChat!.mutedUids.contains(IbUtils.getCurrentUid());
      isCircle.value = ibChat!.isCircle;
      isPublicCircle.value = ibChat!.isPublicCircle;
    }
  }

  Future<void> sendMessage() async {
    if (txtController.text.trim().isEmpty && urls.isEmpty) {
      return;
    }
    isSending.value = true;
    if (ibChat == null) {
      if (recipientId.isNotEmpty) {
        print('ChatPageController looking for IbChat');
        ibChat = await IbChatDbService().queryOneToOneIbChat(recipientId);
      }

      if (ibChat != null) {
        setUpStreams();
        setUpInfo();
      } else {
        try {
          print('ChatPageController creating new IbChat');
          final List<String> sortedArr = [
            IbUtils.getCurrentUid()!,
            recipientId
          ];
          sortedArr.sort();
          ibChat = IbChat(chatId: IbUtils.getUniqueId(), memberUids: sortedArr);
          await IbChatDbService().addIbChat(ibChat!);
          await IbChatDbService().addChatMember(
              member: IbChatMember(
                  chatId: ibChat!.chatId,
                  uid: IbUtils.getCurrentUid()!,
                  role: IbChatMember.kRoleLeader));
          await IbChatDbService().addChatMember(
              member: IbChatMember(
                  chatId: ibChat!.chatId,
                  uid: recipientId,
                  role: IbChatMember.kRoleMember));
          setUpStreams();
          setUpInfo();
        } catch (e) {
          IbUtils.showSimpleSnackBar(
              msg: 'Failed to create chat room $e',
              backgroundColor: IbColors.errorRed);
        }
      }
    }
    if (ibChatMembers.length == 2 && isCircle.isFalse) {
      final item = ibChatMembers.firstWhereOrNull(
          (element) => element.user.id != IbUtils.getCurrentUid());
      if (item != null) {
        final IbUser? user = await IbUserDbService().queryIbUser(item.user.id);
        if (user != null) {
          item.user = user;
          ibChatMembers.refresh();

          if (user.blockedFriendUids.contains(IbUtils.getCurrentUid())) {
            IbUtils.showSimpleSnackBar(
                msg: 'Sending message failed, message is blocked',
                backgroundColor: IbColors.errorRed);
            isSending.value = false;
            return;
          }
        }
      }
    }

    try {
      if (urls.isNotEmpty) {
        for (final String url in urls.toSet()) {
          await IbChatDbService().uploadMessage(buildImgMessage(url));
        }
        urls.clear();
      }

      if (txtController.text.trim().isNotEmpty) {
        await IbChatDbService().uploadMessage(buildTxtMessage());
        generateMentionIds();
        txtController.clear();
      }
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to send message $e", backgroundColor: IbColors.errorRed);
    } finally {
      isSending.value = false;
      await IbChatDbService().removeTypingUid(chatId: ibChat!.chatId);
    }
  }

  Future<void> removeFromCircle(IbChatMemberModel model) async {
    Get.dialog(
      IbDialog(
        title: 'Are you sure to remove ${model.user.username} from the circle?',
        subtitle: '',
        onPositiveTap: () async {
          Get.back();
          try {
            await IbChatDbService().removeChatMember(member: model.member);
            await IbChatDbService().uploadMessage(IbMessage(
                messageId: IbUtils.getUniqueId(),
                content:
                    '${IbUtils.getCurrentIbUser()!.username} removed ${model.user.username} from the circle',
                messageType: IbMessage.kMessageTypeAnnouncement,
                readUids: [IbUtils.getCurrentUid()!],
                senderUid: IbUtils.getCurrentUid()!,
                chatRoomId: ibChat!.chatId));
          } catch (e) {
            Get.dialog(IbDialog(
              title: 'Error',
              subtitle: e.toString(),
              showNegativeBtn: false,
            ));
          }
          ibChatMembers.refresh();
          IbUtils.showSimpleSnackBar(
              msg: 'Member Removed', backgroundColor: IbColors.primaryColor);
        },
      ),
    );
  }

  Future<void> transferLeadership(IbChatMemberModel model) async {
    final mChatModel = ibChatMembers.firstWhereOrNull(
        (element) => element.user.id == IbUtils.getCurrentUid()!);
    Get.dialog(
      IbDialog(
        title:
            'Are you sure to transfer your leadership to ${model.user.username}?',
        subtitle: '',
        onPositiveTap: () async {
          Get.back();
          try {
            if (mChatModel != null) {
              mChatModel.member.role = IbChatMember.kRoleAssistant;
              await IbChatDbService()
                  .updateChatMember(member: mChatModel.member);
            }

            model.member.role = IbChatMember.kRoleLeader;
            await IbChatDbService().updateChatMember(member: model.member);
            await IbChatDbService().uploadMessage(IbMessage(
                messageId: IbUtils.getUniqueId(),
                content: '${model.user.username} is now the new circle leader',
                messageType: IbMessage.kMessageTypeAnnouncement,
                senderUid: IbUtils.getCurrentUid()!,
                readUids: [IbUtils.getCurrentUid()!],
                chatRoomId: ibChat!.chatId));
          } catch (e) {
            Get.dialog(IbDialog(
              title: 'Error',
              subtitle: e.toString(),
              showNegativeBtn: false,
            ));
          }
          ibChatMembers.refresh();
          IbUtils.showSimpleSnackBar(
              msg: 'Leadership Transferred',
              backgroundColor: IbColors.accentColor);
        },
      ),
    );
  }

  Future<void> promoteToAssistant(IbChatMemberModel model) async {
    try {
      model.member.role = IbChatMember.kRoleAssistant;
      await IbChatDbService().updateChatMember(member: model.member);
      await IbChatDbService().uploadMessage(IbMessage(
          messageId: IbUtils.getUniqueId(),
          readUids: [IbUtils.getCurrentUid()!],
          content:
              '${model.user.username} is promoted to be a circle assistant',
          messageType: IbMessage.kMessageTypeAnnouncement,
          senderUid: IbUtils.getCurrentUid()!,
          chatRoomId: ibChat!.chatId));
    } catch (e) {
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
    ibChatMembers.refresh();
    IbUtils.showSimpleSnackBar(
        msg: 'Member Promoted', backgroundColor: IbColors.accentColor);
  }

  Future<void> demoteToMember(IbChatMemberModel model) async {
    try {
      model.member.role = IbChatMember.kRoleMember;
      await IbChatDbService().updateChatMember(member: model.member);
    } catch (e) {
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
    ibChatMembers.refresh();
    IbUtils.showSimpleSnackBar(
        msg: 'Member Demoted', backgroundColor: IbColors.primaryColor);
  }

  Future<void> leaveChat() async {
    try {
      if (!ibChat!.isCircle && ibChatMembers.length <= 2) {
        Get.dialog(
          IbDialog(
            title: 'Are you sure to leave this chat?',
            subtitle: 'All messages and medias will be deleted',
            onPositiveTap: () async {
              Get.back();
              Get.dialog(const IbLoadingDialog(messageTrKey: 'Deleting...'));
              await IbChatDbService().leaveChatRoom(ibChat!.chatId);
              Get.back(closeOverlays: true);
              Get.back();
            },
          ),
        );
      } else {
        final chatMember = ibChatMembers.firstWhereOrNull(
            (element) => element.member.uid == IbUtils.getCurrentUid()!);
        if (chatMember == null) {
          return;
        }

        if (chatMember.member.role == IbChatMember.kRoleLeader &&
            ibChatMembers.length >= 2) {
          Get.dialog(const IbDialog(
              title: 'Info',
              showNegativeBtn: false,
              subtitle:
                  'You need to transfer your leadership before leaving the circle'));
          return;
        }

        Get.dialog(
          IbDialog(
            title: 'Are you sure to leave this circle?',
            subtitle: '',
            onPositiveTap: () async {
              Get.back();
              Get.dialog(const IbLoadingDialog(messageTrKey: 'Leaving...'));
              if (ibChatMembers.length == 1) {
                await IbChatDbService().leaveChatRoom(ibChat!.chatId);
                print('delete everything');
              } else {
                await IbChatDbService()
                    .removeChatMember(member: chatMember.member);
                await IbChatDbService().uploadMessage(IbMessage(
                    messageId: IbUtils.getUniqueId(),
                    readUids: [IbUtils.getCurrentUid()!],
                    content: '${chatMember.user.username} left the circle',
                    senderUid: IbUtils.getCurrentUid()!,
                    messageType: IbMessage.kMessageTypeAnnouncement,
                    chatRoomId: ibChat!.chatId));
              }
              Get.back(closeOverlays: true);
              Get.back();
            },
          ),
        );
      }
    } catch (e) {
      Get.back(closeOverlays: true);
      Get.dialog(IbDialog(title: 'Error', subtitle: e.toString()));
    }
  }

  Future<void> muteNotification() async {
    isMuted.value = true;
    await IbChatDbService().muteNotification(ibChat!);
    IbUtils.showSimpleSnackBar(
        msg: "Notification OFF", backgroundColor: IbColors.primaryColor);
  }

  Future<void> unMuteNotification() async {
    isMuted.value = false;
    await IbChatDbService().unMuteNotification(ibChat!);
    IbUtils.showSimpleSnackBar(
        msg: "Notification ON", backgroundColor: IbColors.primaryColor);
  }

  IbMessage buildTxtMessage() {
    return IbMessage(
        messageId: IbUtils.getUniqueId(),
        content: txtController.text.trim(),
        senderUid: IbUtils.getCurrentUid()!,
        readUids: [IbUtils.getCurrentUid()!],
        messageType: IbMessage.kMessageTypeText,
        mentionUids: generateMentionIds(),
        chatRoomId: ibChat!.chatId);
  }

  IbMessage buildImgMessage(String url) {
    return IbMessage(
        messageId: IbUtils.getUniqueId(),
        content: url,
        senderUid: IbUtils.getCurrentUid()!,
        readUids: [IbUtils.getCurrentUid()!],
        messageType: IbMessage.kMessageTypePic,
        chatRoomId: ibChat!.chatId);
  }

  Future<void> sendCircleInvites(List<IbUser> users) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'Sending invites....'));
    try {
      for (final IbUser user in users) {
        final n = IbNotification(
            id: ibChat!.chatId,
            title: 'Group invite from ${IbUtils.getCurrentIbUser()!.username}',
            subtitle: '',
            type: IbNotification.kGroupInvite,
            timestampInMs: DateTime.now().millisecondsSinceEpoch,
            senderId: IbUtils.getCurrentUid()!,
            recipientId: user.id,
            avatarUrl: IbUtils.getCurrentIbUser()!.avatarUrl);
        await IbUserDbService().sendAlertNotification(n);
      }
      Get.back();
      IbUtils.showSimpleSnackBar(
          msg: 'Invite(s) sent', backgroundColor: IbColors.accentColor);
    } catch (e) {
      Get.back();
      Get.dialog(
        IbDialog(
          title: 'Error',
          subtitle: e.toString(),
          showNegativeBtn: false,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.isTrue || lastSnap == null) {
      return;
    }
    if (lastSnap != null) {
      isLoadingMore.value = true;
      messages.add(loadMessage);
      final snapshot = await Future.delayed(
          const Duration(milliseconds: 1000),
          () => IbChatDbService().queryMessages(
              chatRoomId: ibChat!.chatId,
              snapshot: lastSnap!,
              limit: kQueryLimit));

      final List<IbMessage> tempList = [];

      for (final doc in snapshot.docs) {
        final IbMessage message = IbMessage.fromJson(doc.data());
        if (!messages.contains(message)) {
          tempList.add(IbMessage.fromJson(doc.data()));
        }
      }
      messages.remove(loadMessage);
      messages.addAll(tempList);

      lastSnap = tempList.length >= kQueryLimit ? snapshot.docs.last : null;
    }
    isLoadingMore.value = false;
  }
}

class IbChatMemberModel {
  IbChatMember member;
  IbUser user;
  double compScore;

  IbChatMemberModel(
      {required this.member, required this.user, required this.compScore});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbChatMemberModel &&
          runtimeType == other.runtimeType &&
          member == other.member;

  @override
  int get hashCode => member.hashCode;
}
