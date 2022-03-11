import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class IbUserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? uid;
  final double? compScore;
  final bool showOnlineStatus;
  final bool disableOnTap;
  final double radius;
  const IbUserAvatar(
      {Key? key,
      required this.avatarUrl,
      this.compScore,
      this.uid,
      this.disableOnTap = false,
      this.showOnlineStatus = false,
      this.radius = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return SizedBox(
        height: radius * 2,
        width: radius * 2,
        child: const IbProgressIndicator(),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        if (compScore != null && uid != IbUtils.getCurrentUid())
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: compScore),
            duration: const Duration(milliseconds: 888),
            builder: (BuildContext context, double value, Widget? child) {
              return SizedBox(
                  height: radius * 2 + 2,
                  width: radius * 2 + 2,
                  child: CircularProgressIndicator(
                    color: IbUtils.handleIndicatorColor(value),
                    value: value,
                  ));
            },
          ),
        GestureDetector(
          onTap: (disableOnTap || uid == null || uid!.isEmpty)
              ? null
              : () {
                  if (uid == IbUtils.getCurrentUid()!) {
                    Get.to(MyProfilePage());
                  } else {
                    Get.to(ProfilePage(Get.put(ProfileController(uid!))));
                  }
                },
          child: CachedNetworkImage(
            errorWidget: (context, str, value) => CircleAvatar(
                radius: radius, backgroundColor: IbColors.lightBlue),
            imageUrl: avatarUrl,
            imageBuilder: (context, imageProvider) => Container(
              height: radius * 2,
              width: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => CircleAvatar(
              radius: radius,
              backgroundColor: IbColors.lightBlue,
              child: const IbProgressIndicator(),
            ),
          ),
        ),
        if (compScore != null && uid != IbUtils.getCurrentUid())
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color:
                    IbUtils.handleIndicatorColor(compScore!).withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              width: 32,
              alignment: Alignment.center,
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 888),
                tween: Tween<double>(begin: 0, end: compScore),
                builder: (BuildContext context, double value, Widget? child) {
                  return Text(
                    '${(value * 100).toInt()}%',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          )
      ],
    );
  }
}
