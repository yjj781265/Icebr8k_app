// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icebreaker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Icebreaker _$IcebreakerFromJson(Map<String, dynamic> json) => Icebreaker(
      text: json['text'] as String,
      bgColor: json['bgColorInHex'] as int? ?? 0xFFFFFF,
      textColor: json['textColorInHex'] as int? ?? 0x000000,
      id: json['id'] as String,
      collectionName: json['collectionName'] as String,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IcebreakerToJson(Icebreaker instance) =>
    <String, dynamic>{
      'text': instance.text,
      'bgColorInHex': instance.bgColor,
      'textColorInHex': instance.textColor,
      'id': instance.id,
      'collectionName': instance.collectionName,
      'timestamp': instance.timestamp,
    };
