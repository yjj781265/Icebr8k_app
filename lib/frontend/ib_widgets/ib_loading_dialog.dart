import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class IbLoadingDialog extends StatelessWidget {
  final String messageTrKey;

  const IbLoadingDialog({required this.messageTrKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 120,
        child: IbCard(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              const IbProgressIndicator(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    messageTrKey.tr,
                    style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
