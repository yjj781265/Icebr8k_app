// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbNotification _$IbNotificationFromJson(Map<String, dynamic> json) =>
    IbNotification(
      id: json['id'] as String,
      body: json['body'] as String,
      url: json['url'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String,
      timestamp: json['timestamp'],
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
    );

Map<String, dynamic> _$IbNotificationToJson(IbNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'url': instance.url,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'isRead': instance.isRead,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
    };
