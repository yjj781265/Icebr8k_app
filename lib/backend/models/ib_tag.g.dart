// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbTag _$IbTagFromJson(Map<String, dynamic> json) => IbTag(
      text: json['text'] as String,
      creatorId: json['creatorId'] as String,
      timestamp: json['timestamp'],
      questionCount: json['questionCount'] as int? ?? 0,
    );

Map<String, dynamic> _$IbTagToJson(IbTag instance) => <String, dynamic>{
      'text': instance.text,
      'questionCount': instance.questionCount,
      'timestamp': instance.timestamp,
      'creatorId': instance.creatorId,
    };
