import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_ad_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import 'ib_card.dart';

class IbAdWidget extends StatelessWidget {
  const IbAdWidget(this._controller, {Key? key}) : super(key: key);
  final IbAdController _controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isError.isTrue) {
        return IbCard(
          child: Container(
            margin: const EdgeInsets.all(8),
            width: Get.width,
            height: _controller.bannerAd.size.height.toDouble(),
            child: const Center(
              child: Text(
                'Failed to load ad',
                style: TextStyle(color: IbColors.lightGrey),
              ),
            ),
          ),
        );
      }
      if (_controller.isLoading.isTrue) {
        return IbCard(
          child: Container(
            margin: const EdgeInsets.all(8),
            width: Get.width,
            height: _controller.bannerAd.size.height.toDouble(),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [IbProgressIndicator(), Text('Loading Ad...')],
              ),
            ),
          ),
        );
      }

      return IbCard(
        child: Container(
          margin: const EdgeInsets.all(8),
          width: Get.width,
          height: _controller.bannerAd.size.height.toDouble(),
          child: _controller.bannerAd.responseInfo == null
              ? const SizedBox()
              : AdWidget(
                  ad: _controller.bannerAd,
                ),
        ),
      );
    });
  }
}
