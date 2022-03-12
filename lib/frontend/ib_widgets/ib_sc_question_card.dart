import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_tags.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../ib_colors.dart';
import '../ib_config.dart';
import 'ib_media_slide.dart';
import 'ib_question_header.dart';
import 'ib_question_info.dart';
import 'ib_question_stats_bar.dart';

class IbScQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;
  const IbScQuestionCard(this._controller, {Key? key}) : super(key: key);

  @override
  _IbScQuestionCardState createState() => _IbScQuestionCardState();
}

class _IbScQuestionCardState extends State<IbScQuestionCard>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  final _scrollController = ScrollController();
  List<Color> colors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.blueAccent,
    Colors.greenAccent
  ];
  bool isSwitched = false;

  @override
  void initState() {
    _prepareAnimations();
    super.initState();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    super.build(context);
    _runExpandCheck();
    final Widget expandableInfo = Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget._controller.showComparison.isTrue)
              IbQuestionStats(Get.put(
                  IbQuestionStatsController(
                      ibAnswers: widget._controller.ibAnswers!,
                      ibQuestion: widget._controller.rxIbQuestion.value),
                  tag: widget._controller.rxIbQuestion.value.id))
            else
              Align(
                  child: AnimatedSize(
                duration: const Duration(
                    milliseconds: IbConfig.kEventTriggerDelayInMillis),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _handleScType(),
                    if (widget._controller.voted.isTrue)
                      Text(' Avg  ${_getAverage().toStringAsFixed(1)}')
                  ],
                ),
              )),
            const SizedBox(
              height: 16,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IbQuestionHeader(widget._controller),
          IbMediaSlide(widget._controller.rxIbQuestion.value.medias),
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

  Widget _handleScType() {
    final IbChoice? choice = widget._controller.rxIbQuestion.value.choices
        .firstWhereOrNull((element) =>
            element.choiceId == widget._controller.selectedChoiceId.value);
    final double initRating = widget._controller.isPollClosed.isTrue
        ? _getAverage()
        : choice == null
            ? 0
            : double.parse(choice.content ?? '0');
    if (widget._controller.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleOne) {
      return RatingBar.builder(
        ignoreGestures: widget._controller.isPollClosed.isTrue,
        allowHalfRating: widget._controller.isPollClosed.isTrue,
        itemPadding: const EdgeInsets.all(4),
        itemSize: IbConfig.kScItemHeight,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        initialRating: initRating,
        onRatingUpdate: (rating) {
          _onRatingUpdate(rating);
        },
      );
    }

    if (widget._controller.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleTwo) {
      return RatingBar.builder(
        ignoreGestures: widget._controller.isPollClosed.isTrue,
        allowHalfRating: widget._controller.isPollClosed.isTrue,
        itemPadding: const EdgeInsets.all(4),
        itemSize: IbConfig.kScItemHeight,
        initialRating: initRating,
        itemBuilder: (context, _) => const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onRatingUpdate: (rating) {
          _onRatingUpdate(rating);
        },
      );
    }

    if (widget._controller.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleThree) {
      return RatingBar.builder(
        ignoreGestures: widget._controller.isPollClosed.isTrue,
        itemPadding: const EdgeInsets.all(4),
        allowHalfRating: widget._controller.isPollClosed.isTrue,
        itemSize: IbConfig.kScItemHeight,
        initialRating: initRating,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return const Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return const Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return const SizedBox();
          }
        },
        onRatingUpdate: (rating) {
          _onRatingUpdate(rating);
        },
      );
    }

    return const SizedBox();
  }

  void _onRatingUpdate(double rating) {
    final IbChoice? choice = widget._controller.rxIbQuestion.value.choices
        .firstWhereOrNull(
            (element) => element.content! == rating.toInt().toString());
    widget._controller.selectedChoiceId.value =
        choice == null ? '' : choice.choiceId;
  }

  double _getAverage() {
    if (widget._controller.rxIbQuestion.value.pollSize == 0) {
      return 0.0;
    }
    double totalPoints = 0;
    for (final choice in widget._controller.rxIbQuestion.value.choices) {
      totalPoints = totalPoints +
          ((widget._controller.countMap[choice.choiceId] ?? 0) *
              (double.parse(choice.content ?? '0')));
    }
    return totalPoints /
        widget._controller.rxIbQuestion.value.pollSize.toDouble();
  }

  @override
  bool get wantKeepAlive => true;
}
