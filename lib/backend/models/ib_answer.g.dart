// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbAnswer _$IbAnswerFromJson(Map<String, dynamic> json) => IbAnswer(
      choiceId: json['choiceId'] as String,
      answeredTimeInMs: json['answeredTimeInMs'] as int,
      askedTimeInMs: json['askedTimeInMs'] as int,
      questionId: json['questionId'] as String,
      questionType: json['questionType'] as String,
      edited: json['edited'] as bool? ?? false,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$IbAnswerToJson(IbAnswer instance) => <String, dynamic>{
      'choiceId': instance.choiceId,
      'answeredTimeInMs': instance.answeredTimeInMs,
      'uid': instance.uid,
      'askedTimeInMs': instance.askedTimeInMs,
      'questionId': instance.questionId,
      'questionType': instance.questionType,
      'edited': instance.edited,
    };
