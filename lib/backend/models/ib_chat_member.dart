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
}
