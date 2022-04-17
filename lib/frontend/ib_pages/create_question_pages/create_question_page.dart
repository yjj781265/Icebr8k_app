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
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_persistent_header.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/chat_tab_controller.dart';
import '../../../backend/controllers/user_controllers/create_question_controller.dart';
import '../../ib_config.dart';
import 'ib_media_bar.dart';

class CreateQuestionPage extends StatefulWidget {
  final List<ChatTabItem> circles;
  const CreateQuestionPage({Key? key, this.circles = const []})
      : super(key: key);

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage>
    with SingleTickerProviderStateMixin {
  final CreateQuestionController _controller =
      Get.put(CreateQuestionController());
  late TabController _tabController;
  late List<Widget> chips;

  @override
  void initState() {
    super.initState();
    _controller.pickedCircles = widget.circles;
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _controller.questionType.value = IbQuestion.kMultipleChoice;
        _controller.title.value = 'text only';
      } else if (_tabController.index == 1) {
        _controller.questionType.value = IbQuestion.kMultipleChoicePic;
        _controller.title.value = 'text with picture';
      } else {
        _controller.questionType.value = IbQuestion.kScaleOne;
        _controller.title.value = 'scale';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        IbLocalDataService().updateBoolValue(
            key: StorageKey.pickTagForQuestionBool, value: true);
      },
      builder: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Obx(
              () => Text(
                'create_question'.trParams({'type': _controller.title.value}),
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _controller.validQuestion(context);
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                  )),
            ],
          ),
          body: ExtendedNestedScrollView(
            onlyOneScrollInBody: true,
            dragStartBehavior: DragStartBehavior.down,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: IbCard(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          TextField(
                            keyboardType: TextInputType.text,
                            controller: _controller.questionEditController,
                            minLines: 3,
                            maxLines: 8,
                            maxLength: IbConfig.kQuestionTitleMaxLength,
                            style: const TextStyle(
                                fontSize: IbConfig.kPageTitleSize,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'question'.tr,
                                hintStyle: const TextStyle(
                                  color: IbColors.lightGrey,
                                )),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Divider(
                            height: 0,
                            thickness: 1,
                          ),
                          IbMediaBar(_controller),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: IbCard(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        controller: _controller.descriptionEditController,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        minLines: 3,
                        maxLines: 8,
                        maxLength: IbConfig.kQuestionDescMaxLength,
                        style: const TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'description_option'.tr,
                            hintStyle: const TextStyle(
                              color: IbColors.lightGrey,
                            )),
                      ),
                    ),
                  ),
                ),
                SliverOverlapAbsorber(
                  handle:
                      ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: IbPersistentHeader(
                      widget: IbCard(
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tooltip(
                                message: 'mc'.tr,
                                child: const Tab(
                                    icon: Icon(
                                  FontAwesomeIcons.bars,
                                ))),
                            Tooltip(
                                message: 'mc_p'.tr,
                                child: const Tab(
                                    icon: Icon(FontAwesomeIcons.listUl))),
                            Tooltip(
                                message: 'sc'.tr,
                                child: const Tab(
                                    icon: Icon(FontAwesomeIcons.star))),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ];
            },
            body: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: TabBarView(
                controller: _tabController,
                children: [
                  CreateQuestionMcTab(_controller),
                  CreateQuestionMcPicTab(_controller),
                  CreateQuestionScTab(_controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
