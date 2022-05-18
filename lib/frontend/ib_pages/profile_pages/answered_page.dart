import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/answered_question_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ib_utils.dart';

class AnsweredPage extends StatelessWidget {
  final AnsweredQuestionController _controller;
  final ScrollController _scrollController = ScrollController();

  AnsweredPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Answered'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          return SmartRefresher(
            controller: _controller.refreshController,
            scrollController: _scrollController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: () async {
              await _controller.loadMore();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                return IbUtils.handleQuestionType(
                    _controller.answeredQs[index].ibQuestion);
              },
              itemCount: _controller.answeredQs.length,
            ),
          );
        }),
      ),
    );
  }
}
