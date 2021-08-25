// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbAnswer _$IbAnswerFromJson(Map<String, dynamic> json) {
  return IbAnswer(
    answer: json['answer'] as String,
    answeredTimeInMs: json['answeredTimeInMs'] as int,
    askedTimeInMs: json['askedTimeInMs'] as int,
    questionId: json['questionId'] as String,
    questionType: json['questionType'] as String,
    uid: json['uid'] as String,
  );
}

Map<String, dynamic> _$IbAnswerToJson(IbAnswer instance) => <String, dynamic>{
      'answer': instance.answer,
      'answeredTimeInMs': instance.answeredTimeInMs,
      'uid': instance.uid,
      'askedTimeInMs': instance.askedTimeInMs,
      'questionId': instance.questionId,
      'questionType': instance.questionType,
    };
