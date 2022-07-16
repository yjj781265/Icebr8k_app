import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_tags.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../ib_config.dart';
import 'ib_media_slide.dart';
import 'ib_question_header.dart';
import 'ib_question_info.dart';
import 'ib_question_stats_bar.dart';
import 'ib_question_voted_txt.dart';

class IbScQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;
  const IbScQuestionCard(this._controller);

  @override
  _IbScQuestionCardState createState() => _IbScQuestionCardState();
}

class _IbScQuestionCardState extends State<IbScQuestionCard>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
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

  @override
  void didChangeDependencies() {
    _runExpandCheck();
    super.didChangeDependencies();
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
                      ibAnswers: widget._controller.ibAnswers,
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
            const SizedBox(
              height: 8,
            ),
            if (!widget._controller.showComparison.value)
              Center(child: IbQuestionButtons(widget._controller)),
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
      },
      builder: Builder(builder: (context) {
        return IbCard(
          child: Column(
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
                  Obx(
                    () => Showcase(
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
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.5),
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
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
        QuestionType.scaleOne) {
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
        QuestionType.scaleTwo) {
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
        QuestionType.scaleThree) {
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
