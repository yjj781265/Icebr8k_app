import 'package:json_annotation/json_annotation.dart';

part 'ib_settings.g.dart';

@JsonSerializable()
class IbSettings {
  bool pollCommentN;
  bool pollLikesN;
  bool pollCommentLikesN;
  bool pollVoteN;
  bool circleInviteN;
  bool circleRequestN;
  bool friendRequestN;

  IbSettings({
    this.pollCommentN = true,
    this.pollLikesN = true,
    this.pollCommentLikesN = true,
    this.pollVoteN = true,
    this.friendRequestN = true,
    this.circleRequestN = true,
    this.circleInviteN = true,
  });

  factory IbSettings.fromJson(Map<String, dynamic> json) =>
      _$IbSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$IbSettingsToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbSettings &&
          runtimeType == other.runtimeType &&
          pollCommentN == other.pollCommentN &&
          pollLikesN == other.pollLikesN &&
          pollCommentLikesN == other.pollCommentLikesN &&
          pollVoteN == other.pollVoteN &&
          circleInviteN == other.circleInviteN &&
          circleRequestN == other.circleRequestN;

  @override
  int get hashCode =>
      pollCommentN.hashCode ^
      pollLikesN.hashCode ^
      pollCommentLikesN.hashCode ^
      pollVoteN.hashCode ^
      circleInviteN.hashCode ^
      circleRequestN.hashCode;
}
