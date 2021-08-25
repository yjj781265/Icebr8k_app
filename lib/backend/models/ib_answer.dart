import 'package:json_annotation/json_annotation.dart';

part 'ib_answer.g.dart';

@JsonSerializable(explicitToJson: true)
class IbAnswer {
  final String answer;
  final int answeredTimeInMs;
  final String uid;
  final int askedTimeInMs;
  final String questionId;
  final String questionType;

  IbAnswer(
      {required this.answer,
      required this.answeredTimeInMs,
      required this.askedTimeInMs,
      required this.questionId,
      required this.questionType,
      required this.uid});

  factory IbAnswer.fromJson(Map<String, dynamic> json) =>
      _$IbAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$IbAnswerToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbAnswer &&
          runtimeType == other.runtimeType &&
          answer == other.answer &&
          questionId == other.questionId;

  @override
  int get hashCode => answer.hashCode ^ questionId.hashCode;

  @override
  String toString() {
    return 'IbAnswer{answer: $answer, questionType: $questionType';
  }
}
