import 'package:json_annotation/json_annotation.dart';

part 'ib_comment.g.dart';

/// reply Id is the id for the reply of a comment
/// notifyUid is the Uid of a comment reply to(for push notification)
@JsonSerializable(explicitToJson: true)
class IbComment {
  String? replyId;
  String notifyUid;
  String commentId;
  String questionId;
  String uid;
  int likes;
  int replies;
  bool isAnonymous;
  String content;
  String type;
  dynamic timestamp;

  static const String kCommentTypeText = 'text';
  static const String kCommentTypePic = 'pic';
  static const String kCommentTypeAudio = 'audio';

  IbComment({
    required this.commentId,
    required this.uid,
    required this.questionId,
    this.isAnonymous = false,
    required this.notifyUid,
    this.likes = 0,
    this.replies = 0,
    this.replyId,
    required this.content,
    required this.type,
    this.timestamp,
  });

  factory IbComment.fromJson(Map<String, dynamic> json) =>
      _$IbCommentFromJson(json);

  Map<String, dynamic> toJson() => _$IbCommentToJson(this);

  @override
  String toString() {
    return 'IbComment{commentId: $commentId, uid: $uid, isAnonymous: '
        '$isAnonymous, content: $content, type: $type, '
        'replies: $replies, timestamp: $timestamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbComment &&
          runtimeType == other.runtimeType &&
          commentId == other.commentId;

  @override
  int get hashCode => commentId.hashCode;
}
