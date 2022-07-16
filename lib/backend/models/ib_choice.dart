import 'package:json_annotation/json_annotation.dart';

part 'ib_choice.g.dart';

@JsonSerializable()
class IbChoice {
  String? content;
  String? url;
  String choiceId;

  IbChoice({this.content, this.url, required this.choiceId})
      : assert(content != null || url != null);

  factory IbChoice.fromJson(Map<String, dynamic> json) =>
      _$IbChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$IbChoiceToJson(this);

  @override
  String toString() {
    return 'IbChoice{content: $content, url: $url, choiceId: $choiceId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbChoice &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          url == other.url &&
          choiceId == other.choiceId;

  @override
  int get hashCode => content.hashCode ^ url.hashCode ^ choiceId.hashCode;
}
