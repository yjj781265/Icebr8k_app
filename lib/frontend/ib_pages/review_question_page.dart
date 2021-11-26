import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

class ReviewQuestionPage extends StatelessWidget {
  final IbQuestionItemController itemController;
  const ReviewQuestionPage({Key? key, required this.itemController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review your question'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handleQuestionType(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Options',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
              ),
              ListTile(
                tileColor: Theme.of(context).primaryColor,
                leading: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text('Time Limit'),
                trailing: const Text('Tomorrow'),
              ),
              Obx(
                () => SwitchListTile(
                  tileColor: Theme.of(context).primaryColor,
                  value: itemController.rxIbQuestion.value.isCommentEnabled,
                  onChanged: (value) {
                    itemController.rxIbQuestion.value.isCommentEnabled = value;
                    itemController.rxIbQuestion.refresh();
                  },
                  title: const Text('Comment'),
                  secondary: const Icon(
                    FontAwesomeIcons.comment,
                    color: IbColors.primaryColor,
                  ),
                ),
              ),
              ListTile(
                tileColor: Theme.of(context).primaryColor,
                trailing: const Text('ALL'),
                title: const Text(
                  'Privacy Bonds',
                ),
                leading: const Icon(
                  Icons.remove_red_eye,
                  color: IbColors.primaryColor,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  tileColor: Theme.of(context).primaryColor,
                  value: itemController.rxIbQuestion.value.isAnonymous,
                  onChanged: (value) {
                    itemController.rxIbQuestion.value.isAnonymous = value;
                    itemController.rxIbQuestion.refresh();
                  },
                  title: const Text('Anonymous'),
                  secondary: const Icon(
                    Icons.person,
                    color: IbColors.lightGrey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleQuestionType() {
    if (itemController.rxIbQuestion.value.questionType ==
        IbQuestion.kMultipleChoice) {
      return IbMcQuestionCard(itemController);
    }
    return IbScQuestionCard(
      itemController,
    );
  }
}
