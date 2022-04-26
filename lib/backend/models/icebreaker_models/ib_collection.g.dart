// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbCollection _$IbCollectionFromJson(Map<String, dynamic> json) => IbCollection(
      name: json['name'] as String,
      id: json['id'] as String,
      link: json['link'] as String? ?? '',
      creatorId: json['creatorId'] as String? ?? '',
      bgColor: json['bgColor'] as int? ?? 4294967295,
      textColor: json['textColor'] as int? ?? 4278190080,
      textStyleIndex: json['textStyleIndex'] as int? ?? 0,
      isItalic: json['isItalic'] as bool? ?? false,
      icebreakers: (json['icebreakers'] as List<dynamic>?)
              ?.map((e) => Icebreaker.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IbCollectionToJson(IbCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'link': instance.link,
      'creatorId': instance.creatorId,
      'isItalic': instance.isItalic,
      'bgColor': instance.bgColor,
      'textColor': instance.textColor,
      'textStyleIndex': instance.textStyleIndex,
      'icebreakers': instance.icebreakers.map((e) => e.toJson()).toList(),
      'timestamp': instance.timestamp,
    };
