import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

class IbSimpleDialog extends StatelessWidget {
  final String message;
  final String positiveBtnTrKey;
  final List<Widget> actionButtons;
  final Function? positiveBtnEvent;
  const IbSimpleDialog(
      {Key? key,
      required this.message,
      required this.positiveBtnTrKey,
      this.actionButtons = const [],
      this.positiveBtnEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IbCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.start,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Wrap(
                        children: actionButtons,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16, left: 8),
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              'cancel'.tr,
                              style: const TextStyle(color: IbColors.errorRed),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16, left: 8),
                          child: TextButton(
                            onPressed: () {
                              Get.back();
                              if (positiveBtnEvent != null) {
                                positiveBtnEvent?.call();
                              }
                            },
                            child: Text(positiveBtnTrKey.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
