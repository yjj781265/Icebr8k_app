import 'package:icebr8k/backend/models/ib_chat_models/ib_circle_join_request.dart';
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
  List<String> blackListUids;
  List<String> mentionOnlyUids;
  List<IbCircleJoinRequest> joinRequests;
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
      this.blackListUids = const [],
      this.memberUids = const [],
      this.mentionOnlyUids = const [],
      this.mutedUids = const [],
      this.joinRequests = const [],
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
          welcomeMsg == other.welcomeMsg &&
          createdAtTimestamp == other.createdAtTimestamp &&
          memberUids == other.memberUids &&
          mutedUids == other.mutedUids &&
          blackListUids == other.blackListUids &&
          mentionOnlyUids == other.mentionOnlyUids &&
          joinRequests == other.joinRequests &&
          isCircle == other.isCircle &&
          isPublicCircle == other.isPublicCircle &&
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
      welcomeMsg.hashCode ^
      createdAtTimestamp.hashCode ^
      memberUids.hashCode ^
      mutedUids.hashCode ^
      blackListUids.hashCode ^
      mentionOnlyUids.hashCode ^
      joinRequests.hashCode ^
      isCircle.hashCode ^
      isPublicCircle.hashCode ^
      memberCount.hashCode ^
      lastMessage.hashCode ^
      isTypingUids.hashCode ^
      messageCount.hashCode;

  @override
  String toString() {
    return 'IbChat{chatId: $chatId, name: $name, photoUrl: $photoUrl, memberCount: $memberCount}';
  }
}
