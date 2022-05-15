import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_pages/comment_pages/reply_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';
import '../../../backend/controllers/user_controllers/reply_controller.dart';
import '../../../backend/models/ib_question.dart';
import '../../ib_widgets/ib_mc_question_card.dart';
import '../comment_pages/comment_page.dart';

class QuestionMainPage extends StatefulWidget {
  final IbQuestionItemController _controller;
  final ToPage toPage;
  final String? commentId;
  const QuestionMainPage(this._controller,
      {this.toPage = ToPage.none, this.commentId});

  @override
  State<QuestionMainPage> createState() => _QuestionMainPageState();
}

class _QuestionMainPageState extends State<QuestionMainPage> {
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      switch (widget.toPage) {
        case ToPage.none:
          break;
        case ToPage.comment:
          Get.to(CommentPage(Get.put(
              CommentController(itemController: widget._controller),
              tag: IbUtils.getUniqueId())));
          break;
        case ToPage.reply:
          if (widget.commentId == null) {
            return;
          }
          Get.to(ReplyPage(Get.put(
              ReplyController(
                  parentCommentId: widget.commentId!,
                  ibQuestion: widget._controller.rxIbQuestion.value),
              tag: IbUtils.getUniqueId())));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._controller.rxIbQuestion.value.question),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () {
          widget._controller
              .refreshStats()
              .then((value) => refreshController.refreshCompleted());
        },
        child: SingleChildScrollView(
            child: _handleQuestionType(widget._controller.rxIbQuestion.value)),
      ),
    );
  }

  Widget _handleQuestionType(IbQuestion question) {
    final IbQuestionItemController itemController = Get.put(
        IbQuestionItemController(
            rxIbQuestion: question.obs, rxIsExpanded: false.obs),
        tag: question.id);

    if (question.questionType == IbQuestion.kMultipleChoice ||
        question.questionType == IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }

    return IbScQuestionCard(itemController);
  }
}

enum ToPage { none, comment, reply }
