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
      notifyUid: json['notifyUid'] as String,
      likes: json['likes'] as int? ?? 0,
      replies: json['replies'] as int? ?? 0,
      replyId: json['replyId'] as String?,
      content: json['content'] as String,
      type: json['type'] as String,
      timestampInMs: json['timestampInMs'] as int,
    );

Map<String, dynamic> _$IbCommentToJson(IbComment instance) => <String, dynamic>{
      'replyId': instance.replyId,
      'notifyUid': instance.notifyUid,
      'commentId': instance.commentId,
      'questionId': instance.questionId,
      'uid': instance.uid,
      'likes': instance.likes,
      'replies': instance.replies,
      'isAnonymous': instance.isAnonymous,
      'content': instance.content,
      'type': instance.type,
      'timestampInMs': instance.timestampInMs,
    };
