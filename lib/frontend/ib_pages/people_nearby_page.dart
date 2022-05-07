import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/people_nearby_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_card.dart';

class PeopleNearbyPage extends StatelessWidget {
  final PeopleNearbyController _controller = Get.put(PeopleNearbyController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: CarouselSlider.builder(
                itemBuilder: (BuildContext context, int index, int num) {
                  return PeopleNearbyCard();
                },
                carouselController: _controller.carouselController,
                options: CarouselOptions(
                    initialPage: 0,
                    height: Get.width * 1.66,
                    aspectRatio: 1.66,
                    viewportFraction: 0.98,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {}),
                itemCount: 10,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 48,
                  child: IbElevatedButton(
                    textTrKey: 'Message',
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                  ),
                )),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: IbElevatedButton(
                      textTrKey: 'View Profile',
                      icon: const Icon(
                        Icons.remove_red_eye_sharp,
                      ),
                      onPressed: () {
                        Get.to(() => ProfilePage(Get.put(
                            ProfileController(IbUtils.getCurrentUid()!))));
                      },
                      color: IbColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }
}
