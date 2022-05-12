import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/settings_pages/settings_notification_page.dart';

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
              title: const Text('Notification'),
              trailing: const Icon(Icons.arrow_forward_ios),
            )
          ],
        ));
  }
}
