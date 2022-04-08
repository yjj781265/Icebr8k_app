import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';
import '../../../backend/controllers/user_controllers/reply_controller.dart';
import '../../ib_colors.dart';
import '../../ib_config.dart';

class ReplyPage extends StatelessWidget {
  final ReplyController _controller;

  const ReplyPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Replies'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _handleReplyCommentUI(context)),
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
                  () => SafeArea(
                    child: TextField(
                      minLines: 1,
                      maxLines: 5,
                      maxLength: IbConfig.kCommentMaxLen,
                      focusNode: _controller.focusNode,
                      controller: _controller.editingController,
                      textInputAction: TextInputAction.newline,
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        counterText: '',
                        hintStyle: const TextStyle(
                            color: IbColors.lightGrey,
                            fontSize: IbConfig.kNormalTextSize),
                        hintText: _controller.hintText.value,
                        border: InputBorder.none,
                        suffixIcon: _controller.isAddingReply.isTrue
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator()),
                              )
                            : IconButton(
                                icon: Icon(
                                  _controller.replyUid.value !=
                                          _controller
                                              .rxCommentItem.value.ibComment.uid
                                      ? FontAwesomeIcons.reply
                                      : FontAwesomeIcons.comment,
                                  color: IbColors.primaryColor,
                                ),
                                onPressed: () async {
                                  _controller.addReply(
                                      text: _controller.editingController.text
                                          .trim(),
                                      type: IbComment.kCommentTypeText);
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _handleReplyCommentUI(BuildContext context) {
    return Obx(() {
      return SmartRefresher(
        controller: _controller.refreshController,
        enablePullDown: false,
        enablePullUp: true,
        footer: ClassicFooter(
          noDataText: 'no_more_replies'.tr,
        ),
        onLoading: () async {
          await _controller.loadMore();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              _handleFirstIndexUI(context),
              if (_controller.isLoading.value)
                const Center(
                  child: IbProgressIndicator(),
                )
              else
                Column(
                  children: _controller.replies
                      .map((element) => _handleReplyItemUI(element, context))
                      .toList(),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _handleReplyItemUI(CommentItem item, BuildContext context) {
    return InkWell(
      onTap: () {
        _controller.focusNode.requestFocus();
        _controller.replyUid.value = item.ibComment.uid;
        _controller.hintText.value = 'Reply to ${item.user.username}';
      },
      child: Ink(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IbUserAvatar(
              avatarUrl: item.user.avatarUrl,
              radius: 16,
              uid: item.user.id,
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
                        '${item.user.username} '
                        '${item.user.id == _controller.commentController.creatorId.value ? ' 👑' : ''}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: IbConfig.kNormalTextSize),
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
                    ],
                  ),
                  Text(
                    IbUtils.getChatTabDateString(
                        DateTime.fromMillisecondsSinceEpoch(
                            item.ibComment.timestampInMs)),
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
                    text: item.ibComment.content,
                    style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handleFirstIndexUI(BuildContext context) {
    return Hero(
      tag: _controller.rxCommentItem.value.ibComment.commentId,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IbUserAvatar(
                avatarUrl: _controller.rxCommentItem.value.user.avatarUrl,
                radius: 16,
                uid: _controller.rxCommentItem.value.ibComment.uid,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                /// added singChildScrollView to  prevent overflow at hero animation
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_controller.rxCommentItem.value.user.username} '
                            '${_controller.rxCommentItem.value.user.id == _controller.commentController.creatorId.value ? ' 👑' : ''}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                          if (_controller.rxCommentItem.value.ibAnswer !=
                                  null &&
                              _controller
                                  .rxCommentItem.value.ibAnswer!.isPublic)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Vote: ',
                                  style: TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize),
                                ),
                                _handleIbAnswerUI(
                                    _controller.rxCommentItem.value),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        IbUtils.getAgoDateTimeString(
                            DateTime.fromMillisecondsSinceEpoch(_controller
                                .rxCommentItem.value.ibComment.timestampInMs)),
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Linkify(
                        options: const LinkifyOptions(looseUrl: true),
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          }
                        },
                        text: _controller.rxCommentItem.value.ibComment.content,
                        style:
                            const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      Obx(
                        () => Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _controller.focusNode.requestFocus();
                                _controller.replyUid.value = _controller
                                    .rxCommentItem.value.ibComment.uid;
                                _controller.hintText.value =
                                    'Add a creative reply here';
                              },
                              icon: const Icon(
                                FontAwesomeIcons.reply,
                                size: 16,
                              ),
                              label: Text(
                                IbUtils.statsShortString(
                                    _controller.replyCount.value),
                                style: const TextStyle(
                                    fontSize: IbConfig.kSecondaryTextSize),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                if (_controller.isLiked.isTrue) {
                                  await _controller.commentController
                                      .dislikeComment(
                                          _controller.rxCommentItem.value);
                                  _controller.likes.value--;
                                  _controller.isLiked.value = false;
                                } else {
                                  await _controller.commentController
                                      .likeComment(
                                          _controller.rxCommentItem.value);
                                  _controller.likes.value++;
                                  _controller.isLiked.value = true;
                                }
                              },
                              icon: Icon(
                                FontAwesomeIcons.thumbsUp,
                                color: _controller.isLiked.isTrue
                                    ? IbColors.errorRed
                                    : IbColors.lightGrey,
                                size: 16,
                              ),
                              label: Text(
                                  IbUtils.statsShortString(
                                      _controller.likes.value),
                                  style: const TextStyle(
                                      fontSize: IbConfig.kSecondaryTextSize)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleIbAnswerUI(CommentItem item) {
    if (item.ibAnswer == null) {
      return const SizedBox();
    }

    final IbChoice ibChoice = _controller.commentController.choices
        .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId);

    if (_controller.commentController.questionType.value ==
        IbQuestion.kScaleOne) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {},
      );
    }

    if (_controller.commentController.questionType.value ==
        IbQuestion.kScaleTwo) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
        itemBuilder: (context, _) => const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onRatingUpdate: (rating) {},
      );
    }

    if (_controller.commentController.questionType.value ==
        IbQuestion.kScaleThree) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
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

    if (_controller.commentController.questionType.value ==
            IbQuestion.kMultipleChoice ||
        _controller.commentController.questionType.value ==
            IbQuestion.kMultipleChoicePic) {
      return Text(
        _controller.commentController.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_controller.commentController.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content !=
        null) {
      return Text(_controller.commentController.choices
          .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId)
          .content!);
    }

    return const SizedBox();
  }
}
