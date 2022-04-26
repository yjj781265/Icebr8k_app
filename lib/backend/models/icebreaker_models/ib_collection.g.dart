// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbCollection _$IbCollectionFromJson(Map<String, dynamic> json) => IbCollection(
      name: json['name'] as String,
      link: json['link'] as String? ?? '',
      creatorId: json['creatorId'] as String,
      bgColor: json['bgColorInHex'] as int? ?? 0xFFFFFF,
      textColor: json['textColorInHex'] as int? ?? 0x000000,
      icebreakers: (json['icebreakers'] as List<dynamic>?)
              ?.map((e) => Icebreaker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IbCollectionToJson(IbCollection instance) =>
    <String, dynamic>{
      'name': instance.name,
      'link': instance.link,
      'creatorId': instance.creatorId,
      'bgColorInHex': instance.bgColor,
      'textColorInHex': instance.textColor,
      'icebreakers': instance.icebreakers.map((e) => e.toJson()).toList(),
      'timestamp': instance.timestamp,
    };
