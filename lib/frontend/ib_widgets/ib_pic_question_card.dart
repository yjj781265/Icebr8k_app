import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_buttons.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_header.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_info.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_stats_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_tags.dart';

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
    final Widget expandableInfo = Obx(
      () => Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget._controller.showComparison.isTrue)
              IbQuestionStats(Get.put(IbQuestionStatsController(
                  questionId: widget._controller.rxIbQuestion.value.id,
                  ibAnswers: widget._controller.ibAnswers!))),
            if (widget._controller.showComparison.isFalse)
              Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget._controller.rxIbQuestion.value.choices
                      .map((e) => PicItem(
                          ibChoice: e, itemController: widget._controller))
                      .toList(growable: false)),
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
            IbQuestionTags(widget._controller),
            const SizedBox(
              height: 8,
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            if (widget._controller.showComparison.isFalse)
              Center(child: IbQuestionButtons(widget._controller)),
          ],
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IbQuestionStatsBar(widget._controller),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget._controller.rxIsExpanded.value =
                          !widget._controller.rxIsExpanded.isTrue;
                    },
                    icon: Obx(() {
                      _runExpandCheck();
                      return widget._controller.rxIsExpanded.isTrue
                          ? const Icon(
                              Icons.expand_less_rounded,
                              color: IbColors.primaryColor,
                            )
                          : const Icon(
                              Icons.expand_more_outlined,
                              color: IbColors.primaryColor,
                            );
                    }),
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
    return OpenContainer(
      openColor: Colors.black,
      closedColor: Colors.transparent,
      openElevation: 0,
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IbConfig.kMcItemCornerRadius),
      ),
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (_, openContainer) {
        return Obx(
          () => InkWell(
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
            onDoubleTap: openContainer,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.center,
              children: [
                AnimatedContainer(
                  width: IbConfig.kPicHeight + 16,
                  height: IbConfig.kPicHeight + 16,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(IbConfig.kMcItemCornerRadius)),
                      color: itemController.selectedChoiceId.value ==
                              ibChoice.choiceId
                          ? IbColors.primaryColor
                          : IbColors.lightBlue),
                  duration: const Duration(
                      milliseconds: IbConfig.kEventTriggerDelayInMillis),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: !ibChoice.url!.contains('http')
                      ? Image.file(
                          File(ibChoice.url!),
                          height: IbConfig.kPicHeight,
                          width: IbConfig.kPicHeight,
                        )
                      : CachedNetworkImage(
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholderFadeInDuration:
                              const Duration(milliseconds: 100),
                          fadeInDuration: const Duration(milliseconds: 100),
                          fit: BoxFit.fill,
                          imageUrl: ibChoice.url!,
                          height: IbConfig.kPicHeight,
                          width: IbConfig.kPicHeight,
                        ),
                ),
                if (itemController.showResult.isTrue)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      width: IbConfig.kPicHeight,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(IbConfig.kMcItemCornerRadius)),
                          color: IbUtils.handleIndicatorColor(
                                  itemController.resultMap[ibChoice] ?? 0)
                              .withOpacity(0.8)),
                      child: Text(
                        '${(itemController.resultMap[ibChoice] ?? 0) * 100}%',
                        style:
                            const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                    ),
                  ),
                if (itemController.showResult.isTrue &&
                    itemController.rxIbAnswer!.value.choiceId ==
                        ibChoice.choiceId)
                  const Positioned(
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
                  ),
              ],
            ),
          ),
        );
      },
      openBuilder:
          (BuildContext context, void Function({Object? returnValue}) action) {
        return IbMediaViewer(
          urls: itemController.rxIbQuestion.value.choices
              .map((e) => e.url!)
              .toList(),
          currentIndex: itemController.rxIbQuestion.value.choices
              .map((e) => e.url!)
              .toList()
              .indexWhere((element) => ibChoice.url! == element),
        );
      },
    );
  }
}
