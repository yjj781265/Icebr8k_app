import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../ib_config.dart';

class PastPolls extends StatelessWidget {
  final ChatPageController _chatPageController;

  const PastPolls(this._chatPageController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Polls'),
      ),
      body: Obx(() => SmartRefresher(
            enablePullUp:
                _chatPageController.pastPolls.length >= IbConfig.kPerPage,
            onLoading: () async {
              await _chatPageController.loadPastPolls();
            },
            onRefresh: () async {
              await _chatPageController.loadPastPolls(isRefresh: true);
            },
            controller: _chatPageController.pastPollRefresh,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return IbUtils()
                    .handleQuestionType(_chatPageController.pastPolls[index]);
              },
              itemCount: _chatPageController.pastPolls.length,
            ),
          )),
    );
  }
}
