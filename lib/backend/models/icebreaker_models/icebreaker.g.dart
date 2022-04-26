// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icebreaker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Icebreaker _$IcebreakerFromJson(Map<String, dynamic> json) => Icebreaker(
      text: json['text'] as String,
      bgColor: json['bgColor'] as int? ?? 4294967295,
      textColor: json['textColor'] as int? ?? 4278190080,
      textStyleIndex: json['textStyleIndex'] as int? ?? 0,
      isItalic: json['isItalic'] as bool? ?? false,
      id: json['id'] as String,
      collectionId: json['collectionId'] as String,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IcebreakerToJson(Icebreaker instance) =>
    <String, dynamic>{
      'text': instance.text,
      'bgColor': instance.bgColor,
      'textColor': instance.textColor,
      'textStyleIndex': instance.textStyleIndex,
      'id': instance.id,
      'collectionId': instance.collectionId,
      'isItalic': instance.isItalic,
      'timestamp': instance.timestamp,
    };
