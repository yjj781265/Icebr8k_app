import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_settings_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_keys.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_settings.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/friends_picker.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_pages/people_nearby_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/search_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/managers/Ib_analytics_manager.dart';
import '../ib_colors.dart';
import 'chat_pages/chat_page.dart';

class SocialTab extends StatefulWidget {
  const SocialTab({Key? key}) : super(key: key);

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab>
    with SingleTickerProviderStateMixin {
  final SocialTabController _controller = Get.find();
  String title = 'circles'.tr;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _controller.currentIndex.value = _tabController.index;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    IbAnalyticsManager()
        .logScreenView(className: "SocialTab", screenName: "SocialTab");
    return ShowCaseWidget(
      onComplete: (index, key) {
        if (key == IbShowCaseKeys.kPeopleNearbyKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.peopleNearbyShowCaseBool, value: true);
        }
      },
      builder: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Social'),
            ),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: true,
              controller: _tabController,
              tabs: [
                Obx(() {
                  int total = 0;
                  for (final item in _controller.circles) {
                    total += item.unReadCount;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('Circles'),
                        const SizedBox(
                          width: 4,
                        ),
                        if (total > 0)
                          CircleAvatar(
                            backgroundColor: IbColors.errorRed,
                            radius: 10,
                            child: Text(
                              total >= 99 ? '99+' : total.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                Obx(() {
                  int total = 0;
                  for (final item in _controller.oneToOneChats) {
                    total += item.unReadCount;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chat_rounded),
                        const SizedBox(
                          width: 8,
                        ),
                        const Text('Chats'),
                        const SizedBox(
                          width: 4,
                        ),
                        if (total > 0)
                          CircleAvatar(
                            backgroundColor: IbColors.errorRed,
                            radius: 10,
                            child: Text(
                              total >= 99 ? '99+' : total.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.contacts),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Friends'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Showcase(
                overlayOpacity: 0.3,
                shapeBorder: const CircleBorder(),
                key: IbShowCaseKeys.kPeopleNearbyKey,
                description: 'Click here to see people nearby',
                child: IconButton(
                  tooltip: 'People Nearby',
                  icon: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: IbColors.errorRed,
                  ),
                  onPressed: () {
                    Get.to(() => PeopleNearbyPage());
                  },
                ),
              ),
              IconButton(
                tooltip: 'Search all',
                icon: const Icon(Icons.search),
                onPressed: () {
                  Get.to(() => SearchPage());
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TabBarView(
              controller: _tabController,
              children: [
                buildCircle(),
                buildOneToOneList(),
                buildFriendList(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Obx(() {
              if (_controller.currentIndex.value == 0) {
                return const Icon(Icons.group_add_outlined);
              }
              if (_controller.currentIndex.value == 1) {
                return const Icon(Icons.message);
              }

              if (_controller.currentIndex.value == 2) {
                return const Icon(Icons.person_search);
              }
              return const SizedBox();
            }),
            onPressed: () async {
              if (_controller.currentIndex.value == 0) {
                Get.to(
                    () => CircleSettings(Get.put(CircleSettingsController())),
                    fullscreenDialog: true);
              } else if (_controller.currentIndex.value == 1) {
                final users = await Get.to(
                  () => FriendsPicker(
                    Get.put(
                      IbFriendsPickerController(IbUtils().getCurrentUid()!),
                    ),
                    limit: 1,
                    buttonTxt: 'Add',
                  ),
                );
                if (users != null) {
                  final IbUser user = (users as List<IbUser>).first;
                  Get.to(() => ChatPage(
                      Get.put(ChatPageController(recipientId: (user.id))
                        ..title.value = user.username
                        ..avatarUrl.value = user.avatarUrl)));
                }
              } else {
                Get.to(() => SearchPage());
              }
            },
          ),
        );
      }),
    );
  }

  Widget buildOneToOneList() {
    return Obx(() {
      if (_controller.isLoadingChat.value) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.oneToOneChats.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('assets/images/chat.json')),
          ],
        );
      }
      return ListView.separated(
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
                  ),
                if (item.isBlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.block,
                        color: IbColors.errorRed,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              item.unReadCount = 0;
              _controller.oneToOneChats.refresh();
              _controller.calculateTotalUnread();
              Get.to(
                () => ChatPage(
                  Get.put(
                    ChatPageController(
                      ibChat: item.ibChat,
                    ),
                    tag: item.ibChat.chatId,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                ),
                if (item.ibChat.lastMessage != null)
                  Text(
                    IbUtils().readableDateTime(
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
                  child: _controller.buildSubtitle(item),
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
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
      );
    });
  }

  Widget buildCircle() {
    return Obx(() {
      if (_controller.isLoadingCircles.value) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.circles.isEmpty) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('assets/images/friends.json')),
            TextButton(
                onPressed: () {
                  Get.to(() => SearchPage());
                },
                child: const Text('Search Circles'))
          ],
        );
      }

      return ListView.separated(
        itemBuilder: (context, index) {
          final ChatTabItem item = _controller.circles[index];
          return ListTile(
            tileColor: Theme.of(context).backgroundColor,
            leading: Stack(
              children: [
                _controller.buildCircleAvatar(item),
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
                  Get.put(ChatPageController(ibChat: item.ibChat),
                      tag: item.ibChat.chatId),
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
                    IbUtils().readableDateTime(
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
                  child: _controller.buildSubtitle(item),
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
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
      );
    });
  }

  Widget buildFriendList() {
    return Obx(() {
      if (_controller.isFriendListLoading.isTrue) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset('assets/images/monkey_zen.json')),
              const Text(
                'Looks like you do not have any friends yet',
                style: TextStyle(
                  color: IbColors.lightGrey,
                  fontSize: IbConfig.kNormalTextSize,
                ),
              ),
              TextButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => PeopleNearbyPage());
                  },
                  child: const Text('See People Nearby 📍')),
              TextButton(
                  onPressed: () {
                    Get.back();
                    Get.to(() => SearchPage());
                  },
                  child: const Text('Search User'))
            ],
          ),
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
          controller: _controller.scrollController,
          itemBuilder: (context, index) {
            final item = _controller.friends.toSet().toList()[index];
            return FriendListItem(item);
          },
          itemCount: _controller.friends.toSet().length,
        ),
      );
    });
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
}

class FriendListItem extends StatelessWidget {
  final FriendItem item;

  const FriendListItem(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.to(() => ProfilePage(
            Get.put(ProfileController(item.user.id), tag: item.user.id)));
      },
      leading: IbUserAvatar(
        avatarUrl: item.user.avatarUrl,
      ),
      title: Text(
        item.user.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: IbLinearIndicator(endValue: item.compScore),
    );
  }
}
