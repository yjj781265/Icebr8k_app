import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../backend/models/ib_question.dart';
import 'ib_widgets/ib_mc_question_card.dart';

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
        ),
        body: Obx(() => SmartRefresher(
              enablePullUp: true,
              enablePullDown: false,
              controller: _controller.refreshController,
              onLoading: () async {
                _controller.loadMore();
              },
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Text.rich(TextSpan(
                            text:
                                IbUtils.getStatsString(_controller.total.value),
                            style: const TextStyle(
                                fontSize: IbConfig.kNormalTextSize),
                            children: const [
                              TextSpan(
                                  text: ' poll(s)',
                                  style: TextStyle(
                                      fontSize: IbConfig.kSecondaryTextSize,
                                      color: IbColors.lightGrey))
                            ])),
                        if (_controller.user != null)
                          Text.rich(TextSpan(
                              text: 'Tag creator: ',
                              style: const TextStyle(
                                  color: IbColors.lightGrey,
                                  fontSize: IbConfig.kSecondaryTextSize),
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
                                        color: Theme.of(context).indicatorColor,
                                        fontSize: IbConfig.kSecondaryTextSize,
                                        fontWeight: FontWeight.bold))
                              ])),
                        const SizedBox(
                          height: 8,
                        ),
                        Obx(
                          () => Center(
                            child: IbElevatedButton(
                              onPressed: () async {
                                await _controller.updateTag();
                              },
                              textSize: IbConfig.kSecondaryTextSize,
                              textTrKey: _controller.isFollower.isTrue
                                  ? 'Unfollow'
                                  : "Follow",
                              color: _controller.isFollower.isTrue
                                  ? IbColors.errorRed
                                  : IbColors.accentColor,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  index -= 1;
                  return _handleQuestionType(_controller.ibQuestions[index]);
                },
                itemCount: _controller.ibQuestions.isEmpty
                    ? 1
                    : _controller.ibQuestions.length + 1,
              ),
            )));
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
