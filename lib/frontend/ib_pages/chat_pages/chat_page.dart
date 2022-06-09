import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_settings_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page_settings.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_settings.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/icebreaker_main_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_rich_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:icebr8k/frontend/ib_widgets/icebreaker_card.dart';
import 'package:lottie/lottie.dart';
import 'package:reorderables/reorderables.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../backend/controllers/user_controllers/chat_page_controller.dart';
import '../../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../../../backend/controllers/user_controllers/icebreaker_controller.dart';
import '../../../backend/models/ib_question.dart';
import '../ib_tenor_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (widget._controller.messageSub != null) {
          widget._controller.messageSub!.resume();
        }

        if (widget._controller.memberSub != null) {
          widget._controller.memberSub!.resume();
        }

        if (widget._controller.chatSub != null) {
          widget._controller.chatSub!.resume();
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        if (widget._controller.messageSub != null) {
          widget._controller.messageSub!.pause();
        }

        if (widget._controller.memberSub != null) {
          widget._controller.memberSub!.pause();
        }

        if (widget._controller.chatSub != null) {
          widget._controller.chatSub!.pause();
        }
        if (widget._controller.ibChat != null) {
          await IbChatDbService()
              .removeTypingUid(chatId: widget._controller.ibChat!.chatId);
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leadingWidth: 40,
        title: Obx(
          () => SizedBox(
            width: Get.width * 0.6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget._controller.avatarUrl.isEmpty &&
                    widget._controller.isCircle.isFalse)
                  _buildAvatar(
                      context: context,
                      avatarUsers: widget._controller.ibChatMembers
                          .map((element) => element.user)
                          .toList())
                else if (widget._controller.ibChat != null &&
                    widget._controller.isCircle.isTrue)
                  _buildCircleAvatar(
                      context: context, ibChat: widget._controller.ibChat!)
                else
                  IbUserAvatar(
                    avatarUrl: widget._controller.avatarUrl.value,
                    radius: 16,
                  ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          if (widget._controller.isCircle.isTrue &&
                              widget._controller.ibChat != null) {
                            final currentMember = widget
                                ._controller.ibChatMembers
                                .firstWhereOrNull((element) =>
                                    element.user.id == IbUtils.getCurrentUid());
                            final isAbleToEdit = currentMember != null &&
                                currentMember.member.role !=
                                    IbChatMember.kRoleMember;
                            Get.to(() => CircleSettings(Get.put(
                                CircleSettingsController(
                                    ibChat: widget._controller.ibChat,
                                    isAbleToEdit: isAbleToEdit))));
                          }
                        },
                        child: _buildTitle())),
              ],
            ),
          ),
        ),
        actions: [
          Obx(
            () => widget._controller.showSettings.isTrue
                ? IconButton(
                    onPressed: () async {
                      if (widget._controller.isMuted.isTrue) {
                        await widget._controller.unMuteNotification();
                      } else {
                        await widget._controller.muteNotification();
                      }
                    },
                    icon: Icon(widget._controller.isMuted.isTrue
                        ? Icons.notifications_off
                        : Icons.notifications_on))
                : const SizedBox(),
          ),
          Obx(() => widget._controller.showSettings.isTrue
              ? IconButton(
                  onPressed: () {
                    Get.to(() => ChatPageSettings(widget._controller));
                  },
                  icon: const Icon(Icons.more_vert))
              : const SizedBox()),
        ],
      ),
      body: Obx(
        () {
          if (widget._controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }
          return AnimatedSize(
            duration: const Duration(
                milliseconds: IbConfig.kEventTriggerDelayInMillis),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => IbUtils.hideKeyboard(),
                        child: NotificationListener<ScrollNotification>(
                          child: ScrollablePositionedList.builder(
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            itemScrollController:
                                widget._controller.itemScrollController,
                            itemPositionsListener:
                                widget._controller.itemPositionsListener,
                            itemBuilder: (context, index) {
                              return _handleMessageType(
                                  model: widget._controller.messages[index],
                                  context: context);
                            },
                            itemCount: widget._controller.messages.length,
                          ),
                          onNotification: (info) {
                            if (info.metrics.pixels -
                                    info.metrics.maxScrollExtent >
                                32) {
                              widget._controller.loadMore();
                            }
                            return true;
                          },
                        ),
                      ),
                      Positioned(
                          bottom: 16,
                          right: 16,
                          child: _newMessageAlert(context))
                    ],
                  ),
                ),
                if (widget._controller.isTypingUsers.isNotEmpty)
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: _buildTypingIndicator(context)),
                _inputWidget(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleAvatar(
      {required BuildContext context, required IbChat ibChat}) {
    if (ibChat.photoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: IbColors.lightGrey,
        radius: 16,
        child: Text(
          ibChat.name[0],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).indicatorColor,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          Get.to(() => IbMediaViewer(urls: [ibChat.photoUrl], currentIndex: 0),
              transition: Transition.zoom, fullscreenDialog: true);
        },
        child: IbUserAvatar(
          radius: 16,
          avatarUrl: ibChat.photoUrl,
        ),
      );
    }
  }

  Widget _inputWidget(BuildContext context) {
    return RepaintBoundary(
      child: IbCard(
        radius: 24,
        margin: EdgeInsets.zero,
        color: Theme.of(context).backgroundColor,
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          duration:
              const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _mediaPreviewer(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CircleAvatar(
                          backgroundColor: IbColors.accentColor,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              widget._controller.showMsgOptions.value =
                                  !widget._controller.showMsgOptions.value;
                            },
                            icon: Icon(
                                widget._controller.showMsgOptions.isTrue
                                    ? Icons.remove
                                    : Icons.add,
                                color: Theme.of(context).indicatorColor),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 8,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: IbColors.lightGrey.withOpacity(0.3),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: TextField(
                          scrollPadding: EdgeInsets.zero,
                          minLines: 1,
                          maxLines: 8,
                          maxLength: 2000,
                          controller: widget._controller.txtController,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 4.0),
                            counterText: '',
                            fillColor: IbColors.lightGrey,
                            border: InputBorder.none,
                            hintText: 'Write a message',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: widget._controller.isSending.isTrue
                            ? const CircularProgressIndicator(
                                color: IbColors.primaryColor,
                              )
                            : CircleAvatar(
                                backgroundColor: IbColors.primaryColor,
                                child: IconButton(
                                  onPressed: () async {
                                    await widget._controller.sendMessage();
                                  },
                                  icon: Icon(Icons.send,
                                      color: Theme.of(context).indicatorColor),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget._controller.showMsgOptions.isTrue)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget._controller.ibChat != null)
                        IbActionButton(
                            color: IbColors.primaryColor,
                            iconData: Icons.poll,
                            onPressed: () {
                              widget._controller.showMsgOptions.value = false;

                              final chatTabItem = IbUtils.getAllChatTabItems()
                                  .firstWhereOrNull((element) =>
                                      element.ibChat.chatId ==
                                      widget._controller.ibChat!.chatId);
                              final createQuestionController =
                                  Get.put(CreateQuestionController());

                              if (chatTabItem != null) {
                                createQuestionController.pickedChats
                                    .add(chatTabItem);
                              }

                              Get.to(() => CreateQuestionPage(
                                    controller: createQuestionController,
                                  ));
                            },
                            text: 'Poll'),
                      IbActionButton(
                          color: IbColors.accentColor,
                          iconData: Icons.gif,
                          onPressed: () async {
                            widget._controller.showMsgOptions.value = false;
                            IbUtils.hideKeyboard();
                            final gifUrl = await Get.to(
                              () => IbTenorPage(),
                            );
                            if (gifUrl != null &&
                                gifUrl.toString().isNotEmpty) {
                              widget._controller.urls.add(gifUrl!.toString());
                            }
                          },
                          text: 'GIF'),
                    ],
                  ),
                ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LimitedBox(
        maxWidth: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              children: widget._controller.isTypingUsers
                  .map((element) => element)
                  .toList()
                  .map((element) => Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: IbUserAvatar(
                          avatarUrl: element.avatarUrl,
                          radius: 10,
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(
                height: 30, child: Lottie.asset('assets/images/typing.json'))
          ],
        ),
      ),
    );
  }

  Widget _mediaPreviewer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: ReorderableRow(
        onReorder: (int oldIndex, int newIndex) {
          final url = widget._controller.urls.removeAt(oldIndex);
          widget._controller.urls.insert(newIndex, url);
        },
        buildDraggableFeedback: (context, _, child) {
          return Material(
            color: Colors.transparent,
            child: child,
          );
        },
        children: widget._controller.urls.toSet().map((element) {
          final image = element.contains('http')
              ? Image.network(element, height: 100, fit: BoxFit.fitHeight,
                  errorBuilder: (context, obj, trace) {
                  return Container(
                    height: 100,
                    width: 100,
                    color: IbColors.lightGrey,
                    child: const Text('Failed to load image'),
                  );
                })
              : Image.file(
                  File(
                    element,
                  ),
                  height: 100,
                  fit: BoxFit.fitHeight,
                  errorBuilder: (context, obj, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: IbColors.lightGrey,
                      child: const Center(child: Text('Failed to load image')),
                    );
                  },
                );
          return Padding(
            key: ValueKey(element),
            padding: const EdgeInsets.only(
              top: 16,
              right: 8,
            ),
            child: Stack(
              children: [
                InkWell(
                    onTap: () {
                      Get.to(
                          () => IbMediaViewer(
                              urls: widget._controller.urls,
                              currentIndex:
                                  widget._controller.urls.indexOf(element)),
                          transition: Transition.zoom,
                          fullscreenDialog: true);
                    },
                    child: image),
                Positioned(
                    top: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).backgroundColor,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.remove_circle_outlined,
                          color: IbColors.errorRed,
                          size: 20,
                        ),
                        onPressed: () {
                          widget._controller.urls.remove(element);
                        },
                      ),
                    ))
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _newMessageAlert(BuildContext context) {
    return Obx(() {
      return Wrap(
        children: [
          AnimatedContainer(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            duration: const Duration(milliseconds: 300),
            height: widget._controller.showNewMsgAlert.isTrue ? 49 : 0,
            width: widget._controller.showNewMsgAlert.isTrue ? 123 : 0,
            child: TextButton(
              child: Text(
                'New Message(s) ↓',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).indicatorColor),
              ),
              onPressed: () {
                widget._controller.itemScrollController.jumpTo(index: 0);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _meTextMsgItem(IbMessage message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 40, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.mentionUids.isNotEmpty)
            Text(
              '${message.mentionUids.toSet().length} member(s) mentioned',
              style: const TextStyle(
                  fontSize: IbConfig.kDescriptionTextSize,
                  fontStyle: FontStyle.italic,
                  color: IbColors.lightGrey),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: InkWell(
                  customBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  onLongPress: () {
                    HapticFeedback.heavyImpact();
                    Clipboard.setData(ClipboardData(text: message.content));
                    IbUtils.showSimpleSnackBar(
                        msg: "Text copied to clipboard",
                        backgroundColor: IbColors.primaryColor);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: IbColors.primaryColor.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            topLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IbRichText(
                        highlightColor: Colors.greenAccent,
                        string: message.content,
                        defaultTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: IbConfig.kNormalTextSize),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Text(
            message.timestamp == null
                ? 'Sending...'
                : IbUtils.readableDateTime(
                    DateTime.fromMillisecondsSinceEpoch(
                        (message.timestamp as Timestamp)
                            .millisecondsSinceEpoch),
                    showTime: true),
            style: const TextStyle(
                color: IbColors.lightGrey,
                fontSize: IbConfig.kDescriptionTextSize),
          ),
          _buildReadIndicator(message),
        ],
      ),
    );
  }

  Widget _textMsgItem(IbMessage message) {
    final IbUser? senderUser = widget._controller.ibChatMembers
        .firstWhereOrNull((element) => element.user.id == message.senderUid)
        ?.user;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 40, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IbUserAvatar(
                avatarUrl: senderUser == null ? '' : senderUser.avatarUrl,
                uid: senderUser == null ? '' : senderUser.id,
                radius: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (senderUser != null &&
                        widget._controller.isCircle.isTrue)
                      Text(senderUser.username),
                    if (message.mentionUids.isNotEmpty)
                      Text(
                        '${message.mentionUids.toSet().length} member(s) mentioned',
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            fontStyle: FontStyle.italic,
                            color: IbColors.lightGrey),
                      ),
                    InkWell(
                      customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      onLongPress: () {
                        HapticFeedback.heavyImpact();
                        Clipboard.setData(ClipboardData(text: message.content));
                        IbUtils.showSimpleSnackBar(
                            msg: "Text copied to clipboard",
                            backgroundColor: IbColors.primaryColor);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: IbColors.accentColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IbRichText(
                            string: message.content,
                            defaultTextStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.timestamp == null
                      ? 'Sending...'
                      : IbUtils.readableDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              (message.timestamp as Timestamp)
                                  .millisecondsSinceEpoch),
                          showTime: true),
                  style: const TextStyle(
                      color: IbColors.lightGrey,
                      fontSize: IbConfig.kDescriptionTextSize),
                ),
                _buildReadIndicator(message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meImgMsgItem(IbMessage message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 40, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                topLeft: Radius.circular(16),
                bottomRight: Radius.circular(16)),
            child: InkWell(
              onTap: () {
                Get.to(
                    () =>
                        IbMediaViewer(urls: [message.content], currentIndex: 0),
                    transition: Transition.zoom,
                    fullscreenDialog: true);
              },
              child: Image.network(
                message.content,
                height: 150,
                fit: BoxFit.fitHeight,
                loadingBuilder: (context, child, event) {
                  if (event == null) return child;
                  return const SizedBox(
                    height: 120,
                    child: IbProgressIndicator(),
                  );
                },
                errorBuilder: (context, obj, trace) {
                  return Container(
                    height: 150,
                    width: 150,
                    color: IbColors.lightGrey,
                    child: const Text('Failed to load image'),
                  );
                },
              ),
            ),
          ),
          Text(
            message.timestamp == null
                ? 'Sending...'
                : IbUtils.readableDateTime(
                    DateTime.fromMillisecondsSinceEpoch(
                        (message.timestamp as Timestamp)
                            .millisecondsSinceEpoch),
                    showTime: true),
            style: const TextStyle(
                color: IbColors.lightGrey,
                fontSize: IbConfig.kDescriptionTextSize),
          ),
          _buildReadIndicator(message),
        ],
      ),
    );
  }

  Widget _imgMsgItem(IbMessage message) {
    final IbUser? senderUser = widget._controller.ibChatMembers
        .firstWhereOrNull((element) => element.user.id == message.senderUid)
        ?.user;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 40, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              IbUserAvatar(
                avatarUrl: senderUser == null ? '' : senderUser.avatarUrl,
                uid: senderUser == null ? '' : senderUser.id,
                radius: 16,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (senderUser != null &&
                        widget._controller.isCircle.isTrue)
                      Text(senderUser.username),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16)),
                      child: InkWell(
                        onTap: () {
                          Get.to(
                              () => IbMediaViewer(
                                  urls: [message.content], currentIndex: 0),
                              transition: Transition.zoom,
                              fullscreenDialog: true);
                        },
                        child: Image.network(
                          message.content,
                          height: 150,
                          fit: BoxFit.fitHeight,
                          errorBuilder: (context, obj, trace) {
                            return Container(
                              height: 150,
                              width: 150,
                              color: IbColors.lightGrey,
                              child: const Text('Failed to load image'),
                            );
                          },
                          loadingBuilder: (context, child, event) {
                            if (event == null) return child;
                            return const SizedBox(
                              height: 150,
                              child: IbProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.timestamp == null
                      ? 'Sending...'
                      : IbUtils.readableDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              (message.timestamp as Timestamp)
                                  .millisecondsSinceEpoch),
                          showTime: true),
                  style: const TextStyle(
                      color: IbColors.lightGrey,
                      fontSize: IbConfig.kDescriptionTextSize),
                ),
                _buildReadIndicator(message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pollMsgItem(
      {required IbMessageModel model, required BuildContext context}) {
    if (model.ibMessage.messageType == IbMessage.kMessageTypePoll) {
      final IbQuestion? question = model.ibQuestion;
      final IbMessage message = model.ibMessage;
      final member = widget._controller.ibChatMembers
          .firstWhereOrNull((p0) => p0.user.id == message.senderUid);
      final avatarUrl = member == null ? '' : member.user.avatarUrl;
      final username = member == null ? '' : member.user.username;

      if (question == null) {
        return Column(
          children: [
            const SizedBox(
              height: 16,
            ),

            /// title
            Text(
              message.timestamp == null
                  ? 'Posting...'
                  : IbUtils.readableDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          (message.timestamp as Timestamp)
                              .millisecondsSinceEpoch),
                      showTime: true),
              style: const TextStyle(
                  color: IbColors.lightGrey,
                  fontSize: IbConfig.kDescriptionTextSize),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IbUserAvatar(
                  avatarUrl: avatarUrl,
                  radius: 11,
                ),
                Text(' $username shared a poll')
              ],
            ),
            const IbCard(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('This poll is no longer available'),
            ))
          ],
        );
      }

      Widget pollWidget = const SizedBox();
      final IbQuestionItemController itemController = Get.put(
          IbQuestionItemController(
              rxIsSample: false.obs,
              isShowCase: false.obs,
              rxIbQuestion: question.obs,
              rxIsExpanded: false.obs),
          tag: question.id);

      if (question.questionType == QuestionType.multipleChoice ||
          question.questionType == QuestionType.multipleChoicePic) {
        pollWidget = IbMcQuestionCard(itemController);
      } else {
        pollWidget = IbScQuestionCard(itemController);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 16,
          ),

          /// title
          Text(
            message.timestamp == null
                ? 'Sending...'
                : IbUtils.readableDateTime(
                    DateTime.fromMillisecondsSinceEpoch(
                        (message.timestamp as Timestamp)
                            .millisecondsSinceEpoch),
                    showTime: true),
            style: const TextStyle(
                color: IbColors.lightGrey,
                fontSize: IbConfig.kDescriptionTextSize),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IbUserAvatar(
                avatarUrl: avatarUrl,
                radius: 11,
              ),
              Text(' $username shared a poll')
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: pollWidget,
          ),
          Align(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildReadIndicator(message),
          )),
          const SizedBox(
            height: 8,
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _icebreakerMsgItem(
      {required IbMessageModel model, required BuildContext context}) {
    if (model.ibMessage.messageType == IbMessage.kMessageTypeIcebreaker) {
      final icebreaker = model.icebreaker;
      final message = model.ibMessage;
      final member = widget._controller.ibChatMembers
          .firstWhereOrNull((p0) => p0.user.id == message.senderUid);
      final avatarUrl = member == null ? '' : member.user.avatarUrl;
      final username = member == null ? '' : member.user.username;

      if (icebreaker == null) {
        return Column(
          children: [
            const SizedBox(
              height: 16,
            ),

            /// title
            Text(
              message.timestamp == null
                  ? 'Posting...'
                  : IbUtils.readableDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                          (message.timestamp as Timestamp)
                              .millisecondsSinceEpoch),
                      showTime: true),
              style: const TextStyle(
                  color: IbColors.lightGrey,
                  fontSize: IbConfig.kDescriptionTextSize),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IbUserAvatar(
                  avatarUrl: avatarUrl,
                  radius: 11,
                ),
                Text(' $username shared an icebreaker')
              ],
            ),
            const IbCard(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('This icebreaker is no longer available'),
            ))
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 16,
          ),

          /// title
          Text(
            message.timestamp == null
                ? 'Sending...'
                : IbUtils.readableDateTime(
                    DateTime.fromMillisecondsSinceEpoch(
                        (message.timestamp as Timestamp)
                            .millisecondsSinceEpoch),
                    showTime: true),
            style: const TextStyle(
                color: IbColors.lightGrey,
                fontSize: IbConfig.kDescriptionTextSize),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IbUserAvatar(
                avatarUrl: avatarUrl,
                radius: 11,
              ),
              Text(' $username shared an icebreaker')
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 32,
              right: 32,
            ),
            child: InkWell(
              onTap: () {
                if (model.ibCollection == null) {
                  print('return');
                  return;
                }
                final controller = Get.put(
                    IcebreakerController(model.ibCollection!, isEdit: false),
                    tag: model.ibCollection!.id);
                controller.currentIndex.value = controller.icebreakers
                    .indexWhere((e) => model.icebreaker!.id == e.id);
                if (controller.currentIndex.value == -1) {
                  return;
                }

                Get.to(() => IcebreakerMainPage(controller));
              },
              child: SizedBox(
                height: 500,
                child: IcebreakerCard(
                  minSize: IbConfig.kDescriptionTextSize,
                  maxSize: IbConfig.kPageTitleSize,
                  icebreaker: icebreaker,
                  ibCollection: model.ibCollection,
                ),
              ),
            ),
          ),
          Align(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildReadIndicator(message),
          )),
          const SizedBox(
            height: 8,
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildAvatar(
      {required BuildContext context, required List<IbUser> avatarUsers}) {
    avatarUsers.removeWhere((element) => element.id == IbUtils.getCurrentUid());
    final list = avatarUsers.take(4).toList();
    final double radius = avatarUsers.length > 1 ? 8 : 16;
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
      minRadius: 16,
      maxRadius: 22,
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: list
            .map((e) => IbUserAvatar(
                  uid: e.id,
                  avatarUrl: e.avatarUrl,
                  radius: radius,
                ))
            .toList(),
      ),
    );
  }

  ///won't show sender and current User's avatar
  Widget _buildReadIndicator(IbMessage message) {
    if (widget._controller.messages.indexWhere(
            (element) => element.ibMessage.messageId == message.messageId) ==
        0) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: message.readUids
                .where((element) =>
                    element != message.senderUid &&
                    element != IbUtils.getCurrentUid())
                .map((e) {
              final IbChatMemberModel? model = widget._controller.ibChatMembers
                  .firstWhereOrNull((item) => item.user.id == e);
              if (model != null) {
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: IbUserAvatar(
                    avatarUrl: model.user.avatarUrl,
                    radius: 8,
                  ),
                );
              }
              return const SizedBox();
            }).toList()),
      );
    }
    return const SizedBox();
  }

  Widget _buildTitle() {
    if (widget._controller.ibChat != null &&
        widget._controller.ibChat!.name.isNotEmpty) {
      return Text(
        widget._controller.title.value,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (widget._controller.title.isEmpty) {
      final avatarUsers = widget._controller.ibChatMembers
          .map((element) => element.user)
          .toList();
      avatarUsers
          .removeWhere((element) => element.id == IbUtils.getCurrentUid());
      for (final user in avatarUsers) {
        widget._controller.title.value =
            '${widget._controller.title.value}${user.username} ';
      }
    }
    return Text(
      widget._controller.title.value,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _handleMessageType(
      {required IbMessageModel model, required BuildContext context}) {
    final message = model.ibMessage;
    final bool isMe = message.senderUid == IbUtils.getCurrentUid();
    if (message.messageType == IbMessage.kMessageTypeText) {
      return isMe ? _meTextMsgItem(message) : _textMsgItem(message);
    }
    if (message.messageType == IbMessage.kMessageTypePic) {
      return isMe ? _meImgMsgItem(message) : _imgMsgItem(message);
    }

    if (message.messageType == IbMessage.kMessageTypeAnnouncement) {
      return Align(
        child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(
                    message.timestamp == null
                        ? 'Sending...'
                        : IbUtils.readableDateTime(
                            DateTime.fromMillisecondsSinceEpoch(
                                (message.timestamp as Timestamp)
                                    .millisecondsSinceEpoch),
                            showTime: true),
                    style: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kDescriptionTextSize),
                  ),
                  Text(
                    message.content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kSecondaryTextSize),
                  ),
                ],
              ),
            )),
      );
    }
    if (message.messageType == IbMessage.kMessageTypeLoadMore) {
      return const Center(
        child: IbProgressIndicator(
          height: 30,
          width: 30,
        ),
      );
    }

    if (message.messageType == IbMessage.kMessageTypePoll) {
      return _pollMsgItem(model: model, context: context);
    }

    if (message.messageType == IbMessage.kMessageTypeIcebreaker) {
      return _icebreakerMsgItem(model: model, context: context);
    }

    return const SizedBox();
  }
}
