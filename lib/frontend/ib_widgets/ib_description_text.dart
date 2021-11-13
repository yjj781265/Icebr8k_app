import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbDescriptionText extends StatefulWidget {
  final String text;

  const IbDescriptionText({required this.text});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<IbDescriptionText>
    with SingleTickerProviderStateMixin {
  bool isOverFlow = false;
  bool isExpanded = false;
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isOverFlow = widget.text.length >= 30;
    return AnimatedSize(
      duration:
          const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.text,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: IbConfig.kNormalTextSize,
            ),
          ),
          if (isOverFlow)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                child: Text(
                  isExpanded ? "show less" : "show more",
                  style: const TextStyle(color: IbColors.primaryColor),
                ),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
