import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/reply_controller.dart';
import 'package:icebr8k/backend/models/ib_comment.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_rich_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';
import '../../../backend/models/ib_question.dart';

class ReplyPage extends StatelessWidget {
  final ReplyController _controller;

  const ReplyPage(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Obx(
              () => Text(
            'Replies${_controller.count.value == 0 ? '' : '(${_controller.count.value})'}',
            style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
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
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset('assets/images/monkey_zen.json')),
                      const Text(
                        '😞 No replies to see here',
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
                  noDataText: 'no_more_replies'.tr,
                ),
                enablePullUp:
                _controller.comments.length >= _controller.kPerPageMax,
                enablePullDown: false,
                onLoading: () async {
                  await _controller.loadMore();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final item = _controller.comments[index];
                    return Ink(
                      color: index == 0
                          ? Theme.of(context).backgroundColor
                          : Theme.of(context).primaryColor,
                      child: InkWell(
                        onTap: () async => _onReplyTap(item),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        IbUserAvatar(
                                          avatarUrl: item.user.avatarUrl,
                                          radius: 16,
                                          uid: item.ibComment.uid,
                                        ),
                                        if (item.user.id ==
                                            _controller.creatorId.value &&
                                            _controller
                                                .isQuestionAnonymous.isFalse)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(top: 4.0),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                  color: IbColors.primaryColor,
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(4))),
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
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  item.user.username,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: IbConfig
                                                          .kNormalTextSize),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              item.ibComment.timestamp == null
                                                  ? 'Posting...'
                                                  : IbUtils
                                                  .getAgoDateTimeString(
                                                  (item.ibComment
                                                      .timestamp
                                                  as Timestamp)
                                                      .toDate()),
                                              style: const TextStyle(
                                                  fontSize: IbConfig
                                                      .kDescriptionTextSize,
                                                  color: IbColors.lightGrey),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            IbRichText(
                                              string: item.ibComment.content,
                                              defaultTextStyle :const TextStyle(
                                                  fontSize:
                                                  IbConfig.kNormalTextSize),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  await _onReplyTap(item);
                                                },
                                                child: const Text(
                                                  'Reply',
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (item.ibAnswer != null &&
                                        !item.ibAnswer!.isAnonymous)
                                      Wrap(
                                        children: [
                                          const Text(
                                            'Vote: ',
                                            style: TextStyle(
                                                color: IbColors.lightGrey,
                                                fontSize: IbConfig
                                                    .kDescriptionTextSize),
                                          ),
                                          _handleIbAnswerUI(item),
                                        ],
                                      ),
                                  ]),
                            ),
                            if (index == 0)
                              const SizedBox()
                            else
                              const Divider(
                                height: 1,
                                thickness: 1,
                              )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _controller.comments.length,
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
                  focusNode: _controller.node,
                  maxLength: IbConfig.kCommentMaxLen,
                  controller: _controller.editingController,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    counterText: '',
                    hintStyle: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kNormalTextSize),
                    hintText: 'Add a reply here',
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
                        FontAwesomeIcons.reply,
                        color: IbColors.primaryColor,
                      ),
                      onPressed: () async {
                        await _controller.addReply(
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

  Widget _handleIbAnswerUI(CommentItem item) {
    if (item.ibAnswer == null) {
      return const SizedBox();
    }

    final ibChoice = _controller.ibQuestion.choices
        .firstWhere((element) => element.choiceId == item.ibAnswer!.choiceId);

    if (_controller.ibQuestion.questionType == IbQuestion.kMultipleChoice ||
        _controller.ibQuestion.questionType == IbQuestion.kMultipleChoicePic) {
      return Text(
        ibChoice.content ?? '',
        style: const TextStyle(
          fontSize: IbConfig.kDescriptionTextSize,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (_controller.ibQuestion.questionType == IbQuestion.kScaleOne) {
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

    if (_controller.ibQuestion.questionType == IbQuestion.kScaleTwo) {
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

    if (_controller.ibQuestion.questionType == IbQuestion.kScaleThree) {
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
        _controller.ibQuestion.choices
            .firstWhere(
                (element) => element.choiceId == item.ibAnswer!.choiceId)
            .content!,
        style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize,
            fontWeight: FontWeight.bold),
      );
    }

    return const SizedBox();
  }

  Future<void> _onReplyTap(CommentItem item) async {
    _controller.editingController.clear();
    final text = '@${_controller.editingController.text}${item.user.username} ';
    _controller.editingController.value = TextEditingValue(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length));
    _controller.node.requestFocus();
    _controller.notifyUid = item.user.id;
  }
}
