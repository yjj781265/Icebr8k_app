import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_report_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

class IbReportCard extends StatelessWidget {
  final IbReportController ibReportController;
  const IbReportCard({required this.ibReportController, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IbCard(
          child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🚨 Report this ${ibReportController.type.name}',
                    style: const TextStyle(
                        fontSize: IbConfig.kPageTitleSize,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.clear))
                ],
              ),
            ),
            Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: ibReportController.selectionMap.keys
                    .map((e) => CheckboxListTile(
                        title: Text(e),
                        value: ibReportController.selectionMap[e] ?? false,
                        onChanged: (value) {
                          ibReportController.selectionMap[e] = value ?? false;
                        }))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: ibReportController.editingController,
                decoration: const InputDecoration(hintText: 'Other'),
              ),
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    child: IbElevatedButton(
                        textTrKey: ibReportController.isReporting.isTrue
                            ? 'Reporting...'
                            : 'Report',
                        textColor: IbColors.creamYellow,
                        color: IbColors.errorRed,
                        onPressed: () async {
                          try {
                            if (!ibReportController.selectionMap.values
                                    .contains(true) &&
                                ibReportController.editingController.text
                                    .trim()
                                    .isEmpty) {
                              IbUtils.showSimpleSnackBar(
                                  msg: 'Pick at least one report category.',
                                  backgroundColor: IbColors.errorRed);
                              return;
                            }
                            await ibReportController.report();
                            Get.back();
                            showReceivedDialog();
                          } catch (e) {
                            Get.back();
                            IbUtils.showSimpleSnackBar(
                                msg: 'Report failed',
                                backgroundColor: IbColors.errorRed);
                          }
                        }),
                  ),
                )),
          ],
        ),
      )),
    );
  }

  void showReceivedDialog() {
    final widget = IbDialog(
      title: 'Your report has been received',
      subtitle: '',
      actionButtons: TextButton(
          onPressed: () async {
            try {
              await ibReportController.cancelReport();
              Get.back();
              IbUtils.showSimpleSnackBar(
                  msg: 'Report canceled',
                  backgroundColor: IbColors.primaryColor);
            } catch (e) {
              Get.back();
              IbUtils.showSimpleSnackBar(
                  msg: 'Report failed', backgroundColor: IbColors.errorRed);
            }
          },
          child: const Text('Cancel Report')),
      showNegativeBtn: false,
    );

    Get.dialog(widget);
  }
}
