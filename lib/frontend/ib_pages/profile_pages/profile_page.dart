import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/compare_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/asked_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/compare_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/followed_tags_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/friend_list.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/word_cloud_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/word_cloud_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _controller;

  const ProfilePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        return SafeArea(
          child: SmartRefresher(
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
                              Obx(
                                () => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_controller.isProfileVisible.isTrue ||
                                        _controller.isFriend.value)
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .backgroundColor
                                            .withOpacity(0.8),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            Get.to(() => ChatPage(Get.put(
                                                ChatPageController(
                                                    recipientId: _controller
                                                        .rxIbUser.value.id)
                                                  ..title.value = _controller
                                                      .rxIbUser.value.username
                                                  ..avatarUrl.value =
                                                      _controller.rxIbUser.value
                                                          .avatarUrl,
                                                tag: _controller
                                                    .rxIbUser.value.id)));
                                          },
                                          icon: Icon(Icons.message,
                                              color: Theme.of(context)
                                                  .indicatorColor),
                                        ),
                                      ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    _handleFrIcon(context),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .backgroundColor
                                            .withOpacity(0.8),
                                        child: IconButton(
                                            onPressed: () {
                                              Get.to(() => WordCloudPage(
                                                  Get.put(WordCloudController(
                                                      _controller
                                                          .rxIbUser.value))));
                                            },
                                            icon: Icon(Icons.cloud,
                                                color: Theme.of(context)
                                                    .indicatorColor))),
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
                                        icon: Icon(Icons.more_vert,
                                            color: Theme.of(context)
                                                .indicatorColor),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            child: Obx(
                              () => IbUserAvatar(
                                  radius: 49,
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
                              beautifyProfilePrivacy(
                                  _controller.rxIbUser.value.profilePrivacy),
                              style: const TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize),
                            ),
                          ),
                        ))
                  ],
                ),

                /// poll stats
                Wrap(
                  children: [
                    InkWell(
                      customBorder: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      onTap: () {
                        if (_controller.isProfileVisible.isFalse) {
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
                        padding: const EdgeInsets.all(4.0),
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
                        if (_controller.isProfileVisible.isFalse) {
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
                        padding: const EdgeInsets.all(4.0),
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
                        if (_controller.isProfileVisible.isFalse) {
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
                        padding: const EdgeInsets.all(4.0),
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
                                        _controller.rxIbUser.value.askedCount),
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
                        if (_controller.isProfileVisible.isFalse) {
                          return;
                        }
                        Get.to(() => FriendList(Get.put(
                            FriendListController(_controller.rxIbUser.value),
                            tag: _controller.rxIbUser.value.id)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
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
                                        .rxIbUser.value.friendUids.length),
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
                        if (_controller.isProfileVisible.isFalse) {
                          return;
                        }
                        Get.to(() => FollowedTagsPage(
                            _controller.rxIbUser.value.tags,
                            _controller.rxIbUser.value.username));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
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
                                        _controller.rxIbUser.value.tags.length),
                                    style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: IbConfig.kPageTitleSize),
                                  )),
                              const Text(
                                '🏷️ TAGS',
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

                if (_controller.rxIbUser.value.profilePrivacy ==
                        IbUser.kUserPrivacyPrivate ||
                    _controller.isBlocked.isTrue)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('private_profile'.tr),
                  )),

                if (_controller.rxIbUser.value.profilePrivacy ==
                        IbUser.kUserPrivacyFrOnly &&
                    _controller.isFriend.isFalse &&
                    _controller.isBlocked.isFalse)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('friends_only_profile'.tr),
                  )),

                /// user info
                if (_controller.isProfileVisible.isTrue)
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              Text(
                                _controller.rxIbUser.value.gender,
                                style: const TextStyle(
                                    fontSize: IbConfig.kNormalTextSize),
                              ),
                              if (_controller.rxIbUser.value.birthdateInMs !=
                                  null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Age: ${IbUtils.calculateAge(_controller.rxIbUser.value.birthdateInMs!).toString()}',
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
                              text: _controller.rxIbUser.value.bio),
                          const Divider(
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                /// emoPics
                if (_controller.isProfileVisible.isTrue)
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
                                style:
                                    const TextStyle(color: IbColors.lightGrey),
                              ),
                            )
                        ],
                      )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _handleFrIcon(BuildContext context) {
    if (_controller.frNotification != null) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final Widget dialog = IbCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IbUserAvatar(
                            avatarUrl: _controller.rxIbUser.value.avatarUrl,
                            uid: _controller.frNotification!.senderId,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _controller.rxIbUser.value.username,
                                      style: const TextStyle(
                                          fontSize: IbConfig.kNormalTextSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          IbUtils.getAgoDateTimeString(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                (_controller.frNotification!
                                                        .timestamp as Timestamp)
                                                    .millisecondsSinceEpoch),
                                          ),
                                          style: const TextStyle(
                                              fontSize:
                                                  IbConfig.kDescriptionTextSize,
                                              color: IbColors.lightGrey)),
                                    )
                                  ],
                                ),
                                Text(
                                  'sent_you_a_friend_request'.tr,
                                  style: const TextStyle(
                                      color: IbColors.lightGrey),
                                ),
                                if (_controller.frNotification!.body.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child:
                                        Text(_controller.frNotification!.body),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: IbElevatedButton(
                            textTrKey: 'decline',
                            onPressed: () async {
                              final NotificationController nController =
                                  Get.find();
                              Get.back();
                              await nController.removeNotification(
                                  _controller.frNotification!);
                              await _controller.onRefresh();
                            },
                            color: IbColors.errorRed,
                          )),
                          Expanded(
                            child: IbElevatedButton(
                                textTrKey: 'accept',
                                onPressed: () async {
                                  Get.back();
                                  final NotificationController nController =
                                      Get.find();
                                  await nController
                                      .acceptFr(_controller.frNotification!);
                                  await _controller.onRefresh();
                                }),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
            Get.bottomSheet(dialog, ignoreSafeArea: false);
          },
          icon: const Icon(Icons.notification_important,
              color: IbColors.accentColor),
        ),
      );
    }
    if (_controller.isFriend.isTrue) {
      return CircleAvatar(
        backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            Get.dialog(IbDialog(
              title:
                  'Are you sure to unfriend ${_controller.rxIbUser.value.username}?',
              subtitle: '',
              onPositiveTap: () async {
                Get.back();
                await _controller.removeFriend();
              },
            ));
          },
          icon: Icon(Icons.person_remove,
              color: Theme.of(context).indicatorColor),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Theme.of(context).backgroundColor.withOpacity(0.8),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          if (IbUtils.getCurrentIbUser() == null ||
              (_controller.isFrSent.isTrue &&
                  _controller.frSentNotification != null)) {
            await IbUserDbService()
                .removeNotification(_controller.frSentNotification!);
            _controller.isFrSent.value = false;
            IbUtils.showSimpleSnackBar(
                msg: 'Friend request canceled',
                backgroundColor: Colors.orangeAccent);
            return;
          }
          showFriendRequestDialog();
        },
        icon: Icon(
            _controller.isFrSent.isTrue ? Icons.cancel : Icons.person_add,
            color: Theme.of(context).indicatorColor),
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

  void showFriendRequestDialog() {
    final TextEditingController editingController = TextEditingController();
    final Widget dialog = IbCard(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'friend_request_dialog_title'
                .trParams({'username': _controller.rxIbUser.value.username}),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IbUserAvatar(
                  avatarUrl: _controller.rxIbUser.value.avatarUrl,
                  uid: _controller.rxIbUser.value.id,
                  radius: 32,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: editingController,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onChanged: (requestMsg) {},
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: IbConfig.kSecondaryTextSize,
                  ),
                  maxLength: IbConfig.kFriendRequestMsgMaxLength,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: IbColors.lightGrey),
                    hintText: 'friend_request_msg_hint'.tr,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: IbElevatedButton(
                onPressed: () {
                  Get.back();
                },
                textTrKey: 'cancel',
                color: IbColors.lightGrey,
              )),
              Expanded(
                flex: 2,
                child: IbElevatedButton(
                  onPressed: () {
                    _controller.addFriend(editingController.text.trim());
                    Get.back();
                    IbUtils.hideKeyboard();
                  },
                  textTrKey: 'send_friend_request',
                ),
              ),
            ],
          )
        ],
      ),
    ));

    Get.bottomSheet(dialog, ignoreSafeArea: false);
  }
}
