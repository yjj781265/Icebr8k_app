import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/people_nearby_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/profile_controller.dart';
import '../profile_pages/profile_page.dart';

class ProfileLikedPage extends StatelessWidget {
  ProfileLikedPage({Key? key}) : super(key: key);
  final PeopleNearbyController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People who liked you'),
      ),
      body: Obx(() {
        if (_controller.likeItems.isEmpty) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/images/dog.json'),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'No one has liked you yet, be patient, they will come!'),
              )
            ],
          ));
        }

        return SmartRefresher(
          controller: _controller.likeRefreshController,
          enablePullDown: false,
          enablePullUp: _controller.likeItems.length >= IbConfig.kPerPage,
          onLoading: () async {
            await _controller.loadMoreLikedItems();
          },
          child: ListView.builder(
            itemBuilder: (context, index) {
              final item = _controller.likeItems[index];
              return IbCard(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    onTap: () {
                      Get.to(() => ProfilePage(Get.put(
                          ProfileController(item.user.id),
                          tag: item.user.id)));
                    },
                    leading: IbUserAvatar(
                      avatarUrl: item.user.avatarUrl,
                    ),
                    title: Text(
                      item.user.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: IbConfig.kNormalTextSize),
                    ),
                    subtitle: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('🔍${item.user.intentions.join(" · ")}'),
                        if (item.distanceInMeters != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              IbUtils.getDistanceString(
                                  item.distanceInMeters!.toDouble()),
                              style: const TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize),
                            ),
                          )
                      ],
                    ),
                    trailing: item.isBingo
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.favorite,
                                color: IbColors.errorRed,
                              ),
                              Icon(
                                Icons.favorite,
                                color: IbColors.errorRed,
                              )
                            ],
                          )
                        : const Icon(
                            Icons.favorite,
                            color: IbColors.errorRed,
                          ),
                  ),
                ),
              );
            },
            itemCount: _controller.likeItems.length,
          ),
        );
      }),
    );
  }
}
