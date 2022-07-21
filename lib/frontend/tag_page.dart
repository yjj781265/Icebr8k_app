import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TagPage extends StatelessWidget {
  final TagPageController _controller;
  const TagPage(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              Obx(() {
                if (_controller.url.isNotEmpty) {
                  return IbUserAvatar(
                    radius: 16,
                    avatarUrl: _controller.url.value,
                  );
                } else {
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: IbColors.lightGrey,
                    child: Text(_controller.text.split('').first),
                  );
                }
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_controller.text),
              ),
            ],
          ),
          actions: [
            Obx(
              () => TextButton(
                onPressed: () async {
                  await _controller.updateFollowTag();
                },
                child: Text(
                  _controller.isFollower.isTrue ? 'Unfollow' : "Follow",
                  style: TextStyle(
                    color: _controller.isFollower.isTrue
                        ? IbColors.errorRed
                        : IbColors.primaryColor,
                  ),
                ),
              ),
            )
          ],
        ),
        body: Obx(() => _controller.isLoading.isTrue
            ? const Center(
                child: IbProgressIndicator(),
              )
            : SmartRefresher(
                enablePullUp: true,
                enablePullDown: false,
                controller: _controller.refreshController,
                onLoading: () async {
                  _controller.loadMore();
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text.rich(TextSpan(
                              text: IbUtils()
                                  .getStatsString(_controller.total.value),
                              style: const TextStyle(
                                  fontSize: IbConfig.kNormalTextSize,
                                  fontWeight: FontWeight.bold),
                              children: const [
                                TextSpan(
                                    text: ' Public Poll(s)',
                                    style: TextStyle(
                                        fontSize: IbConfig.kDescriptionTextSize,
                                        fontWeight: FontWeight.normal,
                                        color: IbColors.lightGrey))
                              ])),
                          const SizedBox(
                            width: 16,
                          ),
                          if (_controller.user != null)
                            Text.rich(TextSpan(
                                text: 'Tag creator: ',
                                style: const TextStyle(
                                    color: IbColors.lightGrey,
                                    fontWeight: FontWeight.normal,
                                    fontSize: IbConfig.kDescriptionTextSize),
                                children: [
                                  TextSpan(
                                      text: _controller.creatorUsername.value,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.to(() => ProfilePage(Get.put(
                                              ProfileController(
                                                  _controller.user!.id))));
                                        },
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).indicatorColor,
                                          fontSize: IbConfig.kSecondaryTextSize,
                                          fontWeight: FontWeight.bold))
                                ])),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      );
                    }
                    index -= 1;
                    return IbUtils().handleQuestionType(
                        _controller.ibQuestions[index],
                        customTag: 'tag-${_controller.ibQuestions[index].id}',
                        uniqueTag: true);
                  },
                  itemCount: _controller.ibQuestions.isEmpty
                      ? 1
                      : _controller.ibQuestions.length + 1,
                ),
              )));
  }
}
