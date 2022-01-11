// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbComment _$IbCommentFromJson(Map<String, dynamic> json) => IbComment(
      commentId: json['commentId'] as String,
      uid: json['uid'] as String,
      questionId: json['questionId'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      content: json['content'] as String,
      type: json['type'] as String,
      timestampInMs: json['timestampInMs'] as int,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => IbComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <IbComment>[],
    );

Map<String, dynamic> _$IbCommentToJson(IbComment instance) => <String, dynamic>{
      'commentId': instance.commentId,
      'questionId': instance.questionId,
      'uid': instance.uid,
      'isAnonymous': instance.isAnonymous,
      'content': instance.content,
      'type': instance.type,
      'replies': instance.replies.map((e) => e.toJson()).toList(),
      'timestampInMs': instance.timestampInMs,
    };
