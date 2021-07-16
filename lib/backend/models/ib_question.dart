import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable()
class IbQuestion {
  static const String kMultipleChoice = "mc";
  static const String kScale = "sc";
  String question;
  String description;
  String id;
  String creatorId;
  int createdTimeInMs;
  int endTimeInMs;
  List<String> choices;
  String questionType;

  IbQuestion(
      {required this.question,
      required this.id,
      required this.creatorId,
      required this.choices,
      required this.questionType,
      this.description = '',
      required this.createdTimeInMs,
      this.endTimeInMs = 0});

  factory IbQuestion.fromJson(Map<String, dynamic> json) =>
      _$IbQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$IbQuestionToJson(this);
}
