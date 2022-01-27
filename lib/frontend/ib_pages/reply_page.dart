import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/controllers/reply_controller.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class ReplyPage extends StatelessWidget {
  final ReplyController _controller;

  const ReplyPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Reply'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _handleReplyCommentUI()),
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
                  focusNode: _controller.focusNode,
                  controller: _controller.editingController,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kNormalTextSize),
                    hintText: 'Add a creative reply here',
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
                            icon: const Icon(
                              Icons.send_outlined,
                              color: IbColors.primaryColor,
                            ),
                            onPressed: () async {
                              _controller.addReply(
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

  Widget _handleReplyCommentUI() {
    return Obx(
      () => SmartRefresher(
        controller: _controller.refreshController,
        enablePullDown: false,
        enablePullUp: true,
        onLoading: () async {
          await _controller.loadMore();
        },
        child: ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _handleFirstIndexUI(context);
            }
            index -= 1;
            final CommentItem item = _controller.replies[index]!;
            return _handleReplyItemUI(item, context);
          },
          itemCount: _controller.replies.length + 1,
        ),
      ),
    );
  }

  Material _handleReplyItemUI(CommentItem item, BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          _controller.editingController.text = '@${item.user.username} ';
          _controller.focusNode.requestFocus();
        },
        child: Ink(
          color: Theme.of(context).backgroundColor,
          padding:
              const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 10),
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
                          '${item.user.id == _controller.commentController.ibQuestion.creatorId ? ' 👑' : ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: IbConfig.kNormalTextSize),
                        ),
                        if (item.ibAnswer != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
                    Text(
                      item.ibComment.content,
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleFirstIndexUI(BuildContext context) {
    return Obx(
      () => Hero(
        tag: _controller.replyComment.ibComment.commentId,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.only(bottom: 4),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IbUserAvatar(
                  avatarUrl: _controller.replyComment.user.avatarUrl,
                  radius: 16,
                  uid: _controller.replyComment.ibComment.uid,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_controller.replyComment.user.username} '
                              '${_controller.replyComment.user.id == _controller.commentController.ibQuestion.creatorId ? ' 👑' : ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kNormalTextSize),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Vote: ',
                                  style: TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize),
                                ),
                                _handleIbAnswerUI(_controller.replyComment),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          IbUtils.getAgoDateTimeString(
                              DateTime.fromMillisecondsSinceEpoch(_controller
                                  .replyComment.ibComment.timestampInMs)),
                          style: const TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: IbColors.lightGrey),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          _controller.replyComment.ibComment.content,
                          style: const TextStyle(
                              fontSize: IbConfig.kNormalTextSize),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                _controller.focusNode.requestFocus();
                              },
                              icon: const Icon(
                                FontAwesomeIcons.reply,
                                size: 16,
                              ),
                              label: Text(
                                IbUtils.statsShortString(
                                    _controller.replyCounts.value),
                                style: const TextStyle(
                                    fontSize: IbConfig.kSecondaryTextSize),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                if (_controller.isLiked.isTrue) {
                                  await _controller.commentController
                                      .dislikeComment(_controller.replyComment);
                                  _controller.isLiked.value = false;
                                } else {
                                  await _controller.commentController
                                      .likeComment(_controller.replyComment);
                                  _controller.isLiked.value = true;
                                }
                              },
                              icon: Icon(
                                FontAwesomeIcons.thumbsUp,
                                color: _controller.isLiked.isTrue
                                    ? IbColors.accentColor
                                    : null,
                                size: 16,
                              ),
                              label: Text(
                                  IbUtils.statsShortString(
                                      _controller.replyComment.ibComment.likes),
                                  style: const TextStyle(
                                      fontSize: IbConfig.kSecondaryTextSize)),
                            ),
                          ],
                        ),
                      ],
                    ),
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

    if (_controller.commentController.ibQuestion.questionType ==
        IbQuestion.kPic) {
      final String url = _controller.commentController.ibQuestion.choices
          .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId)
          .url!;
      return InkWell(
        onTap: () {
          Get.to(() => IbMediaViewer(urls: [url], currentIndex: 0));
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: CachedNetworkImage(
              width: 30, height: 30, fit: BoxFit.fill, imageUrl: url),
        ),
      );
    }

    if (_controller.commentController.ibQuestion.questionType ==
            IbQuestion.kMultipleChoice ||
        _controller.commentController.ibQuestion.questionType ==
            IbQuestion.kMultipleChoicePic) {
      return Text(
        _controller.commentController.ibQuestion.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_controller.commentController.ibQuestion.questionType ==
        IbQuestion.kScale) {
      return Text(_controller.commentController.ibQuestion.choices
          .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId)
          .content!);
    }

    return const SizedBox();
  }
}
