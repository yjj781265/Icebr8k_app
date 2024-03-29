import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../ib_config.dart';
import '../ib_pages/profile_pages/my_profile_page.dart';
import '../ib_pages/profile_pages/profile_page.dart';

class IbUserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? uid;
  final double? compScore;
  final bool showOnlineStatus;
  final bool disableOnTap;
  final bool showBorder;
  final double radius;
  const IbUserAvatar(
      {Key? key,
      required this.avatarUrl,
      this.compScore,
      this.showBorder = false,
      this.uid,
      this.disableOnTap = false,
      this.showOnlineStatus = false,
      this.radius = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: IbColors.lightGrey,
            border: showBorder
                ? Border.all(color: Theme.of(context).indicatorColor, width: 2)
                : null),
        height: radius * 2,
        width: radius * 2,
        child: Icon(
          Icons.person,
          size: radius,
          color: Colors.grey,
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (compScore != null)
          TweenAnimationBuilder(
            tween: Tween<double>(
                begin: 0,
                end: uid == IbUtils().getCurrentUid() ? 0 : compScore),
            duration: const Duration(milliseconds: 888),
            builder: (BuildContext context, double value, Widget? child) {
              return SizedBox(
                  height: radius * 2 + 2,
                  width: radius * 2 + 2,
                  child: CircularProgressIndicator(
                    color: IbUtils().handleIndicatorColor(value),
                    value: value,
                  ));
            },
          ),
        GestureDetector(
            onTap: (disableOnTap || uid == null || uid!.isEmpty)
                ? null
                : () {
                    if (IbUtils().checkFeatureIsLocked()) {
                      return;
                    }
                    if (uid == IbUtils().getCurrentUid()!) {
                      Get.to(() => MyProfilePage());
                    } else {
                      Get.to(() => ProfilePage(Get.put(ProfileController(uid!),
                          tag: IbUtils().getUniqueId())));
                    }
                  },
            child: avatarUrl.contains('http')
                ? CachedNetworkImage(
                    errorWidget: (context, str, value) => CircleAvatar(
                        radius: radius, backgroundColor: IbColors.lightBlue),
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) => Container(
                      height: radius * 2,
                      width: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                        border: showBorder
                            ? Border.all(
                                width: 2,
                                color: Theme.of(context).indicatorColor)
                            : null,
                      ),
                    ),
                    placeholder: (context, str) => CircleAvatar(
                      radius: radius,
                      backgroundColor: IbColors.lightGrey,
                    ),
                  )
                : CircleAvatar(
                    radius: radius,
                    backgroundImage: FileImage(File(avatarUrl)),
                  )),
        if (compScore != null &&
            uid != IbUtils().getCurrentUid() &&
            radius > 32)
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color:
                    IbUtils().handleIndicatorColor(compScore!).withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              width: 40,
              alignment: Alignment.center,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 888),
                tween: Tween<double>(begin: 0, end: compScore),
                builder: (BuildContext context, double value, Widget? child) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
