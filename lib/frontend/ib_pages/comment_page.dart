import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/controllers/reply_controller.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/reply_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  _controller.comments.isEmpty) {
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
                                  () => DropdownButton<String>(
                                    value: _controller.currentOption.value,
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
                            item: _controller.comments[index]!,
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
                  itemCount: _controller.comments.length + 1,
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
                              Icons.send_outlined,
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
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => Text(
                                  '${item.user.username} ${item.user.id == controller.creatorId.value && controller.isAnonymous.isFalse ? ' 👑' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: IbConfig.kNormalTextSize),
                                ),
                              ),
                              if (item.ibAnswer != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Vote: ',
                                      style: TextStyle(
                                          color: IbColors.lightGrey,
                                          fontSize:
                                              IbConfig.kDescriptionTextSize),
                                    ),
                                    _handleIbAnswerUI(item),
                                  ],
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
                            options: const LinkifyOptions(looseUrl: true),
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
                                          commentController: controller))));
                                },
                                icon: const Icon(
                                  FontAwesomeIcons.reply,
                                  size: 16,
                                ),
                                label: Text(
                                  IbUtils.statsShortString(
                                      item.ibComment.replies),
                                  style: const TextStyle(
                                      fontSize: IbConfig.kSecondaryTextSize),
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
                                  FontAwesomeIcons.thumbsUp,
                                  color: item.isLiked
                                      ? IbColors.accentColor
                                      : null,
                                  size: 16,
                                ),
                                label: Text(
                                    IbUtils.statsShortString(
                                        item.ibComment.likes),
                                    style: const TextStyle(
                                        fontSize: IbConfig.kSecondaryTextSize)),
                              ),
                            ],
                          ),
                          Container(
                              width: Get.width * 0.8,
                              color: Theme.of(context).backgroundColor,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _handleReplies(item.replies),
                                  if (item.replies.length > 3)
                                    SizedBox(
                                        height: 40,
                                        width: double.maxFinite,
                                        child: TextButton(
                                          child: Text(
                                              'And ${item.replies.length - 3} more'),
                                          onPressed: () {
                                            Get.to(() => ReplyPage(Get.put(
                                                ReplyController(
                                                    rxCommentItem: item.obs,
                                                    commentController:
                                                        controller))));
                                          },
                                        )),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
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

    return Obx(() {
      if (controller.questionType.value == IbQuestion.kPic) {
        final String url = controller.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
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

      if (controller.questionType.value == IbQuestion.kMultipleChoice ||
          controller.questionType.value == IbQuestion.kMultipleChoicePic) {
        return Text(
          controller.choices
              .firstWhere(
                  (element) => element.choiceId == item.ibAnswer!.choiceId)
              .content!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        );
      }

      if (controller.questionType.value == IbQuestion.kScale) {
        return Text(controller.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content!);
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
                          if (e.ibAnswer != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Vote: ',
                                  style: TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize),
                                ),
                                _handleIbAnswerUI(e),
                              ],
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
