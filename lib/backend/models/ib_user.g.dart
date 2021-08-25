// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbUser _$IbUserFromJson(Map<String, dynamic> json) {
  return IbUser(
    avatarUrl: json['avatarUrl'] as String,
    coverPhotoUrl: json['coverPhotoUrl'] as String,
    loginTimeInMs: json['loginTimeInMs'] as int,
    joinTimeInMs: json['joinTimeInMs'] as int,
    birthdateInMs: json['birthdateInMs'] as int,
    isOnline: json['isOnline'] as bool,
    description: json['description'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    id: json['id'] as String,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$IbUserToJson(IbUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'loginTimeInMs': instance.loginTimeInMs,
      'joinTimeInMs': instance.joinTimeInMs,
      'birthdateInMs': instance.birthdateInMs,
      'isOnline': instance.isOnline,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'description': instance.description,
    };
