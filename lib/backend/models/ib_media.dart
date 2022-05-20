import 'package:json_annotation/json_annotation.dart';

part 'ib_media.g.dart';

@JsonSerializable()
class IbMedia {
  String url;
  String id;
  String type;
  String description;

  static const String kAudioType = 'audio';
  static const String kVideoType = 'video';
  static const String kPicType = 'pic';

  IbMedia(
      {required this.url,
      required this.id,
      required this.type,
      this.description = ''});

  factory IbMedia.fromJson(Map<String, dynamic> json) =>
      _$IbMediaFromJson(json);
  Map<String, dynamic> toJson() => _$IbMediaToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbMedia &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          id == other.id &&
          type == other.type &&
          description == other.description;

  @override
  int get hashCode =>
      url.hashCode ^ id.hashCode ^ type.hashCode ^ description.hashCode;
}
