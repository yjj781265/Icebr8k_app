import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/frontend/admin/admin_main_page.dart';
import 'package:icebr8k/frontend/admin/feedback_chat_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/ib_premium_page.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_pages/people_nearby_page.dart';
import 'package:icebr8k/frontend/ib_pages/settings_pages/settings_main_page.dart';
import 'package:icebr8k/frontend/ib_themes.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../../backend/controllers/admin_controllers/feedback_chat_controller.dart';
import '../../backend/controllers/user_controllers/auth_controller.dart';
import '../../backend/models/ib_user.dart';
import '../../backend/services/user_services/ib_local_data_service.dart';
import 'profile_pages/my_profile_page.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isDarkMode =
      IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool);
  final MainPageController _mainPageController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: Get.width * 0.7,
        child: IbCard(
          margin: const EdgeInsets.only(
            top: 4,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Obx(
                () => DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      SizedBox(
                        height: 300 / 1.618,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              topLeft: Radius.circular(16)),
                          child: _mainPageController
                                  .rxCurrentIbUser.value.coverPhotoUrl.isEmpty
                              ? Image.asset(
                                  'assets/images/header_img.jpg',
                                  fit: BoxFit.fill,
                                )
                              : CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: _mainPageController
                                      .rxCurrentIbUser.value.coverPhotoUrl,
                                ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16))),
                            onTap: () {
                              Get.back();
                              Get.to(() => MyProfilePage());
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IbUserAvatar(
                                radius: 32,
                                avatarUrl: _mainPageController
                                    .rxCurrentIbUser.value.avatarUrl),
                            IbCard(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  _mainPageController
                                      .rxCurrentIbUser.value.username,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kPageTitleSize,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_mainPageController.rxCurrentIbUser.value.isPremium)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: IbCard(
                            child: Icon(
                              Icons.workspace_premium,
                              color: IbColors.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SwitchListTile.adaptive(
                value: isDarkMode,
                onChanged: (value) {
                  print('dark mode to $value');
                  setState(() {
                    isDarkMode = value;
                    IbLocalDataService().updateBoolValue(
                        key: StorageKey.isDarkModeBool, value: value);
                    Get.changeTheme(value
                        ? IbThemes(context).buildDarkTheme()
                        : IbThemes(context).buildLightTheme());
                    IbUtils().changeStatusBarColor();
                  });
                },
                title: const Text('Dark Mode'),
              ),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (IbUtils().getCurrentIbUser() != null &&
                          IbUtils()
                              .getCurrentIbUser()!
                              .roles
                              .contains(IbUser.kAdminRole))
                        ListTile(
                          onTap: () {
                            Get.to(() => AdminMainPage());
                          },
                          leading: const Icon(
                            FontAwesomeIcons.chessKing,
                            color: IbColors.lightGrey,
                          ),
                          title: const Text('Admin Page',
                              style: TextStyle(
                                  fontSize: IbConfig.kNormalTextSize,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ListTile(
                        leading: const Icon(
                          Icons.workspace_premium,
                          color: IbColors.primaryColor,
                        ),
                        title: const Text(
                          "Go Premium",
                          style: TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Remove Ads and More'),
                        onTap: () async {
                          if (IbUtils().checkFeatureIsLocked()) {
                            return;
                          }
                          Get.to(() => IbPremiumPage());
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person_pin_circle_rounded,
                          color: IbColors.errorRed,
                        ),
                        title: const Text(
                          "People Nearby",
                          style: TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.normal),
                        ),
                        onTap: () {
                          if (IbUtils().checkFeatureIsLocked()) {
                            return;
                          }
                          Get.to(() => PeopleNearbyPage());
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.support_agent,
                          color: IbColors.accentColor,
                        ),
                        title: const Text(
                          "Support/Feedback",
                          style: TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.normal),
                        ),
                        onTap: () {
                          if (IbUtils().checkFeatureIsLocked()) {
                            return;
                          }
                          Get.to(() => FeedBackChatPage(Get.put(
                              FeedbackChatController(
                                  IbUtils().getCurrentUid()!))));
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: IbColors.lightGrey,
                        ),
                        title: const Text(
                          "Settings",
                          style: TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.normal),
                        ),
                        onTap: () {
                          Get.back();
                          Get.to(() => SettingsMainPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextButton.icon(
                      onPressed: () {
                        Get.find<AuthController>().signOut();
                      },
                      icon: const Icon(
                        Icons.exit_to_app_outlined,
                        color: IbColors.errorRed,
                      ),
                      label: Text(
                        'sign_out'.tr,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Scrollbar(
        child: const Text("")
      ),
    );
  }
}

class TermAndConditionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("")
          ),
        ),
      ),
    );
  }
}
