import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/compare_controller.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ComparePage extends StatelessWidget {
  final CompareController _controller;

  const ComparePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.title),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          return SmartRefresher(
            enablePullUp: true,
            enablePullDown: false,
            onLoading: () async {
              await _controller.loadMore();
            },
            controller: _controller.refreshController,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return IbUtils().handleQuestionType(
                    _controller.items.keys.toList()[index],
                    ibAnswers: _controller
                            .items[_controller.items.keys.toList()[index]] ??
                        [],
                    customTag:
                        'compare-${IbUtils().getCurrentUid()}${_controller.items.keys.toList()[index].id}',
                    uniqueTag: true);
              },
              itemCount: _controller.items.keys.toList().length,
            ),
          );
        }),
      ),
    );
  }
}
