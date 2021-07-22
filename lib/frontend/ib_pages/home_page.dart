import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_icon.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  final HomeController _homeController = Get.put(HomeController());
  final _drawerController = ZoomDrawerController();
  final GlobalKey<IbAnimatedIconState> _iconKey = GlobalKey();
  final _actionsList = [
    [
      IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
    ]
  ];

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: IbColors.lightBlue),
    );
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          backgroundColor: IbColors.lightBlue,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(() => const CreateQuestionPage());
                },
                icon: const Icon(Icons.edit)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
          ],
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
          title: Obx(
            () => Text(
              _homeController.tabTitleList[_homeController.currentIndex.value],
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
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
    /// Question tab
    final _ibQuestionController = Get.put(IbQuestionController());

    final List<Widget> pages = [
      Obx(() {
        if (_ibQuestionController.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        return Container(
          color: IbColors.lightBlue,
          child: Swiper(
            physics: const BouncingScrollPhysics(),
            controller: SwiperController(),
            itemBuilder: (BuildContext context, int index) {
              final _ibQuestion = _ibQuestionController.ibQuestions[index];
              if (_ibQuestion.questionType == IbQuestion.kScale) {
                return IbScQuestionCard(Get.put(
                    IbQuestionItemController(_ibQuestion),
                    tag: _ibQuestion.id));
              }

              return IbMcQuestionCard(Get.put(
                  IbQuestionItemController(_ibQuestion),
                  tag: _ibQuestion.id));
            },
            loop: false,
            itemCount: _ibQuestionController.ibQuestions.length,
            viewportFraction: 0.9,
            scale: 0.96,
          ),
        );
      }),
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
            notification: 9,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
