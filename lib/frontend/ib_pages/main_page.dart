import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/frontend/ib_pages/alert_tab.dart';
import 'package:icebr8k/frontend/ib_pages/nearby_tab.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:move_to_background/move_to_background.dart';

import '../../backend/controllers/user_controllers/social_tab_controller.dart';
import '../../backend/services/user_services/ib_local_data_service.dart';
import '../ib_colors.dart';
import 'create_question_pages/create_question_page.dart';
import 'home_tab.dart';
import 'social_tab.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MainPageView();
  }
}

class MainPageView extends StatefulWidget {
  const MainPageView({Key? key}) : super(key: key);

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView>
    with WidgetsBindingObserver {
  final MainPageController _mainPageController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
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
      child: Scaffold(
          body: SafeArea(child: getBody()),
          bottomNavigationBar: _buildBottomBar()),
    );
  }

  Widget getBody() {
    final List<Widget> pages = [
      HomeTab(),
      const SocialTab(),
      const SizedBox(),
      NearbyTab(),
      AlertTab(),
    ];
    return Obx(
      () => IndexedStack(
        alignment: Alignment.center,
        index: _mainPageController.currentIndex.value,
        children: pages,
      ),
    );
  }

  Widget _buildBottomBar() {
    const _inactiveColor = IbColors.lightGrey;
    return Obx(
      () => IbAnimatedBottomBar(
        containerHeight: _mainPageController.isNavBarVisible.isTrue ? 80 : 0,
        selectedIndex: _mainPageController.currentIndex.value,
        onItemSelected: (index) async {
          if (index == 2) {
            Get.to(
                () => CreateQuestionPage(
                      controller: Get.put(CreateQuestionController()),
                    ),
                fullscreenDialog: true,
                popGesture: false,
                transition: Transition.zoom);
            return;
          }
          _mainPageController.currentIndex.value = index;
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: 'home'.tr,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.people_alt_outlined,
            ),
            title: 'social'.tr,
            inactiveColor: _inactiveColor,
            notification: Get.find<SocialTabController>().totalUnread.value,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(
              Icons.add_circle,
              size: 48,
            ),
            title: '',
            inactiveColor: IbColors.accentColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
              icon: const Icon(Icons.person_pin_circle_rounded),
              title: 'nearby'.tr,
              inactiveColor: _inactiveColor,
              textAlign: TextAlign.center),
          BottomNavyBarItem(
            icon: const Icon(Icons.notifications),
            notification: Get.find<NotificationController>()
                .items
                .where((p0) => p0.notification.isRead == false)
                .length,
            title: 'alert'.tr,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
