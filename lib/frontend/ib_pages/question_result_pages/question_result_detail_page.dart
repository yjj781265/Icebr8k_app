import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/question_result_detail_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class QuestionResultDetailPage extends StatelessWidget {
  final QuestionResultDetailPageController _controller;

  const QuestionResultDetailPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            children: [
              Text(
                  '${_controller.itemController.countMap[_controller.ibChoice.choiceId] ?? 0} Vote(s)'),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return SmartRefresher(
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            await _controller.loadMore();
          },
          controller: _controller.refreshController,
          child: ListView.builder(
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Align(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Users who voted anonymously are hidden',
                      style: TextStyle(
                          fontSize: IbConfig.kSecondaryTextSize,
                          color: IbColors.lightGrey),
                    ),
                  ),
                );
              }
              index -= 1;
              final item = _controller.results[index];
              return ListTile(
                onTap: () {
                  if (item.user.id == IbUtils.getCurrentUid()) {
                    Get.to(() => MyProfilePage());
                    return;
                  }
                  Get.to(() =>
                      ProfilePage(Get.put(ProfileController(item.user.id))));
                },
                tileColor: Theme.of(context).backgroundColor,
                leading: IbUserAvatar(
                  uid: item.user.id,
                  avatarUrl: item.user.avatarUrl,
                ),
                title: Text(
                  item.user.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: IbLinearIndicator(
                  endValue: item.compScore,
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
              );
            },
            itemCount: _controller.results.length + 1,
          ),
        );
      }),
    );
  }
}
