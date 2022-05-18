import 'dart:io';

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_slide.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_info.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_tags.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
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
      padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget._controller.showComparison.isTrue)
              IbQuestionStats(Get.put(
                  IbQuestionStatsController(
                      ibAnswers: widget._controller.ibAnswers!,
                      ibQuestion: widget._controller.rxIbQuestion.value),
                  tag: widget._controller.rxIbQuestion.value.id))
            else
              LimitedBox(
                maxHeight: widget._controller.rxIbQuestion.value.questionType ==
                        QuestionType.multipleChoice
                    ? 200
                    : 400,
                child: Scrollbar(
                  thickness: 3,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: widget._controller.rxIbQuestion.value.choices
                            .map((e) => IbQuestionMcItem(e, widget._controller))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            if (QuestionType.multipleChoicePic ==
                    widget._controller.rxIbQuestion.value.questionType &&
                widget._controller.showComparison.isFalse)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'double_tap_pic'.tr,
                  style: const TextStyle(
                      color: IbColors.lightGrey,
                      fontSize: IbConfig.kDescriptionTextSize),
                ),
              ),
            const SizedBox(
              height: 8,
            ),
            IbQuestionTags(widget._controller),
            const SizedBox(
              height: 8,
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            if (!widget._controller.showComparison.value)
              Center(child: IbQuestionButtons(widget._controller))
          ],
        ),
      ),
    );
    return IbCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IbQuestionHeader(widget._controller),
          const SizedBox(
            height: 8,
          ),
          IbMediaSlide(widget._controller.rxIbQuestion.value.medias),
          IbQuestionInfo(widget._controller),
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
                      !widget._controller.rxIsExpanded.value;
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
    if (_controller.voted.isFalse) {
      if (choice.choiceId == _controller.selectedChoiceId.value) {
        return IbColors.primaryColor;
      } else {
        return IbColors.lightBlue;
      }
    } else {
      if (_controller.rxIbQuestion.value.isQuiz &&
          choice.choiceId == _controller.rxIbQuestion.value.correctChoiceId &&
          (_controller.resultMap[choice] ?? 0) != 0) {
        return IbColors.accentColor;
      } else if (_controller.rxIbQuestion.value.isQuiz &&
          choice.choiceId != _controller.rxIbQuestion.value.correctChoiceId &&
          _controller.rxIbAnswer != null &&
          choice.choiceId == _controller.rxIbAnswer!.value.choiceId) {
        return IbColors.errorRed;
      } else if (_controller.rxIbQuestion.value.isQuiz &&
          (_controller.resultMap[choice] ?? 0) == 0) {
        return IbColors.lightBlue;
      } else if (_controller.rxIbQuestion.value.isQuiz &&
          (_controller.resultMap[choice] ?? 0) != 0) {
        return IbColors.lightGrey;
      }

      if (choice.choiceId == _controller.selectedChoiceId.value &&
          !_controller.rxIbQuestion.value.isQuiz) {
        return IbColors.primaryColor;
      } else if ((_controller.resultMap[choice] ?? 0) == 0) {
        return IbColors.lightBlue;
      } else {
        return IbColors.lightGrey;
      }
    }
  }

  double getItemWidth() {
    if (_controller.voted.isFalse) {
      return Get.width;
    }

    return (Get.width * (_controller.resultMap[choice] ?? 0)) == 0
        ? Get.width
        : Get.width * (_controller.resultMap[choice] ?? 0);
  }

  Widget getItemIcon() {
    if (!_controller.rxIbQuestion.value.isQuiz &&
        _controller.voted.isTrue &&
        _controller.rxIbAnswer != null &&
        choice.choiceId == _controller.rxIbAnswer!.value.choiceId) {
      return const CircleAvatar(
        radius: 8,
        backgroundColor: IbColors.white,
        child: Icon(
          Icons.check_circle_rounded,
          color: IbColors.accentColor,
          size: 16,
        ),
      );
    }

    if (_controller.rxIbQuestion.value.isQuiz &&
        _controller.voted.isTrue &&
        choice.choiceId == _controller.rxIbQuestion.value.correctChoiceId) {
      return const CircleAvatar(
        radius: 8,
        backgroundColor: IbColors.white,
        child: Icon(
          Icons.check_circle_rounded,
          color: IbColors.accentColor,
          size: 16,
        ),
      );
    }
    if (_controller.rxIbQuestion.value.isQuiz &&
        _controller.voted.isTrue &&
        _controller.rxIbAnswer != null &&
        choice.choiceId == _controller.rxIbAnswer!.value.choiceId &&
        choice.choiceId != _controller.rxIbQuestion.value.correctChoiceId) {
      return const CircleAvatar(
        radius: 8,
        backgroundColor: IbColors.white,
        child: Icon(
          Icons.cancel,
          color: IbColors.errorRed,
          size: 16,
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 8,
                child: InkWell(
                  radius: IbConfig.kMcItemCornerRadius,
                  borderRadius:
                      BorderRadius.circular(IbConfig.kMcItemCornerRadius),
                  onTap: onItemTap,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        width: Get.width,
                        height: _controller.rxIbQuestion.value.questionType ==
                                QuestionType.multipleChoice
                            ? IbConfig.kMcTxtItemSize
                            : IbConfig.kMcPicItemSize,
                        decoration: BoxDecoration(
                            color: IbColors.lightBlue,
                            borderRadius: BorderRadius.circular(
                                IbConfig.kMcItemCornerRadius)),
                      ),
                      AnimatedContainer(
                        height: _controller.rxIbQuestion.value.questionType ==
                                QuestionType.multipleChoice
                            ? IbConfig.kMcTxtItemSize
                            : IbConfig.kMcPicItemSize,
                        decoration: BoxDecoration(
                            color: getItemColor(),
                            borderRadius: BorderRadius.circular(8)),
                        width: getItemWidth(),
                        duration: Duration(
                            milliseconds: _controller.voted.value
                                ? IbConfig.kEventTriggerDelayInMillis
                                : 0),
                      ),
                      SizedBox(
                        width: Get.width,
                        height: _controller.rxIbQuestion.value.questionType ==
                                QuestionType.multipleChoice
                            ? IbConfig.kMcTxtItemSize
                            : IbConfig.kMcPicItemSize,
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
                                transitionType:
                                    ContainerTransitionType.fadeThrough,
                                openBuilder: (BuildContext context,
                                    void Function({Object? returnValue})
                                        action) {
                                  return IbMediaViewer(
                                    urls: _controller.rxIbQuestion.value.choices
                                        .map((e) => e.url!)
                                        .toList(),
                                    currentIndex: _controller
                                        .rxIbQuestion.value.choices
                                        .map((e) => e.url!)
                                        .toList()
                                        .indexWhere((element) =>
                                            choice.url! == element),
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
                                              width: IbConfig.kMcPicSize,
                                              height: IbConfig.kMcPicSize,
                                            )
                                          : CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 300),
                                              width: IbConfig.kMcPicSize,
                                              height: IbConfig.kMcPicSize,
                                              imageUrl: choice.url!,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                choice.content.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                maxFontSize: IbConfig.kNormalTextSize,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 2,
                        child: getItemIcon(),
                      ),

                      /// show percentage animation
                      if (_controller.voted.value)
                        TweenAnimationBuilder(
                            tween: Tween<double>(
                                begin: 0,
                                end: _controller.resultMap[choice] ?? 0),
                            duration: const Duration(
                                milliseconds:
                                    IbConfig.kEventTriggerDelayInMillis),
                            builder: (context, double value, child) {
                              return Positioned(
                                right: 8,
                                child: Text(
                                  '${(value * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            })
                    ],
                  ),
                ),
              ),

              /// show radios if is sample and quiz option is on
              if (_controller.rxIbQuestion.value.isQuiz && _controller.isSample)
                _handleShowCaseQuizWidget()
            ],
          ),
        ));
  }

  Widget _handleShowCaseQuizWidget() {
    final radio = Radio(
      activeColor: IbColors.accentColor,
      value: choice.choiceId,
      groupValue: _controller.rxIbQuestion.value.correctChoiceId,
      onChanged: (id) {
        _controller.rxIbQuestion.value.correctChoiceId = id.toString();
        _controller.rxIbQuestion.refresh();
      },
    );
    if (_controller.rxIbQuestion.value.choices.indexOf(choice) == 0 &&
        !IbLocalDataService()
            .retrieveBoolValue(StorageKey.pickAnswerForQuizBool)) {
      //show showcase widget
      return Expanded(
        child: Showcase(
          overlayColor: Colors.transparent,
          shapeBorder: const CircleBorder(),
          key: IbShowCaseManager.kPickAnswerForQuizKey,
          description: 'show_case_quiz'.tr,
          child: radio,
        ),
      );
    }

    return Expanded(child: radio);
  }

  void onItemTap() {
    if (_controller.rxIbQuestion.value.isQuiz && _controller.voted.isTrue) {
      return;
    }

    if (DateTime.now().millisecondsSinceEpoch >
            _controller.rxIbQuestion.value.endTimeInMs &&
        _controller.rxIbQuestion.value.endTimeInMs > 0) {
      return;
    }

    if (_controller.isSample ||
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
