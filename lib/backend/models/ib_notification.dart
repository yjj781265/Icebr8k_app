import 'package:json_annotation/json_annotation.dart';

part 'ib_notification.g.dart';

@JsonSerializable()
class IbNotification {
  String id;
  String body;

  /// can be use for doc id
  String url;
  String type;
  dynamic timestamp;
  bool isRead;
  String senderId;
  String recipientId;

  static const String kFriendRequest = 'friend_request';
  static const String kFriendAccepted = 'friend_accepted';
  static const String kChat = 'chat';
  static const String kPoll = 'poll';
  static const String kProfileLiked = 'profile_liked';
  static const String kCircleInvite = 'circle_invite';
  static const String kCircleRequest = 'circle_request';
  static const String kPollComment = 'poll_comment';
  static const String kPollCommentReply = 'poll_comment_reply';
  static const String kNewVote = 'new_vote';
  static const String kPollLike = 'new_like_poll';
  static const String kPollCommentLike = 'new_like_comment';

  IbNotification(
      {required this.id,
      required this.body,
      this.url = '',
      this.isRead = false,
      required this.type,
      required this.timestamp,
      required this.senderId,
      required this.recipientId});

  factory IbNotification.fromJson(Map<String, dynamic> json) =>
      _$IbNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$IbNotificationToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          body == other.body &&
          url == other.url &&
          type == other.type &&
          timestamp == other.timestamp &&
          isRead == other.isRead &&
          senderId == other.senderId &&
          recipientId == other.recipientId;

  @override
  int get hashCode =>
      id.hashCode ^
      body.hashCode ^
      url.hashCode ^
      type.hashCode ^
      timestamp.hashCode ^
      isRead.hashCode ^
      senderId.hashCode ^
      recipientId.hashCode;

  @override
  String toString() {
    return 'IbNotification{id: $id, body: $body, url: $url, type: $type, '
        'timestamp: $timestamp, isRead: $isRead, '
        'senderId: $senderId, recipientId: $recipientId}';
  }
}
