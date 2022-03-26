import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/frontend/ib_pages/social_tab/my_friends_list.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';

class SocialTab extends StatefulWidget {
  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab>
    with SingleTickerProviderStateMixin {
  String title = 'friends_tab'.tr;
  late TabController _tabController;
  final SocialTabController _controller = Get.put(SocialTabController());

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          title = 'friends_tab'.tr;
        } else {
          title = 'ppl_nearby_tab'.tr;
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.sort))],
      ),
      body: SafeArea(
        child: ExtendedNestedScrollView(
          onlyOneScrollInBody: true,
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
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tooltip(
                              message: 'friends'.tr,
                              child: const Tab(
                                  height: 32,
                                  icon: Icon(
                                    Icons.group,
                                  ))),
                          Tooltip(
                              message: 'people_nearby'.tr,
                              child: const Tab(
                                  height: 32,
                                  icon: Icon(
                                    Icons.person_pin_circle_rounded,
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
                MyFriendsList(_controller),
                Text('People Nearby'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
