import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ib_question.g.dart';

@JsonSerializable(explicitToJson: true)
class IbQuestion {
  static const String kMultipleChoice = "mc";
  static const String kScale = "sc";
  static const String kPic = "pic";
  static const String kMultipleChoicePic = "mc_pic";

  List<String> tagIds;
  List<String> privacyBounds;
  String question;
  String description;
  bool isAnonymous;
  bool isCommentEnabled;
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
      this.isAnonymous = false,
      this.isCommentEnabled = true,
      this.privacyBounds = const ['public'],
      this.tagIds = const [],
      this.endpoints,
      this.description = '',
      this.likes = 0,
      this.comments = 0,
      this.pollSize = 0,
      required this.askedTimeInMs,
      this.endTimeInMs = -1}) {
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
      other is IbQuestion &&
          runtimeType == other.runtimeType &&
          tagIds == other.tagIds &&
          privacyBounds == other.privacyBounds &&
          question == other.question &&
          description == other.description &&
          isAnonymous == other.isAnonymous &&
          isCommentEnabled == other.isCommentEnabled &&
          comments == other.comments &&
          pollSize == other.pollSize &&
          likes == other.likes &&
          id == other.id &&
          creatorId == other.creatorId &&
          askedTimeInMs == other.askedTimeInMs &&
          endTimeInMs == other.endTimeInMs &&
          choices == other.choices &&
          endpoints == other.endpoints &&
          questionType == other.questionType;

  @override
  int get hashCode =>
      tagIds.hashCode ^
      privacyBounds.hashCode ^
      question.hashCode ^
      description.hashCode ^
      isAnonymous.hashCode ^
      isCommentEnabled.hashCode ^
      comments.hashCode ^
      pollSize.hashCode ^
      likes.hashCode ^
      id.hashCode ^
      creatorId.hashCode ^
      askedTimeInMs.hashCode ^
      endTimeInMs.hashCode ^
      choices.hashCode ^
      endpoints.hashCode ^
      questionType.hashCode;

  @override
  String toString() {
    return 'IbQuestion{question: $question, id: $id}';
  }
}
