import 'package:json_annotation/json_annotation.dart';

part 'ib_chat_member.g.dart';

@JsonSerializable()
class IbChatMember {
  String uid;
  String role;
  static const String kRoleLeader = 'leader';
  static const String kRoleMember = 'member';

  IbChatMember(this.uid, this.role);

  factory IbChatMember.fromJson(Map<String, dynamic> json) =>
      _$IbChatMemberFromJson(json);

  Map<String, dynamic> toJson() => _$IbChatMemberToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbChatMember &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}
