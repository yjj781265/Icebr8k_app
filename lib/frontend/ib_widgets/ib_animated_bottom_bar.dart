import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../ib_colors.dart';

class IbAnimatedBottomBar extends StatelessWidget {
  const IbAnimatedBottomBar({
    Key? key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.containerHeight = 56,
    this.backgroundColor,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
    required this.items,
    required this.onItemSelected,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  final int selectedIndex;
  final double iconSize;
  final Color? backgroundColor;
  final bool showElevation;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double containerHeight;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).bottomAppBarColor;

    return AnimatedContainer(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          if (showElevation)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
            ),
        ],
      ),
      duration: const Duration(milliseconds: 200),

      /// user wrap to prevent overflow at the bottom when nav is not visible
      child: Wrap(
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: mainAxisAlignment,
              children: items.map((item) {
                final index = items.indexOf(item);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => onItemSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _ItemWidget(
                        item: item,
                        iconSize: iconSize,
                        isSelected: index == selectedIndex,
                        backgroundColor: bgColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;

  const _ItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.backgroundColor,
    required this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: AlignmentDirectional.center, children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(
              size: iconSize,
              color: isSelected
                  ? item.activeColor.withOpacity(1)
                  : item.inactiveColor ?? item.activeColor,
            ),
            child: item.icon,
          ),
          if (item.title.isNotEmpty)
            Text(
              item.title,
              style: TextStyle(
                  color: isSelected ? item.activeColor : item.inactiveColor,
                  fontSize: IbConfig.kDescriptionTextSize,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
      if (item.notification > 0)
        Positioned(
          top: 2,
          right: 0,
          child: CircleAvatar(
            backgroundColor: IbColors.errorRed,
            radius: 11,
            child: Text(
              item.notification >= 99 ? '99+' : item.notification.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: IbColors.white,
                fontSize: 11,
              ),
            ),
          ),
        ),
    ]);
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.icon,
    required this.title,
    this.notification = -1,
    this.activeColor = IbColors.primaryColor,
    this.textAlign,
    this.inactiveColor,
  });

  final Widget icon;
  final String title;
  final Color activeColor;
  final Color? inactiveColor;
  final TextAlign? textAlign;
  final int notification;
}
