import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/comment_pages/reply_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/comment_controller.dart';
import '../../../backend/controllers/user_controllers/question_main_controller.dart';
import '../../../backend/controllers/user_controllers/reply_controller.dart';
import '../comment_pages/comment_page.dart';

class QuestionMainPage extends StatefulWidget {
  final QuestionMainController _controller;
  final ToPage toPage;
  final String? commentId;
  const QuestionMainPage(this._controller,
      {this.toPage = ToPage.none, this.commentId});

  @override
  State<QuestionMainPage> createState() => _QuestionMainPageState();
}

class _QuestionMainPageState extends State<QuestionMainPage> {
  RefreshController refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      switch (widget.toPage) {
        case ToPage.none:
          break;
        case ToPage.comment:
          Get.to(CommentPage(Get.put(
              CommentController(
                  itemController: widget._controller.itemController),
              tag: IbUtils().getUniqueId())));
          break;
        case ToPage.reply:
          if (widget.commentId == null) {
            return;
          }
          Get.to(ReplyPage(Get.put(
              ReplyController(
                  parentCommentId: widget.commentId!,
                  ibQuestion:
                      widget._controller.itemController.rxIbQuestion.value),
              tag: IbUtils().getUniqueId())));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget._controller.itemController.rxIbQuestion.value.question),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () async {
          await widget._controller.itemController.refreshStats();
          refreshController.refreshCompleted();
        },
        child: SingleChildScrollView(
            child: IbUtils().handleQuestionType(
          widget._controller.itemController.rxIbQuestion.value,
          uniqueTag: true,
        )),
      ),
    );
  }
}

enum ToPage { none, comment, reply }
