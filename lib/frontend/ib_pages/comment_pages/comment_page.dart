import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';
import '../../../backend/controllers/user_controllers/reply_controller.dart';
import 'reply_page.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_controller.title.value),
              Text(
                '${IbUtils.statsShortString(_controller.commentCount.value)} '
                '${_controller.commentCount.value <= 1 ? 'comment' : 'comments'}',
                style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
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
                  _controller.itemController.cachedCommentItems.isEmpty) {
                return const Center(
                  child: Text(
                    '😞 No comments to see here',
                    style: TextStyle(
                      color: IbColors.lightGrey,
                      fontSize: IbConfig.kPageTitleSize,
                    ),
                  ),
                );
              }

              return SmartRefresher(
                controller: _controller.refreshController,
                footer: ClassicFooter(
                  noDataText: 'no_more_comments'.tr,
                ),
                enablePullUp: true,
                enablePullDown: false,
                onLoading: () async {
                  await _controller.loadMore();
                },
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    return Builder(builder: (context) {
                      if (index == 0) {
                        return SizedBox(
                          height: 56,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Obx(
                                  () => DropdownButton2<String>(
                                    value: _controller
                                        .itemController.currentSortOption.value,
                                    items: _controller.dropDownOptions
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) async {
                                      await _controller.loadList(value!);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      index -= 1;
                      return Column(
                        children: [
                          CommentItemWidget(
                            item: _controller
                                .itemController.cachedCommentItems[index],
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
                  itemCount:
                      _controller.itemController.cachedCommentItems.length + 1,
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
                  color: IbColors.primaryColor,
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
                              color: IbColors.primaryColor,
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
    return Hero(
      tag: item.ibComment.commentId,
      child: Material(
        child: InkWell(
          onTap: () {
            Get.to(() => ReplyPage(Get.put(
                ReplyController(
                    rxCommentItem: item.obs, commentController: controller),
                tag: item.ibComment.commentId)));
          },
          child: Ink(
            color: Theme.of(context).backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IbUserAvatar(
                            avatarUrl: item.user.avatarUrl,
                            radius: 16,
                            uid: item.ibComment.uid,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                        () => Text(
                                          '${item.user.username} ${item.user.id == controller.creatorId.value && controller.isAnonymous.isFalse ? ' 👑' : ''}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  IbConfig.kNormalTextSize),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    IbUtils.getAgoDateTimeString(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            item.ibComment.timestampInMs)),
                                    style: const TextStyle(
                                        fontSize: IbConfig.kDescriptionTextSize,
                                        color: IbColors.lightGrey),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Linkify(
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      }
                                    },
                                    options:
                                        const LinkifyOptions(looseUrl: true),
                                    text: item.ibComment.content,
                                    style: const TextStyle(
                                        fontSize: IbConfig.kNormalTextSize),
                                  ),
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          Get.to(() => ReplyPage(Get.put(
                                              ReplyController(
                                                  rxCommentItem: item.obs,
                                                  commentController:
                                                      controller))));
                                        },
                                        icon: const Icon(
                                          FontAwesomeIcons.reply,
                                          size: 16,
                                        ),
                                        label: Text(
                                          IbUtils.statsShortString(
                                              item.ibComment.replies),
                                          style: const TextStyle(
                                              fontSize:
                                                  IbConfig.kSecondaryTextSize),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          if (item.isLiked) {
                                            await controller
                                                .dislikeComment(item);
                                          } else {
                                            await controller.likeComment(item);
                                          }
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.thumbsUp,
                                          color: item.isLiked
                                              ? IbColors.errorRed
                                              : IbColors.lightGrey,
                                          size: 16,
                                        ),
                                        label: Text(
                                            IbUtils.statsShortString(
                                                item.ibComment.likes),
                                            style: const TextStyle(
                                                fontSize: IbConfig
                                                    .kSecondaryTextSize)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (item.ibAnswer != null)
                            Wrap(
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
                        ]),
                    Container(
                        color: Theme.of(context).backgroundColor,
                        margin: const EdgeInsets.only(left: 32),
                        child: Column(
                          children: [
                            _handleReplies(item.replies),
                            if (item.ibComment.replies > 3)
                              SizedBox(
                                  height: 40,
                                  width: double.maxFinite,
                                  child: TextButton(
                                    child: Text(
                                        'And ${item.ibComment.replies - 3} more'),
                                    onPressed: () {
                                      Get.to(() => ReplyPage(Get.put(
                                          ReplyController(
                                              rxCommentItem: item.obs,
                                              commentController: controller))));
                                    },
                                  )),
                          ],
                        )),
                  ],
                ),
              ),
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

    final IbChoice ibChoice = controller.choices
        .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId);

    return Obx(() {
      if (controller.questionType.value == IbQuestion.kMultipleChoice ||
          controller.questionType.value == IbQuestion.kMultipleChoicePic) {
        return Text(
          ibChoice.content ?? '',
          style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize,
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (controller.questionType.value == IbQuestion.kScaleOne) {
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

      if (controller.questionType.value == IbQuestion.kScaleTwo) {
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

      if (controller.questionType.value == IbQuestion.kScaleThree) {
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
          controller.choices
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

  Widget _handleReplies(List<CommentItem> replies) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: replies
            .getRange(0, replies.length > 3 ? 3 : replies.length)
            .map((e) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IbUserAvatar(
                  avatarUrl: e.user.avatarUrl,
                  radius: 16,
                  uid: e.user.id,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${e.user.username} ${e.user.id == controller.creatorId.value && controller.isAnonymous.isFalse ? ' 👑' : ''}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                        ],
                      ),
                      Text(
                        IbUtils.getChatTabDateString(
                            DateTime.fromMillisecondsSinceEpoch(
                                e.ibComment.timestampInMs)),
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                      Linkify(
                        options: const LinkifyOptions(looseUrl: true),
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          }
                        },
                        text: e.ibComment.content,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: IbConfig.kNormalTextSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList());
  }
}
