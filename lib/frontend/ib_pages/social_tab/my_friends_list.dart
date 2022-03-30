import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyFriendsList extends StatelessWidget {
  final SocialTabController _controller;

  /// need this scroll controller to have pull to refresh effect!
  final ScrollController scrollController = ScrollController();

  MyFriendsList(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (_controller.isFriendListLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }
          return SmartRefresher(
            scrollDirection: Axis.vertical,
            controller: _controller.friendListRefreshController,
            physics: const AlwaysScrollableScrollPhysics(),
            onRefresh: () async {
              await _controller.onFriendListRefresh();
            },
            child: ListView.builder(
              controller: scrollController,
              itemBuilder: (context, index) {
                final item = _controller.friends[index];
                return FriendListItem(
                  Get.put(FriendItemController(item), tag: item.username),
                );
              },
              itemCount: _controller.friends.length,
            ),
          );
        }),
      ),
    );
  }
}

class FriendListItem extends StatelessWidget {
  final FriendItemController _controller;

  const FriendListItem(this._controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.isTrue) {
        return const SizedBox();
      }

      return ListTile(
        onLongPress: () {
          _showBtmSheet(context);
        },
        onTap: () {
          Get.to(
            () => ProfilePage(
              Get.put(
                ProfileController(_controller.user.id),
              ),
            ),
          );
        },
        leading: Stack(
          children: [
            IbUserAvatar(
              avatarUrl: _controller.avatarUrl.value,
            ),
            if (_controller.isBlocked.isTrue)
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).backgroundColor),
                    child: const Icon(
                      Icons.block_flipped,
                      color: IbColors.errorRed,
                    ),
                  ))
          ],
        ),
        title: Text(
          _controller.username.value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: IbLinearIndicator(
          endValue: _controller.compScore.value,
        ),
        trailing: IconButton(
            onPressed: () {
              _showBtmSheet(context);
            },
            icon: const Icon(Icons.more_horiz)),
      );
    });
  }

  void _showBtmSheet(BuildContext context) {
    final Widget menu = IbCard(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.person_remove,
                color: IbColors.errorRed,
              ),
              onTap: () async {
                Get.back();
                Get.dialog(IbDialog(
                  title:
                      'Are you sure to unfriend ${_controller.username.value}?',
                  subtitle: '',
                  onPositiveTap: () async {
                    Get.back();
                    await _controller.removeFriend();
                  },
                ));
              },
              title: Text.rich(
                TextSpan(
                    text: 'Unfriend ',
                    style: const TextStyle(color: IbColors.errorRed),
                    children: [
                      TextSpan(
                          text: _controller.username.value,
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor))
                    ]),
              ),
            ),
            if (_controller.isBlocked.isTrue)
              ListTile(
                onTap: () {
                  Get.back();
                  Get.dialog(IbDialog(
                    title:
                        'Are you sure to unblock ${_controller.username.value}?',
                    subtitle: '',
                    onPositiveTap: () async {
                      Get.back();
                      await _controller.unblockFriend();
                    },
                  ));
                },
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: IbColors.accentColor,
                ),
                title: Text.rich(
                  TextSpan(
                      text: 'Unblock ',
                      style: const TextStyle(color: IbColors.accentColor),
                      children: [
                        TextSpan(
                            text: _controller.username.value,
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor))
                      ]),
                ),
              ),
            if (_controller.isBlocked.isFalse)
              ListTile(
                onTap: () {
                  Get.back();
                  Get.dialog(IbDialog(
                    title:
                        'Are you sure to block ${_controller.username.value}?',
                    subtitle:
                        'You will not able to receive messages from this user',
                    onPositiveTap: () async {
                      Get.back();
                      await _controller.blockFriend();
                    },
                  ));
                },
                leading: const Icon(
                  Icons.block_flipped,
                  color: IbColors.errorRed,
                ),
                title: Text.rich(
                  TextSpan(
                      text: 'Block ',
                      style: const TextStyle(color: IbColors.errorRed),
                      children: [
                        TextSpan(
                            text: _controller.username.value,
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor))
                      ]),
                ),
              ),
          ],
        ),
      ),
    );

    Get.bottomSheet(menu, ignoreSafeArea: false);
  }
}
