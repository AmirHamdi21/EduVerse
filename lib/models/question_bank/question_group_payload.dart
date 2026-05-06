import 'question_bank_enums.dart';

class QuestionGroupPayload {
  const QuestionGroupPayload({
    required this.courseId,
    this.title,
    this.sharedPrompt,
    this.sharedFileId,
    this.sharedFileCaption,
    this.sharedFileAltText,
    this.groupType = QuestionGroupType.other,
  });

  final int? courseId;
  final String? title;
  final String? sharedPrompt;
  final int? sharedFileId;
  final String? sharedFileCaption;
  final String? sharedFileAltText;
  final QuestionGroupType groupType;

  String? validate() {
    if (courseId == null || courseId! <= 0) return 'Course is required';
    if (sharedFileId != null && sharedFileId! <= 0) {
      return 'Shared file id must be positive';
    }
    return null;
  }
}
