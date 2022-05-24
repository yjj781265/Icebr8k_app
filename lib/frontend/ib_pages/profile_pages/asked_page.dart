import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ib_utils.dart';

class AskedPage extends StatelessWidget {
  final AskedQuestionsController _controller;
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController();

  AskedPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Poll(s)'),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            scrollController: _scrollController,
            enablePullDown: false,
            enablePullUp: true,
            onLoading: () async {
              if (_controller.lastDoc == null) {
                _refreshController.loadNoData();
                return;
              }

              await _controller.loadMore();
              _refreshController.loadComplete();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // return the header
                  if (_controller.showPublicOnly) {
                    return Align(
                      child: Text(
                        'asked_question_ps'.tr,
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                    );
                  }
                  return const SizedBox();
                }
                index -= 1;
                return IbUtils.handleQuestionType(
                    _controller.createdQuestions[index]);
              },
              itemCount: _controller.createdQuestions.length + 1,
            ),
          );
        }),
      ),
    );
  }
}
