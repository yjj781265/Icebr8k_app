import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_up_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:lottie/lottie.dart';

import '../ib_colors.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SafeArea(
                      child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Lottie.asset('assets/images/friends.json')),
                    ),
                    RichText(
                      text: const TextSpan(
                          text: 'Post Polls',
                          style: TextStyle(
                              fontSize: IbConfig.kSloganSize,
                              fontWeight: FontWeight.bold,
                              color: IbColors.primaryColor),
                          children: [
                            TextSpan(
                                text: ' & ',
                                style: TextStyle(color: IbColors.lightGrey)),
                            TextSpan(
                                text: 'Make Friends',
                                style: TextStyle(color: IbColors.accentColor))
                          ]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'login',
                    child: Container(
                      width: Get.width,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      child: IbElevatedButton(
                        icon: const Icon(FontAwesomeIcons.rightToBracket),
                        textTrKey: 'login',
                        onPressed: () {
                          Get.to(() => SignInPage());
                        },
                        color: IbColors.primaryColor,
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'sign_up',
                    child: Container(
                      width: Get.width,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      child: IbElevatedButton(
                        icon: const Icon(Icons.person_add_alt_1),
                        textTrKey: 'sign_up',
                        onPressed: () {
                          Get.to(() => const SignUpPage());
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
