import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page_settings.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:reorderables/reorderables.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/controllers/user_controllers/chat_page_controller.dart';
import '../ib_tenor_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;

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
                if (_controller.avatarUrl.isEmpty &&
                    _controller.isCircle.isFalse)
                  _buildAvatar(
                      context: context,
                      avatarUsers: _controller.ibChatMembers
                          .map((element) => element.user)
                          .toList())
                else if (_controller.ibChat != null &&
                    _controller.isCircle.isTrue)
                  _buildCircleAvatar(
                      context: context, ibChat: _controller.ibChat!)
                else
                  IbUserAvatar(
                    avatarUrl: _controller.avatarUrl.value,
                    radius: 16,
                  ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: _buildTitle()),
              ],
            ),
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
                onPressed: () async {
                  if (_controller.isMuted.isTrue) {
                    await _controller.unMuteNotification();
                  } else {
                    await _controller.muteNotification();
                  }
                },
                icon: Icon(_controller.isMuted.isTrue
                    ? Icons.notifications_off
                    : Icons.notifications_on)),
          ),
          IconButton(
              onPressed: () {
                Get.to(() => ChatPageSettings(_controller));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Obx(
        () {
          return GestureDetector(
            onTap: () {
              IbUtils.hideKeyboard();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_controller.isLoading.isTrue)
                  const Expanded(
                    child: Center(
                      child: IbProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                      child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      NotificationListener<ScrollNotification>(
                        child: ScrollablePositionedList.builder(
                          physics: const BouncingScrollPhysics(),
                          reverse: true,
                          itemScrollController:
                              _controller.itemScrollController,
                          itemPositionsListener:
                              _controller.itemPositionsListener,
                          itemBuilder: (context, index) {
                            return _handleMessageType(
                                message: _controller.messages[index],
                                context: context);
                          },
                          itemCount: _controller.messages.length,
                        ),
                        onNotification: (info) {
                          if (info.metrics.pixels -
                                  info.metrics.maxScrollExtent >
                              32) {
                            _controller.loadMore();
                          }
                          return true;
                        },
                      ),
                      _buildTypingIndicator(context),
                    ],
                  )),
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
    return IbCard(
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
            mediaPreviewer(context),
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
                            _controller.showOptions.value =
                                !_controller.showOptions.value;
                          },
                          icon: Icon(
                              _controller.showOptions.isTrue
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
                        onSubmitted: (value) async {
                          if (value.isNotEmpty) {
                            _controller.sendMessage();
                          }
                        },
                        textInputAction: TextInputAction.send,
                        controller: _controller.txtController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
                      child: _controller.isSending.isTrue
                          ? const CircularProgressIndicator(
                              color: IbColors.primaryColor,
                            )
                          : CircleAvatar(
                              backgroundColor: IbColors.primaryColor,
                              child: IconButton(
                                onPressed: () async {
                                  await _controller.sendMessage();
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
            if (_controller.showOptions.isTrue)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IbActionButton(
                        color: IbColors.errorRed,
                        iconData: Icons.mic,
                        onPressed: () {},
                        text: 'Voice'),
                    IbActionButton(
                        color: IbColors.primaryColor,
                        iconData: Icons.image,
                        onPressed: () {
                          _controller.showOptions.value = false;
                          showMediaBtmSheet();
                        },
                        text: 'Images'),
                  ],
                ),
              ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    if (_controller.isTypingUsers.isEmpty) {
      return const SizedBox();
    }

    return IbCard(
        color: Theme.of(context).backgroundColor.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: _controller.isTypingUsers
                    .map((element) => IbUserAvatar(
                          avatarUrl: element.avatarUrl,
                          radius: 10,
                        ))
                    .toList(),
              ),
              SizedBox(
                  height: 30, child: Lottie.asset('assets/images/typing.json'))
            ],
          ),
        ));
  }

  Widget mediaPreviewer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: ReorderableRow(
        onReorder: (int oldIndex, int newIndex) {
          final url = _controller.urls.removeAt(oldIndex);
          _controller.urls.insert(newIndex, url);
        },
        buildDraggableFeedback: (context, _, child) {
          return Material(
            color: Colors.transparent,
            child: child,
          );
        },
        children: _controller.urls.toSet().map((element) {
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
                              urls: _controller.urls,
                              currentIndex: _controller.urls.indexOf(element)),
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
                          _controller.urls.remove(element);
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

  void showMediaBtmSheet() {
    IbUtils.hideKeyboard();
    final options = IbCard(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () async {
            IbUtils.hideKeyboard();
            Get.back();
            final gifUrl = await Get.to(
              () => IbTenorPage(),
            );
            if (gifUrl != null && gifUrl.toString().isNotEmpty) {
              _controller.urls.add(gifUrl!.toString());
            }
          },
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          title: const Text('Choose GIF from Tenor'),
          leading: const Icon(
            Icons.gif,
            color: IbColors.accentColor,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    ));
    Get.bottomSheet(SafeArea(child: options), ignoreSafeArea: false);
  }

  Widget _meTextMsgItem(IbMessage message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 40, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                      child: Linkify(
                        linkStyle: const TextStyle(color: IbColors.creamYellow),
                        options: const LinkifyOptions(looseUrl: true),
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            launch(link.url);
                          }
                        },
                        text: message.content,
                        style: const TextStyle(
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
    final IbUser? senderUser = _controller.ibChatMembers
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
                    if (senderUser != null && _controller.isCircle.isTrue)
                      Text(senderUser.username),
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
                          child: Linkify(
                            options: const LinkifyOptions(looseUrl: true),
                            text: message.content,
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                launch(link.url);
                              }
                            },
                            style: const TextStyle(
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
                height: 120,
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
                    height: 120,
                    width: 120,
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
    final IbUser? senderUser = _controller.ibChatMembers
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
                    if (senderUser != null && _controller.isCircle.isTrue)
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
                          height: 120,
                          fit: BoxFit.fitHeight,
                          errorBuilder: (context, obj, trace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: IbColors.lightGrey,
                              child: const Text('Failed to load image'),
                            );
                          },
                          loadingBuilder: (context, child, event) {
                            if (event == null) return child;
                            return const SizedBox(
                              height: 120,
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
                  avatarUrl: e.avatarUrl,
                  radius: radius,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildReadIndicator(IbMessage message) {
    if (_controller.messages.indexOf(message) == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: message.readUids
                  .where((element) => element != message.senderUid)
                  .map((e) {
                final IbChatMemberModel? model = _controller.ibChatMembers
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
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildTitle() {
    if (_controller.ibChat != null && _controller.ibChat!.name.isNotEmpty) {
      return Text(
        _controller.title.value,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_controller.title.isEmpty) {
      final avatarUsers =
          _controller.ibChatMembers.map((element) => element.user).toList();
      avatarUsers
          .removeWhere((element) => element.id == IbUtils.getCurrentUid());
      for (final user in avatarUsers) {
        _controller.title.value = '${_controller.title.value}${user.username} ';
      }
    }
    return Text(
      _controller.title.value,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _handleMessageType(
      {required IbMessage message, required BuildContext context}) {
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
    return const SizedBox();
  }
}
