import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_show_case_keys.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/admin/edit_ib_collection_main_page.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/search_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/controllers/user_controllers/home_tab_controller.dart';
import '../ib_colors.dart';

class HomeTab extends StatelessWidget {
  HomeTab({Key? key}) : super(key: key);
  final HomeTabController _controller = Get.put(HomeTabController());

  @override
  Widget build(BuildContext context) {
    IbAnalyticsManager()
        .logScreenView(className: "HomeTab", screenName: "HomeTab");
    return ShowCaseWidget(
      onComplete: (index, key) {
        if (key == IbShowCaseKeys.kPollExpandKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.pollExpandShowCaseBool, value: true);
        }

        if (key == IbShowCaseKeys.kVoteOptionsKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.voteOptionsShowCaseBool, value: true);
        }

        if (key == IbShowCaseKeys.kIcebreakerKey) {
          IbLocalDataService().updateBoolValue(
              key: StorageKey.icebreakerShowCaseBool, value: true);
        }
      },
      builder: Builder(
          builder: (context) => Scaffold(
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
                            _controller.selectedCategory.value =
                                value as String;
                          } else {
                            _controller.selectedCategory.value =
                                _controller.categories[1];
                          }
                          if (_controller.isLocked.isFalse) {
                            _controller.onRefresh(refreshStats: true);
                          }
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
                    Showcase(
                      key: IbShowCaseKeys.kIcebreakerKey,
                      overlayOpacity: 0.3,
                      description: 'Click to view our awesome Icebreakers',
                      shapeBorder: const CircleBorder(),
                      child: IconButton(
                        icon: const Text(
                          '🧊',
                          style: TextStyle(fontSize: 24),
                        ),
                        onPressed: () {
                          if (IbUtils.checkFeatureIsLocked()) {
                            return;
                          }
                          Get.to(() => EditIbCollectionMainPage());
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        Get.to(() => SearchPage());
                      },
                    ),
                  ],
                  leadingWidth: 48,
                  leading: Builder(
                      builder: (context) => IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: const Icon(Icons.menu))),
                ),
                drawer: const MenuPage(),
                body: Obx(() {
                  if (_controller.isLoading.isTrue) {
                    return const Center(
                      child: IbProgressIndicator(),
                    );
                  }
                  if (_controller.isLocked.isTrue &&
                      _controller.selectedCategory.value == 'Trending') {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('assets/images/lock.json')),
                          const Text.rich(
                            TextSpan(
                                text:
                                    "Please answer the first eight polls from Icebr8k in ",
                                children: [
                                  TextSpan(
                                      text: 'For You',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          ' page in order to unlock other features')
                                ]),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    );
                  }

                  if (_controller.forYourList.isEmpty &&
                      _controller.selectedCategory.value ==
                          _controller.categories[1]) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 200,
                              height: 200,
                              child: Lottie.asset(
                                  'assets/images/monkey_zen.json')),
                          const Text(
                            'This page will show polls from your friends, and tags you followed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: IbColors.lightGrey,
                              fontSize: IbConfig.kNormalTextSize,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Get.back();
                                Get.to(() => SearchPage());
                              },
                              child: const Text('Search Users and Tags'))
                        ],
                      ),
                    );
                  }

                  return SmartRefresher(
                    enablePullUp: _handlePullUp(),
                    enablePullDown: _controller.isLocked.isFalse,
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
                            return IbUtils.handleQuestionType(
                                _controller.forYourList[index],
                                isShowcase: index == 0 &&
                                    !IbLocalDataService().retrieveBoolValue(
                                        StorageKey.pollExpandShowCaseBool),
                                expanded: IbUtils.getCurrentUserSettings()
                                    .pollExpandedByDefault);
                          }

                          if (_controller.selectedCategory.value ==
                              _controller.categories[2]) {
                            return IbUtils.handleQuestionType(
                                _controller.newestList[index],
                                isShowcase: index == 0 &&
                                    !IbLocalDataService().retrieveBoolValue(
                                        StorageKey.pollExpandShowCaseBool),
                                expanded: IbUtils.getCurrentUserSettings()
                                    .pollExpandedByDefault);
                          }
                          return IbUtils.handleQuestionType(
                              _controller.trendingList[index],
                              isShowcase: index == 0 &&
                                  !IbLocalDataService().retrieveBoolValue(
                                      StorageKey.pollExpandShowCaseBool),
                              expanded: IbUtils.getCurrentUserSettings()
                                  .pollExpandedByDefault);
                        },
                        itemCount: _handleItemCount()),
                  );
                }),
              )),
    );
  }

  int _handleItemCount() {
    if (_controller.selectedCategory.value == _controller.categories[1]) {
      return _controller.forYourList.length;
    }

    if (_controller.selectedCategory.value == _controller.categories[0]) {
      return _controller.trendingList.length;
    }

    return _controller.newestList.length;
  }

  bool _handlePullUp() {
    if (_controller.selectedCategory.value == _controller.categories[1]) {
      return _controller.forYourList.length >= IbConfig.kPerPage;
    }

    if (_controller.selectedCategory.value == _controller.categories[2]) {
      return _controller.newestList.length >= IbConfig.kPerPage;
    }
    return _controller.trendingList.length >= IbConfig.kPerPage;
  }
}
