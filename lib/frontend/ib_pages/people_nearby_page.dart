import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/people_nearby_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_card.dart';
import 'package:lottie/lottie.dart';

import '../../backend/models/ib_user.dart';

class PeopleNearbyPage extends StatelessWidget {
  final PeopleNearbyController _controller =
      Get.put(PeopleNearbyController(), tag: IbUtils.getUniqueId());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => _controller.items.isNotEmpty
              ? Text(
                  '${_controller.currentIndex.value + 1}/ ${_controller.items.length}')
              : const SizedBox(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showFilterDialog(context);
              },
              icon: const Icon(Icons.tune)),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 300,
                    width: 300,
                    child: Lottie.asset('assets/images/location.json')),
                Text.rich(TextSpan(text: 'Searching people in ', children: [
                  TextSpan(
                      text: '${_controller.rangeInMi.toInt()} mi ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(
                    text: 'radius...',
                  )
                ]))
              ],
            ),
          );
        }

        if (_controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 300,
                    child: Lottie.asset('assets/images/location.json')),
                const Text(
                  'No one is nearby, try different search criteria',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: CarouselSlider.builder(
                  itemBuilder: (BuildContext context, int index, int num) {
                    return PeopleNearbyCard(_controller.items[index]);
                  },
                  carouselController: _controller.carouselController,
                  options: CarouselOptions(
                      initialPage: 0,
                      aspectRatio: 0.65,
                      viewportFraction: 0.96,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        _controller.currentIndex.value = index;
                        if (index == _controller.items.length - 1) {
                          print('loadmore');
                        }
                      }),
                  itemCount: _controller.items.length,
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
                      onPressed: () {
                        final user = _controller
                            .items[_controller.currentIndex.value].user;
                        if (user.profilePrivacy != IbUser.kUserPrivacyPublic) {
                          return;
                        }
                        Get.to(() => ChatPage(
                            Get.put(ChatPageController(recipientId: user.id))));
                      },
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
                          final user = _controller
                              .items[_controller.currentIndex.value].user;
                          if (user.profilePrivacy !=
                              IbUser.kUserPrivacyPublic) {
                            return;
                          }
                          Get.to(() =>
                              ProfilePage(Get.put(ProfileController(user.id))));
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
        );
      }),
    );
  }

  void _showFilterDialog(BuildContext context) {
    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: IbConfig.kNormalTextSize);
    final Widget _content = Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('distance'.tr, style: headerStyle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _controller.rangeInMi.value,
                onChanged: (value) {
                  _controller.rangeInMi.value = value;
                },
                min: 1,
                max: IbConfig.kMaxRangeInMi,
              ),
              Text(
                '${_controller.rangeInMi.value.toInt()}mi',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          Text('age'.tr, style: headerStyle),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              RangeSlider(
                onChanged: (value) {
                  _controller.rangeValue.value = value;
                  _controller.rangeValue.refresh();
                },
                min: 13,
                max: 120,
                values: _controller.rangeValue.value,
              ),
              Text(
                '${_controller.rangeValue.value.start.toInt()}-${_controller.rangeValue.value.end.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
          Text('gender'.tr, style: headerStyle),
          Obx(
            () => ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderColor: IbColors.lightGrey,
                selectedColor: IbColors.primaryColor,
                selectedBorderColor: IbColors.accentColor,
                borderWidth: 2,
                onPressed: (index) {
                  _controller.genderSelections[index] =
                      !_controller.genderSelections[index];
                  _controller.genderSelections.refresh();
                },
                isSelected: _controller.genderSelections.toList(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      IbUser.kGenders[0],
                      style: TextStyle(color: Theme.of(context).indicatorColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      IbUser.kGenders[1],
                      style: TextStyle(color: Theme.of(context).indicatorColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      IbUser.kGenders[2],
                      style: TextStyle(color: Theme.of(context).indicatorColor),
                    ),
                  )
                ]),
          ),
        ],
      ),
    );
    Get.dialog(Center(
      child: IbDialog(
        title: 'Preference',
        subtitle: '',
        content: _content,
        onPositiveTap: () {
          if (_controller.genderSelections.contains(true)) {
            Get.back();
            _controller.loadItem();
          } else {
            IbUtils.showSimpleSnackBar(
                msg: 'Pick at least one gender',
                backgroundColor: IbColors.errorRed);
          }
        },
      ),
    ));
  }
}
