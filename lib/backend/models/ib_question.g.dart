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
      correctChoiceId: json['correctChoiceId'] as String? ?? '',
      isQuiz: json['isQuiz'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isCommentEnabled: json['isCommentEnabled'] as bool? ?? true,
      sharedFriendUids: (json['sharedFriendUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      description: json['description'] as String? ?? '',
      isCircleOnly: json['isCircleOnly'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? true,
      points: json['points'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      position: json['position'],
      medias: (json['medias'] as List<dynamic>?)
              ?.map((e) => IbMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pollSize: json['pollSize'] as int? ?? 0,
      askedTimeInMs: json['askedTimeInMs'] as int,
      endTimeInMs: json['endTimeInMs'] as int? ?? -1,
    );

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'medias': instance.medias.map((e) => e.toJson()).toList(),
      'position': instance.position,
      'sharedFriendUids': instance.sharedFriendUids,
      'question': instance.question,
      'description': instance.description,
      'isPublic': instance.isPublic,
      'isCircleOnly': instance.isCircleOnly,
      'isAnonymous': instance.isAnonymous,
      'isCommentEnabled': instance.isCommentEnabled,
      'isQuiz': instance.isQuiz,
      'points': instance.points,
      'correctChoiceId': instance.correctChoiceId,
      'comments': instance.comments,
      'pollSize': instance.pollSize,
      'likes': instance.likes,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'askedTimeInMs': instance.askedTimeInMs,
      'endTimeInMs': instance.endTimeInMs,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
      'questionType': instance.questionType,
    };
