import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class PendingAppDetailPage extends StatelessWidget {
  final AdminMainController _controller = Get.find();
  final IbUser user;

  PendingAppDetailPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.username} Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            IbUserAvatar(
              avatarUrl: user.avatarUrl,
              radius: 48,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'First Name: ${user.fName}',
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Last Name: ${user.lName}',
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gender: ${user.gender}',
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Birthdate: ${IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(user.birthdateInMs!))}',
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bio: ${user.bio}',
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 250,
                  child: Row(
                    children: user.emoPics
                        .map((e) => IbEmoPicCard(emoPic: e))
                        .toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: IbElevatedButton(
                  textTrKey: 'Approve',
                  onLongPressed: () async {
                    await _controller.approveApplication(user);
                  },
                  onPressed: () {
                    IbUtils.showSimpleSnackBar(
                        msg: 'Long press to approve',
                        backgroundColor: IbColors.accentColor);
                  },
                  icon: const Icon(Icons.check_circle),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: IbElevatedButton(
                  textTrKey: 'Reject',
                  color: IbColors.errorRed,
                  onLongPressed: () async {
                    await _controller.rejectApplication(user);
                  },
                  onPressed: () {
                    IbUtils.showSimpleSnackBar(
                        msg: 'Long press to reject',
                        backgroundColor: IbColors.errorRed);
                  },
                  icon: const Icon(Icons.cancel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
