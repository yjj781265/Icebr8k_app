import 'package:json_annotation/json_annotation.dart';

part 'ib_emo_pic.g.dart';

@JsonSerializable()
class IbEmoPic {
  String url;
  String emoji;
  String? description;
  String id;

  IbEmoPic({required this.url, required this.emoji, required this.id});

  factory IbEmoPic.fromJson(Map<String, dynamic> json) =>
      _$IbEmoPicFromJson(json);

  Map<String, dynamic> toJson() => _$IbEmoPicToJson(this);
}
