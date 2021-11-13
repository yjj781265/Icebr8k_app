import 'package:json_annotation/json_annotation.dart';

part 'ib_choice.g.dart';

@JsonSerializable()
class IbChoice {
  String? content;
  String? url;
  int count;
  String choiceId;

  IbChoice({this.content, this.url, this.count = 0, required this.choiceId})
      : assert(content != null || url != null);

  factory IbChoice.fromJson(Map<String, dynamic> json) =>
      _$IbChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$IbChoiceToJson(this);

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
