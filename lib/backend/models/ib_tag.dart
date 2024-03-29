import 'package:json_annotation/json_annotation.dart';

part 'ib_tag.g.dart';

@JsonSerializable()
class IbTag {
  String text;
  int questionCount;
  dynamic timestamp;
  String creatorId;

  IbTag(
      {required this.text,
      required this.creatorId,
      this.timestamp,
      this.questionCount = 0});

  factory IbTag.fromJson(Map<String, dynamic> json) => _$IbTagFromJson(json);

  Map<String, dynamic> toJson() => _$IbTagToJson(this);

  @override
  String toString() {
    return 'IbTag{text: $text, questionCount: $questionCount, timestamp: $timestamp, creatorId: $creatorId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbTag && runtimeType == other.runtimeType && text == other.text;

  @override
  int get hashCode => text.hashCode;
}
