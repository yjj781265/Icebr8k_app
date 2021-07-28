import 'package:json_annotation/json_annotation.dart';

part 'ib_answer.g.dart';

@JsonSerializable()
class IbAnswer {
  final String answer;
  final String questionId;
  final int timeStampInMs;
  final String uid;

  IbAnswer(
      {required this.answer,
      required this.questionId,
      required this.timeStampInMs,
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
    return 'IbAnswer{answer: $answer, questionId: $questionId, timeStampInMs: $timeStampInMs, uid: $uid}';
  }
}
