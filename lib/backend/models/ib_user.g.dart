// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbUser _$IbUserFromJson(Map<String, dynamic> json) => IbUser(
      avatarUrl: json['avatarUrl'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String? ?? '',
      loginTimeInMs: json['loginTimeInMs'] as int? ?? -1,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFriendsOnly: json['isFriendsOnly'] as bool? ?? false,
      joinTime: json['joinTime'],
      birthdateInMs: json['birthdateInMs'] as int? ?? -1,
      banedEndTimeInMs: json['banedEndTimeInMs'] as int? ?? -1,
      friendCount: json['friendCount'] as int? ?? 0,
      notificationCount: json['notificationCount'] as int? ?? 0,
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
      answeredCount: json['answeredCount'] as int? ?? 0,
      askedCount: json['askedCount'] as int? ?? 0,
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
      'answeredCount': instance.answeredCount,
      'askedCount': instance.askedCount,
      'friendCount': instance.friendCount,
      'notificationCount': instance.notificationCount,
      'isOnline': instance.isOnline,
      'isPrivate': instance.isPrivate,
      'isFriendsOnly': instance.isFriendsOnly,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'bio': instance.bio,
      'voiceMemoUrl': instance.voiceMemoUrl,
      'roles': instance.roles,
      'emoPics': instance.emoPics.map((e) => e.toJson()).toList(),
    };
