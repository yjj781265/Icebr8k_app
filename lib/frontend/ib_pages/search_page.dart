import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/search_page_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_info.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/question_pages/question_main_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';

import '../../backend/controllers/user_controllers/circle_info_controller.dart';
import '../../backend/controllers/user_controllers/tag_page_controller.dart';
import '../tag_page.dart';

class SearchPage extends StatelessWidget {
  final SearchPageController _controller = Get.put(SearchPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: searchWidget(context),
        ),
        body: Obx(() {
          if (_controller.isSearching.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }
          if (_controller.questions.isEmpty &&
              _controller.users.isEmpty &&
              _controller.tags.isEmpty &&
              _controller.circles.isEmpty &&
              _controller.isSearching.isFalse &&
              _controller.searchText.isNotEmpty) {
            return Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/images/sloth_zen.json'),
                    const Text('I could not find anything')
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                userWidget(context),
                questionWidget(context),
                circleWidget(context),
                tagWidget(context),
              ],
            ),
          );
        }));
  }

  Widget searchWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Theme.of(context).backgroundColor),
      child: TextField(
        autofocus: true,
        controller: _controller.textEtController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'master_search_hint'.tr,
          hintStyle: const TextStyle(fontSize: IbConfig.kDescriptionTextSize),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(
            () => _controller.searchText.isEmpty
                ? const SizedBox()
                : IconButton(
                    onPressed: () {
                      _controller.textEtController.clear();
                    },
                    icon: const Icon(Icons.cancel),
                  ),
          ),
        ),
      ),
    );
  }

  Widget userWidget(BuildContext context) {
    return Obx(() {
      if (_controller.users.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Icebr8k Users',
                style: TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.users
                    .map(
                      (element) => SizedBox(
                        width: 150,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          onTap: () {
                            if (element.id == IbUtils.getCurrentUid()) {
                              Get.to(() => MyProfilePage());
                            } else {
                              Get.to(() => ProfilePage(Get.put(
                                  ProfileController(element.id),
                                  tag: element.id)));
                            }
                          },
                          child: IbCard(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IbUserAvatar(
                                    avatarUrl: element.avatarUrl,
                                    uid: element.id,
                                  ),
                                  Text(
                                    element.username,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: IbConfig.kNormalTextSize),
                                  ),
                                  Text(
                                    element.fName,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: IbColors.lightGrey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }

  Widget circleWidget(BuildContext context) {
    return Obx(() {
      if (_controller.circles.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Circles',
                style: TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.circles
                    .map(
                      (element) => SizedBox(
                        width: 200,
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          onTap: () {
                            Get.to(() => CircleInfo(
                                Get.put(CircleInfoController(element.obs))));
                          },
                          child: IbCard(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (element.photoUrl.isEmpty)
                                    CircleAvatar(
                                      backgroundColor: IbColors.lightGrey,
                                      radius: 24,
                                      child: Text(
                                        element.name[0],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .indicatorColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  else
                                    IbUserAvatar(
                                      avatarUrl: element.photoUrl,
                                    ),
                                  Text(
                                    element.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: IbConfig.kNormalTextSize),
                                  ),
                                  Text('${element.memberCount} member(s)'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: IbColors.primaryColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8))),
                                    padding: const EdgeInsets.all(2),
                                    child: Text(
                                      element.isPublicCircle
                                          ? 'Public'
                                          : 'Private',
                                      style: const TextStyle(
                                          fontSize:
                                              IbConfig.kDescriptionTextSize),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }

  Widget questionWidget(BuildContext context) {
    return Obx(() {
      if (_controller.questions.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Questions',
                style: TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.questions.map((element) {
                  Icon icon = const Icon(
                    FontAwesomeIcons.bars,
                    size: 16,
                    color: IbColors.primaryColor,
                  );
                  if (element.questionType == IbQuestion.kMultipleChoicePic) {
                    icon = const Icon(FontAwesomeIcons.listUl,
                        size: 16, color: IbColors.primaryColor);
                  } else if (element.questionType ==
                      IbQuestion.kMultipleChoice) {
                    icon = const Icon(
                      FontAwesomeIcons.bars,
                      size: 16,
                      color: IbColors.primaryColor,
                    );
                  } else {
                    icon = const Icon(FontAwesomeIcons.star,
                        size: 16, color: IbColors.primaryColor);
                  }

                  return InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: () {
                      Get.to(() => QuestionMainPage(Get.put(
                          IbQuestionItemController(
                              rxIbQuestion: element.obs,
                              rxIsExpanded: true.obs),
                          tag: element.id)));
                    },
                    child: IbCard(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              icon,
                              const SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                width: 150,
                                child: AutoSizeText(
                                  element.question,
                                  maxLines: 3,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: IbConfig.kNormalTextSize),
                                  maxFontSize: IbConfig.kNormalTextSize,
                                ),
                              ),
                            ],
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }

  Widget tagWidget(BuildContext context) {
    return Obx(() {
      if (_controller.tags.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Tags',
                style: TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: _controller.tags.map((element) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            border: Border.all(
                                color: Theme.of(context).indicatorColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(element.text,
                              style: TextStyle(
                                  fontWeight:
                                      IbUtils.getCurrentIbUser() != null &&
                                              IbUtils.getCurrentIbUser()!
                                                  .tags
                                                  .contains(element.text)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: IbConfig.kDescriptionTextSize)),
                        ),
                      ),
                      Positioned.fill(
                          child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          onTap: () {
                            if (Get.isRegistered<TagPageController>(
                                tag: element.text)) {
                              return;
                            }

                            Get.to(
                                () => TagPage(Get.put(
                                    TagPageController(element.text),
                                    tag: element.text)),
                                preventDuplicates: false);
                          },
                        ),
                      ))
                    ],
                  );
                }).toList(),
              ),
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
          ],
        );
      }
      return const SizedBox();
    });
  }
}
