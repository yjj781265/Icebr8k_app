// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbQuestion _$IbQuestionFromJson(Map<String, dynamic> json) => IbQuestion(
      question: json['question'] as String,
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => IbChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      questionType: json['questionType'] as String,
      tagIds: (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      endpoints: (json['endpoints'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: json['description'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      pollSize: json['pollSize'] as int? ?? 0,
      askedTimeInMs: json['askedTimeInMs'] as int,
      endTimeInMs: json['endTimeInMs'] as int? ?? 0,
    );

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'tagIds': instance.tagIds,
      'question': instance.question,
      'description': instance.description,
      'comments': instance.comments,
      'pollSize': instance.pollSize,
      'likes': instance.likes,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'askedTimeInMs': instance.askedTimeInMs,
      'endTimeInMs': instance.endTimeInMs,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
      'endpoints': instance.endpoints,
      'questionType': instance.questionType,
    };
