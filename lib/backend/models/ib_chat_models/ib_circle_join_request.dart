import 'package:json_annotation/json_annotation.dart';

part 'ib_circle_join_request.g.dart';

@JsonSerializable()
class IbCircleJoinRequest {
  String id;
  String avatarUrl;
  String title;
  dynamic timestamp;
  String text;
  String uid;

  IbCircleJoinRequest(
      {required this.id,
      required this.timestamp,
      required this.avatarUrl,
      required this.title,
      required this.text,
      required this.uid});

  factory IbCircleJoinRequest.fromJson(Map<String, dynamic> json) =>
      _$IbCircleJoinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IbCircleJoinRequestToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbCircleJoinRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          timestamp == other.timestamp &&
          text == other.text &&
          uid == other.uid;

  @override
  int get hashCode =>
      id.hashCode ^ timestamp.hashCode ^ text.hashCode ^ uid.hashCode;
}
