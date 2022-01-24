import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_info.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_tags.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_media_viewer.dart';
import 'ib_question_stats.dart';

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
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget._controller.showStats.isTrue)
              IbQuestionStats(Get.put(
                  IbQuestionStatsController(
                      ibAnswers: widget._controller.ibAnswers!,
                      questionId: widget._controller.rxIbQuestion.value.id),
                  tag: widget._controller.rxIbQuestion.value.id))
            else
              LimitedBox(
                maxHeight: 300,
                child: Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
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
            if (IbQuestion.kMultipleChoicePic ==
                widget._controller.rxIbQuestion.value.questionType)
              const Text(
                'Double tap on the picture to enlarge',
                style: TextStyle(
                    color: IbColors.lightGrey,
                    fontSize: IbConfig.kDescriptionTextSize),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: IbQuestionTags(widget._controller),
            ),
            const SizedBox(
              height: 8,
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            if (!widget._controller.showStats.value)
              Center(child: IbQuestionButtons(widget._controller))
          ],
        ),
      ),
    );
    return SingleChildScrollView(
      child: SizedBox(
          width: Get.width * 0.95,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IbQuestionStatsBar(widget._controller),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        widget._controller.rxIsExpanded.value =
                            !widget._controller.rxIsExpanded.isTrue;
                      },
                      icon: Obx(() {
                        _runExpandCheck();
                        return widget._controller.rxIsExpanded.isTrue
                            ? const Icon(
                                Icons.expand_less_rounded,
                                color: IbColors.primaryColor,
                              )
                            : const Icon(
                                Icons.expand_more_outlined,
                                color: IbColors.primaryColor,
                              );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          )),
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

  Color getItemColor() {
    if (choice.choiceId == _controller.selectedChoiceId.value) {
      return IbColors.primaryColor;
    }

    if (_controller.showResult.isTrue &&
        (_controller.resultMap[choice] ?? 0) != 0) {
      return IbColors.lightGrey;
    }

    return IbColors.lightBlue;
  }

  double getItemWidth() {
    if (choice.choiceId == _controller.selectedChoiceId.value &&
        _controller.showResult.isFalse) {
      return Get.width * 0.95;
    }

    if (_controller.totalPolled.value <= 0 && _controller.showResult.isTrue) {
      return Get.width * 0.95;
    }

    if ((_controller.resultMap[choice] ?? 0) == 0) {
      return Get.width * 0.95;
    }

    if (_controller.showResult.isTrue) {
      return (_controller.resultMap[choice] ?? 0) * (Get.width * 0.95);
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Obx(
          () => InkWell(
            radius: IbConfig.kMcItemCornerRadius,
            borderRadius: BorderRadius.circular(IbConfig.kMcItemCornerRadius),
            onTap: onItemTap,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                      color: getItemColor(),
                      borderRadius: BorderRadius.circular(8)),
                  width: getItemWidth(),
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
                        OpenContainer(
                          openElevation: 0,
                          closedElevation: 0,
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                IbConfig.kMcItemCornerRadius),
                          ),
                          openColor: Colors.black,
                          middleColor: Colors.black,
                          closedColor: Colors.transparent,
                          transitionType: ContainerTransitionType.fadeThrough,
                          openBuilder: (BuildContext context,
                              void Function({Object? returnValue}) action) {
                            return IbMediaViewer(
                              urls: _controller.rxIbQuestion.value.choices
                                  .map((e) => e.url!)
                                  .toList(),
                              currentIndex: _controller
                                  .rxIbQuestion.value.choices
                                  .map((e) => e.url!)
                                  .toList()
                                  .indexWhere(
                                      (element) => choice.url! == element),
                            );
                          },
                          closedBuilder: (_, openContainer) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onDoubleTap: openContainer,
                              onTap: onItemTap,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    IbConfig.kMcItemCornerRadius),
                                child: !choice.url!.contains('http')
                                    ? Image.file(
                                        File(choice.url!),
                                        fit: BoxFit.fill,
                                        width: IbConfig.kMcPicHeight,
                                        height: IbConfig.kMcPicHeight,
                                      )
                                    : CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        fadeInDuration:
                                            const Duration(milliseconds: 300),
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
                if (_controller.showResult.value &&
                    _controller.rxIbAnswer!.value.choiceId == choice.choiceId)
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
                if (_controller.showResult.value &&
                    _controller.totalPolled.value > 0)
                  TweenAnimationBuilder(
                    builder:
                        (BuildContext context, Object? value, Widget? child) {
                      return Positioned(
                        right: 8,
                        child: Text(
                          '${((_controller.resultMap[choice] ?? 0 / _controller.totalPolled.value.toDouble()) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    },
                    duration: const Duration(
                        milliseconds: IbConfig.kEventTriggerDelayInMillis),
                    tween: Tween<double>(
                        begin: 0,
                        end: _controller.resultMap[choice]! /
                            _controller.totalPolled.value.toDouble()),
                  ),
              ],
            ),
          ),
        ));
  }

  void onItemTap() {
    if (_controller.isSample ||
        _controller.disableChoiceOnTouch ||
        (_controller.rxIbAnswer != null &&
            _controller.rxIbAnswer!.value.uid != IbUtils.getCurrentUid())) {
      return;
    }

    if (_controller.selectedChoiceId.value == choice.choiceId) {
      _controller.selectedChoiceId.value = '';
    } else {
      _controller.selectedChoiceId.value = choice.choiceId;
    }
  }
}
