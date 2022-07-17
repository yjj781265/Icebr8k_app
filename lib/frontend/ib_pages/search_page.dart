import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

                  if (_controller.isSearching.isFalse &&
                      _controller.questions.isEmpty &&
                      _controller.users.isEmpty &&
                      _controller.tags.isEmpty &&
                      _controller.circles.isEmpty &&
                      _controller.searchText.isEmpty &&
                      _controller.icebreakers.isEmpty) {
                    return const SizedBox();
                  }
                  if (_controller.questions.isEmpty &&
                      _controller.users.isEmpty &&
                      _controller.tags.isEmpty &&
                      _controller.circles.isEmpty &&
                      _controller.isSearching.isFalse &&
                      _controller.searchText.isNotEmpty &&
                      _controller.icebreakers.isEmpty) {
                    return Center(
                      child: SizedBox(
                        width: 300,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset('assets/images/sloth_zen.json'),
                              Text(
                                  'No Results Regarding ${_controller.searchText.value}')
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return DefaultTabController(
                    length: 6,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          indicatorSize: TabBarIndicatorSize.tab,
                          padding: EdgeInsets.zero,
                          tabs: <Widget>[
                            const Tab(
                              text: 'Top',
                            ),
                            Obx(
                              () => Tab(
                                text: '${_controller.users.length} User(s)',
                              ),
                            ),
                            Obx(
                              () => Tab(
                                text: '${_controller.circles.length} Circle(s)',
                              ),
                            ),
                            Obx(
                              () => Tab(
                                text: '${_controller.questions.length} Poll(s)',
                              ),
                            ),
                            Obx(
                              () => Tab(
                                text: '${_controller.tags.length} Tag(s)',
                              ),
                            ),
                            Obx(
                              () => Tab(
                                text:
                                    '${_controller.icebreakers.length} Icebreaker(s)',
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TabBarView(children: [
                              topWidget(context),
                              userWidget(context),
                              circleWidget(context),
                              questionWidget(context),
                              tagWidget(context),
                              icebreakerWidget(context),
                            ]),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
              if (IbUtils().getCurrentIbUser() != null &&
                  !IbUtils().isPremiumMember() &&
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

  Widget topWidget(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            if (_controller.users.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User(s)',
                    style: TextStyle(
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _controller.users
                        .take(3)
                        .map(
                          (element) => IbCard(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                onTap: () {
                                  if (element.id == IbUtils().getCurrentUid()) {
                                    Get.to(() => MyProfilePage());
                                  } else {
                                    Get.to(() => ProfilePage(Get.put(
                                        ProfileController(element.id),
                                        tag: element.id)));
                                  }
                                },
                                leading: IbUserAvatar(
                                  avatarUrl: element.avatarUrl,
                                  uid: element.id,
                                ),
                                title: Text(
                                  element.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: IbConfig.kNormalTextSize),
                                ),
                                subtitle: Text(
                                  element.fName,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: IbColors.lightGrey),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(
                    thickness: 1,
                    color: IbColors.lightGrey,
                  ),
                ],
              ),
            if (_controller.circles.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Circle(s)',
                    style: TextStyle(
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  StaggeredGrid.count(
                    crossAxisCount: 3,
                    children: _controller.circles
                        .take(5)
                        .map(
                          (ibChat) => IbCircleCard(ibChat),
                        )
                        .toList(),
                  ),
                  const Divider(
                    thickness: 1,
                    color: IbColors.lightGrey,
                  ),
                ],
              ),
            if (_controller.questions.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poll(s)',
                    style: TextStyle(
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _controller.questions.take(3).map((element) {
                      return IbQuestionSnippetCard(element);
                    }).toList(),
                  ),
                  const Divider(
                    thickness: 1,
                    color: IbColors.lightGrey,
                  ),
                ],
              ),
            if (_controller.tags.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tag(s)',
                    style: TextStyle(
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    children: _controller.tags.take(3).map((element) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                border: Border.all(
                                    color: Theme.of(context).indicatorColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(element.text,
                                  style: TextStyle(
                                      fontWeight:
                                          IbUtils().getCurrentIbUser() !=
                                                      null &&
                                                  IbUtils()
                                                      .getCurrentIbUser()!
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
                  const Divider(
                    thickness: 1,
                    color: IbColors.lightGrey,
                  ),
                ],
              ),
            if (_controller.icebreakers.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Icebreaker(s)',
                    style: TextStyle(
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _controller.icebreakers[index];
                      final collection = IbCacheManager()
                          .retrieveIbCollection(item.collectionId);
                      if (collection != null) {
                        Get.put(IcebreakerController(collection, isEdit: false),
                            tag: item.collectionId);
                      }
                      return IbCard(
                        color: Color(item.bgColor),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: AutoSizeText(
                              item.text,
                              minFontSize: IbConfig.kNormalTextSize,
                              maxFontSize: IbConfig.kPageTitleSize,
                              maxLines: IbConfig.kIbCardMaxLine,
                              overflow: TextOverflow.ellipsis,
                              style: IbUtils().getIbFonts(TextStyle(
                                  fontSize: IbConfig.kPageTitleSize,
                                  color: Color(item.textColor),
                                  fontStyle: item.isItalic
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  fontWeight:
                                      FontWeight.bold))[item.textStyleIndex],
                            ),
                            tileColor: Color(item.bgColor),
                            onTap: () {
                              final collection = IbCacheManager()
                                  .retrieveIbCollection(item.collectionId);
                              if (collection == null) {
                                return;
                              }
                              final controller = Get.put(
                                  IcebreakerController(collection,
                                      isEdit: false),
                                  tag: item.collectionId);
                              controller.currentIndex.value = controller
                                  .icebreakers
                                  .indexWhere((e) => item.id == e.id);
                              if (controller.currentIndex.value == -1) {
                                return;
                              }
                              IbUtils().hideKeyboard();
                              Get.to(() => IcebreakerMainPage(controller),
                                  transition: Transition.zoom);
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: _controller.icebreakers.length > 3
                        ? 3
                        : _controller.icebreakers.length,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget userWidget(BuildContext context) {
    return Obx(() {
      if (_controller.users.isNotEmpty) {
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: _controller.users
              .take(IbConfig.kPerPage)
              .map(
                (element) => IbCard(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onTap: () {
                        if (element.id == IbUtils().getCurrentUid()) {
                          Get.to(() => MyProfilePage());
                        } else {
                          Get.to(() => ProfilePage(Get.put(
                              ProfileController(element.id),
                              tag: element.id)));
                        }
                      },
                      leading: IbUserAvatar(
                        avatarUrl: element.avatarUrl,
                        uid: element.id,
                      ),
                      title: Text(
                        element.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: IbConfig.kNormalTextSize),
                      ),
                      subtitle: Text(
                        element.fName,
                        maxLines: 1,
                        style: const TextStyle(color: IbColors.lightGrey),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      }
      return const SizedBox();
    });
  }

  Widget circleWidget(BuildContext context) {
    return Obx(() {
      if (_controller.circles.isNotEmpty) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            children: _controller.circles
                .map(
                  (ibChat) => IbCircleCard(ibChat),
                )
                .toList(),
          ),
        );
      }
      return const SizedBox();
    });
  }

  Widget icebreakerWidget(BuildContext context) {
    return Obx(() {
      if (_controller.icebreakers.isNotEmpty) {
        return ListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemBuilder: (context, index) {
            final item = _controller.icebreakers[index];
            final collection =
                IbCacheManager().retrieveIbCollection(item.collectionId);
            if (collection != null) {
              Get.put(IcebreakerController(collection, isEdit: false),
                  tag: item.collectionId);
            }

            return IbCard(
              color: Color(item.bgColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: AutoSizeText(
                    item.text,
                    minFontSize: IbConfig.kNormalTextSize,
                    maxFontSize: IbConfig.kPageTitleSize,
                    maxLines: IbConfig.kIbCardMaxLine,
                    overflow: TextOverflow.ellipsis,
                    style: IbUtils().getIbFonts(TextStyle(
                        fontSize: IbConfig.kPageTitleSize,
                        color: Color(item.textColor),
                        fontStyle:
                            item.isItalic ? FontStyle.italic : FontStyle.normal,
                        fontWeight: FontWeight.bold))[item.textStyleIndex],
                  ),
                  tileColor: Color(item.bgColor),
                  onTap: () async {
                    final collection = IbCacheManager()
                        .retrieveIbCollection(item.collectionId);
                    if (collection == null) {
                      print('collection is null');
                      return;
                    }
                    final controller = Get.put(
                        IcebreakerController(collection, isEdit: false),
                        tag: item.collectionId);
                    if (controller.currentIndex.value == -1) {
                      print('collection is -1');
                      return;
                    }
                    IbUtils().hideKeyboard();
                    Get.to(() => IcebreakerMainPage(controller),
                        transition: Transition.zoom);
                  },
                ),
              ),
            );
          },
          itemCount: _controller.icebreakers.length,
        );
      }
      return const SizedBox();
    });
  }

  Widget questionWidget(BuildContext context) {
    return Obx(() {
      if (_controller.questions.isNotEmpty) {
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: _controller.questions.map((element) {
            return IbQuestionSnippetCard(element);
          }).toList(),
        );
      }
      return const SizedBox();
    });
  }

  Widget tagWidget(BuildContext context) {
    return Obx(() {
      if (_controller.tags.isNotEmpty) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Wrap(
            children: _controller.tags.map((element) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        border:
                            Border.all(color: Theme.of(context).indicatorColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(element.text,
                          style: TextStyle(
                              fontWeight:
                                  IbUtils().getCurrentIbUser() != null &&
                                          IbUtils()
                                              .getCurrentIbUser()!
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
        );
      }
      return const SizedBox();
    });
  }
}
