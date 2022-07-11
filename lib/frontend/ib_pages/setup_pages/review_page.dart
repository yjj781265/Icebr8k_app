import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
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
                      'Profile is Under Review',
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
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                            text:
                                'At Icebr8k we want to create a safe environment for every Icebr8ker'
                                '\n\nYour profile is currently under review, we will notify you via',
                            children: [
                              TextSpan(
                                text: ' email(check spam folder)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text:
                                      ' once is done, thank you for your patience😃 \n -Junjie(Founder of Icebr8k)')
                            ]),
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: IbElevatedButton(
                        textTrKey: 'Home',
                        onPressed: () async {
                          Get.offAll(() => WelcomePage());
                        },
                        icon: const Icon(Icons.home),
                        color: IbColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
