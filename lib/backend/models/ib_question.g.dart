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
    answers:
        (json['answers'] as List<dynamic>).map((e) => e as String).toList(),
    questionType: json['questionType'] as String,
    description: json['description'] as String,
    createdTime: json['createdTime'] as int,
    endTime: json['endTime'] as int,
  );
}

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'question': instance.question,
      'description': instance.description,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'createdTime': instance.createdTime,
      'endTime': instance.endTime,
      'answers': instance.answers,
      'questionType': instance.questionType,
    };
