import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

class IbDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String positiveTextKey;
  final Widget? content;
  final Widget? actionButtons;
  final Function? onPositiveTap;
  final bool showNegativeBtn;

  const IbDialog(
      {required this.title,
      required this.subtitle,
      this.actionButtons,
      this.positiveTextKey = 'confirm',
      this.content,
      this.onPositiveTap,
      this.showNegativeBtn = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IbCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: IbConfig.kPageTitleSize,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                  ),
                ),
                content ?? const SizedBox(),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    actionButtons ?? const SizedBox(),
                    if (actionButtons != null)
                      const SizedBox(
                        width: 32,
                      ),
                    if (showNegativeBtn)
                      Expanded(
                        flex: 4,
                        child: IbElevatedButton(
                          icon: const Icon(
                            Icons.cancel,
                            size: 16,
                          ),
                          textTrKey: 'cancel'.tr,
                          onPressed: Get.back,
                          color: IbColors.lightGrey,
                        ),
                      ),
                    Expanded(
                      flex: 5,
                      child: IbElevatedButton(
                        icon: const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                        ),
                        textTrKey: positiveTextKey.tr,
                        color: IbColors.primaryColor,
                        onPressed: onPositiveTap ?? Get.back,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
