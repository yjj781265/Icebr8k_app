import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_icon.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final HomeController _homeController = Get.put(HomeController());
  final _drawerController = ZoomDrawerController();
  final GlobalKey<IbAnimatedIconState> _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _drawerController.stateNotifier!.addListener(() {
        if (_drawerController.stateNotifier!.value == DrawerState.open) {
          _iconKey.currentState!.forward();
        } else {
          _iconKey.currentState!.reverse();
        }
      });
    });
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: IbColors.darkPrimaryColor),
    );
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: IbColors.primaryColor,
          leading: IconButton(
              icon:
                  IbAnimatedIcon(key: _iconKey, icon: AnimatedIcons.menu_close),
              onPressed: () {
                if (_drawerController.stateNotifier!.value ==
                    DrawerState.open) {
                  _drawerController.close!();
                  _iconKey.currentState!.reverse();
                } else {
                  _drawerController.open!();
                  _iconKey.currentState!.forward();
                }
              }),
          title: const Text('Home Page'),
        ),
        backgroundColor: IbColors.lightBlue,
        body: ZoomDrawer(
          controller: _drawerController,
          style: DrawerStyle.Style1,
          menuScreen: MenuPage(),
          mainScreen: getBody(),
          borderRadius: IbConfig.kCardCornerRadius,
          showShadow: true,
          angle: 0,
          backgroundColor: IbColors.lightBlue,
          openCurve: Curves.linear,
          closeCurve: Curves.linear,
        ),
        bottomNavigationBar: _buildBottomBar());
  }

  Widget getBody() {
    final List<Widget> pages = [
      Container(
        color: IbColors.lightBlue,
        alignment: Alignment.center,
        child: const Text(
          "Poll",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.lightBlue,
        child: const Text(
          "Chat",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.lightBlue,
        child: const Text(
          "Score",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.primaryColor,
        child: const Text(
          "Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
    ];
    return Obx(
      () => IndexedStack(
        index: _homeController.currentIndex.value,
        children: pages,
      ),
    );
  }

  Widget _buildBottomBar() {
    final _inactiveColor = Colors.grey;
    return Obx(
      () => IbAnimatedBottomBar(
        backgroundColor: IbColors.white,
        selectedIndex: _homeController.currentIndex.value,
        itemCornerRadius: IbConfig.kCardCornerRadius,
        animationDuration:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
        curve: Curves.fastLinearToSlowEaseIn,
        onItemSelected: (index) {
          _homeController.currentIndex.value = index;
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.poll_outlined),
            title: Text('poll'.tr),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat_outlined),
            title: Text('chat'.tr),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.star_border_outlined),
            title: Text('score'.tr),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_outline),
            title: Text(
              'profile'.tr,
            ),
            notification: 9,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
