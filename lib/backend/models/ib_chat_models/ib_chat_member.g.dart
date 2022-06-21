// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_chat_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbChatMember _$IbChatMemberFromJson(Map<String, dynamic> json) => IbChatMember(
      chatId: json['chatId'] as String,
      uid: json['uid'] as String,
      role: json['role'] as String,
      joinTimestamp: json['joinTimestamp'],
    );

Map<String, dynamic> _$IbChatMemberToJson(IbChatMember instance) =>
    <String, dynamic>{
      'chatId': instance.chatId,
      'uid': instance.uid,
      'role': instance.role,
      'joinTimestamp': instance.joinTimestamp,
    };
