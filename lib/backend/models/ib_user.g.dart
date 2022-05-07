// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbUser _$IbUserFromJson(Map<String, dynamic> json) => IbUser(
      avatarUrl: json['avatarUrl'] as String? ?? '',
      coverPhotoUrl: json['coverPhotoUrl'] as String? ?? '',
      loginTimestamp: json['loginTimestamp'] ?? -1,
      profilePrivacy: json['profilePrivacy'] as String? ?? 'public',
      birthdateInMs: json['birthdateInMs'] as int? ?? -1,
      banedEndTimeInMs: json['banedEndTimeInMs'] as int? ?? -1,
      friendUids: (json['friendUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      blockedFriendUids: (json['blockedFriendUids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notificationCount: json['notificationCount'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? false,
      geoPoint: json['geoPoint'],
      lastLocationTimestampInMs:
          json['lastLocationTimestampInMs'] as int? ?? -1,
      gender: json['gender'] as String? ?? '',
      status: json['status'] as String? ?? '',
      voiceMemoUrl: json['voiceMemoUrl'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
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
    )..joinTime = json['joinTime'];

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
      'geoPoint': instance.geoPoint,
      'lastLocationTimestampInMs': instance.lastLocationTimestampInMs,
      'loginTimestamp': instance.loginTimestamp,
      'joinTime': instance.joinTime,
      'birthdateInMs': instance.birthdateInMs,
      'answeredCount': instance.answeredCount,
      'askedCount': instance.askedCount,
      'friendUids': instance.friendUids,
      'blockedFriendUids': instance.blockedFriendUids,
      'notificationCount': instance.notificationCount,
      'profilePrivacy': instance.profilePrivacy,
      'isOnline': instance.isOnline,
      'coverPhotoUrl': instance.coverPhotoUrl,
      'bio': instance.bio,
      'voiceMemoUrl': instance.voiceMemoUrl,
      'roles': instance.roles,
      'tags': instance.tags,
      'emoPics': instance.emoPics.map((e) => e.toJson()).toList(),
    };
