import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_create_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';

class IbScQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;
  final bool isSample;
  const IbScQuestionCard(this._controller, {Key? key, this.isSample = false})
      : super(key: key);

  @override
  _IbScQuestionCardState createState() => _IbScQuestionCardState();
}

class _IbScQuestionCardState extends State<IbScQuestionCard>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('build');
    widget._controller.isSample = widget.isSample;
    widget._controller.updateResult();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (cardKey.currentContext == null) {
        return;
      }
      widget._controller.height.value = cardKey.currentContext!.size!.height;
      widget._controller.width.value = cardKey.currentContext!.size!.width;
      print(cardKey.currentContext!.size);
    });

    return Center(
      child: FlipCard(
          flipOnTouch: false,
          key: cardKey,
          front: IbCard(
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
                if (!widget.isSample)
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => IbElevatedButton(
                              textTrKey: widget._controller.voteBtnTrKey.value,
                              color: widget._controller.isVoted.isTrue
                                  ? IbColors.accentColor
                                  : widget._controller.selectedChoice.isNotEmpty
                                      ? IbColors.primaryColor
                                      : IbColors.lightGrey,
                              onPressed:
                                  widget._controller.selectedChoice.isEmpty
                                      ? null
                                      : () async {
                                          await widget._controller.onVote();
                                          cardKey.currentState!.toggleCard();
                                          setState(() {});
                                        }),
                        ),
                      ),
                      /*    Expanded(
                      child: IbElevatedButton(
                          color: IbColors.primaryColor,
                          textTrKey: 'Home',
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }),
                    )*/
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Get.find<IbCreateQuestionController>().reset();
                              Get.back();
                            }),
                      ),
                      Obx(() => Expanded(
                            flex: 2,
                            child: IbElevatedButton(
                                textTrKey:
                                    widget._controller.submitBtnTrKey.value,
                                onPressed: () {
                                  widget._controller.submit();
                                }),
                          )),
                      Expanded(
                        child: IconButton(
                            icon: const Icon(Icons.home_outlined),
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }),
                      )
                    ],
                  ),
              ],
            ),
          )),
          back: _cardBackSide()),
    );
  }

  Widget _cardBackSide() {
    return Obx(
      () => SizedBox(
        height: widget._controller.height.value,
        width: widget._controller.width.value,
        child: IbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: IconButton(
                    onPressed: () {
                      cardKey.currentState!.toggleCard();
                    },
                    icon: const Icon(Icons.arrow_back_ios_outlined)),
              ),
              Expanded(
                flex: 10,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    startDegreeOffset: 45,
                    sections: _getSectionData(),
                  ),
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
    Color lastRandomColor = IbUtils.getRandomColor();
    for (final String choice in widget._controller.resultMap.keys) {
      final int percentage =
          ((widget._controller.resultMap[choice] ?? 0) * 100).toInt();
      Color randomColor = IbUtils.getRandomColor();
      while (randomColor == lastRandomColor) {
        randomColor = IbUtils.getRandomColor();
      }
      lastRandomColor = randomColor;

      final PieChartSectionData data = PieChartSectionData(
          badgeWidget: (percentage > 0 && percentage != 100)
              ? Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: randomColor),
                    color: IbColors.lightBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                      child: Text(
                    choice,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: IbColors.primaryColor),
                  )),
                )
              : null,
          color: randomColor,
          badgePositionPercentageOffset: 0.95,
          titlePositionPercentageOffset: 0.5,
          value: percentage.toDouble(),
          radius: 80,
          titleStyle: const TextStyle(
              fontSize: IbConfig.kPageTitleSize, fontWeight: FontWeight.bold),
          title: '$percentage%');
      _pieChartDataList.add(data);
    }
    return _pieChartDataList;
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      final bool isEmptyUrl = widget._controller.avatarUrl.value.isEmpty;

      if (isEmptyUrl) {
        return const CircleAvatar(
            radius: 16,
            foregroundImage: AssetImage('assets/icons/logo_ios.png'));
      }
      return CircleAvatar(
        radius: 16,
        foregroundImage:
            CachedNetworkImageProvider(widget._controller.avatarUrl.value),
      );
    });
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
                  onChanged: _controller.isSample
                      ? null
                      : (value) {
                          _controller.selectedChoice.value =
                              value.toInt().toString();
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
