import 'package:json_annotation/json_annotation.dart';

part 'ib_answer.g.dart';

@JsonSerializable(explicitToJson: true)
class IbAnswer {
  final String choiceId;
  final int answeredTimeInMs;
  final String uid;
  final int askedTimeInMs;
  final String questionId;
  final String questionType;
  final bool edited;

  IbAnswer(
      {required this.choiceId,
      required this.answeredTimeInMs,
      required this.askedTimeInMs,
      required this.questionId,
      required this.questionType,
      this.edited = false,
      required this.uid});

  factory IbAnswer.fromJson(Map<String, dynamic> json) =>
      _$IbAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$IbAnswerToJson(this);

  @override
  bool operator ==(Object other) =>
      other is IbAnswer &&
      choiceId == other.choiceId &&
      questionId == other.questionId;

  @override
  int get hashCode => choiceId.hashCode ^ questionId.hashCode;

  @override
  String toString() {
    return 'IbAnswer{choiceId: $choiceId, uid: $uid, questionId: $questionId, questionType: $questionType}';
  }
}
