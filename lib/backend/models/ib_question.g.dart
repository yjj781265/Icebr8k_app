// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbQuestion _$IbQuestionFromJson(Map<String, dynamic> json) {
  return IbQuestion(
    question: json['question'] as String,
    id: json['id'] as String,
    creatorId: json['creatorId'] as String,
    choices:
        (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
    questionType: json['questionType'] as String,
    description: json['description'] as String,
    likes: json['likes'] as int,
    comments: json['comments'] as int,
    pollSize: json['pollSize'] as int,
    askedTimeInMs: json['askedTimeInMs'] as int,
    endTimeInMs: json['endTimeInMs'] as int,
  );
}

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
      'choices': instance.choices,
      'questionType': instance.questionType,
    };
