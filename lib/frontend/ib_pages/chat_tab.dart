import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_settings_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_settings.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/ib_friends_picker.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_colors.dart';
import 'chat_pages/chat_page.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with SingleTickerProviderStateMixin {
  final ChatTabController _controller = Get.find();
  String title = 'circles'.tr;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 1) {
          title = 'one_to_one_chat'.tr;
        } else {
          title = 'circles'.tr;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(title),
        ),
      ),
      body: SafeArea(
        child: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
          dragStartBehavior: DragStartBehavior.down,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(
                    context),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: IbPersistentHeader(
                    height: 40,
                    widget: IbCard(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Obx(() {
                            int total = 0;
                            for (final item in _controller.circles) {
                              total += item.unReadCount;
                            }

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Tab(
                                  height: 32,
                                  icon: Icon(
                                    Icons.circle_outlined,
                                  ),
                                ),
                                if (total > 0)
                                  Positioned(
                                    right: -10,
                                    top: 0,
                                    child: CircleAvatar(
                                      backgroundColor: IbColors.errorRed,
                                      radius: 10,
                                      child: Text(
                                        total >= 99 ? '99+' : total.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: IbColors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          Obx(() {
                            int total = 0;
                            for (final item in _controller.oneToOneChats) {
                              total += item.unReadCount;
                            }

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Tab(
                                  height: 32,
                                  icon: Icon(
                                    Icons.message,
                                  ),
                                ),
                                if (total > 0)
                                  Positioned(
                                    right: -10,
                                    top: 0,
                                    child: CircleAvatar(
                                      backgroundColor: IbColors.errorRed,
                                      radius: 10,
                                      child: Text(
                                        total >= 99 ? '99+' : total.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: IbColors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ];
          },
          body: Padding(
            padding: const EdgeInsets.only(top: 42),
            child: TabBarView(
              controller: _tabController,
              children: [
                buildCircle(),
                buildOneToOneList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: title != ('one_to_one_chat'.tr)
            ? const Icon(Icons.group_add_outlined)
            : const Icon(Icons.message),
        onPressed: () async {
          if (title != ('one_to_one_chat'.tr)) {
            Get.to(() => CircleSettings(Get.put(CircleSettingsController())),
                fullscreenDialog: true);
          } else {
            final users = await Get.to(
              () => IbFriendsPicker(
                Get.put(
                  IbFriendsPickerController(IbUtils.getCurrentUid()!),
                ),
                limit: 1,
                buttonTxt: 'Add',
              ),
            );
            if (users != null) {
              Get.to(() => ChatPage(Get.put(ChatPageController(
                  recipientId: (users as List<IbUser>).first.id))));
            }
          }
        },
      ),
    );
  }

  Widget buildOneToOneList() {
    return Obx(() => ListView.separated(
          itemBuilder: (context, index) {
            final ChatTabItem item = _controller.oneToOneChats[index];
            return ListTile(
              tileColor: Theme.of(context).backgroundColor,
              leading: Stack(
                children: [
                  if (item.ibChat.photoUrl.isEmpty)
                    _buildAvatar(item.avatars)
                  else
                    IbUserAvatar(avatarUrl: item.ibChat.photoUrl),
                  if (item.isMuted)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_off,
                          size: 16,
                        ),
                      ),
                    )
                ],
              ),
              onTap: () {
                item.unReadCount = 0;
                _controller.oneToOneChats.refresh();
                _controller.calculateTotalUnread();
                Get.to(
                  () => ChatPage(
                    Get.put(
                      ChatPageController(ibChat: item.ibChat),
                    ),
                  ),
                );
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                  if (item.ibChat.lastMessage != null)
                    Text(
                      IbUtils.readableDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              (item.ibChat.lastMessage!.timestamp as Timestamp)
                                  .millisecondsSinceEpoch),
                          showTime: true),
                      style: const TextStyle(
                          color: IbColors.lightGrey,
                          fontWeight: FontWeight.normal,
                          fontSize: IbConfig.kDescriptionTextSize),
                    ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 9,
                    child: _buildSubtitle(item),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: IbColors.errorRed, shape: BoxShape.circle),
                      child: item.unReadCount != 0
                          ? Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                item.unReadCount > 99
                                    ? '99+'
                                    : item.unReadCount.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  color: IbColors.white,
                                  fontSize: IbConfig.kDescriptionTextSize,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: _controller.oneToOneChats.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: IbColors.lightGrey,
              thickness: 0.5,
              height: 1,
            );
          },
        ));
  }

  Widget buildCircle() {
    return Obx(() => ListView.separated(
          itemBuilder: (context, index) {
            final ChatTabItem item = _controller.circles[index];
            return ListTile(
              tileColor: Theme.of(context).backgroundColor,
              leading: Stack(
                children: [
                  _buildCircleAvatar(item),
                  if (item.isMuted)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_off,
                          size: 16,
                        ),
                      ),
                    )
                ],
              ),
              onTap: () {
                item.unReadCount = 0;
                _controller.circles.refresh();
                _controller.calculateTotalUnread();
                Get.to(
                  () => ChatPage(
                    Get.put(
                      ChatPageController(ibChat: item.ibChat),
                    ),
                  ),
                );
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: IbConfig.kNormalTextSize),
                    ),
                  ),
                  if (item.ibChat.lastMessage != null)
                    Text(
                      IbUtils.readableDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              (item.ibChat.lastMessage!.timestamp as Timestamp)
                                  .millisecondsSinceEpoch),
                          showTime: true),
                      style: const TextStyle(
                          color: IbColors.lightGrey,
                          fontWeight: FontWeight.normal,
                          fontSize: IbConfig.kDescriptionTextSize),
                    ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 9,
                    child: _buildSubtitle(item),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: IbColors.errorRed, shape: BoxShape.circle),
                      child: item.unReadCount != 0
                          ? Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                item.unReadCount > 99
                                    ? '99+'
                                    : item.unReadCount.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: const TextStyle(
                                  color: IbColors.white,
                                  fontSize: IbConfig.kDescriptionTextSize,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: _controller.circles.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              color: IbColors.lightGrey,
              thickness: 0.5,
              height: 1,
            );
          },
        ));
  }

  Widget _buildCircleAvatar(ChatTabItem item) {
    if (item.ibChat.photoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: IbColors.lightGrey,
        radius: 24,
        child: Text(
          item.ibChat.name[0],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).indicatorColor,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return IbUserAvatar(
        avatarUrl: item.ibChat.photoUrl,
      );
    }
  }

  Widget _buildAvatar(List<IbUser> avatarUsers) {
    final double radius = avatarUsers.length > 1 ? 10 : 24;
    return CircleAvatar(
      backgroundColor: Theme.of(context).backgroundColor,
      radius: 26,
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: avatarUsers
            .map((e) => IbUserAvatar(
                  avatarUrl: e.avatarUrl,
                  radius: radius,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSubtitle(ChatTabItem item) {
    if (item.ibChat.lastMessage == null) {
      return const SizedBox();
    }

    final String messageType = item.ibChat.lastMessage!.messageType;

    if (item.ibChat.isCircle) {
      switch (messageType) {
        case IbMessage.kMessageTypeAnnouncement:
          return Text(
            item.ibChat.lastMessage!.content,
            style: const TextStyle(
                fontSize: IbConfig.kSecondaryTextSize,
                color: IbColors.accentColor),
          );
        case IbMessage.kMessageTypeText:
          return Text(
            '${item.lastMessageUser == null ? '' : '${item.lastMessageUser!.username}:'} ${item.ibChat.lastMessage!.content}',
            style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          );
        default:
          return const SizedBox();
      }
    } else {
      return Text(
        item.ibChat.lastMessage!.content,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: IbConfig.kSecondaryTextSize,
        ),
      );
    }
  }
}
