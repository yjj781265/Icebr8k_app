import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_collection.g.dart';

@JsonSerializable(explicitToJson: true)
class IbCollection {
  String id;
  String name;
  String link;
  String creatorId;
  bool isItalic;
  int bgColor;
  int textColor;
  int textStyleIndex;
  List<Icebreaker> icebreakers;
  dynamic timestamp;

  IbCollection(
      {required this.name,
      required this.id,
      this.link = '',
      this.creatorId = '',
      this.bgColor = 4294967295,
      this.textColor = 4278190080,
      this.textStyleIndex = 0,
      this.isItalic = false,
      this.icebreakers = const [],
      this.timestamp});

  factory IbCollection.fromJson(Map<String, dynamic> json) =>
      _$IbCollectionFromJson(json);
  Map<String, dynamic> toJson() => _$IbCollectionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          link == other.link &&
          creatorId == other.creatorId &&
          isItalic == other.isItalic &&
          bgColor == other.bgColor &&
          textColor == other.textColor &&
          textStyleIndex == other.textStyleIndex &&
          icebreakers == other.icebreakers &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      link.hashCode ^
      creatorId.hashCode ^
      isItalic.hashCode ^
      bgColor.hashCode ^
      textColor.hashCode ^
      textStyleIndex.hashCode ^
      icebreakers.hashCode ^
      timestamp.hashCode;
}
