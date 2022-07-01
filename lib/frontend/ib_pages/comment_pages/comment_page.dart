import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/reply_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/comment_pages/reply_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_rich_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';

class CommentPage extends StatelessWidget {
  final CommentController _controller;

  const CommentPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controller.itemController.rxIbQuestion.value.question,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
              Text(
                '${IbUtils.statsShortString(_controller.itemController.rxIbQuestion.value.comments)} '
                '${_controller.itemController.rxIbQuestion.value.comments <= 1 ? 'comment' : 'comments'}',
                style: const TextStyle(
                    fontSize: IbConfig.kDescriptionTextSize,
                    color: IbColors.lightGrey,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.isTrue) {
                return const Center(
                  child: IbProgressIndicator(),
                );
              }

              if (_controller.isLoading.isFalse &&
                  _controller.commentItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset('assets/images/monkey_zen.json')),
                      const Text(
                        '😞 No comments to see here',
                        style: TextStyle(
                          color: IbColors.lightGrey,
                          fontSize: IbConfig.kPageTitleSize,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SmartRefresher(
                controller: _controller.refreshController,
                footer: ClassicFooter(
                  noDataText: 'no_more_comments'.tr,
                ),
                enablePullUp:
                    _controller.commentItems.length >= IbConfig.kPerPage,
                enablePullDown: false,
                onLoading: () async {
                  await _controller.loadMore();
                },
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    return Builder(builder: (context) {
                      return Column(
                        children: [
                          CommentItemWidget(
                            item: _controller.commentItems[index],
                            controller: _controller,
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                          ),
                        ],
                      );
                    });
                  },
                  itemCount: _controller.commentItems.length,
                ),
              );
            }),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(
                    Radius.circular(IbConfig.kTextBoxCornerRadius)),
                border: Border.all(
                  color: IbColors.accentColor,
                ),
              ),
              child: Obx(
                () => TextField(
                  minLines: 1,
                  maxLines: 5,
                  maxLength: IbConfig.kCommentMaxLen,
                  focusNode: _controller.focusNode,
                  controller: _controller.editingController,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    counterText: '',
                    hintStyle: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kNormalTextSize),
                    hintText: _controller.hintText.value,
                    border: InputBorder.none,
                    suffixIcon: _controller.isAddingComment.isTrue
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator()),
                          )
                        : IconButton(
                            icon: const Icon(
                              FontAwesomeIcons.comment,
                              color: IbColors.accentColor,
                            ),
                            onPressed: () async {
                              await _controller.addComment(
                                  text:
                                      _controller.editingController.text.trim(),
                                  type: IbComment.kCommentTypeText);
                            },
                          ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CommentItemWidget extends StatelessWidget {
  final CommentItem item;
  final CommentController controller;

  const CommentItemWidget({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Get.to(() => ReplyPage(Get.put(ReplyController(
              parentCommentId: item.ibComment.commentId,
              ibQuestion: controller.itemController.rxIbQuestion.value))));
        },
        child: Ink(
          color: Theme.of(context).backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// header row
                Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IbUserAvatar(
                            avatarUrl: item.user.avatarUrl,
                            radius: 16,
                            uid: item.ibComment.uid,
                          ),
                          if (item.user.id ==
                                  controller.itemController.rxIbQuestion.value
                                      .creatorId &&
                              !controller.itemController.rxIbQuestion.value
                                  .isAnonymous)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                    color: IbColors.primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: const Text(
                                  'Creator',
                                  style: TextStyle(fontSize: 8),
                                ),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.user.username,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kNormalTextSize),
                            ),
                            Text(
                              item.ibComment.timestamp == null
                                  ? 'Posting...'
                                  : IbUtils.getAgoDateTimeString(
                                      (item.ibComment.timestamp as Timestamp)
                                          .toDate()),
                              style: const TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize,
                                  color: IbColors.lightGrey),
                            ),
                          ],
                        ),
                      ),
                      if (item.ibAnswer != null && !item.ibAnswer!.isAnonymous)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              children: [
                                const Text(
                                  'Vote: ',
                                  style: TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize),
                                ),
                                _handleIbAnswerUI(item),
                              ],
                            ),
                          ),
                        ),
                    ]),
                Padding(
                  padding: const EdgeInsets.only(left: 48.0, right: 8, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IbRichText(
                          string: item.ibComment.content,
                          defaultTextStyle: TextStyle(
                              color: Theme.of(context).indicatorColor,
                              fontSize: IbConfig.kNormalTextSize)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Get.to(() => ReplyPage(Get.put(ReplyController(
                                  parentCommentId: item.ibComment.commentId,
                                  ibQuestion: controller
                                      .itemController.rxIbQuestion.value))));
                            },
                            icon: const Icon(
                              FontAwesomeIcons.reply,
                              size: 16,
                              color: IbColors.lightGrey,
                            ),
                            label: Text(
                              IbUtils.statsShortString(
                                  item.ibComment.replies.length),
                              style: TextStyle(
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              if (item.isLiked) {
                                await controller.dislikeComment(item);
                              } else {
                                await controller.likeComment(item);
                              }
                            },
                            icon: Icon(
                              item.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: item.isLiked
                                  ? IbColors.errorRed
                                  : IbColors.lightGrey,
                              size: 16,
                            ),
                            label: Text(
                                IbUtils.statsShortString(item.ibComment.likes),
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontSize: IbConfig.kSecondaryTextSize)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handleIbAnswerUI(CommentItem item) {
    if (item.ibAnswer == null) {
      return const SizedBox();
    }

    final IbChoice ibChoice = controller
        .itemController.rxIbQuestion.value.choices
        .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId);

    return Obx(() {
      if (controller.itemController.rxIbQuestion.value.questionType ==
              QuestionType.multipleChoice ||
          controller.itemController.rxIbQuestion.value.questionType ==
              QuestionType.multipleChoicePic) {
        return Text(
          ibChoice.content ?? '',
          style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (controller.itemController.rxIbQuestion.value.questionType ==
          QuestionType.scaleOne) {
        return RatingBar.builder(
          initialRating: double.parse(ibChoice.content ?? '0'),
          ignoreGestures: true,
          itemSize: 16,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        );
      }

      if (controller.itemController.rxIbQuestion.value.questionType ==
          QuestionType.scaleTwo) {
        return RatingBar.builder(
          initialRating: double.parse(ibChoice.content ?? '0'),
          ignoreGestures: true,
          itemSize: 16,
          itemBuilder: (context, _) => const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          onRatingUpdate: (rating) {},
        );
      }

      if (controller.itemController.rxIbQuestion.value.questionType ==
          QuestionType.scaleThree) {
        return RatingBar.builder(
          initialRating: double.parse(ibChoice.content ?? '0'),
          ignoreGestures: true,
          itemSize: 16,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return const Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: Colors.red,
                );
              case 1:
                return const Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                );
              case 2:
                return const Icon(
                  Icons.sentiment_neutral,
                  color: Colors.amber,
                );
              case 3:
                return const Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.lightGreen,
                );
              case 4:
                return const Icon(
                  Icons.sentiment_very_satisfied,
                  color: Colors.green,
                );
              default:
                return const SizedBox();
            }
          },
          onRatingUpdate: (rating) {},
        );
      }

      if (ibChoice.content != null) {
        return Text(
          controller.itemController.rxIbQuestion.value.choices
              .firstWhere(
                  (element) => element.choiceId == item.ibAnswer!.choiceId)
              .content!,
          style: const TextStyle(
              fontSize: IbConfig.kDescriptionTextSize,
              fontWeight: FontWeight.bold),
        );
      }

      return const SizedBox();
    });
  }
}
