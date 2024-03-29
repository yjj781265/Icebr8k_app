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
  List<String> sharedChatIds;
  String question;
  String description;
  bool isPublic;
  bool isShareable;
  bool isAnonymous;
  bool isOpenEnded;
  bool isCommentEnabled;
  bool isQuiz;
  int points;
  String correctChoiceId;
  int comments;
  int shares;
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
      this.sharedChatIds = const [],
      this.description = '',
      this.isPublic = true,
      this.isShareable = true,
      this.isOpenEnded = false,
      this.points = 0,
      this.shares = 0,
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
          sharedChatIds == other.sharedChatIds &&
          question == other.question &&
          description == other.description &&
          isPublic == other.isPublic &&
          isAnonymous == other.isAnonymous &&
          isCommentEnabled == other.isCommentEnabled &&
          isQuiz == other.isQuiz &&
          points == other.points &&
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
      sharedChatIds.hashCode ^
      question.hashCode ^
      description.hashCode ^
      isPublic.hashCode ^
      isAnonymous.hashCode ^
      isCommentEnabled.hashCode ^
      isQuiz.hashCode ^
      points.hashCode ^
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
  scaleThree('sc_3'),
  @JsonValue('ad')
  ad('ad');

  final String type;
  const QuestionType(this.type);

  @override
  String toString() {
    return type;
  }
}
