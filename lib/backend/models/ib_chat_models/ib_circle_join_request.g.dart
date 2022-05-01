// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_circle_join_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbCircleJoinRequest _$IbCircleJoinRequestFromJson(Map<String, dynamic> json) =>
    IbCircleJoinRequest(
      id: json['id'] as String,
      timestamp: json['timestamp'],
      avatarUrl: json['avatarUrl'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$IbCircleJoinRequestToJson(
        IbCircleJoinRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avatarUrl': instance.avatarUrl,
      'title': instance.title,
      'timestamp': instance.timestamp,
      'text': instance.text,
      'uid': instance.uid,
    };
