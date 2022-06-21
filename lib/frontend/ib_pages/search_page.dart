import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/icebreaker_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/search_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_circle_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_snippet_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:icebr8k/frontend/ib_widgets/icebreaker_card.dart';
import 'package:lottie/lottie.dart';

import '../../backend/controllers/user_controllers/tag_page_controller.dart';
import '../tag_page.dart';
import 'icebreaker_pages/icebreaker_main_page.dart';

class SearchPage extends StatelessWidget {
  final SearchPageController _controller = Get.put(SearchPageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: searchWidget(context),
        ),
        body: Obx(
          () => Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (_controller.isSearching.isTrue) {
                    return const Center(
                      child: IbProgressIndicator(),
                    );
                  }
                  if (_controller.questions.isEmpty &&
                      _controller.users.isEmpty &&
                      _controller.tags.isEmpty &&
                      _controller.circles.isEmpty &&
                      _controller.icebreakers.isEmpty &&
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        userWidget(context),
                        questionWidget(context),
                        icebreakerWidget(context),
                        circleWidget(context),
                        tagWidget(context),
                      ],
                    ),
                  );
                }),
              ),
              if (IbUtils.getCurrentIbUser() != null &&
                  !IbUtils.getCurrentIbUser()!.isPremium &&
                  _controller.isLoadingAd.isFalse)
                SafeArea(
                  child: SizedBox(
                    height: 56,
                    child: AdWidget(ad: _controller.ad),
                  ),
                ),
            ],
          ),
        ));
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Icebr8k Users(${_controller.users.length})',
                style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Circles(${_controller.circles.length})',
                style: const TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.circles
                    .map(
                      (element) => IbCircleCard(element),
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

  Widget icebreakerWidget(BuildContext context) {
    return Obx(() {
      if (_controller.icebreakers.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Icebreakers(${_controller.icebreakers.length})',
                style: const TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 288,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final item = _controller.icebreakers[index];
                  return SizedBox(
                    width: 200,
                    height: 288,
                    child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        onTap: () {
                          final collection = IbCacheManager()
                              .retrieveIbCollection(item.collectionId);
                          if (collection == null) {
                            return;
                          }
                          final controller = Get.put(
                              IcebreakerController(collection, isEdit: false),
                              tag: item.collectionId);
                          controller.currentIndex.value = controller.icebreakers
                              .indexWhere((e) => item.id == e.id);
                          if (controller.currentIndex.value == -1) {
                            return;
                          }

                          Get.to(() => IcebreakerMainPage(controller));
                        },
                        child: IcebreakerCard(
                          icebreaker: item,
                          minSize: IbConfig.kDescriptionTextSize,
                          maxSize: IbConfig.kSecondaryTextSize,
                        )),
                  );
                },
                itemCount: _controller.icebreakers.length,
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Questions(${_controller.questions.length})',
                style: const TextStyle(
                    fontSize: IbConfig.kPageTitleSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.questions.map((element) {
                  return SizedBox(
                      height: 200, child: IbQuestionSnippetCard(element));
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Tags(${_controller.tags.length})',
                style: const TextStyle(
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
