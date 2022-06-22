import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_ad_manager.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        IbLocalDataService().updateBoolValue(
            key: StorageKey.pickTagForQuestionShowCaseBool, value: true);
      },
      builder: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Obx(
              () => SizedBox(
                width: 300,
                child: AutoSizeText(
                  'create_question'.trParams({'type': _controller.title.value}),
                  maxFontSize: IbConfig.kPageTitleSize,
                  overflow: TextOverflow.ellipsis,
                  minFontSize: IbConfig.kSecondaryTextSize,
                  style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
                ),
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
                if (!IbUtils.isPremiumMember())
                  SliverToBoxAdapter(
                    child: IbAdWidget(
                        Get.put(IbAdController(IbAdManager().getBanner1()))),
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
                          controller: _controller.tabController,
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
                controller: _controller.tabController,
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
