// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbReport _$IbReportFromJson(Map<String, dynamic> json) => IbReport(
      id: json['id'] as String,
      reporteeId: json['reporteeId'] as String,
      reporterId: json['reporterId'] as String,
      reports:
          (json['reports'] as List<dynamic>).map((e) => e as String).toList(),
      url: json['url'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      versionCode: json['versionCode'] as String,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IbReportToJson(IbReport instance) => <String, dynamic>{
      'id': instance.id,
      'reporteeId': instance.reporteeId,
      'reporterId': instance.reporterId,
      'reports': instance.reports,
      'url': instance.url,
      'versionCode': instance.versionCode,
      'type': _$ReportTypeEnumMap[instance.type],
      'timestamp': instance.timestamp,
    };

const _$ReportTypeEnumMap = {
  ReportType.poll: 'poll',
  ReportType.comment: 'comment',
  ReportType.user: 'user',
};
