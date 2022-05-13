import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/backend/services/user_services/icebreaker_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../frontend/ib_widgets/ib_card.dart';
import '../../../frontend/ib_widgets/ib_user_avatar.dart';
import '../../models/ib_question.dart';
import '../../models/icebreaker_models/icebreaker.dart';

class ChatPageController extends GetxController {
  IbChat? ibChat;
  final String recipientId;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final isCircle = false.obs;
  final isPublicCircle = false.obs;
  final showNewMsgAlert = false.obs;
  final showOptions = false.obs;
  final messages = <IbMessageModel>[].obs;

  /// for media previewer of input widget
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
  final IbMessageModel loadMessage = IbMessageModel(
      ibMessage: IbMessage(
          messageId: '',
          readUids: [],
          content: 'content',
          senderUid: '',
          messageType: IbMessage.kMessageTypeLoadMore,
          chatRoomId: ''));
  @override
  Future<void> onInit() async {
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener.itemPositions.value
          .map((e) => e.index)
          .toList()
          .contains(0)) {
        showNewMsgAlert.value = false;
      }
    });

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

  List<String> _generateMentionIds() {
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
    return uids.toSet().toList();
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
  Future<void> onClose() async {
    if (_messageSub != null) {
      await _messageSub!.cancel();
    }

    if (_memberSub != null) {
      await _memberSub!.cancel();
    }

    if (_chatSub != null) {
      await _chatSub!.cancel();
    }

    await IbChatDbService().removeTypingUid(chatId: ibChat!.chatId);
    super.onClose();
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

  void showWelcomeMsg() {
    final leader = ibChatMembers.firstWhereOrNull(
        (element) => element.member.role == IbChatMember.kRoleLeader);

    if (ibChat != null &&
        ibChat!.welcomeMsg.isNotEmpty &&
        leader != null &&
        ibChat!.isCircle &&
        Get.context != null &&
        !IbLocalDataService().retrieveCustomBoolValue(ibChat!.chatId)) {
      final Widget dialog = Stack(
        alignment: AlignmentDirectional.topCenter,
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: Get.width * 0.8,
            child: IbCard(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    'Glad to have you!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kPageTitleSize),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    ibChat!.welcomeMsg,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: IbElevatedButton(
                        textTrKey: 'Enter Circle',
                        onPressed: () {
                          Get.back();
                        },
                        color: IbColors.primaryColor),
                  )
                ],
              ),
            )),
          ),
          Positioned(
            top: -24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(Get.context!).backgroundColor,
                            width: 3),
                        color: Theme.of(Get.context!).backgroundColor,
                        shape: BoxShape.circle),
                    child: IbUserAvatar(
                      avatarUrl: leader.user.avatarUrl,
                      radius: 48,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    leader.user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    leader.member.role,
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize),
                  ),
                )
              ],
            ),
          ),
        ],
      );
      Get.dialog(
          Center(
            child: Material(
              color: Colors.transparent,
              child: dialog,
            ),
          ),
          barrierDismissible: true);
      IbLocalDataService()
          .updateCustomBoolValue(key: ibChat!.chatId, value: true);
    }
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
          messages.insert(0, await _handleOnMessageAdd(ibMessage));

          /// show new message available
          if (!itemPositionsListener.itemPositions.value
                  .map((e) => e.index)
                  .toList()
                  .contains(0) &&
              isLoading.isFalse &&
              ibMessage.senderUid != IbUtils.getCurrentUid()) {
            showNewMsgAlert.value = true;
          }
        } else if (docChange.type == DocumentChangeType.modified) {
          final int index = messages.indexWhere(
              (element) => element.ibMessage.messageId == ibMessage.messageId);
          if (index != -1) {
            messages[index].ibMessage = ibMessage;
          }
        } else {
          final int index = messages.indexWhere(
              (element) => element.ibMessage.messageId == ibMessage.messageId);
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
          messages.first.ibMessage.senderUid != IbUtils.getCurrentUid() &&
          !messages.first.ibMessage.readUids
              .contains(IbUtils.getCurrentUid())) {
        final IbMessage lastMessage = messages.first.ibMessage;
        await IbChatDbService().updateReadUidArray(
            chatRoomId: ibChat!.chatId, messageId: lastMessage.messageId);
      }
      messages.refresh();

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
      showWelcomeMsg();
      setUpTypingUsers();
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

  Future<IbMessageModel> _handleOnMessageAdd(IbMessage ibMessage) async {
    /// store poll message in ibQuestions list
    if (ibMessage.messageType == IbMessage.kMessageTypePoll) {
      final ibQuestion =
          await IbQuestionDbService().querySingleQuestion(ibMessage.content);

      return IbMessageModel(ibMessage: ibMessage, ibQuestion: ibQuestion);
    }

    /// store icebreaker message in icebreaker list
    if (ibMessage.messageType == IbMessage.kMessageTypeIcebreaker) {
      if (ibMessage.extra.isEmpty) {
        return IbMessageModel(ibMessage: ibMessage);
      }

      final ibCollection =
          IbCacheManager().retrieveIbCollection(ibMessage.extra.first);

      if (ibCollection != null) {
        Icebreaker? icebreaker = IbCacheManager()
            .retrieveIbCollection(ibMessage.extra.first)!
            .icebreakers
            .firstWhereOrNull((element) => element.id == ibMessage.content);
        icebreaker ??= IbCacheManager().retrieveIcebreaker(
            collectionId: ibCollection.id, icebreakerId: ibMessage.content);

        return IbMessageModel(
            ibMessage: ibMessage,
            icebreaker: icebreaker,
            ibCollection:
                IbCacheManager().retrieveIbCollection(ibMessage.extra.first));
      }

      final collection =
          await IcebreakerDbService().queryIbCollection(ibMessage.extra.first);
      if (collection == null) {
        return IbMessageModel(ibMessage: ibMessage);
      } else {
        Icebreaker? icebreaker = collection.icebreakers
            .firstWhereOrNull((element) => element.id == ibMessage.content);
        icebreaker ??= IbCacheManager().retrieveIcebreaker(
            collectionId: collection.id, icebreakerId: ibMessage.content);
        return IbMessageModel(
            ibMessage: ibMessage,
            icebreaker: icebreaker,
            ibCollection: ibCollection);
      }
    }
    return IbMessageModel(ibMessage: ibMessage);
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
        _generateMentionIds();
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
        mentionUids: _generateMentionIds(),
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
            id: IbUtils.getUniqueId(),
            type: IbNotification.kCircleInvite,
            timestamp: FieldValue.serverTimestamp(),
            senderId: IbUtils.getCurrentUid()!,
            recipientId: user.id,
            url: ibChat!.chatId,
            body: '');
        final bool isSent = await IbUserDbService()
            .isCircleInviteSent(chatId: ibChat!.chatId, recipientId: user.id);
        if (isSent) {
          print('invite already sent');
          continue;
        }
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

      final List<IbMessageModel> tempList = [];

      for (final doc in snapshot.docs) {
        final IbMessage message = IbMessage.fromJson(doc.data());
        if (messages.indexWhere((element) =>
                element.ibMessage.messageId == message.messageId) ==
            -1) {
          continue;
        }
        tempList.add(await _handleOnMessageAdd(message));
      }
      messages.remove(loadMessage);
      messages.addAll(tempList);
      if (snapshot.docs.isNotEmpty) {
        lastSnap = snapshot.docs.last;
      } else {
        lastSnap = null;
      }
    }
    isLoadingMore.value = false;
  }

  Future<void> blockUser(String uid) async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      final SocialTabController _controller = Get.find();
      await IbUserDbService().blockFriend(uid);
      final item = _controller.oneToOneChats.firstWhereOrNull(
          (element) => element.ibChat.chatId == ibChat!.chatId);
      if (item != null) {
        item.isBlocked = true;
      }
      _controller.oneToOneChats.refresh();
      IbUtils.showSimpleSnackBar(
          msg: 'User blocked!', backgroundColor: IbColors.errorRed);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Block user failed $e', backgroundColor: IbColors.errorRed);
    }
  }

  Future<void> unblockUser(String uid) async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      final SocialTabController _controller = Get.find();
      await IbUserDbService().unblockFriend(uid);
      final item = _controller.oneToOneChats.firstWhereOrNull(
          (element) => element.ibChat.chatId == ibChat!.chatId);
      if (item != null) {
        item.isBlocked = false;
      }
      _controller.oneToOneChats.refresh();
      IbUtils.showSimpleSnackBar(
          msg: 'User unblocked!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Unblock user failed $e', backgroundColor: IbColors.errorRed);
    }
  }
}

class IbMessageModel {
  IbMessage ibMessage;
  Icebreaker? icebreaker;
  IbQuestion? ibQuestion;
  IbCollection? ibCollection;

  IbMessageModel(
      {required this.ibMessage,
      this.icebreaker,
      this.ibQuestion,
      this.ibCollection});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbMessageModel &&
          runtimeType == other.runtimeType &&
          ibMessage.messageId == other.ibMessage.messageId;

  @override
  int get hashCode => ibMessage.messageId.hashCode;
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
