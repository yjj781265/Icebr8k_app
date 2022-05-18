import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable(explicitToJson: true)
class IbQuestion {
  List<String> tags;
  List<IbMedia> medias;
  dynamic position;
  List<String> sharedFriendUids;
  String question;
  String description;
  bool isPublic;
  bool isCircleOnly;
  bool isAnonymous;
  bool isCommentEnabled;
  bool isQuiz;
  int points;
  String correctChoiceId;
  int comments;
  int pollSize;
  int likes;
  String id;
  String creatorId;
  int askedTimeInMs;
  int endTimeInMs;
  List<IbChoice> choices;
  QuestionType questionType;

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
      this.sharedFriendUids = const [],
      this.tags = const [],
      this.description = '',
      this.isCircleOnly = false,
      this.isPublic = true,
      this.points = 0,
      this.likes = 0,
      this.comments = 0,
      this.position,
      this.medias = const [],
      this.pollSize = 0,
      required this.askedTimeInMs,
      this.endTimeInMs = -1}) {
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
      other is IbQuestion &&
          runtimeType == other.runtimeType &&
          tags == other.tags &&
          medias == other.medias &&
          position == other.position &&
          sharedFriendUids == other.sharedFriendUids &&
          question == other.question &&
          description == other.description &&
          isAnonymous == other.isAnonymous &&
          isCommentEnabled == other.isCommentEnabled &&
          isQuiz == other.isQuiz &&
          correctChoiceId == other.correctChoiceId &&
          comments == other.comments &&
          pollSize == other.pollSize &&
          likes == other.likes &&
          id == other.id &&
          creatorId == other.creatorId &&
          askedTimeInMs == other.askedTimeInMs &&
          endTimeInMs == other.endTimeInMs &&
          choices == other.choices &&
          questionType == other.questionType;

  @override
  int get hashCode =>
      tags.hashCode ^
      medias.hashCode ^
      position.hashCode ^
      sharedFriendUids.hashCode ^
      question.hashCode ^
      description.hashCode ^
      isAnonymous.hashCode ^
      isCommentEnabled.hashCode ^
      isQuiz.hashCode ^
      correctChoiceId.hashCode ^
      comments.hashCode ^
      pollSize.hashCode ^
      likes.hashCode ^
      id.hashCode ^
      creatorId.hashCode ^
      askedTimeInMs.hashCode ^
      endTimeInMs.hashCode ^
      choices.hashCode ^
      questionType.hashCode;

  @override
  String toString() {
    return 'IbQuestion{question: $question, id: $id}';
  }
}

enum QuestionType {
  @JsonValue('mc')
  multipleChoice('mc'),
  @JsonValue('mc_pic')
  multipleChoicePic('mc_pic'),
  @JsonValue('sc_1')
  scaleOne('sc_1'),
  @JsonValue('sc_2')
  scaleTwo('sc_2'),
  @JsonValue('sc_3')
  scaleThree('sc_3');

  final String type;
  const QuestionType(this.type);

  @override
  String toString() {
    return type;
  }
}
