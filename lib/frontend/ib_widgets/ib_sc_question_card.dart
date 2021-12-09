import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_question_info.dart';

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
    final Widget expandableInfo = Obx(
      () => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {
                widget._controller.isSwitched.value =
                    !widget._controller.isSwitched.value;
              },
              child: AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                duration: const Duration(
                    milliseconds: IbConfig.kEventTriggerDelayInMillis),
                child: widget._controller.isSwitched.value
                    ? Center(
                        child: SizedBox(
                          height: 100,
                          child: _cardBackSide(),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey(1),
                        height: 100,
                        child: Center(
                            child: IbQuestionScItem(widget._controller))),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (widget._controller.showResult.isTrue)
              widget._controller.isSwitched.isTrue
                  ? const Text(
                      'Double tap pie chart to show slider',
                      style: TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey),
                    )
                  : const Text('Double tap slider to show result',
                      style: TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey)),
            const SizedBox(
              height: 16,
            ),
            IbQuestionButtons(widget._controller),
          ],
        ),
      ),
    );
    return SingleChildScrollView(
      child: IbCard(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IbQuestionHeader(widget._controller),
              IbQuestionInfo(widget._controller),
              SizeTransition(
                sizeFactor: animation,
                child: expandableInfo,
              ),

              /// show current user answer is available
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
              Obx(() {
                _runExpandCheck();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IbQuestionStatsBar(widget._controller),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        widget._controller.rxIsExpanded.value =
                            !widget._controller.rxIsExpanded.value;
                      },
                      icon: widget._controller.rxIsExpanded.isTrue
                          ? const Icon(
                              Icons.expand_less_outlined,
                              color: IbColors.primaryColor,
                            )
                          : const Icon(
                              Icons.expand_more_outlined,
                              color: IbColors.primaryColor,
                            ),
                    )
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardBackSide() {
    return Obx(
      () => widget._controller.isAnswering.isTrue
          ? const Center(
              child: IbProgressIndicator(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                      startDegreeOffset: 45,
                      sections: _getSectionData(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _getIndicators(),
                ),
              ],
            ),
    );
  }

  List<Widget> _getIndicators() {
    final List<IbChoice> choices = widget._controller.resultMap.keys.toList();
    final List<Widget> widgets = [];
    choices.sort((a, b) =>
        int.parse(a.content ?? '1').compareTo(int.parse(b.content ?? '1')));

    for (int i = 0; i < choices.length; i++) {
      if ((widget._controller.resultMap[choices[i]] ?? 0) == 0) {
        continue;
      }
      widgets.add(Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[i],
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            choices[i].content ?? '',
            style: const TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                color: IbColors.primaryColor),
          ),
          if (widget._controller.showResult.value &&
              widget._controller.rxIbAnswer!.value.choiceId ==
                  choices[i].choiceId)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: CircleAvatar(
                radius: 6,
                backgroundColor: IbColors.white,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: IbColors.accentColor,
                  size: 12,
                ),
              ),
            ),
        ],
      ));
    }

    return widgets;
  }

  List<PieChartSectionData> _getSectionData() {
    final List<PieChartSectionData> _pieChartDataList = [];

    for (final IbChoice choice in widget._controller.resultMap.keys) {
      if ((widget._controller.resultMap[choice] ?? 0) == 0) {
        continue;
      }
      final String percentage =
          ((widget._controller.resultMap[choice] ?? 0) * 100)
              .toStringAsFixed(1);

      final PieChartSectionData data = PieChartSectionData(
          color: colors[int.parse(choice.content ?? '1') - 1],
          badgePositionPercentageOffset: 1,
          titlePositionPercentageOffset: 0.5,
          value: double.parse(percentage),
          radius: 32,
          titleStyle: const TextStyle(
              color: Colors.black,
              fontSize: IbConfig.kSecondaryTextSize,
              fontWeight: FontWeight.bold),
          title: '$percentage%');
      _pieChartDataList.add(data);
    }
    return _pieChartDataList;
  }

  @override
  bool get wantKeepAlive => true;
}

class IbQuestionScItem extends StatelessWidget {
  final IbQuestionItemController _controller;

  const IbQuestionScItem(this._controller, {Key? key}) : super(key: key);

  double _getSliderValue() {
    if (_controller.selectedChoiceId.isEmpty) {
      return 1;
    }

    if (_controller.rxIbQuestion.value.choices.indexWhere((element) =>
            element.choiceId == _controller.selectedChoiceId.value) !=
        -1) {
      final index = _controller.rxIbQuestion.value.choices.indexWhere(
          (element) => element.choiceId == _controller.selectedChoiceId.value);
      return double.parse(
          _controller.rxIbQuestion.value.choices[index].content ?? "1");
    }

    return 1;
  }

  void _onValueChange(double value) {
    print(value);
    if (_controller.rxIbQuestion.value.choices.indexWhere(
            (element) => element.content == value.toInt().toString()) !=
        -1) {
      final index = _controller.rxIbQuestion.value.choices
          .indexWhere((element) => element.content == value.toInt().toString());
      _controller.selectedChoiceId.value =
          _controller.rxIbQuestion.value.choices[index].choiceId;
      return;
    }

    _controller.selectedChoiceId.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.always,
            activeTrackColor: IbColors.primaryColor,
            inactiveTrackColor: IbColors.lightBlue,
            trackShape: const RoundedRectSliderTrackShape(),
            trackHeight: 16,
            valueIndicatorShape:
                const _CustomSliderThumbCircle(thumbRadius: 24, min: 1, max: 5),
            thumbColor: IbColors.primaryColor,
            thumbShape:
                const _CustomSliderThumbCircle(thumbRadius: 24, min: 1, max: 5),
            overlayColor: IbColors.primaryColor.withAlpha(80),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 26.0),
          ),
          child: Obx(
            () => SizedBox(
              width: Get.width * 0.9,
              child: Slider(
                  min: 1,
                  max: 5,
                  label: _getSliderValue().toString(),
                  divisions: 4,
                  value: _getSliderValue(),
                  onChanged: (value) {
                    if (_controller.isSample ||
                        _controller.disableChoiceOnTouch ||
                        (_controller.rxIbAnswer != null &&
                            _controller.rxIbAnswer!.value.uid !=
                                IbUtils.getCurrentUid())) {
                      return;
                    }
                    _onValueChange(value);
                  }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 100,
                  child: Text(
                    _controller.rxIbQuestion.value.endpoints!.first.content!,
                    textAlign: TextAlign.start,
                  )),
              SizedBox(
                  width: 100,
                  child: Text(
                    _controller.rxIbQuestion.value.endpoints![1].content!,
                    textAlign: TextAlign.end,
                  ))
            ],
          ),
        )
      ],
    );
  }
}

class _CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const _CustomSliderThumbCircle({
    this.thumbRadius = 6,
    this.min = 0,
    this.max = 10,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = IbColors.lightBlue //Thumb Background Color
      ..style = PaintingStyle.fill;

    final TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme!.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value!),
    );

    final TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    final Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
