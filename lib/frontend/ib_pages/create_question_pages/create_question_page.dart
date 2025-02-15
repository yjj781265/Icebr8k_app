import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_mc_pic_tab.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_mc_tab.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_sc_tab.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_ad_widget.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/create_question_controller.dart';
import '../../../backend/controllers/user_controllers/ib_ad_controller.dart';
import '../../ib_config.dart';
import 'ib_media_bar.dart';

class CreateQuestionPage extends StatefulWidget {
  final CreateQuestionController controller;
  const CreateQuestionPage({Key? key, required this.controller})
      : super(key: key);

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage>
    with SingleTickerProviderStateMixin {
  late CreateQuestionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.tabController = TabController(vsync: this, length: 3);
    _controller.tabController.addListener(() {
      if (_controller.tabController.index == 0) {
        _controller.questionType.value = QuestionType.multipleChoice;
        _controller.title.value = 'Text Only';
      } else if (_controller.tabController.index == 1) {
        _controller.questionType.value = QuestionType.multipleChoicePic;
        _controller.title.value = 'Text with Pictures';
      } else {
        _controller.questionType.value = QuestionType.scaleOne;
        _controller.title.value = 'Scale';
      }
    });
    if (_controller.oldItemController != null) {
      switch (_controller.oldItemController!.rxIbQuestion.value.questionType) {
        case QuestionType.multipleChoice:
          _controller.tabController.index = 0;
          break;
        case QuestionType.multipleChoicePic:
          _controller.tabController.index = 1;
          break;
        case QuestionType.scaleOne:

        case QuestionType.scaleTwo:

        case QuestionType.scaleThree:
          _controller.tabController.index = 2;
          break;
        default:
          _controller.tabController.index = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        IbLocalDataService().updateBoolValue(
            key: StorageKey.pickTagForQuestionShowCaseBool, value: true);
      }, builder: (BuildContext context) { return Text(""); },
    );
  }
}
