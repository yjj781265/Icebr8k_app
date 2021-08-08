import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ScoreTab extends StatefulWidget {
  const ScoreTab({Key? key}) : super(key: key);

  @override
  _ScoreTabState createState() => _ScoreTabState();
}

class _ScoreTabState extends State<ScoreTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _friendListController = Get.find<FriendListController>();
  final _friendRequestController = Get.find<FriendRequestController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _friendListController.refreshEverything();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IbColors.lightBlue,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'score_page_tab_1_title'.tr),
              Obx(
                () => Tab(
                  text:
                      '${'score_page_tab_2_title'.tr}${_friendRequestController.requests.isEmpty ? '' : '(${_friendRequestController.requests.length})'}',
                ),
              ),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            labelColor: Colors.black,
            unselectedLabelColor: IbColors.lightGrey,
            indicatorColor: IbColors.primaryColor,
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: const [
              MyFriendsTab(),
              FriendRequestTab(),
            ],
          ))
        ],
      ),
    );
  }
}

class MyFriendsTab extends StatefulWidget {
  const MyFriendsTab({Key? key}) : super(key: key);

  @override
  _MyFriendsTabState createState() => _MyFriendsTabState();
}

class _MyFriendsTabState extends State<MyFriendsTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<FriendListController>();
  final RefreshController _refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (_controller.friendItems.isEmpty) {
        return Material(
            color: IbColors.lightBlue,
            child: Center(
                child: Lottie.asset('assets/images/friendship.json',
                    width: 230, height: 230)));
      }

      return SmartRefresher(
        controller: _refreshController,
        header: const ClassicHeader(
          textStyle: TextStyle(color: IbColors.primaryColor),
          failedIcon: Icon(
            Icons.error_outline,
            color: IbColors.errorRed,
          ),
          completeIcon: Icon(
            Icons.check_circle_outline,
            color: IbColors.accentColor,
          ),
          refreshingIcon: IbProgressIndicator(
            width: 24,
            height: 24,
            padding: 0,
          ),
        ),
        cacheExtent: Get.height * 2,
        onLoading: () {
          print('onLoading');
        },
        onRefresh: () async {
          await _controller.refreshEverything();
          _refreshController.refreshCompleted();
          print('onRefresh');
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            final FriendListItem _item = _controller.friendItems[index];
            return FriendItemView(friendListItem: _item);
          },
          itemCount: _controller.friendItems.length,
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class FriendItemView extends StatelessWidget {
  final FriendListItem friendListItem;
  const FriendItemView({Key? key, required this.friendListItem})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: IbColors.white,
      child: ListTile(
        dense: true,
        tileColor: IbColors.white,
        leading: IbUserAvatar(
          avatarUrl: friendListItem.avatarUrl,
        ),
        title: Text(
          friendListItem.username,
          style: const TextStyle(
              fontSize: IbConfig.kNormalTextSize, fontWeight: FontWeight.bold),
        ),
        subtitle: IbLinearIndicator(endValue: friendListItem.score),
        trailing: IconButton(
          icon: const Icon(
            Icons.message_outlined,
            color: IbColors.accentColor,
          ),
          onPressed: () {
            final String mUid = Get.find<AuthController>().firebaseUser!.uid;
            final List<String> memberUids = [mUid, friendListItem.uid];
            Get.to(() => ChatPage(Get.put(ChatPageController(memberUids),
                tag: memberUids.toString())));
          },
        ),
      ),
    );
  }
}

class FriendRequestTab extends StatefulWidget {
  const FriendRequestTab({Key? key}) : super(key: key);

  @override
  _FriendRequestTabState createState() => _FriendRequestTabState();
}

class _FriendRequestTabState extends State<FriendRequestTab>
    with AutomaticKeepAliveClientMixin {
  final _controller = Get.find<FriendRequestController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _getBody();
  }

  Widget _getBody() {
    return Obx(() {
      if (_controller.requests.isEmpty) {
        return Material(
            color: IbColors.lightBlue,
            child: Center(
                child: Lottie.asset('assets/images/ice_cream_cup.json',
                    width: 230, height: 230)));
      }
      return AnimatedList(
        key: _controller.animatedListKey,
        itemBuilder: (context, index, animation) {
          final FriendRequestItem item = _controller.requests[index];
          return _buildItem(item, index, animation);
        },
        initialItemCount: _controller.requests.length,
        shrinkWrap: true,
      );
    });
  }

  void _removeItem(int index, FriendRequestItem item) {
    _controller.requests.removeAt(index);
    _controller.animatedListKey.currentState!.removeItem(index,
        (context, animation) {
      return _buildItem(item, index, animation);
    });
  }

  Widget _buildItem(
      FriendRequestItem item, int index, Animation<double> animation) {
    final _controller = Get.find<FriendRequestController>();
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        child: IbCard(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IbUserAvatar(avatarUrl: item.avatarUrl),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.username,
                            style: const TextStyle(
                                fontSize: IbConfig.kNormalTextSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Text(
                            ' · ${IbUtils.getAgoDateTimeString(DateTime.fromMillisecondsSinceEpoch(item.timeStampInMs))}',
                            style: const TextStyle(
                                color: IbColors.lightGrey,
                                fontSize: IbConfig.kDescriptionTextSize),
                          ),
                        ],
                      ),
                      IbLinearIndicator(
                        endValue: item.score,
                        disableAnimation: true,
                      ),
                      if (item.requestMsg.isNotEmpty)
                        Text(item.requestMsg,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: IbConfig.kSecondaryTextSize)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// add friend icon button
                    Expanded(
                        child: IconButton(
                      icon: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: IbColors.accentColor,
                      ),
                      onPressed: () {
                        _removeItem(index, item);
                        _controller.acceptFriendRequest(item.friendUid);
                      },
                    )),

                    /// decline friend request icon button
                    Expanded(
                        child: IconButton(
                      icon: const Icon(
                        Icons.person_remove_alt_1_outlined,
                        color: IbColors.errorRed,
                      ),
                      onPressed: () {
                        _removeItem(index, item);
                        _controller.rejectFriendRequest(item.friendUid);
                      },
                    ))
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
