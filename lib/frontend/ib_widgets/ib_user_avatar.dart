import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class IbUserAvatar extends StatelessWidget {
  final String avatarUrl;
  final bool showOnlineStatus;
  final double radius;
  const IbUserAvatar(
      {Key? key,
      required this.avatarUrl,
      this.showOnlineStatus = false,
      this.radius = 24})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return CircleAvatar(
          radius: radius,
          backgroundImage: const AssetImage('assets/icons/logo_ios.png'));
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(avatarUrl),
    );
  }
}
