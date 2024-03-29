import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/compare_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_ad_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_report_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/models/ib_report.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/asked_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/circles_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/compare_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/followed_tags_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/friend_list.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/word_cloud_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_ad_widget.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_profile_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_report_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/word_cloud_controller.dart';
import '../../../backend/services/user_services/ib_user_db_service.dart';
import '../../ib_widgets/ib_action_button.dart';
import '../../ib_widgets/ib_persistent_header.dart';
import '../../ib_widgets/ib_question_snippet_card.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _controller;
  const ProfilePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_controller.isNotValidUser.isTrue) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset('assets/images/cat.json'),
                  ),
                  const Text('This user does not exist'),
                  TextButton.icon(
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_ios_new),
                      label: const Text(
                        'Back',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ))
                ],
              ),
            ),
          );
        }

        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return SafeArea(
          child: DefaultTabController(
            length: 2,
            child: ExtendedNestedScrollView(
              onlyOneScrollInBody: true,
              physics: const NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Obx(
                      () => Column(
                        children: [
                          _profileHeader(context),
                          _userInfo(context),
                          _stats(),
                          _actions(),
                          if (IbUtils().getCurrentIbUser() != null &&
                              !IbUtils().isPremiumMember())
                            SafeArea(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: LimitedBox(
                                  maxHeight: 88,
                                  child: IbAdWidget(Get.put(IbAdController(),
                                      tag: IbUtils().getUniqueId())),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _tabBar(context),
                ];
              },
              body: Obx(
                () => _controller.isProfileVisible.isTrue
                    ? Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: TabBarView(children: [
                          _emoPicsTab(),
                          _askedTab(),
                        ]),
                      )
                    : const AbsorbPointer(
                        child: SizedBox(),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _handleFrAction() {
    if (_controller.isFrSent.isTrue) {
      return IbActionButton(
          color: Colors.orange,
          iconData: Icons.cancel_schedule_send,
          onPressed: () async {
            await _controller.cancelFriendRequest();
          },
          text: 'Cancel Request');
    }
    if (_controller.frNotification != null) {
      return IbActionButton(
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
                                          IbUtils().getAgoDateTimeString(
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
                              await nController
                                  .declineFr(_controller.frNotification!);
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
          iconData: Icons.notification_important,
          color: IbColors.accentColor,
          text: 'Check Request');
    }
    if (_controller.isFriend.isTrue) {
      return IbActionButton(
        iconData: Icons.person_remove,
        text: 'Unfriend',
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
        color: IbColors.errorRed,
      );
    } else {
      return IbActionButton(
          color: IbColors.accentColor,
          iconData: Icons.person_add_alt_1,
          onPressed: () async {
            if (IbUtils().getCurrentIbUser() == null ||
                (_controller.isFrSent.isTrue &&
                    _controller.frSentNotification != null)) {
              await IbUserDbService()
                  .removeNotification(_controller.frSentNotification!);
              _controller.isFrSent.value = false;
              IbUtils().showSimpleSnackBar(
                  msg: 'Friend request canceled',
                  backgroundColor: Colors.orangeAccent);
              return;
            }
            showFriendRequestDialog();
          },
          text: 'Add Friend');
    }
  }

  Widget _profileHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: Get.width / 2 + 49,
          width: Get.width,
          color: Colors.transparent,
        ),
        Obx(
          () => InkWell(
            onTap: () {
              if (_controller.rxIbUser.value.coverPhotoUrl.isEmpty) {
                return;
              }
              Get.to(
                  () => IbMediaViewer(
                      urls: [_controller.rxIbUser.value.coverPhotoUrl],
                      currentIndex: 0),
                  transition: Transition.zoom,
                  fullscreenDialog: true);
            },
            child: SizedBox(
              width: Get.width,
              height: Get.width / 2.0,
              child: _controller.rxIbUser.value.coverPhotoUrl.isEmpty
                  ? Image.asset(
                      'assets/images/header_img.jpg',
                      fit: BoxFit.fill,
                    )
                  : CachedNetworkImage(
                      imageUrl: _controller.rxIbUser.value.coverPhotoUrl,
                      fit: BoxFit.fill,
                      progressIndicatorBuilder: (context, string, progress) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                            value: progress.progress,
                          ),
                        );
                      },
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
                      CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .backgroundColor
                              .withOpacity(0.8),
                          child: IconButton(
                              onPressed: () {
                                Get.to(() => WordCloudPage(Get.put(
                                    WordCloudController(
                                        _controller.rxIbUser.value))));
                              },
                              icon: Icon(Icons.cloud,
                                  color: Theme.of(context).indicatorColor))),
                      const SizedBox(
                        width: 8,
                      ),
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).backgroundColor.withOpacity(0.8),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Get.bottomSheet(IbReportCard(
                                ibReportController: Get.put(IbReportController(
                                    type: ReportType.user,
                                    reporteeId: _controller.uid,
                                    url: ''))));
                          },
                          icon: const Icon(
                            Icons.report,
                            color: IbColors.errorRed,
                          ),
                        ),
                      )
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
          child: Obx(
            () => GestureDetector(
              onTap: () {
                Get.to(
                    () => IbMediaViewer(
                        urls: [_controller.rxIbUser.value.avatarUrl],
                        currentIndex: 0),
                    transition: Transition.zoom);
              },
              child: IbUserAvatar(
                  showBorder: true,
                  radius: 49,
                  avatarUrl: _controller.rxIbUser.value.avatarUrl),
            ),
          ),
        ),
        Positioned(
            bottom: 57,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _distance(),
                IbCard(
                  color: IbColors.primaryColor.withOpacity(0.8),
                  radius: 8,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      beautifyProfilePrivacy(
                          _controller.rxIbUser.value.profilePrivacy),
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _distance() {
    if (_controller.isProfileVisible.isTrue &&
        _controller.rxIbUser.value.geoPoint != null &&
        (_controller.rxIbUser.value.geoPoint as GeoPoint).latitude != 0 &&
        (_controller.rxIbUser.value.geoPoint as GeoPoint).longitude != 0 &&
        IbUtils().getCurrentIbUser()!.geoPoint != null &&
        (IbUtils().getCurrentIbUser()!.geoPoint as GeoPoint).latitude != 0 &&
        (IbUtils().getCurrentIbUser()!.geoPoint as GeoPoint).longitude != 0 &&
        (Duration(
                    milliseconds: Timestamp.now().millisecondsSinceEpoch -
                        IbUtils().getCurrentIbUser()!.lastLocationTimestampInMs)
                .inDays <=
            IbConfig.kValidNearbyLocationDurationInDays) &&
        (Duration(
                    milliseconds: Timestamp.now().millisecondsSinceEpoch -
                        _controller.rxIbUser.value.lastLocationTimestampInMs)
                .inDays <=
            IbConfig.kValidNearbyLocationDurationInDays)) {
      final myGeoPoint = IbUtils().getCurrentIbUser()!.geoPoint as GeoPoint;
      final userGeoPoint = _controller.rxIbUser.value.geoPoint as GeoPoint;

      final double distanceInMeters = Geolocator.distanceBetween(
          myGeoPoint.latitude,
          myGeoPoint.longitude,
          userGeoPoint.latitude,
          userGeoPoint.longitude);

      return Tooltip(
        message:
            'This user is ${IbUtils().getDistanceString(distanceInMeters)} away',
        child: IbCard(
            elevation: 0,
            radius: 8,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(
                IbUtils().getDistanceString(distanceInMeters),
                style: const TextStyle(fontSize: IbConfig.kDescriptionTextSize),
              ),
            )),
      );
    }
    return const SizedBox();
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StaggeredGrid.count(crossAxisCount: 4, children: [
        Obx(
          () => IbProfileStats(
            number: _controller.commonAnswers.length,
            onTap: () {
              if (_controller.isProfileVisible.isFalse ||
                  _controller.commonAnswers.isEmpty) {
                return;
              }
              Get.to(
                () => ComparePage(
                  Get.put(
                    CompareController(
                      title: '👍 AGREE',
                      questionIds: _controller.commonAnswers,
                      uids: [_controller.uid, IbUtils().getCurrentUid() ?? ''],
                    ),
                  ),
                ),
              );
            },
            subText: '👍 AGREE',
          ),
        ),
        Obx(
          () => IbProfileStats(
              number: _controller.uncommonAnswers.length,
              onTap: () {
                if (_controller.isProfileVisible.isFalse ||
                    _controller.uncommonAnswers.isEmpty) {
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
                          IbUtils().getCurrentUid() ?? ''
                        ],
                      ),
                    ),
                  ),
                );
              },
              subText: '👎 DISAGREE'),
        ),
        Obx(() => IbProfileStats(
            number: _controller.rxIbUser.value.askedCount,
            onTap: () {
              if (_controller.isProfileVisible.isFalse ||
                  _controller.rxIbUser.value.askedCount == 0) {
                return;
              }
              Get.to(
                () => AskedPage(
                  Get.put(AskedQuestionsController(_controller.uid),
                      tag: IbUtils().getUniqueId()),
                ),
              );
            },
            subText: '✋ POLL(S)')),
        Obx(() => IbProfileStats(
            number: _controller.rxIbUser.value.friendUids.length,
            onTap: () {
              if (_controller.isProfileVisible.isFalse ||
                  _controller.rxIbUser.value.friendUids.isEmpty) {
                return;
              }
              Get.to(() => FriendList(Get.put(
                  FriendListController(_controller.rxIbUser.value),
                  tag: _controller.rxIbUser.value.id)));
            },
            subText: '👥 FRIEND(S)')),
        Obx(() => IbProfileStats(
            number: _controller.rxIbUser.value.tags.length,
            onTap: () {
              if (_controller.isProfileVisible.isFalse ||
                  _controller.rxIbUser.value.tags.isEmpty) {
                return;
              }
              Get.to(() => FollowedTagsPage(_controller.rxIbUser.value.tags,
                  _controller.rxIbUser.value.username));
            },
            subText: '🏷️ TAG(S)')),
        Obx(
          () => IbProfileStats(
              number: _controller.circles.length,
              onTap: () {
                if (_controller.isProfileVisible.isFalse ||
                    _controller.circles.isEmpty) {
                  return;
                }
                Get.to(() => CirclesPage(_controller.circles));
              },
              subText: "⭕ CIRCLE(S)"),
        ),
      ]),
    );
  }

  Widget _userInfo(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _controller.rxIbUser.value.username,
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Match Interest',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IbLinearIndicator(endValue: _controller.compScore.value),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_controller.rxIbUser.value.fName} ${_controller.rxIbUser.value.lName} ',
              style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _controller.rxIbUser.value.gender,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                if (_controller.rxIbUser.value.birthdateInMs != null &&
                    !_controller.rxIbUser.value.isAgeHidden)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Age: ${IbUtils().calculateAge(_controller.rxIbUser.value.birthdateInMs!).toString()}',
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
            child: IbDescriptionText(text: _controller.rxIbUser.value.bio),
          ),
          const Divider(
            thickness: 2,
          ),
        ],
      );
    });
  }

  Widget _emoPicsTab() {
    return Obx(() {
      if (_controller.isProfileVisible.isTrue) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => StaggeredGrid.count(
                    crossAxisCount: 2,
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
                  ),
                )
            ],
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget _askedTab() {
    final AskedQuestionsController askedQuestionsController = Get.put(
        AskedQuestionsController(_controller.uid),
        tag: IbUtils().getUniqueId());
    return Obx(() {
      if (askedQuestionsController.createdQuestions.isEmpty) {
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
        controller: askedQuestionsController.askedRefreshController,
        enablePullDown: false,
        enablePullUp: askedQuestionsController.createdQuestions.length >=
            IbConfig.kPerPage,
        onLoading: () async {
          await askedQuestionsController.loadMore();
        },
        child: Obx(
          () => ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: askedQuestionsController.createdQuestions
                .map((element) => IbQuestionSnippetCard(element))
                .toList(),
          ),
        ),
      );
    });
  }

  Widget _actions() {
    return Column(
      children: [
        const Divider(
          thickness: 2,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => (_controller.isProfileVisible.isTrue ||
                    _controller.isFriend.value)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IbActionButton(
                        color: IbColors.primaryColor,
                        iconData: Icons.message,
                        onPressed: () {
                          Get.to(() => ChatPage(Get.put(
                              ChatPageController(
                                  recipientId: _controller.rxIbUser.value.id),
                              tag: _controller.rxIbUser.value.id)));
                        },
                        text: 'Message'),
                  )
                : const SizedBox()),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(child: _handleFrAction()),
                )),
          ],
        ),
        const Divider(
          thickness: 2,
        ),
      ],
    );
  }

  Widget _tabBar(BuildContext context) {
    return Obx(() {
      Widget _widget = const SizedBox();
      if (_controller.rxIbUser.value.profilePrivacy ==
          IbUser.kUserPrivacyPrivate) {
        _widget = Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('private_profile'.tr),
        ));
      }
      if (_controller.rxIbUser.value.profilePrivacy ==
              IbUser.kUserPrivacyFrOnly &&
          _controller.isFriend.isFalse) {
        _widget = Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('friends_only_profile'.tr),
        ));
      }

      if (_controller.isProfileVisible.isTrue) {
        _widget = const IbCard(
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
        );
      }
      return SliverOverlapAbsorber(
        handle:
            ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverPersistentHeader(
          pinned: true,
          delegate: IbPersistentHeader(height: 40, widget: _widget),
        ),
      );
    });
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
                    IbUtils().hideKeyboard();
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
