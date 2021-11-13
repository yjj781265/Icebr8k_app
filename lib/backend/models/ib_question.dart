import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable(explicitToJson: true)
class IbQuestion {
  static const String kMultipleChoice = "mc";
  static const String kScale = "sc";
  String question;
  String description;
  int comments;
  int pollSize;
  int likes;
  String id;
  String creatorId;
  int askedTimeInMs;
  int endTimeInMs;
  List<IbChoice> choices;
  List<String>? endpoints;
  String questionType;

  IbQuestion(
      {required this.question,
      required this.id,
      required this.creatorId,
      required this.choices,
      required this.questionType,
      this.endpoints,
      this.description = '',
      this.likes = 0,
      this.comments = 0,
      this.pollSize = 0,
      required this.askedTimeInMs,
      this.endTimeInMs = 0}) {
    if (kScale == questionType && endpoints == null) {
      throw Exception('Scale question need end points to be defined');
    }
  }

  factory IbQuestion.fromJson(Map<String, dynamic> json) =>
      _$IbQuestionFromJson(json);
  Map<String, dynamic> toJson() => _$IbQuestionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IbQuestion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'IbQuestion{question: $question, id: $id}';
  }
}
