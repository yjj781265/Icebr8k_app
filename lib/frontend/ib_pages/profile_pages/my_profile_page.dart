import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/edit_emo_pic_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/word_cloud_controller.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_emo_pics_page.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/answered_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/asked_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/followed_tags_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/friend_list.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/word_cloud_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../../ib_utils.dart';

class MyProfilePage extends StatelessWidget {
  final bool showBackButton;
  final MainPageController _controller = Get.find();
  final double statsWidth = Get.width / 4 - 10;
  final double statsHeight = ((Get.width / 4) - 10) / 1.33;

  MyProfilePage({this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() => ListView(
              children: <Widget>[
                ///cover photo
                Stack(
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          Get.to(
                              () => IbMediaViewer(urls: [
                                    if (_controller.rxCurrentIbUser.value
                                        .coverPhotoUrl.isEmpty)
                                      IbConfig.kDefaultCoverPhotoUrl
                                    else
                                      _controller
                                          .rxCurrentIbUser.value.coverPhotoUrl
                                  ], currentIndex: 0),
                              transition: Transition.zoom,
                              fullscreenDialog: true);
                        },
                        child: SizedBox(
                          width: Get.width,
                          height: Get.width / 1.78,
                          child: CachedNetworkImage(
                            imageUrl: _controller
                                    .rxCurrentIbUser.value.coverPhotoUrl.isEmpty
                                ? IbConfig.kDefaultCoverPhotoUrl
                                : _controller
                                    .rxCurrentIbUser.value.coverPhotoUrl,
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
                                  backgroundColor: Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.8),
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
                                  CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .backgroundColor
                                        .withOpacity(0.8),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Get.to(() => EditProfilePage());
                                      },
                                      hoverColor: IbColors.primaryColor,
                                      icon: Icon(Icons.edit,
                                          color:
                                              Theme.of(context).indicatorColor),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .backgroundColor
                                          .withOpacity(0.8),
                                      child: IconButton(
                                          onPressed: () {
                                            Get.to(() => WordCloudPage(Get.put(
                                                WordCloudController(_controller
                                                    .rxCurrentIbUser.value))));
                                          },
                                          hoverColor: IbColors.primaryColor,
                                          icon: Icon(Icons.cloud,
                                              color: Theme.of(context)
                                                  .indicatorColor))),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 8,
                      right: 0,
                      child: LimitedBox(
                        maxWidth: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              child: Obx(
                                () => IbUserAvatar(
                                    radius: 49,
                                    avatarUrl: _controller
                                        .rxCurrentIbUser.value.avatarUrl),
                              ),
                              onTap: () {
                                Get.to(
                                    () => IbMediaViewer(urls: [
                                          _controller
                                              .rxCurrentIbUser.value.avatarUrl
                                        ], currentIndex: 0),
                                    transition: Transition.zoom,
                                    fullscreenDialog: true);
                              },
                            ),
                            IbCard(
                              radius: 8,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Obx(
                                  () => Text(
                                    _controller.rxCurrentIbUser.value.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: IbConfig.kPageTitleSize),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                              color: IbColors.primaryColor.withOpacity(0.8),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Text(
                              beautifyProfilePrivacy(_controller
                                  .rxCurrentIbUser.value.profilePrivacy),
                              style: const TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize),
                            ),
                          ),
                        ))
                  ],
                ),

                /// poll stats
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Wrap(
                    children: [
                      InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        onTap: () {
                          Get.to(() => AnsweredPage(Get.put(
                              AnsweredQuestionController(
                                  _controller.rxCurrentIbUser.value.id),
                              tag: IbUtils.getUniqueId())));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: statsWidth,
                            height: statsHeight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(_controller
                                          .rxCurrentIbUser.value.answeredCount),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '✅ ANSWERED',
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      color: IbColors.lightGrey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        onTap: () {
                          Get.to(() => AskedPage(Get.put(
                              AskedQuestionsController(
                                  _controller.rxCurrentIbUser.value.id,
                                  showPublicOnly: false),
                              tag: IbUtils.getUniqueId())));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: statsWidth,
                            height: statsHeight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(_controller
                                          .rxCurrentIbUser.value.askedCount),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '✋ ASKED',
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      color: IbColors.lightGrey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        onTap: () {
                          Get.to(() => FriendList(Get.put(
                              FriendListController(
                                  _controller.rxCurrentIbUser.value),
                              tag: _controller.rxCurrentIbUser.value.id)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: statsWidth,
                            height: statsHeight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(_controller
                                          .rxCurrentIbUser
                                          .value
                                          .friendUids
                                          .length),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '👥 FRIEND(S)',
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      color: IbColors.lightGrey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        onTap: () {
                          Get.to(() => FollowedTagsPage(
                              _controller.rxCurrentIbUser.value.tags,
                              _controller.rxCurrentIbUser.value.username));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: statsWidth,
                            height: statsHeight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(_controller
                                          .rxCurrentIbUser.value.tags.length),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '🏷️ TAG(S)',
                                  style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      color: IbColors.lightGrey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// user info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        '${_controller.rxCurrentIbUser.value.fName} ${_controller.rxCurrentIbUser.value.lName} ',
                        style:
                            const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      Row(
                        children: [
                          Text(
                            _controller.rxCurrentIbUser.value.gender,
                            style: const TextStyle(
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                          if (_controller.rxCurrentIbUser.value.birthdateInMs !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Age: ${IbUtils.calculateAge(_controller.rxCurrentIbUser.value.birthdateInMs!).toString()}',
                                style: const TextStyle(
                                    fontSize: IbConfig.kNormalTextSize),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      IbDescriptionText(
                          text: _controller.rxCurrentIbUser.value.bio),
                      const Divider(
                        thickness: 2,
                      ),
                    ],
                  ),
                ),

                /// emoPics
                Obx(
                  () => Column(
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
                                    EditEmoPicController(_controller
                                        .rxCurrentIbUser.value.emoPics.obs),
                                    tag: IbUtils.getUniqueId())));
                              },
                              label: Text(
                                _controller
                                        .rxCurrentIbUser.value.emoPics.isEmpty
                                    ? 'add'.tr
                                    : 'edit'.tr,
                                style: const TextStyle(
                                    color: IbColors.primaryColor),
                              ),
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Obx(() => Wrap(
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
              ],
            )),
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
