import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable(explicitToJson: true)
class IbQuestion {
  static const String kPrivacyBoundCircle = 'circle';
  static const String kPrivacyBoundPublic = 'public';
  static const String kPrivacyBoundFriends = 'friends';

  static const String kMultipleChoice = "mc";
  static const String kScaleOne = "sc_1";
  static const String kScaleTwo = "sc_2";
  static const String kScaleThree = "sc_3";
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
      this.description = '',
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
          tagIds == other.tagIds &&
          medias == other.medias &&
          position == other.position &&
          privacyBounds == other.privacyBounds &&
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
      tagIds.hashCode ^
      medias.hashCode ^
      position.hashCode ^
      privacyBounds.hashCode ^
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
