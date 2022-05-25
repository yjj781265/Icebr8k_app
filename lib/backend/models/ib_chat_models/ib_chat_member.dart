import 'package:json_annotation/json_annotation.dart';

part 'ib_chat_member.g.dart';

@JsonSerializable()
class IbChatMember {
  String chatId;
  String uid;
  String role;
  dynamic joinTimestamp;
  static const String kRoleLeader = 'leader';
  static const String kRoleMember = 'member';
  static const String kRoleAssistant = 'assistant';

  IbChatMember(
      {required this.chatId,
      required this.uid,
      required this.role,
      this.joinTimestamp});

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
