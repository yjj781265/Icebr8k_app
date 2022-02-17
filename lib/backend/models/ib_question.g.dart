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
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isCommentEnabled: json['isCommentEnabled'] as bool? ?? true,
      privacyBounds: (json['privacyBounds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['public'],
      tagIds: (json['tagIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      endpoints: (json['endpoints'] as List<dynamic>?)
          ?.map((e) => IbChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      medias: (json['medias'] as List<dynamic>?)
              ?.map((e) => IbMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      externalLinks: (json['externalLinks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pollSize: json['pollSize'] as int? ?? 0,
      askedTimeInMs: json['askedTimeInMs'] as int,
      endTimeInMs: json['endTimeInMs'] as int? ?? -1,
    );

Map<String, dynamic> _$IbQuestionToJson(IbQuestion instance) =>
    <String, dynamic>{
      'tagIds': instance.tagIds,
      'medias': instance.medias.map((e) => e.toJson()).toList(),
      'externalLinks': instance.externalLinks,
      'privacyBounds': instance.privacyBounds,
      'question': instance.question,
      'description': instance.description,
      'isAnonymous': instance.isAnonymous,
      'isCommentEnabled': instance.isCommentEnabled,
      'comments': instance.comments,
      'pollSize': instance.pollSize,
      'likes': instance.likes,
      'id': instance.id,
      'creatorId': instance.creatorId,
      'askedTimeInMs': instance.askedTimeInMs,
      'endTimeInMs': instance.endTimeInMs,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
      'endpoints': instance.endpoints?.map((e) => e.toJson()).toList(),
      'questionType': instance.questionType,
    };
