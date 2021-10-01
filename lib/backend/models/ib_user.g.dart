// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbUser _$IbUserFromJson(Map<String, dynamic> json) => IbUser(
      avatarUrl: json['avatarUrl'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String? ?? '',
      loginTimeInMs: json['loginTimeInMs'] as int? ?? 0,
      joinTimeInMs: json['joinTimeInMs'] as int? ?? 0,
      birthdateInMs: json['birthdateInMs'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
    )
      ..answeredSize = json['answeredSize'] as int?
      ..askedSize = json['askedSize'] as int?;

Map<String, dynamic> _$IbUserToJson(IbUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'loginTimeInMs': instance.loginTimeInMs,
      'joinTimeInMs': instance.joinTimeInMs,
      'birthdateInMs': instance.birthdateInMs,
      'answeredSize': instance.answeredSize,
      'askedSize': instance.askedSize,
      'isOnline': instance.isOnline,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'description': instance.description,
    };
