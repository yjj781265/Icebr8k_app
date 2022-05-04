import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_list_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../social_tab.dart';

class FriendList extends StatelessWidget {
  const FriendList(this._controller, {Key? key}) : super(key: key);
  final FriendListController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        title: Text("${_controller.user.username}'s friends"),
      ),
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) {
            return FriendListItem(
              Get.put(FriendItemController(_controller.users[index]),
                  tag: _controller.users[index].id),
              showThreeDots: false,
            );
          },
          itemCount: _controller.users.length,
        );
      }),
    );
  }
}
