import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../ib_config.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({Key? key}) : super(key: key);

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage>
    with SingleTickerProviderStateMixin {
  final IbCreateQuestionController _controller =
      Get.put(IbCreateQuestionController());
  final TextEditingController _questionEditingController =
      TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller.questionEditController = _questionEditingController;
    _controller.descriptionEditController = _descriptionEditingController;
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _controller.questionType = IbQuestion.kMultipleChoice;
      } else {
        _controller.questionType = IbQuestion.kScale;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'create_question'.tr,
          style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _controller.validQuestion();
              },
              icon: const Icon(Icons.check))
        ],
        backgroundColor: IbColors.lightBlue,
      ),
      backgroundColor: IbColors.lightBlue,
      body: Scrollbar(
        child: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 125,
                  child: IbCard(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        onChanged: (question) {
                          _controller.question = question;
                        },
                        controller: _questionEditingController,
                        maxLines: 2,
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
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: IbCard(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        maxLines: 2,
                        onChanged: (description) {
                          _controller.description = description;
                        },
                        controller: _descriptionEditingController,
                        style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                        ),
                        maxLength: IbConfig.kQuestionDescMaxLength,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: IbColors.lightGrey),
                          hintText: 'description_option'.tr,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              SizedBox(
                height: 64,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(IbConfig.kCardCornerRadius)),
                      color: IbColors.white),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: 'mc'.tr,
                      ),
                      Tab(text: 'sc'.tr),
                    ],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 32),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    labelColor: Colors.black,
                    unselectedLabelColor: IbColors.lightGrey,
                    indicatorColor: IbColors.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _mCTab(),
                    _sCTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mCTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_controller.choiceList.length < IbConfig.kChoiceLimit) {
                  _showTextFiledBottomSheet('add_choice');
                } else {
                  Get.showSnackbar(GetBar(
                    borderRadius: IbConfig.kCardCornerRadius,
                    margin: const EdgeInsets.all(8),
                    duration: const Duration(seconds: 3),
                    backgroundColor: IbColors.errorRed,
                    messageText: Text('choice_limit'.tr),
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                height: 46,
                decoration: BoxDecoration(
                    color: IbColors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'tap_to_add'.tr,
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                    const Icon(Icons.add_outlined),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                print('$oldIndex to $newIndex');
                _controller.swapIndex(oldIndex, newIndex);
              },
              primary: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final item in _controller.choiceList)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(8),
                    key: UniqueKey(),
                    height: 46,
                    decoration: BoxDecoration(
                        color: IbColors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item),
                        IconButton(
                            onPressed: () {
                              _controller.choiceList.remove(item);
                            },
                            icon: const Icon(
                              Icons.delete_outlined,
                              color: IbColors.errorRed,
                            ))
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sCTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_controller.scaleChoiceList.length <
                    IbConfig.kScChoiceLimit) {
                  _showTextFiledBottomSheet('add_endpoint');
                } else {
                  Get.showSnackbar(GetBar(
                    borderRadius: IbConfig.kCardCornerRadius,
                    margin: const EdgeInsets.all(8),
                    duration: const Duration(seconds: 3),
                    backgroundColor: IbColors.errorRed,
                    messageText: Text('choice_limit_sc'.tr),
                  ));
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                height: 46,
                decoration: BoxDecoration(
                    color: IbColors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'tap_to_add_sc'.tr,
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                    const Icon(Icons.add_outlined),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                print('$oldIndex to $newIndex');
                _controller.swapIndex(oldIndex, newIndex);
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              primary: false,
              children: [
                for (final item in _controller.scaleChoiceList)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.all(8),
                    key: UniqueKey(),
                    height: 46,
                    decoration: BoxDecoration(
                        color: IbColors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item),
                        IconButton(
                            onPressed: () {
                              _controller.scaleChoiceList.remove(item);
                            },
                            icon: const Icon(
                              Icons.delete_outlined,
                              color: IbColors.errorRed,
                            ))
                      ],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showTextFiledBottomSheet(String strTrKey) {
    final TextEditingController _txtController = TextEditingController();
    final Widget _widget = Container(
      color: const Color(0xff757575),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(IbConfig.kCardCornerRadius),
            topRight: Radius.circular(IbConfig.kCardCornerRadius),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strTrKey.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                ),
              ),
              TextField(
                textInputAction: TextInputAction.done,
                maxLength: _controller.questionType == IbQuestion.kScale
                    ? IbConfig.kScAnswerMaxLength
                    : IbConfig.kAnswerMaxLength,
                onSubmitted: (value) {
                  final String _choice = _txtController.text;
                  if (_choice.trim().isNotEmpty &&
                      _controller.questionType == IbQuestion.kMultipleChoice) {
                    _controller.choiceList.add(_choice);
                    Get.back();
                  } else if (_choice.trim().isNotEmpty &&
                      _controller.questionType == IbQuestion.kScale) {
                    _controller.scaleChoiceList.add(_choice);
                    Get.back();
                  } else {
                    print('empty');
                  }
                },
                controller: _txtController,
                autofocus: true,
                textAlign: TextAlign.center,
                cursorColor: IbColors.primaryColor,
              ),
              TextButton(
                onPressed: () {
                  final String _choice = _txtController.text;
                  if (_choice.trim().isNotEmpty &&
                      _controller.questionType == IbQuestion.kMultipleChoice) {
                    _controller.choiceList.add(_choice);
                    Get.back();
                  } else if (_choice.trim().isNotEmpty &&
                      _controller.questionType == IbQuestion.kScale) {
                    _controller.scaleChoiceList.add(_choice);
                    Get.back();
                  } else {
                    print('empty');
                  }
                },
                child: Text('add'.tr),
              ),
            ],
          ),
        ),
      ),
    );
    Get.bottomSheet(
      _widget,
      persistent: true,
    );
  }
}
