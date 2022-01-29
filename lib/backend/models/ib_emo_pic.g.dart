// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_emo_pic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbEmoPic _$IbEmoPicFromJson(Map<String, dynamic> json) => IbEmoPic(
      url: json['url'] as String,
      emoji: json['emoji'] as String,
      id: json['id'] as String,
    )..description = json['description'] as String?;

Map<String, dynamic> _$IbEmoPicToJson(IbEmoPic instance) => <String, dynamic>{
      'url': instance.url,
      'emoji': instance.emoji,
      'description': instance.description,
      'id': instance.id,
    };
