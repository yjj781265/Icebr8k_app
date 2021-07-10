import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';

import '../ib_colors.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Home Page'),
        ),
        backgroundColor: IbColors.lightBlue,
        body: getBody(),
        bottomNavigationBar: _buildBottomBar());
  }

  Widget getBody() {
    final List<Widget> pages = [
      Container(
        color: IbColors.lightBlue,
        alignment: Alignment.center,
        child: const Text(
          "Home",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.lightBlue,
        child: const Text(
          "Users",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.lightBlue,
        child: const Text(
          "Messages",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      Container(
        alignment: Alignment.center,
        color: IbColors.primaryColor,
        child: const Text(
          "Settings",
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
        containerHeight: 70,
        backgroundColor: IbColors.white,
        selectedIndex: _homeController.currentIndex.value,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        onItemSelected: (index) {
          _homeController.currentIndex.value = index;
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.poll_outlined),
            title: Text('Poll'),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.chat_outlined),
            title: Text('Chat'),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.star_border_outlined),
            title: Text('Score'),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person_outline),
            title: Text(
              'Profile ',
            ),
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
