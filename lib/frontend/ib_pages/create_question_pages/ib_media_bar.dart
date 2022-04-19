import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_tag_picker.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/create_question_controller.dart';
import '../../../backend/controllers/user_controllers/create_question_tag_picker_controller.dart';
import 'create_question_image_picker.dart';

/// for CreateQuestionPage Only

class IbMediaBar extends StatelessWidget {
  final CreateQuestionController _controller;

  const IbMediaBar(this._controller);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        children: [
          Obx(() {
            return Showcase(
              key: IbShowCaseManager.kPickTagForQuestionKey,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              description: 'show_case_tag'.tr,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IbActionButton(
                        color: _controller.pickedTags.isEmpty
                            ? IbColors.lightGrey
                            : Colors.orangeAccent,
                        size: 20,
                        fontSize: IbConfig.kDescriptionTextSize,
                        iconData: FontAwesomeIcons.tag,
                        onPressed: () {
                          Get.to(
                              () => CreateQuestionTagPicker(Get.put(
                                  CreateQuestionTagPickerController(
                                      _controller))),
                              transition: Transition.zoom);
                        },
                        text: 'Add Tags'),
                  ),
                  if (_controller.pickedTags.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        height: 16,
                        width: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orangeAccent,
                        ),
                        child: Text(
                          _controller.pickedTags.length.toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: IbConfig.kDescriptionTextSize),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          /*     Stack(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.location_on_rounded,
                    color: IbColors.lightGrey,
                  )),
              Positioned(
                  top: 6,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    height: 18,
                    width: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: IbColors.accentColor,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(fontSize: IbConfig.kDescriptionTextSize),
                    ),
                  ))
            ],
          ),*/
          Stack(
            children: [
              Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IbActionButton(
                      color: _controller.picMediaList.isEmpty
                          ? IbColors.lightGrey
                          : IbColors.accentColor,
                      iconData: Icons.photo_album,
                      size: 20,
                      fontSize: IbConfig.kDescriptionTextSize,
                      onPressed: () {
                        IbUtils.hideKeyboard();
                        Get.to(() => CreateQuestionImagePicker(_controller),
                            transition: Transition.zoom);
                      },
                      text: "Add Pictures"),
                ),
              ),
              Obx(() {
                if (_controller.picMediaList.isEmpty) {
                  return const SizedBox();
                }

                return Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 16,
                    width: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: IbColors.accentColor,
                    ),
                    child: Text(
                      '${_controller.picMediaList.isEmpty ? '' : _controller.picMediaList.length}',
                      style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
/*          Stack(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    FontAwesomeIcons.video,
                    color: IbColors.lightGrey,
                    size: 20,
                  )),
              Positioned(
                  top: 6,
                  right: 0,
                  child: Container(
                    height: 16,
                    width: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: IbColors.accentColor,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(fontSize: IbConfig.kDescriptionTextSize),
                    ),
                  ),)
            ],
          ),*/
        ],
      ),
    );
  }
}
