import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

class CreateQuestionScTab extends StatelessWidget {
  final CreateQuestionController _controller;

  const CreateQuestionScTab(this._controller);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          IbCard(
            radius: 8,
            elevation: 0,
            child: DropdownButtonHideUnderline(
              child: Obx(
                () => DropdownButton2(
                    itemHeight: IbConfig.kScItemHeight + 18,
                    isExpanded: true,
                    value: <String>[
                      IbQuestion.kScaleOne,
                      IbQuestion.kScaleTwo,
                      IbQuestion.kScaleThree
                    ].contains(_controller.questionType.value)
                        ? _controller.questionType.value
                        : IbQuestion.kScaleOne,
                    items: [
                      DropdownMenuItem(
                        alignment: Alignment.center,
                        value: IbQuestion.kScaleOne,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RatingBar.builder(
                            itemPadding: const EdgeInsets.all(4),
                            itemSize: IbConfig.kScItemHeight,
                            initialRating: 5,
                            ignoreGestures: true,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        alignment: Alignment.center,
                        value: IbQuestion.kScaleTwo,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RatingBar.builder(
                            ignoreGestures: true,
                            itemPadding: const EdgeInsets.all(4),
                            itemSize: IbConfig.kScItemHeight,
                            initialRating: 5,
                            itemBuilder: (context, _) => const Icon(
                              Icons.favorite,
                              color: IbColors.errorRed,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                          alignment: Alignment.center,
                          value: IbQuestion.kScaleThree,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RatingBar.builder(
                              ignoreGestures: true,
                              itemPadding: const EdgeInsets.all(4),
                              itemSize: IbConfig.kScItemHeight,
                              initialRating: 5,
                              itemBuilder: (context, index) {
                                switch (index) {
                                  case 0:
                                    return const Icon(
                                      Icons.sentiment_very_dissatisfied,
                                      color: Colors.red,
                                    );
                                  case 1:
                                    return const Icon(
                                      Icons.sentiment_dissatisfied,
                                      color: Colors.redAccent,
                                    );
                                  case 2:
                                    return const Icon(
                                      Icons.sentiment_neutral,
                                      color: Colors.amber,
                                    );
                                  case 3:
                                    return const Icon(
                                      Icons.sentiment_satisfied,
                                      color: Colors.lightGreen,
                                    );
                                  case 4:
                                    return const Icon(
                                      Icons.sentiment_very_satisfied,
                                      color: Colors.green,
                                    );
                                  default:
                                    return const SizedBox();
                                }
                              },
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      _controller.questionType.value = value.toString();
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
