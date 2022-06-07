import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/user_controllers/people_nearby_controller.dart';
import '../../backend/controllers/user_controllers/profile_controller.dart';
import '../ib_colors.dart';
import '../ib_pages/profile_pages/profile_page.dart';
import 'ib_linear_indicator.dart';

class PeopleNearbySnipCard extends StatelessWidget {
  final NearbyItem item;
  const PeopleNearbySnipCard(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.618,
      child: IbCard(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: item.user.avatarUrl,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              color: Colors.black.withOpacity(0.7),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.user.username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: IbConfig.kPageTitleSize),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  AutoSizeText(
                    '${item.user.fName} • ${item.user.gender} • ${IbUtils.calculateAge(item.user.birthdateInMs ?? -1)}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    maxFontSize: IbConfig.kSecondaryTextSize,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: IbColors.lightGrey,
                        fontWeight: FontWeight.normal,
                        fontSize: IbConfig.kSecondaryTextSize),
                  ),
                  Text(
                    '🔍${item.user.intentions.join(' • ')}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  IbLinearIndicator(endValue: item.compScore),
                  const SizedBox(
                    height: 2,
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        IbUtils.getDistanceString(
                            item.distanceInMeter.toDouble()),
                        style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.right,
                      ))
                ],
              ),
            ),
          ),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                Get.to(() => ProfilePage(Get.put(
                    ProfileController(item.user.id),
                    tag: item.user.id)));
              },
            ),
          )),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
                onPressed: () {
                  print('onTap');
                },
                icon: const Icon(
                  Icons.favorite_border,
                  color: IbColors.errorRed,
                )),
          )
        ],
      )),
    );
  }
}
