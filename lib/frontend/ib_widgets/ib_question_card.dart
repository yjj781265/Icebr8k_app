import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

import '../ib_colors.dart';

class IbQuestionCard extends StatelessWidget {
  IbQuestionCard({Key? key}) : super(key: key);
  final _controller = Get.put(IbQuestionItemController(), tag: 'questionId');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.95,
      child: IbCard(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  children: [
                    const Text(
                      'loljayfs',
                      style: TextStyle(
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      '5 days ago',
                      style: TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Coke or Pepsi? ',
              style: TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'They have different tastes',
              style: TextStyle(
                  fontSize: IbConfig.kDescriptionTextSize, color: Colors.black),
            ),
            const SizedBox(
              height: 16,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      _controller.updateSelected(_controller.answers[0]);
                      _controller.printMap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: Get.width * 0.9,
                            height: 40,
                            decoration: BoxDecoration(
                                color: _controller
                                        .isSelectedMap[_controller.answers[0]]!
                                    ? IbColors.primaryColor
                                    : IbColors.lightBlue,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          AnimatedContainer(
                            height: 40,
                            decoration: BoxDecoration(
                                color: IbColors.primaryColor,
                                borderRadius: BorderRadius.circular(8)),
                            width: _controller
                                    .isSelectedMap[_controller.answers[0]]!
                                ? Get.width * 0.9
                                : _controller.isVoted.isTrue
                                    ? Get.width *
                                        0.9 *
                                        _controller.result1.value
                                    : 0,
                            curve: Curves.linearToEaseOut,
                            duration: const Duration(
                                milliseconds:
                                    IbConfig.kEventTriggerDelayInMillis),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              _controller.answers[0],
                              style: const TextStyle(
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  color: Colors.black),
                            ),
                          ),
                          Positioned(
                            child: Text('40%'),
                            right: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      _controller.updateSelected(_controller.answers[1]);
                      _controller.printMap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: Get.width * 0.9,
                            height: 40,
                            decoration: BoxDecoration(
                                color: _controller
                                        .isSelectedMap[_controller.answers[1]]!
                                    ? IbColors.primaryColor
                                    : IbColors.lightBlue,
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          AnimatedContainer(
                            height: 40,
                            decoration: BoxDecoration(
                                color: IbColors.primaryColor,
                                borderRadius: BorderRadius.circular(8)),
                            width: _controller
                                    .isSelectedMap[_controller.answers[1]]!
                                ? Get.width * 0.9
                                : _controller.isVoted.isTrue
                                    ? Get.width *
                                        0.9 *
                                        _controller.result2.value
                                    : 0,
                            curve: Curves.linearToEaseOut,
                            duration: const Duration(
                                milliseconds:
                                    IbConfig.kEventTriggerDelayInMillis),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              _controller.answers[1],
                              style: TextStyle(
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  color: Colors.black),
                            ),
                          ),
                          Positioned(
                            child: Text('40%'),
                            right: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: IbElevatedButton(
                      textTrKey: 'confirm',
                      onPressed: () {
                        _controller.onVote();
                      }),
                ),
                Expanded(
                  child: IbElevatedButton(
                      textTrKey: 'Reset',
                      onPressed: () {
                        _controller.reset();
                      }),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
