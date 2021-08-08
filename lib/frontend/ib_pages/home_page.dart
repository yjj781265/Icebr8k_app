import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_pages/ib_user_search_page.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/question_tab.dart';
import 'package:icebr8k/frontend/ib_pages/score_tab.dart';
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
    initGetXControllers();
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
        GestureDetector(
          onLongPress: () {
            IbQuestionDbService().eraseAllAnsweredQuestions(
                Get.find<AuthController>().firebaseUser!.uid);
          },
          child: IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () async {
              await Get.find<IbQuestionController>().refreshQuestions();
            },
          ),
        ),
        IconButton(
            onPressed: () {
              Get.to(() => const CreateQuestionPage());
            },
            icon: const Icon(Icons.edit_outlined)),
      ],
      List<Widget>.generate(1, (index) => const SizedBox()),
      List<Widget>.generate(
          1,
          (index) => IconButton(
              onPressed: () {
                Get.to(() => IbUserSearchPage());
              },
              icon: const Icon(Icons.person_add_alt_1_outlined))),
      List<Widget>.generate(1, (index) => const SizedBox()),
    ];
    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: IbColors.lightBlue,
        ),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              titleSpacing: 0,
              backwardsCompatibility: true,
              brightness: Brightness.light,
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: IbColors.lightBlue),
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
    );
  }

  Widget getBody() {
    final List<Widget> pages = [
      QuestionTab(),
      Container(
          alignment: Alignment.center,
          color: IbColors.lightBlue,
          child: const Text('I do not know')),
      const ScoreTab(),
      Container(
        alignment: Alignment.center,
        color: IbColors.lightBlue,
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
    final _inactiveColor = IbColors.lightGrey;
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
            title: Text('question'.tr),
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
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void initGetXControllers() {
    Get.put(FriendRequestController());
    Get.put(FriendListController());
    Get.put(IbQuestionController());
  }
}
