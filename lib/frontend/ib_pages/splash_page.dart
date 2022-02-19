import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../../backend/services/user_services/ib_local_data_service.dart';
import '../ib_colors.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
                  ? Colors.black
                  : IbColors.lightBlue),
    );

    return Scaffold(
      body: Obx(() {
        if (controller.isInitializing.isTrue) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/logo_android.png',
                width: IbConfig.kAppLogoSize,
                height: IbConfig.kAppLogoSize,
              ),
              const IbProgressIndicator(),
            ],
          ));
        }
        return const SizedBox();
      }),
    );
  }
}
