// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbMessage _$IbMessageFromJson(Map<String, dynamic> json) => IbMessage(
      messageId: json['messageId'] as String,
      content: json['content'] as String,
      senderUid: json['senderUid'] as String,
      messageType: json['messageType'] as String,
      chatRoomId: json['chatRoomId'] as String,
      edited: json['edited'] as bool? ?? false,
      mentionUids: (json['mentionUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      extra:
          (json['extra'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      timestamp: json['timestamp'],
      readUids:
          (json['readUids'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$IbMessageToJson(IbMessage instance) => <String, dynamic>{
      'messageId': instance.messageId,
      'content': instance.content,
      'senderUid': instance.senderUid,
      'edited': instance.edited,
      'mentionUids': instance.mentionUids,
      'messageType': instance.messageType,
      'chatRoomId': instance.chatRoomId,
      'timestamp': instance.timestamp,
      'extra': instance.extra,
      'readUids': instance.readUids,
    };
