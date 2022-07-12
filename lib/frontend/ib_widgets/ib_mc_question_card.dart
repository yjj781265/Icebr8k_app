import 'dart:io';

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
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
import 'ib_question_voted_txt.dart';

class IbMcQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;

  const IbMcQuestionCard(this._controller);

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

  @override
  void didChangeDependencies() {
    _runExpandCheck();
    super.didChangeDependencies();
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
                      ibAnswers: widget._controller.ibAnswers,
                      ibQuestion: widget._controller.rxIbQuestion.value),
                  tag: widget._controller.rxIbQuestion.value.id))
            else
              LimitedBox(
                maxHeight: 350,
                child: Scrollbar(
                  thickness: 3,
                  radius: const Radius.circular(8),
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: _handleChoiceItems(),
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
            const SizedBox(
              height: 8,
            ),
            if (!widget._controller.showComparison.value)
              Center(child: IbQuestionButtons(widget._controller))
          ],
        ),
      ),
    );
    return ShowCaseWidget(
      onComplete: (index, key) {
        if (key == widget._controller.expandShowCaseKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.pollExpandShowCaseBool, value: true);
        }

        if (key == widget._controller.quizShowCaseKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.pickAnswerForQuizShowCaseBool, value: true);
        }
      },
      builder: Builder(builder: (context) {
        return IbCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IbQuestionHeader(widget._controller),
              const SizedBox(
                height: 8,
              ),
              IbQuestionMediaSlide(widget._controller),
              IbQuestionInfo(widget._controller),
              SizeTransition(
                sizeFactor: animation,
                child: expandableInfo,
              ),
              const SizedBox(
                height: 16,
              ),
              IbQuestionVotedText(widget._controller),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 6, child: IbQuestionStatsBar(widget._controller)),
                  Obx(() => Showcase(
                        key: widget._controller.expandShowCaseKey,
                        shapeBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        overlayOpacity: 0.3,
                        description: widget._controller.rxIsExpanded.isTrue
                            ? 'Click here to minimize'
                            : 'Click here to see vote options',
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            widget._controller.rxIsExpanded.value =
                                !widget._controller.rxIsExpanded.value;
                            _runExpandCheck();
                          },
                          icon: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.6),
                              child: widget._controller.rxIsExpanded.isTrue
                                  ? Icon(
                                      Icons.expand_less_rounded,
                                      color: Theme.of(context).indicatorColor,
                                    )
                                  : Icon(
                                      Icons.expand_more_outlined,
                                      color: Theme.of(context).indicatorColor,
                                    )),
                        ),
                      )),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _handleChoiceItems() {
    final List<Widget> list = [];
    list.addAll(widget._controller.rxIbQuestion.value.choices
        .map((e) => IbQuestionMcItem(e, widget._controller))
        .toList());

    // todo add support for mc pic in the future
    if (widget._controller.rxIbQuestion.value.isOpenEnded &&
        widget._controller.rxIbQuestion.value.questionType ==
            QuestionType.multipleChoice) {
      list.add(headerWidget());
    }
    return list;
  }

  void _showBottomSheet({required String strTrKey}) {
    IbUtils.hideKeyboard();
    final TextEditingController _txtController = TextEditingController();
    final Widget _widget = IbDialog(
      title: strTrKey.tr,
      content: TextField(
        textInputAction: TextInputAction.done,
        maxLength: IbConfig.kAnswerMaxLength,
        onSubmitted: (value) async {
          Get.back();
          final choice =
              IbChoice(choiceId: IbUtils.getUniqueId(), content: value);
          await widget._controller.addChoice(choice);
        },
        controller: _txtController,
        autofocus: true,
        textAlign: TextAlign.center,
        cursorColor: IbColors.primaryColor,
      ),
      subtitle: '',
      onPositiveTap: () async {
        Get.back();
        final choice = IbChoice(
            choiceId: IbUtils.getUniqueId(), content: _txtController.text);
        await widget._controller.addChoice(choice);
      },
    );
    Get.bottomSheet(_widget, persistent: true, ignoreSafeArea: false);
  }

  Widget headerWidget() {
    return Stack(
      children: [
        IbCard(
          elevation: 0,
          radius: 8,
          margin: const EdgeInsets.only(top: 4, bottom: 4),
          color: IbColors.lightBlue,
          child: SizedBox(
            height: IbConfig.kMcTxtItemSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'tap_to_add'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            onTap: () {
              if (widget._controller.rxIsSample.isTrue) {
                return;
              }

              if (widget._controller.rxIbQuestion.value.choices.length >=
                  IbConfig.kOpenEndedChoiceLimit) {
                IbUtils.showSimpleSnackBar(
                    msg: 'Failed to add a choice, poll reaches choice limit',
                    backgroundColor: IbColors.errorRed);
                return;
              }

              _showBottomSheet(strTrKey: 'add_choice');
            },
          ),
        ))
      ],
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
          _controller.myAnswer != null &&
          choice.choiceId == _controller.myAnswer!.choiceId) {
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
        _controller.myAnswer != null &&
        choice.choiceId == _controller.myAnswer!.choiceId) {
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
        _controller.myAnswer != null &&
        choice.choiceId == _controller.myAnswer!.choiceId &&
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
                              Flexible(
                                child: OpenContainer(
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
                                      urls: _controller
                                          .rxIbQuestion.value.choices
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
                                                progressIndicatorBuilder:
                                                    (context, string,
                                                        progress) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(
                                                      value: progress.progress,
                                                    ),
                                                  );
                                                },
                                                errorWidget:
                                                    (context, str, obj) {
                                                  return Container(
                                                    width: IbConfig.kMcPicSize,
                                                    height: IbConfig.kMcPicSize,
                                                    color: IbColors.lightGrey,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color:
                                                            IbColors.errorRed,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AutoSizeText(
                                  choice.content.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  maxFontSize: IbConfig.kNormalTextSize,
                                  style: const TextStyle(color: Colors.black),
                                ),
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
              if (_controller.rxIbQuestion.value.isQuiz &&
                  _controller.rxIsSample.isTrue)
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

    //show showcase widget
    if (_controller.rxIbQuestion.value.isQuiz &&
        _controller.rxIbQuestion.value.choices
                .indexWhere((element) => element.choiceId == choice.choiceId) ==
            0) {
      return Expanded(
        child: Showcase(
          overlayColor: Colors.transparent,
          shapeBorder: const CircleBorder(),
          key: _controller.quizShowCaseKey,
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

    if (_controller.rxIsSample.isTrue ||
        (_controller.myAnswer != null &&
            _controller.myAnswer!.uid != IbUtils.getCurrentUid())) {
      return;
    }

    if (_controller.selectedChoiceId.value == choice.choiceId) {
      _controller.selectedChoiceId.value = '';
    } else {
      _controller.selectedChoiceId.value = choice.choiceId;
    }
  }
}
