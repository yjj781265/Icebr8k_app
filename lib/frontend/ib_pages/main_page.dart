import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_show_case_keys.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_pages/alert_tab.dart';
import 'package:icebr8k/frontend/ib_pages/ib_premium_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_animated_bottom_bar.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../backend/controllers/user_controllers/social_tab_controller.dart';
import '../../backend/managers/ib_ad_manager.dart';
import '../../backend/services/user_services/ib_user_db_service.dart';
import '../ib_colors.dart';
import '../ib_config.dart';
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      /// clear app badge
      FlutterAppBadger.updateBadgeCount(0);
      if (IbUtils.getCurrentIbUser() != null &&
          IbUtils.getCurrentIbUser()!.notificationCount != 0) {
        await IbUserDbService().updateIbUserNotificationCount(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    IbAnalyticsManager()
        .logScreenView(className: "MainPage", screenName: "MainPage");
    IbUtils.changeStatusBarColor();
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          MoveToBackground.moveTaskToBack();
        }
        return false;
      },
      child: Scaffold(
        body: SafeArea(child: getBody()),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget getBody() {
    final List<Widget> pages = [
      HomeTab(),
      const SocialTab(),
      const SizedBox(),
      AlertTab(),
      MyProfilePage(
        showBackButton: false,
      ),
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
          if (index != 0 && index != 4 && IbUtils.checkFeatureIsLocked()) {
            return;
          }

          if (index == 2) {
            if (await IbUtils.isOverDailyPollLimit()) {
              Get.dialog(IbDialog(
                title:
                    'You can only create maximum ${IbConfig.kDailyPollLimit} polls in 24 hrs',
                subtitle:
                    'Go Icebr8k Premium or Watch an Ad to create more polls',
                showNegativeBtn: false,
                actionButtons: Wrap(
                  children: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                          Get.to(() => IbPremiumPage());
                        },
                        child: const Text(
                          'Go Premium',
                          style: TextStyle(color: IbColors.errorRed),
                        )),
                    TextButton(
                        onPressed: () async {
                          Get.back();
                          await IbAdManager().showRewardAd(
                              FullScreenContentCallback(
                                  onAdFailedToShowFullScreenContent:
                                      (RewardedAd ad, AdError error) {
                            print(
                                '$ad onAdFailedToShowFullScreenContent: $error');
                            ad.dispose();
                          }, onAdDismissedFullScreenContent: (ad) {
                            ad.dispose();
                            final createQuestionController = Get.put(
                                CreateQuestionController(),
                                tag: IbUtils.getUniqueId());

                            Get.to(() => CreateQuestionPage(
                                  controller: createQuestionController,
                                ));
                          }));
                        },
                        child: const Text('Watch an Ad')),
                  ],
                ),
              ));
              return;
            }

            Get.to(
                () => CreateQuestionPage(
                      controller: Get.put(CreateQuestionController(),
                          tag: IbUtils.getUniqueId()),
                    ),
                fullscreenDialog: true,
                popGesture: false,
                transition: Transition.zoom);
            return;
          }

          if (index == 0 &&
              !IbLocalDataService()
                  .retrieveBoolValue(StorageKey.icebreakerShowCaseBool) &&
              IbShowCaseKeys.kIcebreakerKey.currentContext != null) {
            ShowCaseWidget.of(IbShowCaseKeys.kIcebreakerKey.currentContext!)!
                .startShowCase([IbShowCaseKeys.kIcebreakerKey]);
          }
          if (index == 1 &&
              !IbLocalDataService()
                  .retrieveBoolValue(StorageKey.peopleNearbyShowCaseBool) &&
              IbShowCaseKeys.kPeopleNearbyKey.currentContext != null) {
            ShowCaseWidget.of(IbShowCaseKeys.kPeopleNearbyKey.currentContext!)!
                .startShowCase([IbShowCaseKeys.kPeopleNearbyKey]);
          }

          _mainPageController.currentIndex.value = index;

          if (index == 3) {
            final NotificationController controller = Get.find();
            await controller.fcm.requestPermission();
            return;
          }

          if (index == 4 &&
              !IbLocalDataService()
                  .retrieveBoolValue(StorageKey.wordCloudShowCaseBool) &&
              IbShowCaseKeys.kWordCloudKey.currentContext != null) {
            ShowCaseWidget.of(IbShowCaseKeys.kWordCloudKey.currentContext!)!
                .startShowCase([IbShowCaseKeys.kWordCloudKey]);
          }
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
            icon: const Icon(Icons.notifications),
            notification: Get.find<NotificationController>().isLoading.isTrue
                ? -1
                : (Get.find<NotificationController>()
                        .items
                        .where((p0) => p0.notification.isRead == false)
                        .toList()
                        .length +
                    Get.find<NotificationController>()
                        .requests
                        .where((p0) => p0.notification.isRead == false)
                        .toList()
                        .length),
            title: 'alert'.tr,
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Obx(() => IbUserAvatar(
                radius: 16,
                avatarUrl:
                    _mainPageController.rxCurrentIbUser.value.avatarUrl)),
            title: '',
            inactiveColor: _inactiveColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
