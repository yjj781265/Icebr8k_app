import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class IbLoadingDialog extends StatelessWidget {
  final String messageTrKey;

  const IbLoadingDialog({required this.messageTrKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 100,
        child: IbCard(
          child: Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const IbProgressIndicator(),
              Text(messageTrKey.tr),
            ],
          ),
        ),
      ),
    );
  }
}