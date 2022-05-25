import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/frontend/admin/pending_app_detail_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class PendingAppMainPage extends StatelessWidget {
  final AdminMainController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Pending Applications"),
      ),
      body: Obx(
        () => ListView.builder(
          itemBuilder: (context, index) {
            final user = _controller.pendingUsers[index];
            return ListTile(
              tileColor: Theme.of(context).backgroundColor,
              onTap: () {
                Get.to(() => PendingAppDetailPage(user));
              },
              leading: IbUserAvatar(
                avatarUrl: user.avatarUrl,
              ),
              title: Text(
                user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${user.fName} ${user.lName}'),
              trailing: Text(IbUtils.getChatTabDateString(
                  (user.joinTime as Timestamp).toDate())),
            );
          },
          itemCount: _controller.pendingUsers.length,
        ),
      ),
    ));
  }
}
