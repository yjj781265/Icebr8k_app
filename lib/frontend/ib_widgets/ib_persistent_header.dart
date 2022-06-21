import 'package:flutter/material.dart';

class IbPersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget widget;
  double height;

  IbPersistentHeader({required this.widget, this.height = 48});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: height, color: Colors.transparent, child: widget);
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
