import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
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
      ),
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: IbCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (question) {
                        _controller.question = question;
                      },
                      keyboardType: TextInputType.text,
                      controller: _questionEditingController,
                      minLines: 3,
                      maxLines: 5,
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
                height: 120,
                child: IbCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      maxLines: 5,
                      keyboardType: TextInputType.text,
                      onChanged: (description) {
                        _controller.description = description;
                      },
                      controller: _descriptionEditingController,
                      style: const TextStyle(
                        fontSize: IbConfig.kSecondaryTextSize,
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
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'mc'.tr,
                ),
                Tab(text: 'sc'.tr),
              ],
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
    );
  }

  Widget _mCTab() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
                        Text(item.content!),
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_controller.scaleEndPoints.length <
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
                for (final item in _controller.scaleEndPoints)
                  IbCard(
                    key: UniqueKey(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.all(8),
                      height: 46,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item),
                          IconButton(
                              onPressed: () {
                                _controller.scaleEndPoints.remove(item);
                              },
                              icon: const Icon(
                                Icons.delete_outlined,
                                color: IbColors.errorRed,
                              ))
                        ],
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  void handleUserInput(String _choice) {
    if (_controller.questionType == IbQuestion.kMultipleChoice &&
        _controller.isChoiceDuplicated(_choice)) {
      Get.back();
      return;
    }

    if (_controller.questionType == IbQuestion.kScale &&
        _controller.isChoiceDuplicated(_choice)) {
      Get.back();
      return;
    }
    if (_choice.trim().isNotEmpty &&
        _controller.questionType == IbQuestion.kMultipleChoice) {
      _controller.choiceList
          .removeWhere((element) => element.content == _choice);
      _controller.choiceList.add(
          IbChoice(choiceId: IbUtils.getUniqueId(), content: _choice.trim()));
      Get.back();
    } else if (_choice.trim().isNotEmpty &&
        _controller.questionType == IbQuestion.kScale) {
      _controller.scaleEndPoints.removeWhere((element) => element == _choice);
      _controller.scaleEndPoints.add(_choice);
      Get.back();
    } else {
      print('empty');
    }
  }

  void _showTextFiledBottomSheet(String strTrKey) {
    final TextEditingController _txtController = TextEditingController();
    final Widget _widget = IbCard(
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
              handleUserInput(value.trim());
            },
            controller: _txtController,
            autofocus: true,
            textAlign: TextAlign.center,
            cursorColor: IbColors.primaryColor,
          ),
          TextButton(
            onPressed: () {
              final String _choice = _txtController.text.trim();
              handleUserInput(_choice);
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    ));
    Get.bottomSheet(
      SizedBox(height: 200, child: _widget),
      persistent: true,
    );
  }
}
