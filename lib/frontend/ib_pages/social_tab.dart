import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/people_nearby_controller.dart';
import 'package:icebr8k/backend/controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SocialTab extends StatefulWidget {
  const SocialTab({Key? key}) : super(key: key);

  @override
  _SocialTabState createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _friendListController = Get.find<FriendListController>();
  final _friendRequestController = Get.find<FriendRequestController>();
  final _peopleNearbyController = Get.find<PeopleNearbyController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    Get.find<SocialTabController>().tabController = _tabController;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: [
              Obx(
                () => SizedBox(
                  height: 32,
                  child: Tab(
                    text:
                        '${'score_page_tab_3_title'.tr}${_peopleNearbyController.items.isEmpty ? '' : '(${_peopleNearbyController.items.length})'}',
                  ),
                ),
              ),
              Obx(
                () => SizedBox(
                  height: 32,
                  child: Tab(
                      text:
                          '${'score_page_tab_1_title'.tr}${_friendListController.friendItems.isEmpty ? '' : '(${_friendListController.friendItems.length})'}'),
                ),
              ),
              Obx(
                () => SizedBox(
                  height: 32,
                  child: Tab(
                    text:
                        '${'score_page_tab_2_title'.tr}${_friendRequestController.requests.isEmpty ? '' : '(${_friendRequestController.requests.length})'}',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TabBarView(
            controller: _tabController,
            children: [
              PeopleNearByTab(),
              const MyFriendsTab(),
              const FriendRequestTab(),
            ],
          ),
        ))
      ],
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
        return Center(
            child: Lottie.asset('assets/images/friendship.json',
                width: 230, height: 230));
      }

      return SmartRefresher(
        physics: const ClampingScrollPhysics(),
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
        },
        child: ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
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
    return ListTile(
      onTap: () => Get.to(
          () => ProfilePage(
                friendListItem.uid,
                showAppBar: true,
              ),
          preventDuplicates: false),
      tileColor: Theme.of(context).primaryColor,
      leading: IbUserAvatar(
        uid: friendListItem.uid,
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
          color: IbColors.primaryColor,
        ),
        onPressed: () {
          final String mUid = Get.find<AuthController>().firebaseUser!.uid;
          final List<String> memberUids = [mUid, friendListItem.uid];
          Get.to(() => ChatPage(Get.put(ChatPageController(memberUids),
              tag: memberUids.toString())));
        },
      ),
    );
  }
}

class PeopleNearByTab extends StatefulWidget {
  @override
  _PeopleNearByTabState createState() => _PeopleNearByTabState();
}

class _PeopleNearByTabState extends State<PeopleNearByTab>
    with AutomaticKeepAliveClientMixin {
  final PeopleNearbyController _controller = Get.find();
  final _refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NestedScrollView(
      physics: const ClampingScrollPhysics(),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Obx(
              () => SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                value: _controller.shareLoc.value,
                onChanged: (value) async {
                  print(value);
                  _controller.shareLoc.value = value;
                  IbLocalStorageService().updateLocSharingFlag(value);
                  if (value) {
                    _controller.isSearching.value = true;
                    await _controller.searchPeopleNearby();
                  } else {
                    _controller.isSearching.value = false;
                    await _controller.removeMyLoc();
                    _controller.items.clear();
                  }
                },
                title: const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text('Share my location'),
                ),
              ),
            ),
          ),
        ];
      },
      body: Obx(() {
        if (_controller.isGranted.isFalse || _controller.shareLoc.isFalse) {
          return Center(
              child: SizedBox(
            height: 230,
            width: 230,
            child: Lottie.asset('assets/images/location.json'),
          ));
        }

        if (_controller.isGranted.isTrue && _controller.isSearching.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return SmartRefresher(
          physics: const ClampingScrollPhysics(),
          controller: _refreshController,
          onRefresh: () async {
            await _controller.searchPeopleNearby();
            _refreshController.refreshCompleted();
          },
          header: ClassicHeader(
            height: 88,
            idleText:
                'Pull down to refresh\nLast update ${IbUtils.readableDateTime(_controller.lastRefreshTime.value, showTime: true)}',
            refreshingText: 'Searching people nearby...',
            releaseText: 'Release to search people nearby',
            completeText: 'Search completed',
            textStyle: const TextStyle(color: IbColors.primaryColor),
            failedIcon: const Icon(
              Icons.error_outline,
              color: IbColors.errorRed,
            ),
            completeIcon: const Icon(
              Icons.check_circle_outline,
              color: IbColors.accentColor,
            ),
            refreshingIcon: const IbProgressIndicator(
              width: 24,
              height: 24,
              padding: 0,
            ),
          ),
          child: _controller.isGranted.isTrue &&
                  _controller.isSearching.isFalse &&
                  _controller.items.isEmpty
              ? Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(
                        Icons.not_listed_location,
                        size: 36,
                        color: IbColors.errorRed,
                      ),
                      Text(
                        'There is no people nearby',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      )
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Users within 30 miles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final PeopleNearbyItem item = _controller.items[index];
                        return ListTile(
                          onTap: () {
                            Get.to(() => ProfilePage(
                                  item.ibUser.id,
                                  showAppBar: true,
                                ));
                          },
                          tileColor: Theme.of(context).primaryColor,
                          leading: IbUserAvatar(
                            uid: item.ibUser.id,
                            avatarUrl: item.ibUser.avatarUrl,
                          ),
                          title: Text(item.ibUser.username),
                          subtitle: IbLinearIndicator(
                            endValue: item.compScore,
                          ),
                        );
                      },
                      itemCount: _controller.items.length,
                    ),
                  ],
                ),
        );
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;
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
        return Center(
            child: Lottie.asset('assets/images/ice_cream_cup.json',
                width: 230, height: 230));
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
            children: [
              IbUserAvatar(
                avatarUrl: item.avatarUrl,
                uid: item.friendUid,
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.username,
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
