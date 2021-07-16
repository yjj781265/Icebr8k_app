import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

import '../ib_colors.dart';

class IbQuestionCard extends StatelessWidget {
  final IbQuestionItemController _controller;
  IbQuestionCard(this._controller, {Key? key}) : super(key: key);
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _controller.updateResult();
    return Center(
      child: LimitedBox(
        maxHeight: 500,
        maxWidth: Get.width * 0.95,
        child: IbCard(
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
                      SizedBox(
                        width: 200,
                        child: Text(
                          _controller.username.value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: IbConfig.kSecondaryTextSize,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        IbUtils.getAgoDateTimeString(
                            DateTime.fromMillisecondsSinceEpoch(
                                _controller.ibQuestion.createdTimeInMs)),
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
                _controller.ibQuestion.question,
                style: const TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
              if (_controller.ibQuestion.description.isNotEmpty)
                Text(
                  _controller.ibQuestion.description,
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: Colors.black),
                ),
              const SizedBox(
                height: 16,
              ),
              LimitedBox(
                maxHeight: 230,
                child: _handleQuestionType(),
              ),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => IbElevatedButton(
                          textTrKey: 'Vote',
                          color: _controller.selectedChoice.isNotEmpty
                              ? IbColors.primaryColor
                              : IbColors.lightGrey,
                          onPressed: () {
                            _controller.onVote();
                          }),
                    ),
                  ),
                  Expanded(
                    child: IbElevatedButton(
                        textTrKey: 'Reset',
                        onPressed: () {
                          _controller.reset();
                        }),
                  ),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      final bool isEmptyUrl = _controller.avatarUrl.value.isEmpty;

      if (isEmptyUrl) {
        return const CircleAvatar(
            radius: 16,
            foregroundImage: AssetImage('assets/icons/logo_ios.png'));
      }
      return CircleAvatar(
        radius: 16,
        foregroundImage: NetworkImage(_controller.avatarUrl.value),
      );
    });
  }

  Widget _handleQuestionType() {
    if (_controller.ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      return Scrollbar(
        isAlwaysShown: true,
        controller: _scrollController,
        child: ListView.builder(
          itemBuilder: (context, index) {
            final String _choice = _controller.ibQuestion.choices[index];
            return IbQuestionMcItem(_choice, _controller);
          },
          shrinkWrap: true,
          controller: _scrollController,
          itemCount: _controller.ibQuestion.choices.length,
        ),
      );
    } else {
      return IbQuestionScItem('123', _controller);
    }
  }
}

class IbQuestionMcItem extends StatelessWidget {
  final String choice;
  final IbQuestionItemController _controller;

  const IbQuestionMcItem(this.choice, this._controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          _controller.updateSelected(choice);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: Get.width * 0.9,
                height: 46,
                decoration: BoxDecoration(
                    color: IbColors.lightBlue,
                    borderRadius: BorderRadius.circular(8)),
              ),
              AnimatedContainer(
                height: 46,
                decoration: BoxDecoration(
                    color: _determineColor(
                      result: _controller.resultMap[choice] ?? 0,
                      isSelected: _controller.selectedChoice.value == choice,
                      isVoted: _controller.isVoted.value,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                width: _determineWidth(
                  isSelected: _controller.selectedChoice.value == choice,
                  result: _controller.resultMap[choice] ?? 0,
                  isVoted: _controller.isVoted.value,
                ),
                duration: Duration(
                    milliseconds: _controller.isVoted.isTrue
                        ? IbConfig.kEventTriggerDelayInMillis
                        : 0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  choice,
                  style: const TextStyle(
                      fontSize: IbConfig.kNormalTextSize, color: Colors.black),
                ),
              ),
              if (_controller.isVoted.isTrue)
                Positioned(
                  right: 8,
                  child: Text(
                      '${((_controller.resultMap[choice] ?? 0) * 100).toInt()}%'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _determineWidth(
      {required bool isSelected,
      required bool isVoted,
      required double result}) {
    if (isVoted) {
      return Get.width * 0.9 * result;
    }

    if (isSelected) {
      return Get.width * 0.9;
    }

    return 0;
  }

  Color _determineColor(
      {required bool isSelected,
      required bool isVoted,
      required double result}) {
    if (isSelected) {
      return IbColors.primaryColor;
    }

    if (isVoted && !isSelected) {
      return IbColors.lightGrey;
    }

    if (!isVoted && !isSelected) {
      return Colors.transparent;
    }

    return Colors.transparent;
  }
}

class IbQuestionScItem extends StatelessWidget {
  final String choice;
  final IbQuestionItemController _controller;

  const IbQuestionScItem(this.choice, this._controller, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int value = 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.always,
            activeTrackColor: IbColors.primaryColor,
            inactiveTrackColor: IbColors.lightBlue,
            trackShape: const RectangularSliderTrackShape(),
            trackHeight: 8.0,
            valueIndicatorShape:
                const CustomSliderThumbCircle(thumbRadius: 24, min: 1, max: 5),
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
                    _controller.selectedChoice.value = value.toString();
                    print(value.toInt());
                  }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              SizedBox(width: 100, child: Text('Hate it very very much')),
              SizedBox(
                child: Text(
                  'Love it',
                  textAlign: TextAlign.end,
                ),
                width: 100,
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        )
      ],
    );
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const CustomSliderThumbCircle({
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

    TextPainter tp = TextPainter(
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
