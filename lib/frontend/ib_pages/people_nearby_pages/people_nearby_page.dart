import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/people_nearby_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_pages/profile_liked_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_card.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_snip_card.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/models/ib_user.dart';

class PeopleNearbyPage extends StatelessWidget {
  final PeopleNearbyController _controller = Get.put(PeopleNearbyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nearby'),
          actions: [
            Obx(() => IconButton(
                onPressed: () {
                  _controller.isExpanded.value = !_controller.isExpanded.value;
                },
                icon: _controller.isExpanded.isFalse
                    ? const Icon(Icons.list)
                    : const Icon(Icons.grid_view))),
            IconButton(
                onPressed: () async {
                  _controller.loadLikedItems();
                  Get.to(() => ProfileLikedPage());
                },
                icon: const Icon(
                  Icons.favorite,
                  color: IbColors.errorRed,
                )),
            IconButton(
                onPressed: () {
                  _showFilterDialog(context);
                },
                icon: const Icon(Icons.tune)),
            IconButton(
                onPressed: () {
                  Get.dialog(IbDialog(
                    title: 'Clear Location History',
                    subtitle:
                        'clear your location history will prevent others seeing you in people nearby',
                    onPositiveTap: () async {
                      await _controller.clearLocation();
                      Get.close(2);
                    },
                  ));
                },
                icon: const Icon(Icons.location_off))
          ],
        ),
        body: Obx(
          () => Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.isTrue) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 300,
                              width: 300,
                              child:
                                  Lottie.asset('assets/images/location.json')),
                          Text.rich(
                              TextSpan(text: 'Searching people in ', children: [
                            TextSpan(
                                text: '${_controller.rangeInMi.toInt()} mi ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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
                              child:
                                  Lottie.asset('assets/images/location.json')),
                          const Text(
                            'No one is nearby, try different search criteria',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return SmartRefresher(
                    controller: _controller.refreshController,
                    enablePullUp:
                        _controller.items.length >= _controller.perPage,
                    enablePullDown: false,
                    onLoading: () async {
                      await _controller.loadMore();
                    },
                    child: _controller.isExpanded.isTrue
                        ? _expandedList()
                        : SingleChildScrollView(
                            child: StaggeredGrid.count(
                              crossAxisCount: 2,
                              children: _controller.items
                                  .map((element) =>
                                      PeopleNearbySnipCard(element))
                                  .toList(),
                            ),
                          ),
                  );
                }),
              ),
              if (IbUtils.getCurrentIbUser() != null &&
                  !IbUtils.getCurrentIbUser()!.isPremium &&
                  _controller.isLoading.isFalse)
                SafeArea(
                  child: SizedBox(
                    height: 56,
                    child: AdWidget(
                      ad: _controller.ad,
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _expandedList() {
    return ListView.builder(
      itemBuilder: (context, index) {
        return PeopleNearbyCard(_controller.items[index]);
      },
      itemCount: _controller.items.length,
    );
  }

  void _showFilterDialog(BuildContext context) {
    final oldDistance = _controller.rangeInMi.value;
    final oldGenderSelection = _controller.genderSelections.toList();
    final oldIntentionSelection = _controller.intentionSelection.toList();
    final oldRange = _controller.rangeValue.value;

    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: IbConfig.kNormalTextSize);
    final Widget _content = Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('distance'.tr, style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('age'.tr, style: headerStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('gender'.tr, style: headerStyle),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ToggleButtons(
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
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        IbUser.kGenders[1],
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        IbUser.kGenders[2],
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                    )
                  ]),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Intention', style: headerStyle),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ToggleButtons(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  borderColor: IbColors.lightGrey,
                  selectedColor: IbColors.primaryColor,
                  selectedBorderColor: IbColors.accentColor,
                  borderWidth: 2,
                  onPressed: (index) {
                    _controller.intentionSelection[index] =
                        !_controller.intentionSelection[index];
                    _controller.intentionSelection.refresh();
                  },
                  isSelected: _controller.intentionSelection.toList(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        IbUser.kIntentions[0],
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        IbUser.kIntentions[1],
                        style:
                            TextStyle(color: Theme.of(context).indicatorColor),
                      ),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
    Get.dialog(Center(
      child: IbDialog(
        title: 'Preference',
        subtitle: '',
        content: _content,
        onNegativeTap: () {
          _controller.rangeValue.value = oldRange;
          _controller.genderSelections.value = oldGenderSelection.toList();
          _controller.rangeInMi.value = oldDistance;
          _controller.intentionSelection.value = oldIntentionSelection.toList();
          _controller.intentionSelection.refresh();
          _controller.genderSelections.refresh();
          Get.closeAllSnackbars();
          Get.back();
        },
        onPositiveTap: () {
          if (!_controller.intentionSelection.contains(true)) {
            IbUtils.showSimpleSnackBar(
                msg: 'Pick at least one intention',
                backgroundColor: IbColors.errorRed);
            return;
          }

          if (!_controller.genderSelections.contains(true)) {
            IbUtils.showSimpleSnackBar(
                msg: 'Pick at least one gender',
                backgroundColor: IbColors.errorRed);
            return;
          }
          Get.back();
          _controller.loadItem();
        },
      ),
    ));
  }
}
