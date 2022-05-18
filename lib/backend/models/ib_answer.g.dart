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
      questionType: $enumDecode(_$QuestionTypeEnumMap, json['questionType']),
      edited: json['edited'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isPublicQuestion: json['isPublicQuestion'] as bool? ?? true,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$IbAnswerToJson(IbAnswer instance) => <String, dynamic>{
      'choiceId': instance.choiceId,
      'answeredTimeInMs': instance.answeredTimeInMs,
      'isAnonymous': instance.isAnonymous,
      'isPublicQuestion': instance.isPublicQuestion,
      'uid': instance.uid,
      'askedTimeInMs': instance.askedTimeInMs,
      'questionId': instance.questionId,
      'questionType': _$QuestionTypeEnumMap[instance.questionType],
      'edited': instance.edited,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'mc',
  QuestionType.multipleChoicePic: 'mc_pic',
  QuestionType.scaleOne: 'sc_1',
  QuestionType.scaleTwo: 'sc_2',
  QuestionType.scaleThree: 'sc_3',
};
