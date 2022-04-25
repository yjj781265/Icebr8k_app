import 'package:json_annotation/json_annotation.dart';

part 'ib_comment.g.dart';

/// reply Id is the id for the reply of a comment
/// notifyUid is the Uid of a comment reply to(for push notification)
@JsonSerializable(explicitToJson: true)
class IbComment {
  String? parentId;
  String notifyUid;
  String commentId;
  String questionId;
  String uid;
  int likes;
  List<IbComment> replies;
  String content;
  String type;
  bool isEdited;
  dynamic timestamp;

  static const String kCommentTypeText = 'text';
  static const String kCommentTypePic = 'pic';
  static const String kCommentTypeAudio = 'audio';

  IbComment({
    required this.commentId,
    required this.uid,
    required this.questionId,
    required this.notifyUid,
    this.isEdited = false,
    this.likes = 0,
    this.replies = const [],
    this.parentId,
    required this.content,
    required this.type,
    this.timestamp,
  });

  factory IbComment.fromJson(Map<String, dynamic> json) =>
      _$IbCommentFromJson(json);

  Map<String, dynamic> toJson() => _$IbCommentToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbComment &&
          runtimeType == other.runtimeType &&
          parentId == other.parentId &&
          notifyUid == other.notifyUid &&
          commentId == other.commentId &&
          questionId == other.questionId &&
          uid == other.uid &&
          likes == other.likes &&
          replies == other.replies &&
          content == other.content &&
          type == other.type &&
          isEdited == other.isEdited &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      parentId.hashCode ^
      notifyUid.hashCode ^
      commentId.hashCode ^
      questionId.hashCode ^
      uid.hashCode ^
      likes.hashCode ^
      replies.hashCode ^
      content.hashCode ^
      type.hashCode ^
      isEdited.hashCode ^
      timestamp.hashCode;
}
