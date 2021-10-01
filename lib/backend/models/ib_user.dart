import 'package:json_annotation/json_annotation.dart';

part 'ib_user.g.dart';

@JsonSerializable()
class IbUser {
  String id;
  String name;
  String email;
  String username;
  String avatarUrl;
  int loginTimeInMs;
  int joinTimeInMs;
  int birthdateInMs;
  int? answeredSize;
  int? askedSize;
  bool isOnline;
  String coverPhotoUrl;
  String description;

  IbUser({
    this.avatarUrl = '',
    this.coverPhotoUrl = '',
    this.loginTimeInMs = 0,
    this.joinTimeInMs = 0,
    this.birthdateInMs = 0,
    this.isOnline = false,
    this.description = '',
    this.name = '',
    this.email = '',
    required this.id,
    this.username = '',
  });

  factory IbUser.fromJson(Map<String, dynamic> json) => _$IbUserFromJson(json);
  Map<String, dynamic> toJson() => _$IbUserToJson(this);

  @override
  String toString() {
    return 'IbUser{id: $id, name: $name, email: $email, username: $username, '
        'avatarUrl: $avatarUrl, loginTimeInMs: $loginTimeInMs, joinTimeInMs: '
        '$joinTimeInMs, birthdateInMs: $birthdateInMs, isOnline: $isOnline, '
        'description: $description}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
