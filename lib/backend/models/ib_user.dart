import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_user.g.dart';

@JsonSerializable(explicitToJson: true)
class IbUser {
  String id;
  String fName;
  String lName;
  String email;
  String username;
  String avatarUrl;
  String gender;
  String status;
  int banedEndTimeInMs;
  int? loginTimeInMs;

  /// covert to FireStore Timestamp
  dynamic joinTime;
  int? birthdateInMs;
  int answeredCount;
  int askedCount;
  List<String> friendUids;
  List<String> blockedFriendUids;
  int notificationCount;
  String profilePrivacy;
  bool isOnline;
  String coverPhotoUrl;
  String bio;
  String voiceMemoUrl;
  List<String> roles;
  List<IbEmoPic> emoPics;

  static String kAdminRole = 'admin';
  static String kUserRole = 'user';
  static const String kUserStatusRejected = 'rejected';
  static const String kUserStatusBanned = 'banned';
  static const String kUserStatusApproved = 'approved';
  static const String kUserPrivacyPublic = 'public';
  static const String kUserPrivacyPrivate = 'private';
  static const String kUserPrivacyFrOnly = 'friends_only';
  static const String kUserStatusPending = 'pending';
  static List<String> kGenders = ['🧑 Male', '👩 Female', '🌈 Other'];

  IbUser({
    this.avatarUrl = '',
    this.coverPhotoUrl = '',
    this.loginTimeInMs = -1,
    this.profilePrivacy = 'public',
    this.birthdateInMs = -1,
    this.banedEndTimeInMs = -1,
    this.friendUids = const [],
    this.blockedFriendUids = const [],
    this.notificationCount = 0,
    this.isOnline = false,
    this.gender = '',
    this.status = '',
    this.voiceMemoUrl = '',
    this.emoPics = const [],
    this.roles = const ['user'],
    this.bio = '',
    this.fName = '',
    this.lName = '',
    this.email = '',
    this.answeredCount = 0,
    this.askedCount = 0,
    required this.id,
    this.username = '',
  });

  factory IbUser.fromJson(Map<String, dynamic> json) => _$IbUserFromJson(json);
  Map<String, dynamic> toJson() => _$IbUserToJson(this);

  @override
  String toString() {
    return 'IbUser{id: $id, fName: $fName, lName: $lName, email: $email, username: $username, avatarUrl: $avatarUrl, gender: $gender, status: $status, banedEndTimeInMs: $banedEndTimeInMs, loginTimeInMs: $loginTimeInMs, joinTime: $joinTime, birthdateInMs: $birthdateInMs, answeredCount: $answeredCount, askedCount: $askedCount, friendUids: $friendUids, blockedFriendUids: $blockedFriendUids, notificationCount: $notificationCount, profilePrivacy: $profilePrivacy, isOnline: $isOnline, coverPhotoUrl: $coverPhotoUrl, bio: $bio, voiceMemoUrl: $voiceMemoUrl, roles: $roles, emoPics: $emoPics}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fName == other.fName &&
          lName == other.lName &&
          email == other.email &&
          username == other.username &&
          avatarUrl == other.avatarUrl &&
          gender == other.gender &&
          status == other.status &&
          banedEndTimeInMs == other.banedEndTimeInMs &&
          loginTimeInMs == other.loginTimeInMs &&
          joinTime == other.joinTime &&
          birthdateInMs == other.birthdateInMs &&
          answeredCount == other.answeredCount &&
          askedCount == other.askedCount &&
          friendUids == other.friendUids &&
          blockedFriendUids == other.blockedFriendUids &&
          notificationCount == other.notificationCount &&
          profilePrivacy == other.profilePrivacy &&
          isOnline == other.isOnline &&
          coverPhotoUrl == other.coverPhotoUrl &&
          bio == other.bio &&
          voiceMemoUrl == other.voiceMemoUrl &&
          roles == other.roles &&
          emoPics == other.emoPics;

  @override
  int get hashCode =>
      id.hashCode ^
      fName.hashCode ^
      lName.hashCode ^
      email.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode ^
      gender.hashCode ^
      status.hashCode ^
      banedEndTimeInMs.hashCode ^
      loginTimeInMs.hashCode ^
      joinTime.hashCode ^
      birthdateInMs.hashCode ^
      answeredCount.hashCode ^
      askedCount.hashCode ^
      friendUids.hashCode ^
      blockedFriendUids.hashCode ^
      notificationCount.hashCode ^
      profilePrivacy.hashCode ^
      isOnline.hashCode ^
      coverPhotoUrl.hashCode ^
      bio.hashCode ^
      voiceMemoUrl.hashCode ^
      roles.hashCode ^
      emoPics.hashCode;
}
