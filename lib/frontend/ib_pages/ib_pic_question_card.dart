import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_info.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_utils.dart';

class IbPicQuestionCard extends StatefulWidget {
  final IbQuestionItemController _controller;

  const IbPicQuestionCard(this._controller);

  @override
  State<IbPicQuestionCard> createState() => _IbPicQuestionCardState();
}

class _IbPicQuestionCardState extends State<IbPicQuestionCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
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
    final Widget expandableInfo = Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Wrap(
              spacing: 8,
              runSpacing: 24,
              children: widget._controller.rxIbQuestion.value.choices
                  .map((e) =>
                      PicItem(ibChoice: e, itemController: widget._controller))
                  .toList(growable: false))),
          if (IbQuestion.kPic ==
              widget._controller.rxIbQuestion.value.questionType)
            const Text(
              'Double tap on the picture to enlarge',
              style: TextStyle(
                  color: IbColors.lightGrey,
                  fontSize: IbConfig.kDescriptionTextSize),
            ),
          const SizedBox(
            height: 8,
          ),
          Center(child: IbQuestionButtons(widget._controller)),
        ],
      ),
    );
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
            child: IbCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IbQuestionHeader(widget._controller),
              IbQuestionInfo(widget._controller),
              const SizedBox(
                height: 8,
              ),
              SizeTransition(
                sizeFactor: animation,
                child: expandableInfo,
              ),

              /// show current user answer if is available
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IbQuestionStatsBar(widget._controller),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget._controller.rxIsExpanded.value =
                          !widget._controller.rxIsExpanded.isTrue;
                      _runExpandCheck();
                    },
                    icon: Obx(
                      () => widget._controller.rxIsExpanded.isTrue
                          ? const Icon(
                              Icons.expand_less_rounded,
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
        )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class PicItem extends StatelessWidget {
  final IbChoice ibChoice;
  final IbQuestionItemController itemController;

  const PicItem({required this.ibChoice, required this.itemController});

  @override
  Widget build(BuildContext context) {
    if (ibChoice.url == null || ibChoice.url!.isEmpty) {
      return const SizedBox();
    }
    return Obx(() => InkWell(
          borderRadius: const BorderRadius.all(
              Radius.circular(IbConfig.kMcItemCornerRadius)),
          onTap: () {
            if (itemController.isSample) {
              return;
            }
            if (itemController.selectedChoiceId.value == ibChoice.choiceId) {
              itemController.selectedChoiceId.value = '';
            } else {
              itemController.selectedChoiceId.value = ibChoice.choiceId;
            }
          },
          onDoubleTap: () {
            final Widget img = itemController.isLocalFile
                ? Image.file(
                    File(ibChoice.url!),
                  )
                : CachedNetworkImage(imageUrl: ibChoice.url!);

            final Widget hero = Hero(
              tag: '${itemController.controllerId}${ibChoice.choiceId}',
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: img,
                ),
              ),
            );

            /// show image preview
            IbUtils.showInteractiveViewer(hero, context);
          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              Container(
                width: IbConfig.kMcPicItemHeight,
                height: IbConfig.kMcPicItemHeight,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(IbConfig.kMcItemCornerRadius)),
                    color: itemController.selectedChoiceId.value ==
                            ibChoice.choiceId
                        ? IbColors.primaryColor
                        : IbColors.lightBlue),
              ),
              if (!itemController.isSample && itemController.showResult.isTrue)
                Positioned(
                    top: -24,
                    child: Chip(
                      backgroundColor: IbUtils.handleIndicatorColor(0.2),
                      padding: EdgeInsets.zero,
                      label: Text('100%',
                          style: const TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize)),
                    )),
              Hero(
                tag: '${itemController.controllerId}${ibChoice.choiceId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: itemController.isLocalFile
                      ? Image.file(
                          File(ibChoice.url!),
                          height: IbConfig.kMcPicHeight,
                          width: IbConfig.kMcPicHeight,
                        )
                      : CachedNetworkImage(
                          imageUrl: ibChoice.url!,
                          height: IbConfig.kMcPicHeight,
                          width: IbConfig.kMcPicHeight,
                        ),
                ),
              ),
              Obx(() {
                if (itemController.selectedChoiceId.value ==
                    ibChoice.choiceId) {
                  return const Positioned(
                    bottom: 2,
                    right: 2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: IbColors.white,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: IbColors.accentColor,
                        size: 16,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              })
            ],
          ),
        ));
  }
}
