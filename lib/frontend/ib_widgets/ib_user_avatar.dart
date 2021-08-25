import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class IbUserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String uid;
  final bool showOnlineStatus;
  final bool disableOnTap;
  final double radius;
  const IbUserAvatar(
      {Key? key,
      required this.avatarUrl,
      required this.uid,
      this.disableOnTap = false,
      this.showOnlineStatus = false,
      this.radius = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty || uid.isEmpty) {
      return CircleAvatar(radius: radius, child: const IbProgressIndicator());
    }
    if (disableOnTap) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.to(
            () => ProfilePage(
                  uid,
                  showAppBar: true,
                ),
            preventDuplicates: false);
      },
      child: CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      ),
    );
  }
}
