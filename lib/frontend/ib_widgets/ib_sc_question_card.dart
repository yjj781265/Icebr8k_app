import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';

import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';

class IbScQuestionCard extends StatelessWidget {
  final IbQuestionItemController _controller;
  final bool isSample;
  IbScQuestionCard(this._controller, {Key? key, this.isSample = false})
      : super(key: key);
  final mKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    _controller.isSample = isSample;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mKey.currentContext == null) {
        return;
      }
      _controller.height.value = mKey.currentContext!.size!.height;
      _controller.width.value = mKey.currentContext!.size!.width;
      print(mKey.currentContext!.size);
    });

    return Center(
      child: FlipCard(
        flipOnTouch: false,
        key: mKey,
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
                            _controller.username.value,
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
                  maxHeight: Get.height * 0.4,
                  child: IbQuestionScItem(_controller)),
              if (!isSample)
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => IbElevatedButton(
                            textTrKey: _controller.voteBtnTrKey.value,
                            color: _controller.isVoted.isTrue
                                ? IbColors.accentColor
                                : _controller.selectedChoice.isNotEmpty
                                    ? IbColors.primaryColor
                                    : IbColors.lightGrey,
                            onPressed: () {
                              _controller.onVote();
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
                    Obx(() => Expanded(
                          child: IbElevatedButton(
                              textTrKey: _controller.submitBtnTrKey.value,
                              onPressed: () {
                                _controller.submit();
                              }),
                        )),
                    Expanded(
                      child: IbElevatedButton(
                          color: IbColors.primaryColor,
                          textTrKey: 'Home',
                          onPressed: () {
                            Get.offAll(() => HomePage());
                          }),
                    )
                  ],
                ),
            ],
          ),
        )),
        back: Obx(() {
          return SizedBox(
            height: _controller.height.value,
            width: _controller.width.value,
            child: const IbCard(
              child: Center(
                child: Text('Back'),
              ),
            ),
          );
        }),
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
        foregroundImage:
            CachedNetworkImageProvider(_controller.avatarUrl.value),
      );
    });
  }
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
                          _controller.selectedChoice.value = value.toString();
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
