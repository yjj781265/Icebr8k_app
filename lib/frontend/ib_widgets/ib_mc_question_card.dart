import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';
import 'ib_user_avatar.dart';

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
                Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: LimitedBox(
                    maxHeight: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ListView.builder(
                        controller: _scrollController,
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
                ),
                _handleButtons()
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _handleButtons() {
    return Obx(() {
      Color btnColor = IbColors.primaryColor;
      final CardState currentState = _controller.currentState.value;
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
      if (!_controller.isSample) {
        return Center(
          child: IbElevatedButton(
              textTrKey: _controller.voteBtnTrKey.value,
              color: btnColor,
              onPressed: currentState == CardState.init
                  ? null
                  : () {
                      _controller.onVote();
                    }),
        );
      } else {
        return Center(
          child: IbElevatedButton(
              textTrKey: _controller.submitBtnTrKey.value,
              onPressed: () async {
                await _controller.submit();
              }),
        );
      }
    });
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      return IbUserAvatar(
        avatarUrl: _controller.avatarUrl.value,
        radius: 16,
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
                      isVoted:
                          _controller.currentState.value == CardState.submitted,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                width: _determineWidth(
                  isSelected: _controller.selectedChoice.value == choice,
                  result: _controller.resultMap[choice] ?? 0,
                  isVoted:
                      _controller.currentState.value == CardState.submitted,
                ),
                duration: Duration(
                    milliseconds:
                        _controller.currentState.value == CardState.submitted
                            ? IbConfig.kEventTriggerDelayInMillis
                            : 0),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  choice,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: IbConfig.kNormalTextSize, color: Colors.black),
                ),
              ),
              if (_controller.currentState.value == CardState.submitted)
                TweenAnimationBuilder(
                  builder:
                      (BuildContext context, Object? value, Widget? child) {
                    return Positioned(
                      right: 8,
                      child: Text(
                          '${((_controller.resultMap[choice] ?? 0) * 100).toInt()}%'),
                    );
                  },
                  duration: const Duration(
                      milliseconds: IbConfig.kEventTriggerDelayInMillis),
                  tween: Tween<double>(
                      begin: 0, end: _controller.resultMap[choice] ?? 0),
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
      return IbColors.lightGrey.withOpacity(0.3);
    }

    if (!isVoted && !isSelected) {
      return Colors.transparent;
    }

    return Colors.transparent;
  }
}
