// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbFriend _$IbFriendFromJson(Map<String, dynamic> json) => IbFriend(
      friendUid: json['friendUid'] as String,
      status: json['status'] as String? ?? '',
      timestampInMs: json['timestampInMs'] as int? ?? 0,
    );

Map<String, dynamic> _$IbFriendToJson(IbFriend instance) => <String, dynamic>{
      'friendUid': instance.friendUid,
      'status': instance.status,
      'timestampInMs': instance.timestampInMs,
    };
