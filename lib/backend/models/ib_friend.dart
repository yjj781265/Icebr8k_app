import 'package:json_annotation/json_annotation.dart';

part 'ib_friend.g.dart';

@JsonSerializable()
class IbFriend {
  String friendUid;
  String status;
  int timestampInMs;

  static const String kFriendshipStatusPending = 'pending';
  static const String kFriendshipStatusAccepted = 'accepted';
  static const String kFriendshipStatusBlocked = 'blocked';

  IbFriend({
    required this.friendUid,
    this.status = '',
    this.timestampInMs = 0,
  });

  factory IbFriend.fromJson(Map<String, dynamic> json) =>
      _$IbFriendFromJson(json);
  Map<String, dynamic> toJson() => _$IbFriendToJson(this);

  @override
  String toString() {
    return 'IbFriend{friendUid: $friendUid, '
        'status: $status, timestampInMs: $timestampInMs}';
  }
}
