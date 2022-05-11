import 'package:json_annotation/json_annotation.dart';

part 'ib_notification.g.dart';

@JsonSerializable()
class IbNotification {
  String id;
  String title;
  String subtitle;
  String? avatarUrl;

  /// can be use for doc id
  String? attachmentUrl;
  String type;
  dynamic timestamp;
  bool isRead;
  String senderId;
  String recipientId;

  static const String kFriendRequest = 'friend_request';

  /// will go open the app if it is in background
  static const String kNormal = 'normal';
  static const String kCircleInvite = 'circle_invite';
  static const String kChatMessage = 'chat_message';
  static const String kComment = 'comment';
  static const String kNewVote = 'new_vote';
  static const String kNewLikeQuestion = 'new_like_question';
  static const String kNewLikeComment = 'new_like_comment';

  IbNotification(
      {required this.id,
      required this.title,
      required this.subtitle,
      this.avatarUrl,
      this.attachmentUrl,
      this.isRead = false,
      required this.type,
      this.timestamp,
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
          title == other.title &&
          subtitle == other.subtitle &&
          avatarUrl == other.avatarUrl &&
          attachmentUrl == other.attachmentUrl &&
          type == other.type &&
          timestamp == other.timestamp &&
          senderId == other.senderId &&
          recipientId == other.recipientId;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      avatarUrl.hashCode ^
      attachmentUrl.hashCode ^
      type.hashCode ^
      timestamp.hashCode ^
      senderId.hashCode ^
      recipientId.hashCode;

  @override
  String toString() {
    return 'IbNotification{id: $id, title: $title, subtitle: $subtitle, '
        'url: $avatarUrl, attachmentUrl: $attachmentUrl, '
        'type: $type, timestamp: $timestamp, '
        'senderId: $senderId, recipientId: $recipientId}';
  }
}
