import 'package:json_annotation/json_annotation.dart';

part 'ib_message.g.dart';

@JsonSerializable()
class IbMessage {
  String messageId;
  String content;
  String senderUid;
  bool edited;
  List<String> mentionUids;
  String messageType;
  String chatRoomId;
  dynamic timestamp;
  List<String> extra;
  List<String> readUids;

  static const String kMessageTypeText = 'text';
  static const String kMessageTypePic = 'pic';
  static const String kMessageTypeAudio = 'audio';
  static const String kMessageTypePoll = 'poll';
  static const String kMessageTypeIcebreaker = 'icebreaker';
  static const String kMessageTypeLoadMore = 'loadMore';
  static const String kMessageTypeAnnouncement = 'announcement';

  IbMessage(
      {required this.messageId,
      required this.content,
      required this.senderUid,
      required this.messageType,
      required this.chatRoomId,
      this.edited = false,
      this.mentionUids = const <String>[],
      this.extra = const <String>[],
      this.timestamp,
      required this.readUids});

  factory IbMessage.fromJson(Map<String, dynamic> json) =>
      _$IbMessageFromJson(json);

  Map<String, dynamic> toJson() => _$IbMessageToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbMessage &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          content == other.content &&
          messageType == other.messageType &&
          chatRoomId == other.chatRoomId;

  @override
  int get hashCode =>
      messageId.hashCode ^
      content.hashCode ^
      messageType.hashCode ^
      chatRoomId.hashCode;
}
