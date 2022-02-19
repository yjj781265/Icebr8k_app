import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';

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
    return const SizedBox();
  }

  Widget _showBarChart() {
    return Obx(
      () => widget._controller.isAnswering.isTrue
          ? const Center(
              child: IbProgressIndicator(),
            )
          : SizedBox(
              height: 120,
              width: 300,
              child: BarChart(
                BarChartData(
                    groupsSpace: 16,
                    backgroundColor: IbColors.lightBlue,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    gridData: FlGridData(show: false),
                    barTouchData: BarTouchData(
                        enabled: false,
                        touchTooltipData: BarTouchTooltipData(
                            tooltipMargin: 0,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) {
                              return BarTooltipItem(
                                '${rod.y}%',
                                const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                            tooltipBgColor: Colors.transparent)),
                    maxY: 150,
                    barGroups: widget._controller.rxIbQuestion.value.choices
                        .map((e) => BarChartGroupData(
                            barsSpace: 16,
                            showingTooltipIndicators: [0],
                            x: int.parse(e.content ?? '0'),
                            barRods: [
                              BarChartRodData(
                                  width: 16,
                                  colors: [
                                    IbUtils.handleIndicatorColor(
                                        widget._controller.resultMap[e] ?? 0)
                                  ],
                                  y: (widget._controller.resultMap[e] ?? 0) *
                                      100),
                            ]))
                        .toList(),
                    titlesData: FlTitlesData(
                        show: true,
                        topTitles: SideTitles(showTitles: false),
                        rightTitles: SideTitles(showTitles: false),
                        bottomTitles: SideTitles(
                          showTitles: true,
                        ),
                        leftTitles: SideTitles(showTitles: false))),
              ),
            ),
    );
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
    return Obx(
      () => SliderTheme(
        data: SliderTheme.of(context).copyWith(
          showValueIndicator: ShowValueIndicator.always,
          activeTrackColor: IbColors.primaryColor,
          inactiveTrackColor: IbColors.lightBlue,
          trackShape: const RoundedRectSliderTrackShape(),
          trackHeight: 16,
          valueIndicatorShape: _CustomSliderThumbCircle(
              thumbRadius: 24,
              min: 1,
              max: 5,
              bgColor: (_controller.rxIbAnswer != null &&
                      _controller.rxIbAnswer!.value.choiceId ==
                          _controller.selectedChoiceId.value)
                  ? IbColors.accentColor.withOpacity(0.8)
                  : IbColors.lightBlue),
          thumbColor: IbColors.primaryColor,
          thumbShape: _CustomSliderThumbCircle(
              thumbRadius: 24,
              min: 1,
              max: 5,
              bgColor: (_controller.rxIbAnswer != null &&
                      _controller.rxIbAnswer!.value.choiceId ==
                          _controller.selectedChoiceId.value)
                  ? IbColors.accentColor
                  : IbColors.lightBlue),
          overlayColor: IbColors.primaryColor.withAlpha(80),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 26.0),
        ),
        child: SizedBox(
          width: Get.width * 0.9,
          child: Slider(
              min: 1,
              max: 5,
              label: _getSliderValue().toString(),
              divisions: 4,
              value: _getSliderValue(),
              onChanged: (value) {
                if (_controller.isSample ||
                    (_controller.rxIbAnswer != null &&
                        _controller.rxIbAnswer!.value.uid !=
                            IbUtils.getCurrentUid())) {
                  return;
                }
                _onValueChange(value);
              }),
        ),
      ),
    );
  }
}

class _CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final Color bgColor;
  final int min;
  final int max;

  const _CustomSliderThumbCircle({
    this.bgColor = IbColors.lightBlue,
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
      ..color = bgColor //Thumb Background Color
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
