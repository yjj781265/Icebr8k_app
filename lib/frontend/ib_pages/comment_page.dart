import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

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
              Text(_controller.ibQuestion.question),
              Text(
                '${_controller.commentCount.value} '
                '${_controller.commentCount.value <= 1 ? 'comment' : 'comments'}',
                style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.isTrue) {
                return const Center(
                  child: IbProgressIndicator(),
                );
              }

              if (_controller.isLoading.isFalse &&
                  _controller.comments.length == 1) {
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

              return ListView.builder(
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
                              child: DropdownButton<String>(
                                value: 'Top Comments',
                                items: <String>['Top Comments', 'Newest First']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (_) {},
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        CommentItemWidget(_controller.comments[index]!),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                      ],
                    );
                  });
                },
                itemCount: _controller.comments.length,
              );
            }),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(
                    Radius.circular(IbConfig.kTextBoxCornerRadius)),
                border: Border.all(
                  color: IbColors.primaryColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Obx(
                  () => TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: _controller.editingController,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintStyle: const TextStyle(
                            color: IbColors.lightGrey,
                            fontSize: IbConfig.kNormalTextSize),
                        hintText: 'Type something creative',
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
                                  Icons.send_outlined,
                                  color: IbColors.primaryColor,
                                ),
                                onPressed: () async {
                                  await _controller.addComment(
                                      text: _controller.editingController.text
                                          .trim(),
                                      type: IbComment.kCommentTypeText);
                                },
                              )),
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
  final CommentController _controller = Get.find();

  CommentItemWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Ink(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.user.username,
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
                              _handleIbAnswerUI(),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        IbUtils.getChatDateTimeString(
                            DateTime.fromMillisecondsSinceEpoch(
                                item.ibComment.timestampInMs)),
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        item.ibComment.content,
                        style:
                            const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.reply,
                                size: 16,
                              ),
                              label: const Text(
                                'Reply',
                                style: TextStyle(
                                    fontSize: IbConfig.kSecondaryTextSize),
                              )),
                          TextButton.icon(
                              onPressed: () async {
                                if (item.isLiked) {
                                  await _controller.dislikeComment(item);
                                } else {
                                  await _controller.likeComment(item);
                                }
                              },
                              icon: Icon(
                                FontAwesomeIcons.thumbsUp,
                                color:
                                    item.isLiked ? IbColors.accentColor : null,
                                size: 16,
                              ),
                              label: Text(
                                item.ibComment.likes.toString(),
                              )),
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

  Widget _handleIbAnswerUI() {
    if (item.ibAnswer == null) {
      return const SizedBox();
    }

    if (_controller.ibQuestion.questionType == IbQuestion.kPic) {
      final String url = _controller.ibQuestion.choices
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

    if (_controller.ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      return Text(
        _controller.ibQuestion.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_controller.ibQuestion.questionType == IbQuestion.kScale) {
      return Text(_controller.ibQuestion.choices
          .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId)
          .content!);
    }

    return const SizedBox();
  }
}
