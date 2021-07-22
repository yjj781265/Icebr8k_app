import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';

class IbMcQuestionCard extends StatelessWidget {
  final IbQuestionItemController _controller;
  final _scrollController = ScrollController();
  final bool isSample;
  IbMcQuestionCard(this._controller, {this.isSample = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _controller.isSample = isSample;
    return Center(
      child: LimitedBox(
        maxHeight: Get.height * 0.7,
        maxWidth: Get.width * 0.95,
        child: IbCard(
            child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 8),
          child: Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
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
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final String _choice =
                                _controller.ibQuestion.choices[index];
                            return IbQuestionMcItem(_choice, _controller);
                          },
                          shrinkWrap: true,
                          itemCount: _controller.ibQuestion.choices.length,
                        ),
                      ),
                    ),
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
                          /* Expanded(
                            child: IbElevatedButton(
                                textTrKey: 'Reset',
                                onPressed: () {
                                  _controller.reset();
                                }),
                          ),*/
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
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                }),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
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
        foregroundImage:
            CachedNetworkImageProvider(_controller.avatarUrl.value),
      );
    });
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
          if (!_controller.isSample) _controller.updateSelected(choice);
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
