// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbQuestion _$IbQuestionFromJson(Map<String, dynamic> json) => IbQuestion(
      question: json['question'] as String,
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      choices:
          (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
      questionType: json['questionType'] as String,
      statMap: Map<String, int>.from(json['statMap'] as Map),
      extras: (json['extras'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      description: json['description'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      pollSize: json['pollSize'] as int? ?? 0,
      askedTimeInMs: json['askedTimeInMs'] as int,
      endTimeInMs: json['endTimeInMs'] as int? ?? 0,
    );

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'description': instance.description,
      'comments': instance.comments,
      'pollSize': instance.pollSize,
      'likes': instance.likes,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'askedTimeInMs': instance.askedTimeInMs,
      'endTimeInMs': instance.endTimeInMs,
      'statMap': instance.statMap,
      'choices': instance.choices,
      'extras': instance.extras,
      'questionType': instance.questionType,
    };
