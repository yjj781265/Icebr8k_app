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
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SafeArea(
                      child: Text(
                        'Welcome to Icebr8k ',
                        style: TextStyle(
                            fontSize: IbConfig.kPageTitleSize,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                      'The place you can build meaningful connection with people around ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                  width: 230,
                  height: 230,
                  child: Lottie.asset('assets/images/business_chat.json')),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'login',
                    child: Container(
                      width: Get.width,
                      height: 80,
                      padding: const EdgeInsets.all(8),
                      child: IbElevatedButton(
                        icon: const Icon(FontAwesomeIcons.signInAlt),
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
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
