import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';
import 'ib_card.dart';
import 'ib_elevated_button.dart';
import 'ib_user_avatar.dart';

class IbMcQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;

  const IbMcQuestionCard(this._controller, {Key? key}) : super(key: key);

  @override
  _IbMcQuestionCardState createState() => _IbMcQuestionCardState();
}

class _IbMcQuestionCardState extends State<IbMcQuestionCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    _prepareAnimations();
    _runExpandCheck();
    super.initState();
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
    if (widget._controller.isExpanded.isTrue) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Widget expandableInfo = Column(
      children: [
        Scrollbar(
          controller: _scrollController,
          child: LimitedBox(
            maxHeight: 300,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  final String _choice =
                      widget._controller.ibQuestion.choices[index];
                  return IbQuestionMcItem(_choice, widget._controller);
                },
                shrinkWrap: true,
                itemCount: widget._controller.ibQuestion.choices.length,
              ),
            ),
          ),
        ),
        Center(child: _handleButtons()),
      ],
    );
    return Center(
      child: LimitedBox(
        maxWidth: Get.width * 0.95,
        child: IbCard(
            child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 8, top: 16, bottom: 8),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Obx(
              () => Column(
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
                              widget._controller.title.value,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text(
                            IbUtils.getAgoDateTimeString(
                                DateTime.fromMillisecondsSinceEpoch(widget
                                    ._controller.ibQuestion.askedTimeInMs)),
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
                  if (widget._controller.ibQuestion.description
                      .trim()
                      .isNotEmpty)
                    Text(
                      widget._controller.ibQuestion.description.trim(),
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: Colors.black),
                    ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (widget._controller.isExpandable)
                    SizeTransition(
                      sizeFactor: animation,
                      child: expandableInfo,
                    )
                  else
                    widget._controller.isExpanded.isTrue
                        ? expandableInfo
                        : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget._controller.totalPolled.value} polled',
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                      if (widget._controller.isExpandable)
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            widget._controller.isExpanded.value =
                                !widget._controller.isExpanded.value;

                            _runExpandCheck();
                          },
                          icon: Obx(
                            () => widget._controller.isExpanded.isTrue
                                ? const Icon(
                                    Icons.expand_less_outlined,
                                    color: IbColors.primaryColor,
                                  )
                                : const Icon(
                                    Icons.expand_more_outlined,
                                    color: IbColors.primaryColor,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _handleButtons() {
    if (!widget._controller.showActionButtons) {
      return const SizedBox();
    }
    return SizedBox(
      height: 56,
      child: Obx(() {
        if (widget._controller.isAnswering.isTrue) {
          return const IbProgressIndicator(
            width: 20,
            height: 20,
          );
        }

        if (widget._controller.showResult.isTrue) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: IbColors.accentColor,
                size: 16,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Voted ${IbUtils.getSuffixDateTimeString(widget._controller.votedDateTime.value)}'),
              )
            ],
          );
        }

        if (!widget._controller.isSample) {
          return Center(
            child: IbElevatedButton(
                textTrKey: 'vote',
                color: IbColors.primaryColor,
                onPressed: widget._controller.selectedChoice.isEmpty
                    ? null
                    : () {
                        widget._controller.onVote();
                      }),
          );
        } else {
          return Center(
            child: IbElevatedButton(
                textTrKey: 'submit',
                color: IbColors.primaryColor,
                onPressed: () async {
                  await widget._controller.onSubmit();
                }),
          );
        }
      }),
    );
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      return IbUserAvatar(
        disableOnTap: widget._controller.disableAvatarOnTouch,
        avatarUrl: widget._controller.avatarUrl.value,
        uid: widget._controller.ibUser == null
            ? ''
            : widget._controller.ibUser!.id,
        radius: 16,
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
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
          if (_controller.isSample ||
              _controller.showResult.isTrue ||
              _controller.disableChoiceOnTouch) {
            return;
          }

          if (_controller.selectedChoice.value == choice) {
            _controller.selectedChoice.value = '';
          } else {
            _controller.selectedChoice.value = choice;
          }
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
                        isVoted: _controller.showResult.value),
                    borderRadius: BorderRadius.circular(8)),
                width: _determineWidth(
                    isSelected: _controller.selectedChoice.value == choice,
                    result: _controller.resultMap[choice] ?? 0,
                    isVoted: _controller.showResult.value),
                duration: Duration(
                    milliseconds: _controller.showResult.value
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
              if (_controller.showResult.value)
                TweenAnimationBuilder(
                  builder:
                      (BuildContext context, Object? value, Widget? child) {
                    return Positioned(
                      right: 8,
                      child: Text(
                          '${((_controller.resultMap[choice] ?? 0) * 100).toStringAsFixed(1)}%'),
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
