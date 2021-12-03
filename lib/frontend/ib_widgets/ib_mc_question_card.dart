import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_info.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_user_avatar.dart';

class IbMcQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;

  const IbMcQuestionCard(this._controller, {Key? key}) : super(key: key);

  @override
  _IbMcQuestionCardState createState() => _IbMcQuestionCardState();
}

class _IbMcQuestionCardState extends State<IbMcQuestionCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    _prepareAnimations();
    super.initState();
  }

  ///Setting up the animation
  void _prepareAnimations() {
    expandController = AnimationController(
        vsync: this,
        duration:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.linear,
    );
  }

  void _runExpandCheck() {
    if (widget._controller.rxIsExpanded.isTrue) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _runExpandCheck();
    final Widget expandableInfo = Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Scrollbar(
            controller: _scrollController,
            isAlwaysShown: true,
            child: LimitedBox(
              maxHeight: 300,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    final IbChoice _choice =
                        widget._controller.rxIbQuestion.value.choices[index];
                    return IbQuestionMcItem(_choice, widget._controller);
                  },
                  shrinkWrap: true,
                  itemCount:
                      widget._controller.rxIbQuestion.value.choices.length,
                ),
              ),
            ),
          ),
          if (IbQuestion.kMultipleChoicePic ==
              widget._controller.rxIbQuestion.value.questionType)
            const Text(
              'Double tap on the picture to enlarge',
              style: TextStyle(
                  color: IbColors.lightGrey,
                  fontSize: IbConfig.kDescriptionTextSize),
            ),
          const SizedBox(
            height: 8,
          ),
          Center(child: IbQuestionButtons(widget._controller)),
        ],
      ),
    );
    return SingleChildScrollView(
      child: Center(
        child: LimitedBox(
            maxWidth: Get.width * 0.95,
            child: IbCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IbQuestionHeader(widget._controller),
                  IbQuestionInfo(widget._controller),
                  const SizedBox(
                    height: 8,
                  ),
                  SizeTransition(
                    sizeFactor: animation,
                    child: expandableInfo,
                  ),

                  /// show current user answer if is available
                  if (Get.find<MyAnsweredQuestionsController>().retrieveAnswer(
                              widget._controller.rxIbQuestion.value.id) !=
                          null &&
                      widget._controller.showMyAnswer)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          IbUserAvatar(
                            avatarUrl: IbUtils.getCurrentIbUser()!.avatarUrl,
                            radius: 8,
                          ),
                          Text(
                              ': ${Get.find<MyAnsweredQuestionsController>().retrieveAnswer(widget._controller.rxIbQuestion.value.id)!.choiceId}')
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IbQuestionStatsBar(widget._controller),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          widget._controller.rxIsExpanded.value =
                              !widget._controller.rxIsExpanded.isTrue;
                          _runExpandCheck();
                        },
                        icon: Obx(
                          () => widget._controller.rxIsExpanded.isTrue
                              ? const Icon(
                                  Icons.expand_less_rounded,
                                  color: IbColors.primaryColor,
                                )
                              : const Icon(
                                  Icons.expand_more_outlined,
                                  color: IbColors.primaryColor,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class IbQuestionMcItem extends StatelessWidget {
  final IbChoice choice;
  final IbQuestionItemController _controller;

  const IbQuestionMcItem(this.choice, this._controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          if (_controller.isSample ||
              _controller.showResult.isTrue ||
              _controller.disableChoiceOnTouch) {
            return;
          }

          if (_controller.selectedChoiceId.value == choice.choiceId) {
            _controller.selectedChoiceId.value = '';
          } else {
            _controller.selectedChoiceId.value = choice.choiceId;
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: Get.width * 0.95,
                height: _controller.rxIbQuestion.value.questionType ==
                        IbQuestion.kMultipleChoice
                    ? IbConfig.kMcTxtItemHeight
                    : IbConfig.kMcPicItemHeight,
                decoration: BoxDecoration(
                    color: IbColors.lightBlue,
                    borderRadius:
                        BorderRadius.circular(IbConfig.kMcItemCornerRadius)),
              ),
              AnimatedContainer(
                height: _controller.rxIbQuestion.value.questionType ==
                        IbQuestion.kMultipleChoice
                    ? IbConfig.kMcTxtItemHeight
                    : IbConfig.kMcPicItemHeight,
                decoration: BoxDecoration(
                    color: _determineColor(
                        result: _controller.resultMap[choice.content] ?? 0,
                        isSelected: _controller.selectedChoiceId.value ==
                            choice.content,
                        isVoted: _controller.showResult.value),
                    borderRadius: BorderRadius.circular(8)),
                width: _determineWidth(
                    isSelected:
                        _controller.selectedChoiceId.value == choice.content,
                    result: _controller.resultMap[choice.content] ?? 0,
                    isVoted: _controller.showResult.value),
                duration: Duration(
                    milliseconds: _controller.showResult.value
                        ? IbConfig.kEventTriggerDelayInMillis
                        : 0),
              ),
              SizedBox(
                width: Get.width * 0.9,
                height: _controller.rxIbQuestion.value.questionType ==
                        IbQuestion.kMultipleChoice
                    ? IbConfig.kMcTxtItemHeight
                    : IbConfig.kMcPicItemHeight,
                child: Row(
                  children: [
                    if (choice.url != null && choice.url!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onDoubleTap: () {
                            final Widget img = _controller.isLocalFile
                                ? Image.file(
                                    File(choice.url!),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: choice.url!,
                                  );

                            final Widget hero = Hero(
                              tag:
                                  '${_controller.controllerId}${choice.choiceId}',
                              child: Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: img,
                                ),
                              ),
                            );

                            /// show image preview
                            IbUtils.showInteractiveViewer(hero, context);
                          },
                          child: Hero(
                            tag:
                                '${_controller.controllerId}${choice.choiceId}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  IbConfig.kMcItemCornerRadius),
                              child: _controller.isLocalFile
                                  ? Image.file(
                                      File(choice.url!),
                                      width: IbConfig.kMcPicHeight,
                                      height: IbConfig.kMcPicHeight,
                                    )
                                  : CachedNetworkImage(
                                      width: IbConfig.kMcPicHeight,
                                      height: IbConfig.kMcPicHeight,
                                      imageUrl: choice.url!,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        choice.content.toString(),
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              //Todo show 3 users who voted this question in stack
              if (_controller.showResult.value)
                const Positioned(
                  bottom: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: IbColors.white,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: IbColors.accentColor,
                      size: 16,
                    ),
                  ),
                ),
              if (_controller.showResult.value)
                TweenAnimationBuilder(
                  builder:
                      (BuildContext context, Object? value, Widget? child) {
                    return Positioned(
                      right: 8,
                      child: Text(
                          '${((_controller.resultMap[choice.content] ?? 0) * 100).toStringAsFixed(1)}%'),
                    );
                  },
                  duration: const Duration(
                      milliseconds: IbConfig.kEventTriggerDelayInMillis),
                  tween: Tween<double>(
                      begin: 0,
                      end: _controller.resultMap[choice.content] ?? 0),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _determineWidth(
      {required bool isSelected,
      required bool isVoted,
      required double result}) {
    if (isVoted) {
      return Get.width * 0.9 * result;
    }

    if (isSelected) {
      return Get.width * 0.9;
    }

    return 0;
  }

  Color _determineColor(
      {required bool isSelected,
      required bool isVoted,
      required double result}) {
    if (isSelected) {
      return IbColors.primaryColor;
    }

    if (isVoted && !isSelected) {
      return IbColors.lightGrey.withOpacity(0.3);
    }

    if (!isVoted && !isSelected) {
      return Colors.transparent;
    }

    return Colors.transparent;
  }
}
