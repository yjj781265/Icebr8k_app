// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbMedia _$IbMediaFromJson(Map<String, dynamic> json) => IbMedia(
      url: json['url'] as String,
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$IbMediaToJson(IbMedia instance) => <String, dynamic>{
      'url': instance.url,
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
    };
