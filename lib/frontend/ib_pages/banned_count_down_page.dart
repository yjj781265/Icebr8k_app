import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:lottie/lottie.dart';

import '../../backend/models/ib_user.dart';
import '../ib_config.dart';

class BannedCountDownPage extends StatelessWidget {
  final IbUser user;
  const BannedCountDownPage(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
              height: 300,
              width: 300,
              child: Lottie.asset('assets/images/hour_glass.json')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'You account is banned for the following reason: \n${user.note}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('You account will be unbanned after ${banedString()}'),
          ),
          ElevatedButton(
              onPressed: () {
                Get.offAll(() => WelcomePage());
              },
              child: const Text('To Home Page 🏠'))
        ],
      ),
    );
  }

  String banedString() {
    final diffInMs =
        user.banedEndTimeInMs - DateTime.now().millisecondsSinceEpoch;

    if (diffInMs < 0) {
      return '';
    }

    final duration = Duration(milliseconds: diffInMs);

    if (duration.inDays >= 0) {
      return '${duration.inDays} day(s)';
    }

    if (duration.inHours >= 0) {
      return '${duration.inDays} hr(s)';
    }

    if (duration.inMinutes >= 0) {
      return '${duration.inDays} min(s)';
    }
    print('here');

    return '';
  }
}
