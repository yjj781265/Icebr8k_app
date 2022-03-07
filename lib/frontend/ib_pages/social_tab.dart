import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';

class SocialTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Social'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
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
                                    Icons.group,
                                  ))),
                          Tooltip(
                              message: 'group_chat'.tr,
                              child: const Tab(
                                  height: 30,
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
          body: const Padding(
            padding: EdgeInsets.only(top: 38),
            child: TabBarView(
              children: [
                Text('Friends'),
                Text('People Nearby'),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
