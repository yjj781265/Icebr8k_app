import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:lottie/lottie.dart';

class ReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      'Profile is under review',
                      style: TextStyle(
                          fontSize: IbConfig.kSloganSize,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/images/waiting.json')),
                    const SizedBox(
                      height: 48,
                    ),
                    const Text(
                      'Your profile is currently under review, '
                      'we will notify you via Email once '
                      'is done, thank you for your patient😃 \n -Junjie(CTO of Icebr8k)',
                      style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: IbElevatedButton(
                    textTrKey: 'sign_out',
                    onPressed: () async {
                      await Get.find<AuthController>().signOut();
                    },
                    icon: const Icon(Icons.exit_to_app),
                    color: IbColors.errorRed,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
