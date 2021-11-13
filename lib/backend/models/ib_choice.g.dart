// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbChoice _$IbChoiceFromJson(Map<String, dynamic> json) => IbChoice(
      content: json['content'] as String?,
      url: json['url'] as String?,
      count: json['count'] as int? ?? 0,
      choiceId: json['choiceId'] as String,
    );

Map<String, dynamic> _$IbChoiceToJson(IbChoice instance) => <String, dynamic>{
      'content': instance.content,
      'url': instance.url,
      'count': instance.count,
      'choiceId': instance.choiceId,
    };
