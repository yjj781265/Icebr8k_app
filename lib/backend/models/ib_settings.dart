import 'package:json_annotation/json_annotation.dart';

part 'ib_settings.g.dart';

@JsonSerializable()
class IbSettings {
  bool pollCommentN;
  bool pollLikesN;
  bool pollCommentLikesN;
  bool pollVoteN;
  bool pollNewN;
  bool profileLikesN;
  bool circleInviteN;
  bool circleRequestN;
  bool friendRequestN;
  bool pollCommentReplyN;

  // poll specific
  bool pollExpandedByDefault;
  bool voteAnonymousByDefault;

  IbSettings({
    this.pollCommentN = true,
    this.pollLikesN = true,
    this.pollCommentLikesN = true,
    this.pollVoteN = true,
    this.pollNewN = true,
    this.friendRequestN = true,
    this.circleRequestN = true,
    this.profileLikesN = true,
    this.circleInviteN = true,
    this.pollCommentReplyN = true,
    this.pollExpandedByDefault = false,
    this.voteAnonymousByDefault = false,
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
          pollNewN == other.pollNewN &&
          profileLikesN == other.profileLikesN &&
          circleInviteN == other.circleInviteN &&
          circleRequestN == other.circleRequestN &&
          friendRequestN == other.friendRequestN &&
          pollCommentReplyN == other.pollCommentReplyN &&
          pollExpandedByDefault == other.pollExpandedByDefault &&
          voteAnonymousByDefault == other.voteAnonymousByDefault;

  @override
  int get hashCode =>
      pollCommentN.hashCode ^
      pollLikesN.hashCode ^
      pollCommentLikesN.hashCode ^
      pollVoteN.hashCode ^
      pollNewN.hashCode ^
      profileLikesN.hashCode ^
      circleInviteN.hashCode ^
      circleRequestN.hashCode ^
      friendRequestN.hashCode ^
      pollCommentReplyN.hashCode ^
      pollExpandedByDefault.hashCode ^
      voteAnonymousByDefault.hashCode;
}
