import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';

import '../../backend/controllers/user_controllers/chat_tab_controller.dart';

class ChatTab extends StatelessWidget {
  ChatTab({Key? key}) : super(key: key);
  final ChatTabController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Chat'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
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
                    height: 38,
                    widget: IbCard(
                      elevation: 0,
                      child: TabBar(
                        tabs: [
                          Tooltip(
                              message: 'one_to_one_chat'.tr,
                              child: const Tab(
                                  height: 30,
                                  icon: Icon(
                                    Icons.person,
                                  ))),
                          Tooltip(
                              message: 'group_chat'.tr,
                              child: const Tab(
                                  height: 30,
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
          body: const Padding(
            padding: EdgeInsets.only(top: 38),
            child: TabBarView(
              children: [
                Text('Chat'),
                Text('Group'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
