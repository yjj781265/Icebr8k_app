import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/models/ib_report.dart';
import 'package:icebr8k/backend/services/user_services/ib_report_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbReportController extends GetxController {
  final ReportType type;
  final isReporting = false.obs;
  final String reporteeId;
  final String url;
  final selectionMap = <String, bool>{}.obs;
  final TextEditingController editingController = TextEditingController();
  IbReport? lastReport;
  IbReportController(
      {required this.type, required this.reporteeId, required this.url});

  @override
  void onInit() {
    for (final str in IbReport.reportCategories) {
      selectionMap[str] = false;
    }
    super.onInit();
  }

  Future<void> report() async {
    isReporting.value = true;
    final reports = selectionMap.keys
        .where((element) => selectionMap[element] ?? false)
        .toList();
    reports.add(editingController.text.trim());
    final IbReport ibReport = IbReport(
        id: IbUtils().getUniqueId(),
        reporteeId: reporteeId,
        reporterId: IbUtils().getCurrentUid()!,
        reports: reports,
        url: url,
        type: type,
        versionCode: '${IbConfig.kVersion}${DbConfig.dbSuffix}');
    await IbReportDbService().addReport(ibReport);
    isReporting.value = false;
    lastReport = ibReport;
  }

  Future<void> cancelReport() async {
    if (lastReport != null) {
      await IbReportDbService().removeReport(lastReport!);
      lastReport = null;
    }
  }
}
