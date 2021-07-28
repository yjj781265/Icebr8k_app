// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbAnswer _$IbAnswerFromJson(Map<String, dynamic> json) {
  return IbAnswer(
    answer: json['answer'] as String,
    questionId: json['questionId'] as String,
    timeStampInMs: json['timeStampInMs'] as int,
    uid: json['uid'] as String,
  );
}

Map<String, dynamic> _$IbAnswerToJson(IbAnswer instance) => <String, dynamic>{
      'answer': instance.answer,
      'questionId': instance.questionId,
      'timeStampInMs': instance.timeStampInMs,
      'uid': instance.uid,
    };
