import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/common_answers_controller.dart';
import 'package:icebr8k/backend/controllers/created_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/profile_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
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
  late CreatedQuestionController _createdQuestionController;
  late CommonAnswersController _commonAnswersController;
  late ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController =
        Get.put(ProfileController(widget.uid), tag: widget.uid);
    if (widget.uid == IbUtils.getCurrentUid()) {
      _answeredQuestionController =
          Get.put(AnsweredQuestionController(widget.uid), tag: widget.uid);
      _createdQuestionController =
          Get.put(CreatedQuestionController(widget.uid), tag: widget.uid);
    }
    _commonAnswersController =
        Get.put(CommonAnswersController(widget.uid), tag: widget.uid);

    _tabController = TabController(
        vsync: this, length: _profileController.isMe.isTrue ? 2 : 1);
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
              title: Obx(() => Text(_profileController.username.value.isEmpty
                  ? ''
                  : "${_profileController.username.value}'s profile")),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomLeft,
                    children: [
                      ///cover photo
                      Obx(
                        () => Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            SizedBox(
                              height: 200,
                              width: double.infinity,
                              child: _profileController.coverPhotoUrl.isEmpty
                                  ? Image.asset(
                                      'assets/images/default_cover_photo.jpeg',
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: _profileController
                                          .coverPhotoUrl.value,
                                    ),
                            ),

                            ///edit button
                            if (_profileController.isMe.isTrue)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: IbColors.lightBlue,
                                    onPressed: () {},
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),

                      /// avatar
                      Obx(
                        () => Positioned(
                          left: 16,
                          bottom: -40,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print('tapped');
                                },
                                child: IbUserAvatar(
                                    disableOnTap: true,
                                    radius: 40,
                                    uid: widget.uid,
                                    avatarUrl:
                                        _profileController.avatarUrl.value),
                              ),
                              if (_profileController.isMe.isTrue)
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: IbColors.lightBlue,
                                    onPressed: () {},
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                    ),
                                  ),
                                )
                            ],
                          ),
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
                          padding: const EdgeInsets.only(top: 40, left: 16),
                          child: Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('@${_profileController.username.value}',
                                    style: const TextStyle(
                                        fontSize: IbConfig.kPageTitleSize,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  _profileController.name.value,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kNormalTextSize),
                                ),
                                if (_profileController.description.isNotEmpty)
                                  Text(_profileController.description.value,
                                      style: const TextStyle(
                                          fontSize:
                                              IbConfig.kDescriptionTextSize)),
                                if (_profileController.isMe.isFalse)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'match_interests'.tr,
                                          style: const TextStyle(
                                              fontSize:
                                                  IbConfig.kNormalTextSize,
                                              fontWeight: FontWeight.w800),
                                        ),
                                        IbLinearIndicator(
                                          endValue: _profileController
                                              .compScore.value,
                                        ),
                                      ],
                                    ),
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
                                    num:
                                        _profileController.totalAnswered.value),
                                IbStats(
                                    title: 'Asked',
                                    num: _profileController.totalAsked.value),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ];
        },
        body: Container(
          margin: const EdgeInsets.only(top: 16),
          color: IbColors.lightBlue,
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  if (_profileController.isMe.isTrue)
                    const Tab(text: 'Answered Questions'),
                  if (_profileController.isMe.isTrue)
                    const Tab(text: 'Asked Questions'),
                  if (_profileController.isMe.isFalse)
                    Obx(() => Tab(
                        text:
                            'Common Answers(${_commonAnswersController.ibQuestions.length})')),
                ],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
                labelColor: Colors.black,
                unselectedLabelColor: IbColors.lightGrey,
                indicatorColor: _tabController.length == 1
                    ? Colors.transparent
                    : IbColors.primaryColor,
              ),
              Expanded(
                  child: TabBarView(
                controller: _tabController,
                children: [
                  if (_profileController.isMe.isTrue) buildAnsweredQTab(),
                  if (_profileController.isMe.isTrue) buildAskedTab(),
                  if (_profileController.isMe.isFalse) buildCommonAnswersTab(),
                ],
              ))
            ],
          ),
        ),
      ),
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
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final AnsweredQuestionItem item =
                  _answeredQuestionController.myAnsweredQuestions[index];
              final tag = 'answered_${item.ibQuestion.id}';
              final IbQuestionItemController _controller = Get.put(
                  IbQuestionItemController(
                      ibAnswer: item.ibAnswer,
                      ibQuestion: item.ibQuestion,
                      isExpandable: true,
                      isExpanded: index == 0),
                  tag: tag.toString());

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
              final tag = 'created_${item.id}';
              final IbQuestionItemController _controller = Get.put(
                  IbQuestionItemController(ibQuestion: item, isExpanded: false),
                  tag: tag.toString());

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
            refreshController.loadComplete();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final IbQuestion item =
                  _commonAnswersController.ibQuestions[index];
              final tag = 'common${item.id}';
              final IbQuestionItemController _controller = Get.put(
                  IbQuestionItemController(
                      ibQuestion: item, isExpandable: true),
                  tag: tag.toString());

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
}
