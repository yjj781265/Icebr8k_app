import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/frontend/ib_pages/chat_tab.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/ib_user_search_page.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/question_tab.dart';
import 'package:icebr8k/frontend/ib_pages/social_tab.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:showcaseview/showcaseview.dart';

import '../ib_colors.dart';
import '../ib_config.dart';
import 'create_question_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
        onComplete: (number, key) {
          if (key == Get.find<HomeController>().key1 ||
              key == Get.find<HomeController>().key2) {
            IbLocalStorageService().updateCustomFlag(
                false, IbLocalStorageService.firstTimeCustomKey);
          } else if (key == Get.find<HomeController>().key3) {
            IbLocalStorageService().updateCustomFlag(
                false, IbLocalStorageService.usernameSearchCustomKey);
          }
        },
        builder: Builder(
          builder: (context) => const HomepageView(),
        ));
  }
}

class HomepageView extends StatefulWidget {
  const HomepageView({Key? key}) : super(key: key);

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView>
    with WidgetsBindingObserver {
  final HomeController _homeController = Get.find();

  final FriendRequestController _friendRequestController = Get.find();
  late List<List<Widget>> _actionsList;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (IbLocalStorageService()
          .isCustomKeyTrue(IbLocalStorageService.firstTimeCustomKey)) {
        ShowCaseWidget.of(context)!
            .startShowCase([_homeController.key1, _homeController.key2]);
      }
    });

    _actionsList = [
      [
        Showcase(
          overlayOpacity: 0.2,
          key: _homeController.key1,
          title: 'Ask away',
          description: 'Click here to ask a question',
          shapeBorder: const CircleBorder(),
          child: IconButton(
              tooltip: 'Ask a question',
              onPressed: () {
                Get.to(() => const CreateQuestionPage());
              },
              icon: const Icon(Icons.add_circle_outline)),
        ),
      ],
      List<Widget>.generate(1, (index) => const SizedBox()),
      List<Widget>.generate(
          1,
          (index) => Showcase(
                key: _homeController.key3,
                description: 'Click here search other users by their username',
                overlayOpacity: 0.2,
                shapeBorder: const CircleBorder(),
                child: IconButton(
                    tooltip: 'Search username',
                    onPressed: () {
                      Get.to(() => IbUserSearchPage());
                    },
                    icon: const Icon(Icons.person_search_outlined)),
              )),
      List<Widget>.generate(
          1,
          (index) => IconButton(
              tooltip: 'Edit profile',
              onPressed: () {
                if (_homeController.currentIbUser == null) {
                  return;
                }
                Get.to(
                  () => EditProfilePage(),
                );
              },
              icon: const Icon(Icons.edit_outlined))),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await FlutterLocalNotificationsPlugin().cancelAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: !IbLocalStorageService()
                  .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
              ? Colors.black
              : IbColors.lightBlue),
    );
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          MoveToBackground.moveTaskToBack();
        }
        return false;
      },
      child: Obx(() => Scaffold(
          drawer: const MenuPage(),
          appBar: AppBar(
            actions: _actionsList[_homeController.currentIndex.value],
            title: Obx(
              () => Text(
                _homeController
                    .tabTitleList[_homeController.currentIndex.value],
              ),
            ),
          ),
          body: getBody(),
          bottomNavigationBar: _buildBottomBar())),
    );
  }

  Widget getBody() {
    final List<Widget> pages = [
      QuestionTab(),
      ChatTab(),
      const SocialTab(),
      ProfilePage(IbUtils.getCurrentUid()!),
    ];
    return Obx(
      () => IndexedStack(
        index: _homeController.currentIndex.value,
        children: pages,
      ),
    );
  }

  Widget _buildBottomBar() {
    const _inactiveColor = IbColors.lightGrey;
    return Obx(
      () => IbAnimatedBottomBar(
        selectedIndex: _homeController.currentIndex.value,
        itemCornerRadius: IbConfig.kCardCornerRadius,
        animationDuration: const Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        onItemSelected: (index) async {
          if (index == 2 &&
              IbLocalStorageService().isCustomKeyTrue(
                  IbLocalStorageService.usernameSearchCustomKey)) {
            ShowCaseWidget.of(context)!.startShowCase([_homeController.key3]);
          }
          _homeController.currentIndex.value = index;
          _homeController.handleIndex(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.poll_outlined),
            title: Text('question'.tr),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat_outlined),
            title: Text('chat'.tr),
            inactiveColor: _inactiveColor,
            notification: Get.find<ChatTabController>().totalUnread.value,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
              icon: Showcase(
                  overlayOpacity: 0.2,
                  overlayPadding: const EdgeInsets.all(8),
                  shapeBorder: const CircleBorder(),
                  description:
                      'Click here to discover people nearby with common interests',
                  key: _homeController.key2,
                  child: const Icon(Icons.group_outlined)),
              title: Text('social'.tr),
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center,
              notification: _friendRequestController.requests.length),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_outline),
            title: Text(
              'profile'.tr,
            ),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
