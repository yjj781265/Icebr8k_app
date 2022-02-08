// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbUser _$IbUserFromJson(Map<String, dynamic> json) => IbUser(
      avatarUrl: json['avatarUrl'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String? ?? '',
      loginTimeInMs: json['loginTimeInMs'] as int? ?? -1,
      joinTime: json['joinTime'],
      birthdateInMs: json['birthdateInMs'] as int? ?? -1,
      banedEndTimeInMs: json['banedEndTimeInMs'] as int? ?? -1,
      isOnline: json['isOnline'] as bool? ?? false,
      gender: json['gender'] as String? ?? '',
      status: json['status'] as String? ?? '',
      voiceMemoUrl: json['voiceMemoUrl'] as String? ?? '',
      emoPics: (json['emoPics'] as List<dynamic>?)
              ?.map((e) => IbEmoPic.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const ['user'],
      bio: json['bio'] as String? ?? '',
      fName: json['fName'] as String? ?? '',
      lName: json['lName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      answeredSize: json['answeredSize'] as int? ?? 0,
      askedSize: json['askedSize'] as int? ?? 0,
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
    );

Map<String, dynamic> _$IbUserToJson(IbUser instance) => <String, dynamic>{
      'id': instance.id,
      'fName': instance.fName,
      'lName': instance.lName,
      'email': instance.email,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'gender': instance.gender,
      'status': instance.status,
      'banedEndTimeInMs': instance.banedEndTimeInMs,
      'loginTimeInMs': instance.loginTimeInMs,
      'joinTime': instance.joinTime,
      'birthdateInMs': instance.birthdateInMs,
      'answeredSize': instance.answeredSize,
      'askedSize': instance.askedSize,
      'isOnline': instance.isOnline,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'bio': instance.bio,
      'voiceMemoUrl': instance.voiceMemoUrl,
      'roles': instance.roles,
      'emoPics': instance.emoPics.map((e) => e.toJson()).toList(),
    };
