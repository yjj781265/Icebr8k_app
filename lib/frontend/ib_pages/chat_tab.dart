import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with SingleTickerProviderStateMixin {
  /* final ChatTabController _controller = Get.find();*/
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
            children: const [
              Text('Chat'),
              Text('Group'),
            ],
          ),
        ),
      ),
    );
  }
}
