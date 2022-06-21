import 'package:json_annotation/json_annotation.dart';

part 'ib_emo_pic.g.dart';

@JsonSerializable()
class IbEmoPic {
  String url;
  String emoji;
  String description;
  int timestampInMs;
  String id;

  IbEmoPic(
      {required this.url,
      required this.emoji,
      required this.id,
      this.timestampInMs = -1,
      this.description = ''});

  factory IbEmoPic.fromJson(Map<String, dynamic> json) =>
      _$IbEmoPicFromJson(json);

  Map<String, dynamic> toJson() => _$IbEmoPicToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbEmoPic && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
