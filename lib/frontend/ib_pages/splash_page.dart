import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/services/user_services/ib_auth_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_db_status_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../../backend/controllers/user_controllers/auth_controller.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);
  final controller = Get.put(
    AuthController(
      ibUtils: IbUtils(),
      ibAuthService: IbAuthService(),
      ibDbStatusService: IbDbStatusService(),
      ibLocalDataService: IbLocalDataService(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    IbUtils().changeStatusBarColor();

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
