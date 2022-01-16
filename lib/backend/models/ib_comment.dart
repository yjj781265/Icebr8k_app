import 'package:json_annotation/json_annotation.dart';

part 'ib_comment.g.dart';

@JsonSerializable(explicitToJson: true)
class IbComment {
  String commentId;
  String questionId;
  String uid;
  int likes;
  bool isAnonymous;
  String content;
  String type;
  List<IbComment> replies;
  int timestampInMs;

  static const String kCommentTypeText = 'text';
  static const String kCommentTypePic = 'pic';
  static const String kCommentTypeAudio = 'audio';

  IbComment(
      {required this.commentId,
      required this.uid,
      required this.questionId,
      this.isAnonymous = false,
      this.likes = 0,
      required this.content,
      required this.type,
      required this.timestampInMs,
      this.replies = const <IbComment>[]});

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
