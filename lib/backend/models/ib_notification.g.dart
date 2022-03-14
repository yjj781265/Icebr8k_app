// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbNotification _$IbNotificationFromJson(Map<String, dynamic> json) =>
    IbNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String,
      timestampInMs: json['timestampInMs'] as int,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
    );

Map<String, dynamic> _$IbNotificationToJson(IbNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'avatarUrl': instance.avatarUrl,
      'attachmentUrl': instance.attachmentUrl,
      'type': instance.type,
      'timestampInMs': instance.timestampInMs,
      'isRead': instance.isRead,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
    };
