// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbChat _$IbChatFromJson(Map<String, dynamic> json) => IbChat(
      chatId: json['chatId'] as String,
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      createdAtTimestamp: json['createdAtTimestamp'],
      isCircle: json['isCircle'] as bool? ?? false,
      isPublicCircle: json['isPublicCircle'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      welcomeMsg: json['welcomeMsg'] as String? ?? '',
      memberUids: (json['memberUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mutedUids: (json['mutedUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      memberCount: json['memberCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] == null
          ? null
          : IbMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
      isTypingUids: (json['isTypingUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      messageCount: json['messageCount'] as int? ?? 0,
    );

Map<String, dynamic> _$IbChatToJson(IbChat instance) => <String, dynamic>{
      'chatId': instance.chatId,
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'description': instance.description,
      'welcomeMsg': instance.welcomeMsg,
      'createdAtTimestamp': instance.createdAtTimestamp,
      'memberUids': instance.memberUids,
      'mutedUids': instance.mutedUids,
      'isCircle': instance.isCircle,
      'isPublicCircle': instance.isPublicCircle,
      'memberCount': instance.memberCount,
      'lastMessage': instance.lastMessage?.toJson(),
      'isTypingUids': instance.isTypingUids,
      'messageCount': instance.messageCount,
    };
