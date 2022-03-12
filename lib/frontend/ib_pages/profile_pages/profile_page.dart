import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/compare_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/asked_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/compare_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _controller;

  const ProfilePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          if (_controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }
          return SmartRefresher(
            scrollController: _controller.scrollController,
            controller: _controller.refreshController,
            onRefresh: () async {
              await _controller.onRefresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller.scrollController,
              children: <Widget>[
                Stack(
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          Get.to(
                              () => IbMediaViewer(urls: [
                                    if (_controller
                                        .rxIbUser.value.coverPhotoUrl.isEmpty)
                                      IbConfig.kDefaultCoverPhotoUrl
                                    else
                                      _controller.rxIbUser.value.coverPhotoUrl
                                  ], currentIndex: 0),
                              transition: Transition.zoom,
                              fullscreenDialog: true);
                        },
                        child: SizedBox(
                          width: Get.width,
                          height: Get.width / 1.78,
                          child: CachedNetworkImage(
                            imageUrl:
                                _controller.rxIbUser.value.coverPhotoUrl.isEmpty
                                    ? IbConfig.kDefaultCoverPhotoUrl
                                    : _controller.rxIbUser.value.coverPhotoUrl,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                      onPressed: () {},
                                      icon: Icon(Icons.message,
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
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      icon: Icon(Icons.person_add,
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
                                          onPressed: () {},
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child: Obx(
                              () => IbUserAvatar(
                                  radius: 40,
                                  compScore: _controller.compScore.value,
                                  avatarUrl:
                                      _controller.rxIbUser.value.avatarUrl),
                            ),
                            onTap: () {
                              Get.to(
                                  () => IbMediaViewer(urls: [
                                        _controller.rxIbUser.value.avatarUrl
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
                                  _controller.rxIbUser.value.username,
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
                  ],
                ),

                /// poll stats
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        onTap: () {
                          if (_controller.rxIbUser.value.isPrivate) {
                            IbUtils.showSimpleSnackBar(
                                msg: 'private_profile'.tr,
                                backgroundColor: IbColors.errorRed);
                            return;
                          }
                          Get.to(
                            () => ComparePage(
                              Get.put(
                                CompareController(
                                  title: '👍 AGREE',
                                  questionIds: _controller.commonAnswers,
                                  uids: [
                                    _controller.uid,
                                    IbUtils.getCurrentUid() ?? ''
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: 88,
                            height: 88 / 1.618,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(
                                          _controller.commonAnswers.length),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '👍 AGREE',
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
                          if (_controller.rxIbUser.value.isPrivate) {
                            IbUtils.showSimpleSnackBar(
                                msg: 'private_profile'.tr,
                                backgroundColor: IbColors.errorRed);
                            return;
                          }
                          Get.to(
                            () => ComparePage(
                              Get.put(
                                CompareController(
                                  title: '👎 DISAGREE',
                                  questionIds: _controller.uncommonAnswers,
                                  uids: [
                                    _controller.uid,
                                    IbUtils.getCurrentUid() ?? ''
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: 88,
                            height: 88 / 1.618,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(
                                          _controller.uncommonAnswers.length),
                                      style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize),
                                    )),
                                const Text(
                                  '👎 DISAGREE',
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
                          if (_controller.rxIbUser.value.isPrivate) {
                            IbUtils.showSimpleSnackBar(
                                msg: 'private_profile'.tr,
                                backgroundColor: IbColors.errorRed);
                            return;
                          }
                          Get.to(
                            () => AskedPage(
                              Get.put(AskedQuestionsController(_controller.uid),
                                  tag: IbUtils.getUniqueId()),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              color: Theme.of(context).backgroundColor,
                            ),
                            width: 88,
                            height: 88 / 1.618,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                      IbUtils.getStatsString(_controller
                                          .rxIbUser.value.askedCount),
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
                      )
                    ],
                  ),
                ),

                if (_controller.rxIbUser.value.isPrivate)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('private_profile'.tr),
                  )),

                /// user info
                if (!_controller.rxIbUser.value.isPrivate)
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            '${_controller.rxIbUser.value.fName} ${_controller.rxIbUser.value.lName} ',
                            style: const TextStyle(
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                          Row(
                            children: [
                              Text(_controller.rxIbUser.value.gender),
                              if (_controller.rxIbUser.value.birthdateInMs !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                      '🎂 ${IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(_controller.rxIbUser.value.birthdateInMs ?? 0))}'),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          IbDescriptionText(
                              text: _controller.rxIbUser.value.bio),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                /// emoPics
                if (!_controller.rxIbUser.value.isPrivate)
                  Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'My EmoPics',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kPageTitleSize),
                            ),
                          ),
                          Obx(() => Wrap(
                                children: _controller.rxIbUser.value.emoPics
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
                          if (_controller.rxIbUser.value.emoPics.isEmpty)
                            Center(
                                child: Text(
                              'nothing'.tr,
                              style: const TextStyle(color: IbColors.lightGrey),
                            ))
                        ],
                      )),
              ],
            ),
          );
        }),
      ),
    );
  }
}
