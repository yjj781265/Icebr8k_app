import 'package:json_annotation/json_annotation.dart';

part 'ib_notification.g.dart';

@JsonSerializable()
class IbNotification {
  String id;
  String title;
  String subtitle;
  String? avatarUrl;
  String? attachmentUrl;
  String type;
  dynamic timestamp;
  bool isRead;
  String senderId;
  String recipientId;

  static const String kFriendRequest = 'friend_request';
  static const String kNormal = 'normal';
  static const String kGroupInvite = 'group_invite';
  static const String kGroupRequest = 'group_request';

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
