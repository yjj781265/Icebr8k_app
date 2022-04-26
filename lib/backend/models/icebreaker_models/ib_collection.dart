import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_collection.g.dart';

@JsonSerializable(explicitToJson: true)
class IbCollection {
  String name;
  String link;
  String creatorId;
  int bgColor;
  int textColor;
  List<Icebreaker> icebreakers;
  dynamic timestamp;

  IbCollection(
      {required this.name,
      this.link = '',
      required this.creatorId,
      this.bgColor = 4294967295,
      this.textColor = 4278190080,
      this.icebreakers = const [],
      this.timestamp});

  factory IbCollection.fromJson(Map<String, dynamic> json) =>
      _$IbCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$IbCollectionToJson(this);
}
