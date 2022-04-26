import 'package:json_annotation/json_annotation.dart';

part 'icebreaker.g.dart';

@JsonSerializable()
class Icebreaker {
  String text;
  int bgColor;
  int textColor;
  String id;
  String collectionName;
  dynamic timestamp;

  Icebreaker(
      {required this.text,
      this.bgColor = 4294967295,
      this.textColor = 4278190080,
      required this.id,
      required this.collectionName,
      required this.timestamp});

  factory Icebreaker.fromJson(Map<String, dynamic> json) =>
      _$IcebreakerFromJson(json);
  Map<String, dynamic> toJson() => _$IcebreakerToJson(this);
}
