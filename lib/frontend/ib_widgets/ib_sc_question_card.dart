import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:page_flip_builder/page_flip_builder.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';

class IbScQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;
  const IbScQuestionCard(this._controller, {Key? key}) : super(key: key);

  @override
  _IbScQuestionCardState createState() => _IbScQuestionCardState();
}

class _IbScQuestionCardState extends State<IbScQuestionCard>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<PageFlipBuilderState> cardKey =
      GlobalKey<PageFlipBuilderState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: PageFlipBuilder(
        nonInteractiveAnimationDuration:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
        interactiveFlipEnabled: false,
        key: cardKey,
        frontBuilder: (_) => IbCard(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _handleAvatarImage(),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => SizedBox(
                            width: 200,
                            child: Text(
                              widget._controller.username.value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Text(
                          IbUtils.getAgoDateTimeString(
                              DateTime.fromMillisecondsSinceEpoch(widget
                                  ._controller.ibQuestion.createdTimeInMs)),
                          style: const TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: IbColors.lightGrey),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  widget._controller.ibQuestion.question,
                  style: const TextStyle(
                      fontSize: IbConfig.kPageTitleSize,
                      fontWeight: FontWeight.bold),
                ),
                if (widget._controller.ibQuestion.description.isNotEmpty)
                  Text(
                    widget._controller.ibQuestion.description,
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize,
                        color: Colors.black),
                  ),
                const SizedBox(
                  height: 16,
                ),
                LimitedBox(
                    maxHeight: Get.height * 0.4,
                    child: IbQuestionScItem(widget._controller)),
                _handleButtons()
              ],
            ),
          ),
        ),
        backBuilder: (BuildContext context) {
          return _cardBackSide();
        },
      ),
    );
  }

  Widget _handleButtons() {
    return Obx(() {
      Color btnColor = IbColors.primaryColor;
      final CardState currentState = widget._controller.currentState.value;
      switch (currentState) {
        case CardState.init:
          btnColor = IbColors.lightGrey;
          break;
        case CardState.picked:
          btnColor = IbColors.primaryColor;
          break;
        case CardState.processing:
          btnColor = IbColors.processingColor;
          break;
        case CardState.submitted:
          btnColor = IbColors.accentColor;
          break;
      }

      if (!widget._controller.isSample) {
        return Center(
          child: IbElevatedButton(
              textTrKey: widget._controller.voteBtnTrKey.value,
              color: btnColor,
              onPressed: widget._controller.selectedChoice.isEmpty
                  ? null
                  : () async {
                      await widget._controller.onVote();
                      setState(() {
                        cardKey.currentState!.flip();
                      });
                    }),
        );
      } else {
        return Center(
          child: IbElevatedButton(
              textTrKey: widget._controller.submitBtnTrKey.value,
              onPressed: () async {
                await widget._controller.submit();
              }),
        );
      }
    });
  }

  Widget _cardBackSide() {
    return SizedBox(
      height: widget._controller.height.value,
      width: widget._controller.width.value,
      child: IbCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: IconButton(
                  onPressed: () {
                    cardKey.currentState!.flip();
                  },
                  icon: const Icon(Icons.arrow_back_ios_outlined)),
            ),
            Expanded(
              flex: 8,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  startDegreeOffset: 45,
                  sections: _getSectionData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSectionData() {
    final List<PieChartSectionData> _pieChartDataList = [];
    for (final String choice in widget._controller.resultMap.keys) {
      final int percentage =
          ((widget._controller.resultMap[choice] ?? 0) * 100).toInt();
      final Color color =
          IbUtils.getRandomColor(widget._controller.resultMap[choice] ?? 0);
      final PieChartSectionData data = PieChartSectionData(
          badgeWidget: Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              border: Border.all(color: color),
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
          color: color,
          badgePositionPercentageOffset: 0.95,
          titlePositionPercentageOffset: 0.5,
          value: percentage.toDouble(),
          radius: 80,
          titleStyle: const TextStyle(
              fontSize: IbConfig.kNormalTextSize, fontWeight: FontWeight.bold),
          title: '$percentage%');
      _pieChartDataList.add(data);
    }
    return _pieChartDataList;
  }

  Widget _handleAvatarImage() {
    return IbUserAvatar(
      avatarUrl: widget._controller.avatarUrl.value,
      radius: 16,
    );
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
                const _CustomSliderThumbCircle(thumbRadius: 24, min: 1, max: 5),
            thumbColor: IbColors.primaryColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            overlayColor: IbColors.primaryColor.withAlpha(80),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
          ),
          child: Obx(
            () => SizedBox(
              width: Get.width * 0.9,
              height: 50,
              child: Slider(
                  min: 1,
                  max: 5,
                  label: _controller.selectedChoice.value,
                  divisions: 4,
                  value: _controller.selectedChoice.isEmpty
                      ? 1
                      : double.parse(_controller.selectedChoice.value),
                  onChanged: (value) {
                    _controller.selectedChoice.value = value.toInt().toString();
                    print(value.toInt());
                  }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: 100,
                  child: Text(_controller.ibQuestion.choices.first)),
              SizedBox(
                width: 100,
                child: Text(
                  _controller.ibQuestion.choices[1],
                  textAlign: TextAlign.end,
                ),
              )
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
    this.thumbRadius = 8,
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
