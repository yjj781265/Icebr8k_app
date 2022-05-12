// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ib_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IbSettings _$IbSettingsFromJson(Map<String, dynamic> json) => IbSettings(
      pollCommentN: json['pollCommentN'] as bool? ?? true,
      pollLikesN: json['pollLikesN'] as bool? ?? true,
      pollCommentLikesN: json['pollCommentLikesN'] as bool? ?? true,
      pollVoteN: json['pollVoteN'] as bool? ?? true,
      circleRequestN: json['circleRequestN'] as bool? ?? true,
      circleInviteN: json['circleInviteN'] as bool? ?? true,
    );

Map<String, dynamic> _$IbSettingsToJson(IbSettings instance) =>
    <String, dynamic>{
      'pollCommentN': instance.pollCommentN,
      'pollLikesN': instance.pollLikesN,
      'pollCommentLikesN': instance.pollCommentLikesN,
      'pollVoteN': instance.pollVoteN,
      'circleInviteN': instance.circleInviteN,
      'circleRequestN': instance.circleRequestN,
    };
