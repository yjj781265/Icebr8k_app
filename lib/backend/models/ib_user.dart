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
  int? joinTimeInMs;
  int? birthdateInMs;
  int answeredSize;
  int askedSize;
  bool isOnline;
  String coverPhotoUrl;
  String bio;
  String voiceMemoUrl;
  List<String> roles;
  List<IbEmoPic> emoPics;

  static String kAdminRole = 'admin';
  static String kUserRole = 'user';
  static String kUserStatusBanned = 'banned';
  static String kUserStatusApproved = 'approved';
  static String kUserStatusPending = 'pending';
  static List<String> kGenders = ['Male', 'Female', 'Other'];

  IbUser({
    this.avatarUrl = '',
    this.coverPhotoUrl = '',
    this.loginTimeInMs = -1,
    this.joinTimeInMs = -1,
    this.birthdateInMs = -1,
    this.banedEndTimeInMs = -1,
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
    this.answeredSize = 0,
    this.askedSize = 0,
    required this.id,
    this.username = '',
  });

  factory IbUser.fromJson(Map<String, dynamic> json) => _$IbUserFromJson(json);
  Map<String, dynamic> toJson() => _$IbUserToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
