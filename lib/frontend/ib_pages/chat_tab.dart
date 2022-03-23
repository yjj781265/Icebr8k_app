import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/models/ib_chat.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import 'chat_pages/chat_page.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with SingleTickerProviderStateMixin {
  final ChatTabController _controller = Get.find();
  String title = 'one_to_one_chat'.tr;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          title = 'one_to_one_chat'.tr;
        } else {
          title = 'group_chat'.tr;
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
      body: ExtendedNestedScrollView(
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
                  height: 32,
                  widget: IbCard(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tooltip(
                            message: 'one_to_one_chat'.tr,
                            child: const Tab(
                                height: 32,
                                icon: Icon(
                                  Icons.person,
                                ))),
                        Tooltip(
                            message: 'group_chat'.tr,
                            child: const Tab(
                                height: 32,
                                icon: Icon(
                                  Icons.group,
                                ))),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(top: 38),
          child: TabBarView(
            controller: _tabController,
            children: [
              buildOneToOneList(),
              Text('Group'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOneToOneList() {
    return Obx(() => ListView.separated(
          itemBuilder: (context, index) {
            final IbChat chat = _controller.oneToOneChats[index];
            return ListTile(
              tileColor: Theme.of(context).backgroundColor,
              leading: IbUserAvatar(
                avatarUrl: chat.photoUrl,
              ),
              onTap: () {
                Get.to(
                  () => ChatPage(
                    Get.put(
                      ChatPageController(ibChat: chat),
                    ),
                  ),
                );
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                  if (chat.lastMessage != null)
                    Text(
                      IbUtils.readableDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              (chat.lastMessage!.timestamp as Timestamp)
                                  .millisecondsSinceEpoch),
                          showTime: true),
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: IbConfig.kDescriptionTextSize),
                    ),
                ],
              ),
              subtitle: Text(
                chat.lastMessage == null ? '' : chat.lastMessage!.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: IbConfig.kSecondaryTextSize,
                ),
              ),
            );
          },
          itemCount: _controller.oneToOneChats.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              thickness: 1,
              height: 1,
            );
          },
        ));
  }
}
