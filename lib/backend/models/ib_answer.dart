import 'package:json_annotation/json_annotation.dart';

part 'ib_answer.g.dart';

@JsonSerializable(explicitToJson: true)
class IbAnswer {
  final String choiceId;
  final int answeredTimeInMs;
  final bool isAnonymous;
  final bool isPublicQuestion;
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
      this.isAnonymous = false,
      this.isPublicQuestion = true,
      required this.uid});

  factory IbAnswer.fromJson(Map<String, dynamic> json) =>
      _$IbAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$IbAnswerToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbAnswer &&
          runtimeType == other.runtimeType &&
          choiceId == other.choiceId &&
          answeredTimeInMs == other.answeredTimeInMs &&
          isAnonymous == other.isAnonymous &&
          uid == other.uid &&
          askedTimeInMs == other.askedTimeInMs &&
          questionId == other.questionId &&
          questionType == other.questionType &&
          edited == other.edited &&
          isPublicQuestion == other.isPublicQuestion;

  @override
  int get hashCode =>
      choiceId.hashCode ^
      answeredTimeInMs.hashCode ^
      isAnonymous.hashCode ^
      uid.hashCode ^
      askedTimeInMs.hashCode ^
      questionId.hashCode ^
      questionType.hashCode ^
      edited.hashCode ^
      isPublicQuestion.hashCode;

  @override
  String toString() {
    return 'IbAnswer{ questionId: $questionId,choiceId: $choiceId, uid: $uid,}';
  }
}
