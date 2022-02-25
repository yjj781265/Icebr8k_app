import 'package:json_annotation/json_annotation.dart';

part 'ib_comment.g.dart';

/// reply Id is for the reply of a comment
@JsonSerializable(explicitToJson: true)
class IbComment {
  String? replyId;
  String commentId;
  String questionId;
  String uid;
  int likes;
  int replies;
  bool isAnonymous;
  String content;
  String type;
  int timestampInMs;

  static const String kCommentTypeText = 'text';
  static const String kCommentTypePic = 'pic';
  static const String kCommentTypeAudio = 'audio';

  IbComment({
    required this.commentId,
    required this.uid,
    required this.questionId,
    this.isAnonymous = false,
    this.likes = 0,
    this.replies = 0,
    this.replyId,
    required this.content,
    required this.type,
    required this.timestampInMs,
  });

  factory IbComment.fromJson(Map<String, dynamic> json) =>
      _$IbCommentFromJson(json);

  Map<String, dynamic> toJson() => _$IbCommentToJson(this);

  @override
  String toString() {
    return 'IbComment{commentId: $commentId, uid: $uid, isAnonymous: '
        '$isAnonymous, content: $content, type: $type, '
        'replies: $replies, timestampInMs: $timestampInMs}';
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
