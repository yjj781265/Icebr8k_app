import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/frontend/ib_pages/chat_tab.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/ib_user_search_page.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/question_tab.dart';
import 'package:icebr8k/frontend/ib_pages/social_tab.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_icon.dart';
import 'package:move_to_background/move_to_background.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final HomeController _homeController = Get.find();
  final FriendRequestController _friendRequestController = Get.find();
  final _drawerController = ZoomDrawerController();

  final GlobalKey<IbAnimatedIconState> _iconKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_drawerController.stateNotifier == null) {
        return;
      }
      _drawerController.stateNotifier!.addListener(() {
        if (_drawerController.stateNotifier!.value == DrawerState.open) {
          _iconKey.currentState!.forward();
        } else {
          _iconKey.currentState!.reverse();
        }
      });
    });

    final List<List<Widget>> _actionsList = [
      [
        IconButton(
            tooltip: 'Ask a question',
            onPressed: () {
              Get.to(() => const CreateQuestionPage());
            },
            icon: const Icon(Icons.add_circle_outline)),
      ],
      List<Widget>.generate(1, (index) => const SizedBox()),
      List<Widget>.generate(
          1,
          (index) => IconButton(
              tooltip: 'Search username',
              onPressed: () {
                Get.to(() => IbUserSearchPage());
              },
              icon: const Icon(Icons.person_search_outlined))),
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
    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: IbColors.lightBlue),
        child: WillPopScope(
          onWillPop: () async {
            if (Platform.isAndroid) {
              MoveToBackground.moveTaskToBack();
            }
            return false;
          },
          child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                titleSpacing: 0,
                backgroundColor: IbColors.lightBlue,
                automaticallyImplyLeading: false,
                actions: _actionsList[_homeController.currentIndex.value],
                leading: IconButton(
                    icon: IbAnimatedIcon(
                        key: _iconKey, icon: AnimatedIcons.menu_close),
                    onPressed: () {
                      if (_drawerController.stateNotifier == null) {
                        return;
                      }
                      if (_drawerController.stateNotifier!.value ==
                          DrawerState.open) {
                        _drawerController.close!();
                        _iconKey.currentState!.reverse();
                      } else {
                        _drawerController.open!();
                        _iconKey.currentState!.forward();
                      }
                    }),
                title: Obx(
                  () => Text(
                    _homeController
                        .tabTitleList[_homeController.currentIndex.value],
                    style: const TextStyle(
                        fontSize: IbConfig.kPageTitleSize,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              backgroundColor: IbColors.lightBlue,
              body: ZoomDrawer(
                slideWidth: 200,
                controller: _drawerController,
                style: DrawerStyle.Style1,
                menuScreen: MenuPage(),
                mainScreen: getBody(),
                showShadow: true,
                angle: 0,
                backgroundColor: IbColors.lightBlue,
                openCurve: Curves.linear,
                closeCurve: Curves.linear,
              ),
              bottomNavigationBar: _buildBottomBar()),
        ),
      ),
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
        backgroundColor: IbColors.white,
        selectedIndex: _homeController.currentIndex.value,
        itemCornerRadius: IbConfig.kCardCornerRadius,
        animationDuration: const Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        onItemSelected: (index) async {
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
              icon: const Icon(Icons.group_outlined),
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
