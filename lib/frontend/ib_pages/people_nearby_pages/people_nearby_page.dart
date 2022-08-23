import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/controllers/user_controllers/people_nearby_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_pages/profile_liked_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_card.dart';
import 'package:icebr8k/frontend/ib_widgets/people_nearby_snip_card.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
                  _controller.showFilterDialog(context);
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
              if (IbUtils().getCurrentIbUser() != null &&
                  !IbUtils().isPremiumMember() &&
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
}
