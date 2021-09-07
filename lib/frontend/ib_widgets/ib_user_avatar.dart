import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class IbUserAvatar extends StatelessWidget {
  final String avatarUrl;
  final String? uid;
  final bool showOnlineStatus;
  final bool disableOnTap;
  final double radius;
  const IbUserAvatar(
      {Key? key,
      required this.avatarUrl,
      this.uid,
      this.disableOnTap = false,
      this.showOnlineStatus = false,
      this.radius = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return CircleAvatar(radius: radius, child: const IbProgressIndicator());
    }
    return GestureDetector(
      onTap: (disableOnTap || uid == null || uid!.isEmpty)
          ? null
          : () {
              Get.to(
                  () => ProfilePage(
                        uid!,
                        showAppBar: true,
                      ),
                  preventDuplicates: false);
            },
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        imageBuilder: (context, imageProvider) => Container(
          height: radius * 2,
          width: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => const IbProgressIndicator(),
      ),
    );
  }
}
