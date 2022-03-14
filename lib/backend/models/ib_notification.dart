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
  int timestampInMs;
  String senderId;
  String recipientId;

  static const String kFriendRequest = 'friend_request';
  static const String kNormal = 'normal';

  IbNotification(
      {required this.id,
      required this.title,
      required this.subtitle,
      this.avatarUrl,
      this.attachmentUrl,
      required this.type,
      required this.timestampInMs,
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
          timestampInMs == other.timestampInMs &&
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
      timestampInMs.hashCode ^
      senderId.hashCode ^
      recipientId.hashCode;

  @override
  String toString() {
    return 'IbNotification{id: $id, title: $title, subtitle: $subtitle, '
        'url: $avatarUrl, attachmentUrl: $attachmentUrl, '
        'type: $type, timestampInMs: $timestampInMs, '
        'senderId: $senderId, recipientId: $recipientId}';
  }
}
