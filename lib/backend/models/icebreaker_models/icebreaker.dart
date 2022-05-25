import 'package:json_annotation/json_annotation.dart';

part 'icebreaker.g.dart';

@JsonSerializable()
class Icebreaker {
  String text;
  int bgColor;
  int textColor;
  int textStyleIndex;
  String id;
  String collectionId;
  bool isItalic;
  dynamic timestamp;

  Icebreaker(
      {required this.text,
      this.bgColor = 4294967295,
      this.textColor = 4278190080,
      this.textStyleIndex = 0,
      this.isItalic = false,
      required this.id,
      required this.collectionId,
      required this.timestamp});

  factory Icebreaker.fromJson(Map<String, dynamic> json) =>
      _$IcebreakerFromJson(json);
  Map<String, dynamic> toJson() => _$IcebreakerToJson(this);
}
