import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/controllers/user_controllers/comment_controller.dart';
import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../ib_colors.dart';
import '../ib_config.dart';
import '../ib_pages/comment_pages/comment_page.dart';
import 'ib_elevated_button.dart';

class IbQuestionButtons extends StatelessWidget {
  final IbQuestionItemController _controller;

  const IbQuestionButtons(this._controller);

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(onComplete: (index, key) {
      print(key);
      if (key == _controller.voteOptionsShowCaseKey) {
        IbLocalDataService().updateBoolValue(
            key: StorageKey.voteOptionsShowCaseBool, value: true);
        _controller.isShowCase.value = false;
      }
    }, builder: Builder(builder: (context) {
      return Obx(() {
        return Row(
          children: [
            // don't show answer button once user is answered the quiz or poll is closed
            if (_controller.rxIbQuestion.value.isQuiz &&
                    _controller.voted.isTrue ||
                (DateTime.now().millisecondsSinceEpoch >
                        _controller.rxIbQuestion.value.endTimeInMs &&
                    _controller.rxIbQuestion.value.endTimeInMs > 0))
              const SizedBox()
            else
              Expanded(
                child: Showcase(
                  key: _controller.voteOptionsShowCaseKey,
                  overlayOpacity: 0.3,
                  shapeBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  description:
                      IbUtils.getCurrentUserSettings().voteAnonymousByDefault
                          ? 'Long press to vote Publicly 📢'
                          : 'Long press to vote Anonymously 🤫',
                  child: IbElevatedButton(
                    disabled: _handleVoteButtonDisableState(),
                    onPressed: () async {
                      if (!_canVoteAgain()) {
                        return;
                      }
                      await _controller.onVote(
                          isAnonymous: IbUtils.getCurrentUserSettings()
                              .voteAnonymousByDefault);
                      if (!IbLocalDataService().retrieveBoolValue(
                          StorageKey.voteOptionsShowCaseBool)) {
                        // ignore: use_build_context_synchronously
                        ShowCaseWidget.of(_controller
                                .voteOptionsShowCaseKey.currentContext!)
                            .startShowCase(
                                [_controller.voteOptionsShowCaseKey]);
                      }
                    },
                    onLongPressed: () async {
                      if (!_canVoteAgain()) {
                        return;
                      }

                      await _controller.onVote(
                          isAnonymous: !IbUtils.getCurrentUserSettings()
                              .voteAnonymousByDefault);
                      if (!IbLocalDataService().retrieveBoolValue(
                          StorageKey.voteOptionsShowCaseBool)) {
                        // ignore: use_build_context_synchronously
                        ShowCaseWidget.of(_controller
                                .voteOptionsShowCaseKey.currentContext!)
                            .startShowCase(
                                [_controller.voteOptionsShowCaseKey]);
                      }
                    },
                    textTrKey: _handleVoteButtonText(),
                    color: IbColors.primaryColor,
                  ),
                ),
              ),
            if (_controller.rxIbQuestion.value.isCommentEnabled)
              Expanded(
                child: IbElevatedButton(
                  disabled: _controller.rxIsSample.isTrue,
                  onPressed: () {
                    Get.to(() => CommentPage(Get.put(
                          CommentController(itemController: _controller),
                        )));
                  },
                  textTrKey: 'comment',
                ),
              )
          ],
        );
      });
    }));
  }

  String _handleVoteButtonText() {
    if (_controller.rxIbQuestion.value.isQuiz) {
      return _controller.isAnswering.isTrue ? 'voting' : 'answer';
    } else {
      return _controller.isAnswering.isTrue
          ? 'voting'
          : _controller.voted.isTrue
              ? 'change_vote'
              : 'vote';
    }
  }

  bool _handleVoteButtonDisableState() {
    return _controller.rxIsSample.isTrue ||
        _controller.selectedChoiceId.isEmpty ||
        (_controller.myAnswer != null &&
            _controller.myAnswer!.uid != IbUtils.getCurrentUid()) ||
        _controller.isAnswering.isTrue ||
        _controller.voted.isTrue && _controller.rxIbQuestion.value.isQuiz;
  }

  bool _canVoteAgain() {
    if (_controller.myAnswer == null) {
      return true;
    }

    if (DateTime.now().millisecondsSinceEpoch <=
        _controller.myAnswer!.answeredTimeInMs) {
      return true;
    }

    final int diffInMs = DateTime.now().millisecondsSinceEpoch -
        _controller.myAnswer!.answeredTimeInMs;

    if (Duration(milliseconds: diffInMs).inMinutes <=
        IbConfig.kVoteAgainGracePeriodInMinutes) {
      return true;
    }

    final DateTime voteAgainDate = DateTime.fromMillisecondsSinceEpoch(
        _controller.myAnswer!.answeredTimeInMs +
            const Duration(hours: IbConfig.kVoteAgainInHours).inMilliseconds);
    Get.dialog(IbDialog(
      title: 'Time Limit',
      subtitle:
          "Sorry, you can't vote on this poll again until ${IbUtils.readableDateTime(voteAgainDate, showTime: true)}",
      showNegativeBtn: false,
    ));
    return false;
  }
}
