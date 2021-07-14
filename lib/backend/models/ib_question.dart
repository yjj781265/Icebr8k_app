import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable()
class IbQuestion {
  static const String kMultipleChoice = "mc";
  static const String kScaleChoice = "sc";
  String question;
  String description;
  String id;
  String creatorId;
  int createdTime;
  int endTime;
  List<String> answers;
  String questionType;

  IbQuestion(
      {required this.question,
      required this.id,
      required this.creatorId,
      required this.answers,
      required this.questionType,
      this.description = '',
      this.createdTime = 0,
      this.endTime = 0});

  factory IbQuestion.fromJson(Map<String, dynamic> json) =>
      _$IbQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$IbQuestionToJson(this);
}
