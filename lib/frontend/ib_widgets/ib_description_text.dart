import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class IbDescriptionText extends StatefulWidget {
  final String text;
  final TextAlign textAlign;

  const IbDescriptionText(
      {required this.text, this.textAlign = TextAlign.left});

  @override
  _DescriptionTextWidgetState createState() => _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<IbDescriptionText>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  int maxLines = 2;
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return const SizedBox();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final span = TextSpan(
          text: widget.text,
        );

        // Use a textpainter to determine if it will exceed max lines
        final tp = TextPainter(
          maxLines: maxLines,
          textAlign: widget.textAlign,
          textDirection: TextDirection.ltr,
          text: span,
        );

        // trigger it to layout
        tp.layout(maxWidth: constraints.maxWidth);

        // whether the text overflowed or not
        final bool isOverflow = tp.didExceedMaxLines;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              alignment: Alignment.topCenter,
              child: Linkify(
                  options: const LinkifyOptions(looseUrl: true),
                  textAlign: widget.textAlign,
                  linkStyle: const TextStyle(
                      fontSize: IbConfig.kSecondaryTextSize,
                      color: IbColors.primaryColor),
                  style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
                  maxLines: isExpanded ? null : maxLines,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  text: widget.text,
                  onOpen: (link) async {
                    if (await canLaunchUrlString(link.url)) {
                      await launchUrlString(link.url);
                    }
                  }),
            ),
            if (isOverflow)
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 30,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? "show less" : "show more",
                        style: const TextStyle(color: IbColors.primaryColor),
                      )),
                ),
              ),
          ],
        );
      },
    );
  }
}
