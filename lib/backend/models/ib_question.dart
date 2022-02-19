import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable(explicitToJson: true)
class IbQuestion {
  static const String kMultipleChoice = "mc";
  static const String kScale = "sc";
  static const String kPic = "pic";
  static const String kMultipleChoicePic = "mc_pic";

  List<String> tagIds;
  List<IbMedia> medias;
  dynamic position;
  List<String> privacyBounds;
  String question;
  String description;
  bool isAnonymous;
  bool isCommentEnabled;
  bool isQuiz;
  String correctChoiceId;
  int comments;
  int pollSize;
  int likes;
  String id;
  String creatorId;
  int askedTimeInMs;
  int endTimeInMs;
  List<IbChoice> choices;
  List<IbChoice>? endpoints;
  String questionType;

  IbQuestion(
      {required this.question,
      required this.id,
      required this.creatorId,
      required this.choices,
      required this.questionType,
      this.correctChoiceId = '',
      this.isQuiz = false,
      this.isAnonymous = false,
      this.isCommentEnabled = true,
      this.privacyBounds = const ['public'],
      this.tagIds = const [],
      this.endpoints,
      this.description = '',
      this.likes = 0,
      this.comments = 0,
      this.position,
      this.medias = const [],
      this.pollSize = 0,
      required this.askedTimeInMs,
      this.endTimeInMs = -1}) {
    if (kScale == questionType && endpoints == null) {
      throw Exception('Scale question need end points to be defined');
    }
    if (isQuiz && correctChoiceId.isEmpty) {
      throw Exception('Quiz needs to have a correct choice id');
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
