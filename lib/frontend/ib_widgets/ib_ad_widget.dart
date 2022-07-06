import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_ad_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import 'ib_card.dart';

class IbAdWidget extends StatelessWidget {
  const IbAdWidget(this._controller, {Key? key}) : super(key: key);
  final IbAdController _controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.isTrue) {
        return IbCard(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: Get.width,
              height: _controller.bannerAd.size.height.toDouble(),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    IbProgressIndicator(),
                    Text('Loading Ad...')
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return IbCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: Get.width,
            height: _controller.bannerAd.size.height.toDouble(),
            child: AdWidget(
              ad: _controller.bannerAd,
            ),
          ),
        ),
      );
    });
  }
}
