import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/admin/edit_ib_collection_main_page.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/search_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
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
        title: DropdownButtonHideUnderline(
          child: Obx(
            () => DropdownButton2(
              buttonPadding: EdgeInsets.zero,
              buttonWidth: 120,
              value: _controller.selectedCategory.value,
              onChanged: (value) {
                if (value != null &&
                    value == _controller.selectedCategory.value) {
                  return;
                }

                if (value != null) {
                  _controller.selectedCategory.value = value as String;
                } else {
                  _controller.selectedCategory.value =
                      _controller.categories[1];
                }
                _controller.onRefresh(refreshStats: true);
              },
              items: _controller.categories
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: IbConfig.kPageTitleSize),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Text(
              '🧊',
              style: TextStyle(fontSize: 24),
            ),
            onPressed: () {
              Get.to(() => EditIbCollectionMainPage());
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              Get.to(() => SearchPage());
            },
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
          () => _controller.isLoading.isTrue
              ? const Center(
                  child: IbProgressIndicator(),
                )
              : SmartRefresher(
                  enablePullUp: _handlePullUp(),
                  onRefresh: () async {
                    await _controller.onRefresh(refreshStats: true);
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
                      if (_controller.selectedCategory.value ==
                          _controller.categories[1]) {
                        return _handleQuestionType(
                            _controller.forYourList[index]);
                      }
                      return _handleQuestionType(
                          _controller.trendingList[index]);
                    },
                    itemCount: _controller.selectedCategory.value ==
                            _controller.categories[1]
                        ? _controller.forYourList.length
                        : _controller.trendingList.length,
                  ),
                ),
        ),
      ),
    );
  }

  bool _handlePullUp() {
    if (_controller.selectedCategory.value == _controller.categories[1]) {
      return _controller.forYourList.length >= IbConfig.kPerPage;
    }
    return _controller.trendingList.length >= IbConfig.kPerPage;
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
