import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_pages/screen_one.dart';
import 'package:icebr8k/frontend/ib_pages/screen_two.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

import '../ib_colors.dart';

class SetupPage extends StatelessWidget {
  SetupPage({Key? key}) : super(key: key);
  final LiquidController _liquidController = LiquidController();
  final SetUpController _setUpController = Get.put(SetUpController());
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    _setUpController.liquidController = _liquidController;
    return Scaffold(
        body: Obx(
      () => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          LiquidSwipe(
            onPageChangeCallback: (index) {
              _setUpController.currentPage.value = index;
            },
            liquidController: _liquidController,
            fullTransitionValue: 666,
            enableLoop: false,
            pages: [
              ScreenOne(),
              ScreenTwo(),
            ],
          ),
          if (_setUpController.isKeyBoardVisible.isFalse)
            Positioned(
              top: 36,
              left: Get.width / 2 - 16,
              child: SizedBox(
                width: 100,
                height: 16,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final bool _isSelected =
                          _setUpController.currentPage.value == index;
                      final double _size = _isSelected ? 10 : 8;
                      return Padding(
                        padding: const EdgeInsets.all(3),
                        child: SizedBox(
                          height: _size,
                          width: _size,
                          child: CircleAvatar(
                              backgroundColor: _isSelected
                                  ? IbColors.primaryColor
                                  : IbColors.lightGrey),
                        ),
                      );
                    });
                  },
                  itemCount: 2,
                ),
              ),
            ),
        ],
      ),
    ));
  }
}
