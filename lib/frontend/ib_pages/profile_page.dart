import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/common_answers_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/uncommon_answers_controller.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  final bool showAppBar;
  const ProfilePage(this.uid, {Key? key, this.showAppBar = false})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnsweredQuestionController _answeredQuestionController;
  late AskedQuestionsController _createdQuestionController;
  late CommonAnswersController _commonAnswersController;
  late UncommonAnswersController _uncommonAnswersController;
  late ProfileController _profileController;
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _profileController =
        Get.put(ProfileController(widget.uid), tag: widget.uid);
    _createdQuestionController =
        Get.put(AskedQuestionsController(widget.uid), tag: widget.uid);

    if (widget.uid == IbUtils.getCurrentUid()) {
      _answeredQuestionController =
          Get.put(AnsweredQuestionController(widget.uid), tag: widget.uid);
      _homeController = Get.find();
    } else {
      _commonAnswersController =
          Get.put(CommonAnswersController(widget.uid), tag: widget.uid);
      _uncommonAnswersController =
          Get.put(UncommonAnswersController(widget.uid), tag: widget.uid);
    }

    _tabController = TabController(
        vsync: this, length: _profileController.isMe.isTrue ? 2 : 3);
    IbUtils.hideKeyboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: IbColors.lightBlue,
              title: Obx(() => Text(
                    _profileController.username.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
            )
          : null,
      body: Obx(
        () => _profileController.isLoading.isTrue
            ? const Center(
                child: IbProgressIndicator(),
              )
            : NestedScrollView(
                headerSliverBuilder: (context, value) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomLeft,
                            children: [
                              ///cover photo
                              Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    if (_profileController.isMe.isFalse) {
                                      return;
                                    }
                                    showCoverPhotoBottomSheet();
                                  },
                                  child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: handleCoverPhoto()),
                                ),
                              ),

                              /// avatar
                              Obx(
                                () => Positioned(
                                  left: 16,
                                  bottom: -40,
                                  child: IbUserAvatar(
                                      disableOnTap: true,
                                      radius: 40,
                                      uid: widget.uid,
                                      avatarUrl: _profileController.isMe.isTrue
                                          ? _homeController
                                              .currentIbAvatarUrl.value
                                          : _profileController.avatarUrl.value),
                                ),
                              ),
                            ],
                          ),

                          /// name info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 40, left: 16),
                                  child: Obx(
                                    () => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '#${_profileController.isMe.isTrue ? _homeController.currentIbUsername.value : _profileController.username.value}',
                                            style: const TextStyle(
                                                fontSize:
                                                    IbConfig.kPageTitleSize,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                          _profileController.isMe.isTrue
                                              ? _homeController
                                                  .currentIbName.value
                                              : _profileController.name.value,
                                          style: const TextStyle(
                                              fontSize:
                                                  IbConfig.kNormalTextSize),
                                        ),
                                        /*  Text(
                                          '🎂 ${_profileController.isMe.isTrue ? IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(_homeController.currentBirthdate.value)) : IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(_profileController.birthdateInMs.value))}',
                                          style: const TextStyle(
                                              fontSize:
                                                  IbConfig.kNormalTextSize),
                                        ),*/
                                        if (_profileController.isMe.isFalse)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'match_interests'.tr,
                                                style: const TextStyle(
                                                    fontSize: IbConfig
                                                        .kNormalTextSize,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              IbLinearIndicator(
                                                endValue: _profileController
                                                    .compScore.value,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              /// questions stats
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Obx(
                                    () => Wrap(
                                      children: [
                                        IbStats(
                                            title: 'Answered',
                                            num: _profileController
                                                .totalAnswered.value),
                                        IbStats(
                                            title: 'Asked',
                                            num: _profileController
                                                .totalAsked.value),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),

                          if (_profileController.isMe.isFalse &&
                              _profileController.description.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Obx(
                                () => Text(
                                  _profileController.description.value,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kNormalTextSize),
                                ),
                              ),
                            ),
                          if (_profileController.isMe.isTrue)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Obx(
                                () => Text(
                                  _homeController.currentBio.value,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kNormalTextSize),
                                ),
                              ),
                            ),

                          if (_profileController.isMe.isFalse)
                            _buildActionButtons(),

                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                        pinned: true,
                        delegate: PersistentHeader(
                          widget: TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            tabs: [
                              if (_profileController.isMe.isTrue)
                                Tab(
                                    text:
                                        'Answered Questions(${_profileController.totalAnswered.value})'),
                              if (_profileController.isMe.isFalse)
                                Obx(() => Tab(
                                    text:
                                        'Common Answers(${_commonAnswersController.ibQuestions.length})')),
                              if (_profileController.isMe.isFalse)
                                Obx(() => Tab(
                                    text:
                                        'Different Answers(${_uncommonAnswersController.ibQuestions.length})')),
                              Tab(
                                  text:
                                      'Asked Questions(${_profileController.totalAsked.value})'),
                            ],
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            unselectedLabelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            labelColor: Colors.black,
                            unselectedLabelColor: IbColors.lightGrey,
                            indicatorColor: _tabController.length == 1
                                ? Colors.transparent
                                : IbColors.primaryColor,
                          ),
                        )),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    if (_profileController.isMe.isTrue) buildAnsweredQTab(),
                    if (_profileController.isMe.isFalse)
                      buildCommonAnswersTab(),
                    if (_profileController.isMe.isFalse)
                      buildUncommonAnswersTab(),
                    buildAskedTab(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget handleCoverPhoto() {
    if (_profileController.isMe.isTrue) {
      final Widget coverPhoto = _homeController.currentIbCoverPhotoUrl.isEmpty
          ? Image.asset(
              'assets/images/default_cover_photo.jpeg',
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              progressIndicatorBuilder: (context, value, progress) {
                /// Todo keep eye on this one
                if (progress.progress == null) {
                  return const SizedBox();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    IbProgressIndicator(),
                    Text('rendering cover photo...'),
                  ],
                );
              },
              fit: BoxFit.fitHeight,
              imageUrl: _homeController.currentIbCoverPhotoUrl.value,
            );
      return Stack(
        fit: StackFit.expand,
        children: [
          coverPhoto,
          const Positioned(
            right: 8,
            bottom: 8,
            child: Icon(
              Icons.edit_outlined,
              color: IbColors.lightBlue,
            ),
          ),
        ],
      );
    }

    return _profileController.coverPhotoUrl.isEmpty
        ? Image.asset(
            'assets/images/default_cover_photo.jpeg',
            fit: BoxFit.cover,
          )
        : CachedNetworkImage(
            fit: BoxFit.fitHeight,
            imageUrl: _profileController.coverPhotoUrl.value,
          );
  }

  Widget buildAnsweredQTab() {
    final refreshController = RefreshController();
    return Obx(
      () {
        if (_answeredQuestionController.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return SmartRefresher(
          footer: const ClassicFooter(
            textStyle: TextStyle(color: IbColors.primaryColor),
            failedIcon: Icon(
              Icons.error_outline,
              color: IbColors.errorRed,
            ),
            loadingIcon: IbProgressIndicator(
              width: 24,
              height: 24,
              padding: 0,
            ),
          ),
          controller: refreshController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            await _answeredQuestionController.loadMore();
            if (_answeredQuestionController.lastDoc == null) {
              refreshController.loadNoData();
              return;
            }
            refreshController.loadComplete();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final AnsweredQuestionItem item =
                  _answeredQuestionController.myAnsweredQuestions[index];

              final tag = 'answered_${item.ibQuestion.id}';
              late IbQuestionItemController _controller;
              if (Get.isRegistered<IbQuestionItemController>(tag: tag)) {
                _controller = Get.find(tag: tag);
              } else {
                _controller = Get.put(
                    IbQuestionItemController(
                        ibAnswer: item.ibAnswer,
                        ibQuestion: item.ibQuestion,
                        disableAvatarOnTouch:
                            item.ibQuestion.creatorId == widget.uid,
                        isExpandable: true),
                    tag: tag);
              }

              _controller.isExpanded.value = index == 0;

              if (item.ibQuestion.questionType == IbQuestion.kMultipleChoice) {
                return IbMcQuestionCard(_controller);
              }
              return IbScQuestionCard(_controller);
            },
            itemCount: _answeredQuestionController.myAnsweredQuestions.length,
          ),
        );
      },
    );
  }

  Widget buildAskedTab() {
    final refreshController = RefreshController();
    return Obx(
      () {
        if (_createdQuestionController.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        return SmartRefresher(
          footer: const ClassicFooter(
            textStyle: TextStyle(color: IbColors.primaryColor),
            failedIcon: Icon(
              Icons.error_outline,
              color: IbColors.errorRed,
            ),
            loadingIcon: IbProgressIndicator(
              width: 24,
              height: 24,
              padding: 0,
            ),
          ),
          controller: refreshController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            await _createdQuestionController.loadMore();
            if (_createdQuestionController.lastDoc == null) {
              refreshController.loadNoData();
              return;
            }
            refreshController.loadComplete();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final IbQuestion item =
                  _createdQuestionController.createdQuestions[index];
              final tag = 'asked_${item.id}';
              late IbQuestionItemController _controller;
              if (Get.isRegistered<IbQuestionItemController>(tag: tag)) {
                _controller = Get.find(tag: tag);
              } else {
                _controller = Get.put(
                    IbQuestionItemController(
                        ibQuestion: item,
                        disableChoiceOnTouch: true,
                        showActionButtons: false,
                        disableAvatarOnTouch: item.creatorId == widget.uid),
                    tag: tag);
              }
              _controller.isExpanded.value = false;

              if (item.questionType == IbQuestion.kMultipleChoice) {
                return IbMcQuestionCard(_controller);
              }
              return IbScQuestionCard(_controller);
            },
            itemCount: _createdQuestionController.createdQuestions.length,
          ),
        );
      },
    );
  }

  Widget buildCommonAnswersTab() {
    final refreshController = RefreshController();
    return Obx(
      () {
        return SmartRefresher(
          footer: const ClassicFooter(
            textStyle: TextStyle(color: IbColors.primaryColor),
            failedIcon: Icon(
              Icons.error_outline,
              color: IbColors.errorRed,
            ),
            loadingIcon: IbProgressIndicator(
              width: 24,
              height: 24,
              padding: 0,
            ),
          ),
          controller: refreshController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            if (_commonAnswersController.lastIbAnswer == null) {
              refreshController.loadNoData();
              return;
            }

            await _commonAnswersController.loadMore();
            refreshController.loadComplete();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final IbQuestion item =
                  _commonAnswersController.ibQuestions[index];
              final tag = 'common_${item.id}';
              late IbQuestionItemController _controller;
              if (Get.isRegistered(tag: tag)) {
                _controller = Get.find(tag: tag);
              } else {
                _controller = Get.put(
                    IbQuestionItemController(
                        ibAnswer:
                            _commonAnswersController.retrieveAnswer(item.id),
                        ibQuestion: item,
                        isExpandable: true,
                        disableAvatarOnTouch: item.creatorId == widget.uid),
                    tag: tag);
              }

              if (item.questionType == IbQuestion.kMultipleChoice) {
                return IbMcQuestionCard(_controller);
              }
              return IbScQuestionCard(_controller);
            },
            itemCount: _commonAnswersController.ibQuestions.length,
          ),
        );
      },
    );
  }

  Widget buildUncommonAnswersTab() {
    final refreshController = RefreshController();
    return Obx(
      () {
        return SmartRefresher(
          footer: const ClassicFooter(
            textStyle: TextStyle(color: IbColors.primaryColor),
            failedIcon: Icon(
              Icons.error_outline,
              color: IbColors.errorRed,
            ),
            loadingIcon: IbProgressIndicator(
              width: 24,
              height: 24,
              padding: 0,
            ),
          ),
          controller: refreshController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            if (_uncommonAnswersController.lastIbAnswer == null) {
              refreshController.loadNoData();
              return;
            }

            await _uncommonAnswersController.loadMore();
            refreshController.loadComplete();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final IbQuestion item =
                  _uncommonAnswersController.ibQuestions[index];
              final tag = 'uncommon_${item.id}';
              late IbQuestionItemController _controller;

              if (Get.isRegistered(tag: tag)) {
                _controller = Get.find(tag: tag);
              } else {
                _controller = Get.put(
                    IbQuestionItemController(
                        ibAnswer:
                            _uncommonAnswersController.retrieveAnswer(item.id),
                        showMyAnswer: true,
                        ibQuestion: item,
                        isExpandable: true,
                        disableAvatarOnTouch: item.creatorId == widget.uid),
                    tag: tag);
              }

              if (item.questionType == IbQuestion.kMultipleChoice) {
                return IbMcQuestionCard(_controller);
              }
              return IbScQuestionCard(_controller);
            },
            itemCount: _uncommonAnswersController.ibQuestions.length,
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IbActionButton(
                text: 'Message',
                iconData: Icons.message_outlined,
                color: IbColors.primaryColor,
                onPressed: () {
                  final List<String> memberUids = [
                    IbUtils.getCurrentUid()!,
                    widget.uid
                  ];
                  Get.to(() => ChatPage(Get.put(ChatPageController(memberUids),
                      tag: memberUids.toString())));
                },
              ),
              if (_profileController.friendshipStatus.value.isEmpty)
                IbActionButton(
                  text: 'Add Friend',
                  iconData: Icons.person_add_alt_1_outlined,
                  color: IbColors.accentColor,
                  onPressed: () => showFriendRequestDialog(),
                )
              else if (_profileController.friendshipStatus.value ==
                  IbFriend.kFriendshipStatusAccepted)
                IbActionButton(
                  text: 'Unfriend',
                  iconData: Icons.person_remove_alt_1_outlined,
                  color: IbColors.errorRed,
                  onPressed: () => _profileController.unfriend(),
                )
              else if (_profileController.friendshipStatus.value ==
                  IbFriend.kFriendshipStatusRequestSent)
                IbActionButton(
                  text: 'Cancel Request',
                  iconData: Icons.cancel_outlined,
                  color: Colors.orangeAccent,
                  onPressed: () => _profileController.unfriend(),
                )
            ],
          ),
        ),
      ),
    );
  }

  void showFriendRequestDialog() {
    final Widget dialog = IbCard(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'friend_request_dialog_title'.trParams(
              {'username': _profileController.username.value},
            ),
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
                  avatarUrl: _profileController.avatarUrl.value,
                  uid: _profileController.uid,
                  radius: 32,
                ),
              ),
              Expanded(
                child: TextField(
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onChanged: (requestMsg) {
                    _profileController.requestMsg = requestMsg;
                  },
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
                color: IbColors.primaryColor,
              )),
              Expanded(
                flex: 2,
                child: IbElevatedButton(
                  onPressed: () {
                    _profileController.sendFriendRequest();
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

    Get.bottomSheet(dialog);
  }

  void showCoverPhotoBottomSheet() {
    final Widget options = ListView(
      shrinkWrap: true,
      children: [
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 90,
            );

            if (pickedFile != null) {
              final File? file = await IbUtils.showImageCropper(pickedFile.path,
                  lockAspectRatio: true,
                  minimumAspectRatio: 16 / 9,
                  resetAspectRatioEnabled: false,
                  height: 9,
                  width: 16,
                  initAspectRatio: CropAspectRatioPreset.ratio16x9,
                  ratios: <CropAspectRatioPreset>[
                    CropAspectRatioPreset.ratio16x9
                  ],
                  cropStyle: CropStyle.rectangle);

              if (file != null) {
                _profileController.updateCoverPhoto(file.path);
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            color: IbColors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(Icons.camera_alt_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text('Take a photo',
                      style: TextStyle(fontSize: IbConfig.kNormalTextSize)),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 88,
            );

            if (pickedFile != null) {
              final File? file = await IbUtils.showImageCropper(pickedFile.path,
                  lockAspectRatio: true,
                  minimumAspectRatio: 16 / 9,
                  resetAspectRatioEnabled: false,
                  height: 9,
                  width: 16,
                  initAspectRatio: CropAspectRatioPreset.ratio16x9,
                  ratios: <CropAspectRatioPreset>[
                    CropAspectRatioPreset.ratio16x9
                  ],
                  cropStyle: CropStyle.rectangle);

              if (file != null) {
                _profileController.updateCoverPhoto(file.path);
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            color: IbColors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(Icons.photo_album_outlined),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Choose from gallery',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    Get.bottomSheet(SafeArea(child: options));
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;
  double height;

  PersistentHeader({required this.widget, this.height = 48});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: height, color: IbColors.lightBlue, child: widget);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
