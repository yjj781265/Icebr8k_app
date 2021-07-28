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
    createdTimeInMs: json['createdTimeInMs'] as int,
    endTimeInMs: json['endTimeInMs'] as int,
  );
}

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'description': instance.description,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'createdTimeInMs': instance.createdTimeInMs,
      'endTimeInMs': instance.endTimeInMs,
      'choices': instance.choices,
      'questionType': instance.questionType,
    };
