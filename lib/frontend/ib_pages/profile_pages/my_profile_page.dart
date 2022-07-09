import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/my_profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/word_cloud_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_keys.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/word_cloud_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_profile_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_snippet_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/answered_question_controller.dart';
import '../../../backend/controllers/user_controllers/edit_emo_pic_controller.dart';
import '../../../backend/controllers/user_controllers/friend_list_controller.dart';
import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../../ib_utils.dart';
import '../edit_profile_pages/edit_emo_pics_page.dart';
import 'answered_page.dart';
import 'asked_page.dart';
import 'circles_page.dart';
import 'followed_tags_page.dart';
import 'friend_list.dart';

class MyProfilePage extends StatelessWidget {
  final bool showBackButton;
  final MainPageController _controller = Get.find();

  final MyProfileController _myProfileController =
      Get.put(MyProfileController());
  MyProfilePage({this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        onComplete: (index, key) {
          if (key == IbShowCaseKeys.kWordCloudKey) {
            IbLocalDataService().updateBoolValue(
                key: StorageKey.wordCloudShowCaseBool, value: true);
          }
        },
        builder: Builder(builder: (context) {
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: ExtendedNestedScrollView(
                onlyOneScrollInBody: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _profileHeader(context),
                          _userInfo(),
                          _stats(),
                          _actions(),
                        ],
                      ),
                    ),
                    SliverOverlapAbsorber(
                      handle: ExtendedNestedScrollView
                          .sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: IbPersistentHeader(
                            height: 40,
                            widget: const IbCard(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              child: TabBar(
                                padding: EdgeInsets.all(2),
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: [
                                  Icon(Icons.face_retouching_natural),
                                  Icon(FontAwesomeIcons.hand),
                                  //Text('Friends'),
                                ],
                              ),
                            )),
                      ),
                    )
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: TabBarView(children: [
                    _emoPicsTab(),
                    _askedTab(),
                  ]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: Get.width / 2 + 49,
          width: Get.width,
          color: Colors.transparent,
        ),
        Obx(
          () => GestureDetector(
            onTap: () {
              if (_controller.rxCurrentIbUser.value.coverPhotoUrl.isEmpty) {
                return;
              }
              Get.to(
                  () => IbMediaViewer(
                      urls: [_controller.rxCurrentIbUser.value.coverPhotoUrl],
                      currentIndex: 0),
                  transition: Transition.zoom,
                  fullscreenDialog: true);
            },
            child: SizedBox(
              width: Get.width,
              height: Get.width / 2.0,
              child: _controller.rxCurrentIbUser.value.coverPhotoUrl.isEmpty
                  ? Image.asset(
                      'assets/images/header_img.jpg',
                      fit: BoxFit.fill,
                    )
                  : CachedNetworkImage(
                      imageUrl: _controller.rxCurrentIbUser.value.coverPhotoUrl,
                      fit: BoxFit.fill,
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: showBackButton
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (showBackButton)
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).backgroundColor.withOpacity(0.8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Platform.isAndroid
                              ? Icons.arrow_back
                              : Icons.arrow_back_ios,
                          color: Theme.of(context).indicatorColor,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),

                  ///actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Showcase(
                        description: 'Click here to see your word cloud',
                        key: showBackButton
                            ? GlobalKey()
                            : IbShowCaseKeys.kWordCloudKey,
                        overlayOpacity: 0.3,
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .backgroundColor
                                .withOpacity(0.8),
                            child: IconButton(
                                onPressed: () {
                                  Get.to(() => WordCloudPage(Get.put(
                                      WordCloudController(
                                          _controller.rxCurrentIbUser.value))));
                                },
                                hoverColor: IbColors.primaryColor,
                                icon: Icon(Icons.cloud,
                                    color: Theme.of(context).indicatorColor))),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 16,
          child: InkWell(
            child: Obx(
              () => IbUserAvatar(
                  showBorder: true,
                  radius: 49,
                  avatarUrl: _controller.rxCurrentIbUser.value.avatarUrl),
            ),
            onTap: () {
              Get.to(
                  () => IbMediaViewer(
                      urls: [_controller.rxCurrentIbUser.value.avatarUrl],
                      currentIndex: 0),
                  transition: Transition.zoom,
                  fullscreenDialog: true);
            },
          ),
        ),
        Positioned(
            bottom: 57,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                  color: IbColors.primaryColor.withOpacity(0.8),
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Obx(
                  () => Text(
                    beautifyProfilePrivacy(
                        _controller.rxCurrentIbUser.value.profilePrivacy),
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize),
                  ),
                ),
              ),
            ))
      ],
    );
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          Obx(
            () => IbProfileStats(
              number: _controller.rxCurrentIbUser.value.answeredCount,
              onTap: () {
                if (_controller.rxCurrentIbUser.value.answeredCount == 0) {
                  return;
                }
                Get.to(() => AnsweredPage(Get.put(AnsweredQuestionController(
                    _controller.rxCurrentIbUser.value.id))));
              },
              subText: '✅ VOTE(S)',
            ),
          ),
          Obx(() => IbProfileStats(
              number: _controller.rxCurrentIbUser.value.askedCount,
              onTap: () {
                if (_myProfileController.asks.isEmpty) {
                  return;
                }
                Get.to(() => AskedPage(Get.put(AskedQuestionsController(
                    IbUtils.getCurrentUid()!,
                    showPublicOnly: false))));
              },
              subText: "✋ POLL(S)")),
          Obx(
            () => IbProfileStats(
                number: _controller.rxCurrentIbUser.value.friendUids.length,
                onTap: () {
                  if (_controller.rxCurrentIbUser.value.friendUids.isEmpty) {
                    return;
                  }
                  Get.to(() => FriendList(Get.put(
                      FriendListController(_controller.rxCurrentIbUser.value),
                      tag: _controller.rxCurrentIbUser.value.id)));
                },
                subText: "👥 FRIEND(S)"),
          ),
          Obx(
            () => IbProfileStats(
                number: _controller.rxCurrentIbUser.value.tags.length,
                onTap: () {
                  if (_controller.rxCurrentIbUser.value.tags.isEmpty) {
                    return;
                  }
                  Get.to(() => FollowedTagsPage(
                      _controller.rxCurrentIbUser.value.tags,
                      _controller.rxCurrentIbUser.value.username));
                },
                subText: "🏷️ TAG(S)"),
          ),
          Obx(
            () => IbProfileStats(
                number: _myProfileController.circles.length,
                onTap: () {
                  if (_myProfileController.circles.isEmpty) {
                    return;
                  }
                  Get.to(() => CirclesPage(_myProfileController.circles));
                },
                subText: "⭕ CIRCLE(S)"),
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Column(
      children: [
        const Divider(
          thickness: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IbActionButton(
                color: IbColors.errorRed,
                iconData: Icons.collections_bookmark_outlined,
                onPressed: () {
                  IbUtils.showSimpleSnackBar(
                      msg: 'This feature is coming soon..',
                      backgroundColor: IbColors.primaryColor);
                },
                text: 'Collections'),
            IbActionButton(
                color: IbColors.primaryColor,
                iconData: Icons.edit,
                onPressed: () {
                  Get.to(() => EditProfilePage());
                },
                text: 'Edit Profile'),
          ],
        ),
        const Divider(
          thickness: 2,
        ),
      ],
    );
  }

  Widget _emoPicsTab() {
    return Obx(
      () => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'My EmoPics',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kPageTitleSize),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextButton.icon(
                    onPressed: () {
                      Get.to(() => EditEmoPicsPage(Get.put(
                          EditEmoPicController(
                              _controller.rxCurrentIbUser.value.emoPics.obs),
                          tag: IbUtils.getUniqueId())));
                    },
                    label: Text(
                      _controller.rxCurrentIbUser.value.emoPics.isEmpty
                          ? 'add'.tr
                          : 'edit'.tr,
                      style: const TextStyle(color: IbColors.primaryColor),
                    ),
                    icon: const Icon(
                      Icons.edit,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            Obx(() => StaggeredGrid.count(
                  crossAxisCount: 2,
                  children: _controller.rxCurrentIbUser.value.emoPics
                      .map((e) => IbEmoPicCard(
                            emoPic: e,
                            onTap: () {
                              Get.to(
                                  () => IbMediaViewer(
                                        urls: [e.url],
                                        currentIndex: 0,
                                      ),
                                  transition: Transition.zoom,
                                  fullscreenDialog: true);
                            },
                            ignoreOnDoubleTap: true,
                          ))
                      .toList(),
                )),
            const SizedBox(
              height: 16,
            ),
            if (_controller.rxCurrentIbUser.value.emoPics.isEmpty)
              Center(
                  child: Text(
                'nothing'.tr,
                style: const TextStyle(color: IbColors.lightGrey),
              )),
          ],
        ),
      ),
    );
  }

  Widget _askedTab() {
    return Obx(() {
      if (_myProfileController.asks.isEmpty) {
        return SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/images/koala.json')),
              ),
            ),
            const Text(
              "I don't have any polls yet",
              textAlign: TextAlign.center,
            )
          ]),
        );
      }

      return SmartRefresher(
        controller: _myProfileController.askedRefreshController,
        enablePullDown: false,
        enablePullUp: _myProfileController.asks.length >= IbConfig.kPerPage,
        onLoading: () async {
          await _myProfileController.onLoadMore();
        },
        child: SingleChildScrollView(
          child: Obx(
            () => StaggeredGrid.count(
              crossAxisCount: 3,
              children: _myProfileController.asks
                  .map((element) => IbQuestionSnippetCard(element))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  Widget _userInfo() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _controller.rxCurrentIbUser.value.username,
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_controller.rxCurrentIbUser.value.fName} ${_controller.rxCurrentIbUser.value.lName} ',
              style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _controller.rxCurrentIbUser.value.gender,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                if (_controller.rxCurrentIbUser.value.birthdateInMs != null &&
                    !_controller.rxCurrentIbUser.value.isAgeHidden)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Age: ${IbUtils.calculateAge(_controller.rxCurrentIbUser.value.birthdateInMs!).toString()}',
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                IbDescriptionText(text: _controller.rxCurrentIbUser.value.bio),
          ),
          const Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }

  String beautifyProfilePrivacy(String text) {
    final list = text.split('');
    list[0] = list[0].toUpperCase();
    final int index = list.indexOf('_');
    if (index != -1) {
      list[index] = ' ';
    }
    return list.map((e) => e).join().capitalize ?? '';
  }
}
