import 'package:json_annotation/json_annotation.dart';

part 'ib_report.g.dart';

@JsonSerializable(explicitToJson: false)
class IbReport {
  final String id;
  final String reporteeId;
  final String reporterId;
  final List<String> reports;
  final String url;
  final String versionCode;
  final ReportType type;

  dynamic timestamp;

  static final List<String> reportCategories = [
    'Inappropriate Content',
    'Pornography',
    'Scam of fraud',
    'Spam',
    'Offensive'
  ];

  IbReport(
      {required this.id,
      required this.reporteeId,
      required this.reporterId,
      required this.reports,
      required this.url,
      required this.type,
      required this.versionCode,
      this.timestamp});

  factory IbReport.fromJson(Map<String, dynamic> json) =>
      _$IbReportFromJson(json);
  Map<String, dynamic> toJson() => _$IbReportToJson(this);
}

enum ReportType {
  @JsonValue('poll')
  poll('Poll'),
  @JsonValue('comment')
  comment('Comment'),
  @JsonValue('user')
  user('User');

  final String type;
  const ReportType(this.type);

  @override
  String toString() {
    return type;
  }
}
