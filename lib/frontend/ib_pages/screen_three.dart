import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

class ScreenThree extends StatelessWidget {
  ScreenThree({Key? key}) : super(key: key);
  final SetUpController _setUpController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        backgroundColor: IbColors.lightBlue,
        leading: IconButton(
            onPressed: () {
              _setUpController.liquidController.animateToPage(page: 1);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          Obx(() {
            if (_setUpController.answeredCounter.value == 8) {
              return IconButton(
                  onPressed: () {
                    Get.offAll(() => HomePage(), binding: HomeBinding());
                  },
                  icon: const Icon(Icons.check));
            }
            return const SizedBox();
          })
        ],
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 24, bottom: 16),
                  child: Text(
                    'Finally, answer the following 8 questions to get your Icebr8k journey started',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: PersistentHeader(
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(
                                    IbConfig.kScrollbarCornerRadius)),
                            child: Obx(
                              () => LinearProgressIndicator(
                                color: IbColors.accentColor,
                                value: _setUpController.answeredCounter.value /
                                    _setUpController.ibQuestions.length,
                                backgroundColor: IbColors.lightGrey,
                                minHeight: 8,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Obx(
                            () => Text(
                              '${_setUpController.answeredCounter.value}/${_setUpController.ibQuestions.length}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ];
          },
          body: Obx(() => ListView.builder(
                itemBuilder: (context, index) {
                  final IbQuestion _ibQuestion =
                      _setUpController.ibQuestions[index];
                  if (_ibQuestion.questionType == IbQuestion.kScale) {
                    return IbScQuestionCard(Get.put(
                        IbQuestionItemController(
                          ibQuestion: _ibQuestion,
                          disableAvatarOnTouch: true,
                        ),
                        tag: _ibQuestion.id));
                  }

                  return IbMcQuestionCard(Get.put(
                      IbQuestionItemController(
                        disableAvatarOnTouch: true,
                        ibQuestion: _ibQuestion,
                      ),
                      tag: _ibQuestion.id));
                },
                itemCount: _setUpController.ibQuestions.length,
              )),
        ),
      ),
    );
  }
}
