// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbComment _$IbCommentFromJson(Map<String, dynamic> json) => IbComment(
      commentId: json['commentId'] as String,
      uid: json['uid'] as String,
      questionId: json['questionId'] as String,
      notifyUid: json['notifyUid'] as String,
      isEdited: json['isEdited'] as bool? ?? false,
      likes: json['likes'] as int? ?? 0,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => IbComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parentId: json['parentId'] as String?,
      content: json['content'] as String,
      type: json['type'] as String,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$IbCommentToJson(IbComment instance) => <String, dynamic>{
      'parentId': instance.parentId,
      'notifyUid': instance.notifyUid,
      'commentId': instance.commentId,
      'questionId': instance.questionId,
      'uid': instance.uid,
      'likes': instance.likes,
      'replies': instance.replies.map((e) => e.toJson()).toList(),
      'content': instance.content,
      'type': instance.type,
      'isEdited': instance.isEdited,
      'timestamp': instance.timestamp,
    };
