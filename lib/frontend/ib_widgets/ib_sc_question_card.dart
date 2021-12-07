import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:page_flip_builder/page_flip_builder.dart';

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
  final GlobalKey<PageFlipBuilderState> cardKey =
      GlobalKey<PageFlipBuilderState>();
  late AnimationController expandController;
  late Animation<double> animation;

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
    final expandableInfo = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IbQuestionScItem(widget._controller),
        ),
        IbQuestionButtons(widget._controller),
      ],
    );
    return SingleChildScrollView(
      child: InkWell(
        child: Ink(
          child: Center(
            child: PageFlipBuilder(
              interactiveFlipEnabled: false,
              key: cardKey,
              frontBuilder: (_) => IbCard(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IbQuestionHeader(widget._controller),
                      IbQuestionInfo(widget._controller),
                      const SizedBox(
                        height: 16,
                      ),
                      SizeTransition(
                        sizeFactor: animation,
                        child: expandableInfo,
                      ),

                      /// show current user answer is available
                      if (Get.find<MyAnsweredQuestionsController>()
                                  .retrieveAnswer(widget
                                      ._controller.rxIbQuestion.value.id) !=
                              null &&
                          widget._controller.showMyAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              IbUserAvatar(
                                avatarUrl:
                                    IbUtils.getCurrentIbUser()!.avatarUrl,
                                radius: 8,
                              ),
                              Text(
                                  ': ${Get.find<MyAnsweredQuestionsController>().retrieveAnswer(widget._controller.rxIbQuestion.value.id)!.choiceId}')
                            ],
                          ),
                        ),
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IbQuestionStatsBar(widget._controller),
                            IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                widget._controller.rxIsExpanded.value =
                                    !widget._controller.rxIsExpanded.value;

                                _runExpandCheck();
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
              backBuilder: (BuildContext context) {
                return _cardBackSide();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardBackSide() {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: IbCard(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: IconButton(
                    onPressed: () {
                      cardKey.currentState!.flip();
                    },
                    icon: const Icon(Icons.arrow_back_ios_outlined)),
              ),
              Expanded(
                flex: 8,
                child: widget._controller.isAnswering.isTrue
                    ? const Center(
                        child: IbProgressIndicator(),
                      )
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 20,
                          startDegreeOffset: 45,
                          sections: _getSectionData(),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${widget._controller.totalPolled.value} polled',
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSectionData() {
    final List<PieChartSectionData> _pieChartDataList = [];
    Color lastColor = IbUtils.getRandomColor();
    for (final String choice in widget._controller.resultMap.keys) {
      final String percentage =
          ((widget._controller.resultMap[choice] ?? 0) * 100)
              .toStringAsFixed(1);
      Color currentColor = IbUtils.getRandomColor();
      while (currentColor == lastColor) {
        currentColor = IbUtils.getRandomColor();
      }
      lastColor = currentColor;
      final PieChartSectionData data = PieChartSectionData(
          badgeWidget: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: lastColor),
              color: IbColors.lightBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Center(
                child: Text(
              choice,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: IbColors.primaryColor),
            )),
          ),
          color: lastColor,
          badgePositionPercentageOffset: 1,
          titlePositionPercentageOffset: 0.5,
          value: double.parse(percentage),
          radius: 80,
          titleStyle: const TextStyle(
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
            trackHeight: 8.0,
            valueIndicatorShape:
                const _CustomSliderThumbCircle(thumbRadius: 20, min: 1, max: 5),
            thumbColor: IbColors.primaryColor,
            thumbShape:
                const _CustomSliderThumbCircle(thumbRadius: 20, min: 1, max: 5),
            overlayColor: IbColors.primaryColor.withAlpha(80),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 26.0),
          ),
          child: Obx(
            () => SizedBox(
              width: Get.width * 0.9,
              child: Slider(
                  min: 1,
                  max: 5,
                  label: _controller.selectedChoiceId.value,
                  divisions: 4,
                  value: _controller.selectedChoiceId.isEmpty
                      ? 1
                      : double.parse(_controller.selectedChoiceId.value),
                  onChanged: (value) {
                    if (_controller.showResult.isFalse) {
                      _controller.selectedChoiceId.value =
                          value.toInt().toString();
                    }
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
