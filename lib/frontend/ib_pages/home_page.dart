import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_pages/ib_user_search_page.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_pages/score_page.dart';
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
  final List<List<Widget>> _actionsList = [
    List<Widget>.generate(
        1,
        (index) => IconButton(
            onPressed: () {
              Get.to(() => const CreateQuestionPage());
            },
            icon: const Icon(Icons.edit_outlined))),
    List<Widget>.generate(
        1,
        (index) => IconButton(
            onPressed: () {
              //Get.to(() => const CreateQuestionPage());
            },
            icon: const Icon(Icons.edit))),
    List<Widget>.generate(
        1,
        (index) => IconButton(
            onPressed: () {
              Get.to(() => IbUserSearchPage());
            },
            icon: const Icon(Icons.person_add_alt_1_outlined))),
    List<Widget>.generate(
        1,
        (index) => IconButton(
            onPressed: () {
              //Get.to(() => const CreateQuestionPage());
            },
            icon: const Icon(Icons.notification_add))),
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
    return Obx(
      () => Scaffold(
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
          bottomNavigationBar: _buildBottomBar()),
    );
  }

  Widget getBody() {
    /// Question tab
    final _ibQuestionController = Get.put(IbQuestionController());

    final List<Widget> pages = [
      Obx(() {
        if (_ibQuestionController.isLoading.isTrue) {
          return Container(
            color: IbColors.lightBlue,
            child: const Center(
              child: IbProgressIndicator(),
            ),
          );
        }
        return Container(
          color: IbColors.lightBlue,
          child: CarouselSlider(
            options: CarouselOptions(
                onPageChanged: (index, reason) {
                  print('$index , $reason');
                  if (index == _ibQuestionController.ibQuestions.length - 2) {
                    _ibQuestionController.addQuestion();
                  }
                },
                viewportFraction: 0.95,
                height: Get.height,
                enableInfiniteScroll: false),
            items: _ibQuestionController.ibQuestions.map((_ibQuestion) {
              if (_ibQuestion.questionType == IbQuestion.kScale) {
                return Center(
                  child: IbScQuestionCard(Get.put(
                      IbQuestionItemController(_ibQuestion),
                      tag: _ibQuestion.id)),
                );
              }

              return IbMcQuestionCard(Get.put(
                  IbQuestionItemController(_ibQuestion),
                  tag: _ibQuestion.id));
            }).toList(),
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
      const ScorePage(),
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
