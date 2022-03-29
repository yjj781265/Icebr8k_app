import 'package:json_annotation/json_annotation.dart';

import 'ib_message.dart';

part 'ib_chat.g.dart';

@JsonSerializable(explicitToJson: true)
class IbChat {
  String chatId;
  String name;
  String photoUrl;
  String description;
  String welcomeMsg;
  dynamic createdAtTimestamp;
  List<String> memberUids;
  List<String> mutedUids;
  bool isCircle;
  bool isPublicCircle;
  int memberCount;
  IbMessage? lastMessage;
  List<String> isTypingUids;
  int messageCount;

  IbChat(
      {required this.chatId,
      this.name = '',
      this.photoUrl = '',
      this.createdAtTimestamp,
      this.isCircle = false,
      this.isPublicCircle = false,
      this.description = '',
      this.welcomeMsg = '',
      this.memberUids = const [],
      this.mutedUids = const [],
      this.memberCount = 0,
      this.lastMessage,
      this.isTypingUids = const [],
      this.messageCount = 0});

  factory IbChat.fromJson(Map<String, dynamic> json) => _$IbChatFromJson(json);

  Map<String, dynamic> toJson() => _$IbChatToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbChat &&
          runtimeType == other.runtimeType &&
          chatId == other.chatId &&
          name == other.name &&
          photoUrl == other.photoUrl &&
          description == other.description &&
          memberUids == other.memberUids &&
          mutedUids == other.mutedUids &&
          memberCount == other.memberCount &&
          lastMessage == other.lastMessage &&
          isTypingUids == other.isTypingUids &&
          messageCount == other.messageCount;

  @override
  int get hashCode =>
      chatId.hashCode ^
      name.hashCode ^
      photoUrl.hashCode ^
      description.hashCode ^
      memberUids.hashCode ^
      mutedUids.hashCode ^
      memberCount.hashCode ^
      lastMessage.hashCode ^
      isTypingUids.hashCode ^
      messageCount.hashCode;

  @override
  String toString() {
    return 'IbChat{chatId: $chatId, name: $name, photoUrl: $photoUrl, memberCount: $memberCount}';
  }
}
