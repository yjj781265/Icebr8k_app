import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/services/user_services/ib_auth_service.dart';
import 'package:icebr8k/frontend/ib_pages/settings_pages/settings_notification_page.dart';
import 'package:icebr8k/frontend/ib_pages/settings_pages/settings_poll_page.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../menu_page.dart';

class SettingsMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Column(
          children: [
            ListTile(
              onTap: () {
                Get.to(() => SettingsNotificationPage());
              },
              leading: const Icon(
                Icons.notifications,
                color: Colors.red,
              ),
              title: const Text(
                'Notification',
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              onTap: () {
                Get.to(() => SettingsPollPage());
              },
              leading: const Icon(
                FontAwesomeIcons.checkToSlot,
                color: IbColors.primaryColor,
              ),
              title: const Text(
                'Poll',
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: const Icon(
                Icons.description_outlined,
                color: IbColors.primaryColor,
              ),
              title: const Text(
                "About",
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showAboutDialog(
                    context: context,
                    applicationName: 'Icebr8k',
                    applicationVersion:
                        '${IbConfig.kVersion.toString()}${DbConfig.dbSuffix}',
                    applicationIcon: SizedBox(
                        height: 80,
                        width: 80,
                        child: Image.asset('assets/icons/logo_ios.png')));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.description,
                color: IbColors.accentColor,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              title: const Text(
                "Privacy Policy",
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Get.to(() => PrivacyPolicyPage());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.description,
                color: IbColors.accentColor,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              title: const Text(
                "Terms & Conditions",
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Get.to(() => TermAndConditionPage());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.no_accounts,
                color: IbColors.errorRed,
              ),
              title: const Text(
                "Delete Account",
                style: TextStyle(
                  color: IbColors.errorRed,
                  fontSize: IbConfig.kNormalTextSize,
                ),
              ),
              onTap: () {
                Get.dialog(IbDialog(
                    title: 'Delete Account',
                    subtitle: 'Are you sure you want to delete your account?'
                        ' If you delete your account, you will permanently '
                        'lose your profile, messages, polls, and photos. '
                        'If you are a premium member, do not forget to cancel your subscription.',
                    onPositiveTap: () async {
                      Get.back();
                      Get.dialog(const IbLoadingDialog(
                        messageTrKey: 'Deleting...',
                      ));
                      final bool result = await IbAuthService().deleteAccount();
                      if (result) {
                        await IbAuthService().signOut();
                        Get.offAll(() => WelcomePage());
                        IbUtils().showSimpleSnackBar(
                            msg: 'Account deleted, we will miss you 🥺',
                            backgroundColor: IbColors.accentColor);
                      } else {
                        Get.back();
                        IbUtils().showSimpleSnackBar(
                            msg:
                                'Delete account failed, please contact support',
                            backgroundColor: IbColors.errorRed);
                      }
                    }));
              },
            )
          ],
        ));
  }
}
