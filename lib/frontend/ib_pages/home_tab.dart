import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../backend/controllers/user_controllers/home_tab_controller.dart';
import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';

class HomeTab extends StatelessWidget {
  HomeTab({Key? key}) : super(key: key);
  final HomeTabController _controller = Get.put(HomeTabController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {},
          ),
        ],
        leading: Builder(
            builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu))),
      ),
      drawer: const MenuPage(),
      body: SafeArea(
        child: Obx(
          () => SmartRefresher(
            enablePullUp: true,
            onRefresh: () async {
              await _controller.onRefresh();
            },
            onLoading: () async {
              await _controller.loadMore();
            },
            controller: _controller.refreshController,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              controller: _controller.scrollController,
              itemBuilder: (context, index) {
                return _handleQuestionType(_controller.trendingList[index]);
              },
              itemCount: _controller.trendingList.length,
            ),
          ),
        ),
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
