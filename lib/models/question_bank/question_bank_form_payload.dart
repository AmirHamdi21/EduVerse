import 'question_bank_enums.dart';
import 'question_bank_fill_blank_model.dart';
import 'question_bank_option_model.dart';
import 'question_bank_question_model.dart';
import 'question_attachment_payload.dart';

class QuestionBankFormPayload {
  const QuestionBankFormPayload({
    this.courseId,
    this.chapterId,
    required this.questionType,
    required this.difficulty,
    required this.bloomLevel,
    this.questionText,
    this.questionFileId,
    this.questionFileCaption,
    this.questionFileAltText,
    this.expectedAnswerText,
    this.hints,
    this.status,
    this.options = const <QuestionBankOptionModel>[],
    this.fillBlanks = const <QuestionBankFillBlankModel>[],
    this.attachments = const <QuestionAttachmentPayload>[],
  });

  final int? courseId;
  final int? chapterId;
  final QuestionBankType questionType;
  final QuestionBankDifficulty difficulty;
  final BloomLevel bloomLevel;
  final String? questionText;
  final int? questionFileId;
  final String? questionFileCaption;
  final String? questionFileAltText;
  final String? expectedAnswerText;
  final String? hints;
  final QuestionBankStatus? status;
  final List<QuestionBankOptionModel> options;
  final List<QuestionBankFillBlankModel> fillBlanks;
  final List<QuestionAttachmentPayload> attachments;

  Map<String, dynamic> toCreateJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'chapterId': chapterId,
      'questionType': questionType.value,
      'difficulty': difficulty.value,
      'bloomLevel': bloomLevel.value,
      if (_hasText(questionText)) 'questionText': questionText!.trim(),
      if (questionFileId != null) 'questionFileId': questionFileId,
      if (_hasText(questionFileCaption))
        'questionFileCaption': questionFileCaption!.trim(),
      if (_hasText(questionFileAltText))
        'questionFileAltText': questionFileAltText!.trim(),
      if (_hasText(expectedAnswerText))
        'expectedAnswerText': expectedAnswerText!.trim(),
      if (_hasText(hints)) 'hints': hints!.trim(),
      if (status != null) 'status': status!.value,
      if (options.isNotEmpty)
        'options': options.map((option) => option.toPayload()).toList(),
      if (fillBlanks.isNotEmpty)
        'fillBlanks': fillBlanks.map((blank) => blank.toPayload()).toList(),
      if (attachments.isNotEmpty)
        'attachments': attachments
            .asMap()
            .entries
            .map(
              (entry) =>
                  entry.value.copyWith(displayOrder: entry.key).toPayload(),
            )
            .toList(),
    }..removeWhere((_, value) => value == null);
  }

  Map<String, dynamic> toDirtyUpdateJson(QuestionBankQuestionModel original) {
    final next = toCreateJson()
      ..remove('courseId')
      ..remove('questionFileId')
      ..remove('questionFileCaption')
      ..remove('questionFileAltText')
      ..remove('questionText')
      ..remove('options')
      ..remove('fillBlanks')
      ..remove('attachments');

    if (chapterId == original.chapterId) next.remove('chapterId');
    if (questionType == original.questionType) next.remove('questionType');
    if (difficulty == original.difficulty) next.remove('difficulty');
    if (bloomLevel == original.bloomLevel) next.remove('bloomLevel');
    if (status == null || status == original.status) next.remove('status');
    if ((expectedAnswerText ?? '').trim() ==
        (original.expectedAnswerText ?? '').trim()) {
      next.remove('expectedAnswerText');
    }
    if ((hints ?? '').trim() == (original.hints ?? '').trim()) {
      next.remove('hints');
    }
    if (questionFileId != original.questionFileId) {
      next['questionFileId'] = questionFileId;
    }
    if ((questionFileCaption ?? '').trim() !=
        (original.questionFileCaption ?? '').trim()) {
      next['questionFileCaption'] = _hasText(questionFileCaption)
          ? questionFileCaption!.trim()
          : null;
    }
    if ((questionFileAltText ?? '').trim() !=
        (original.questionFileAltText ?? '').trim()) {
      next['questionFileAltText'] = _hasText(questionFileAltText)
          ? questionFileAltText!.trim()
          : null;
    }
    if ((questionText ?? '').trim() != (original.questionText ?? '').trim()) {
      next['questionText'] = _hasText(questionText)
          ? questionText!.trim()
          : null;
    }
    if (_childrenChanged(original)) {
      if (options.isNotEmpty) {
        next['options'] = options.map((option) => option.toPayload()).toList();
      }
      if (fillBlanks.isNotEmpty) {
        next['fillBlanks'] = fillBlanks
            .map((blank) => blank.toPayload())
            .toList();
      }
    }
    return next;
  }

  String? validate() {
    if (courseId == null || courseId! <= 0) return 'Course is required';
    if (chapterId == null || chapterId! <= 0) return 'Chapter is required';
    final hasPrompt = _hasText(questionText) || questionFileId != null;
    if (!hasPrompt) return 'Question text or image is required';
    for (final attachment in attachments) {
      final attachmentError = attachment.validate();
      if (attachmentError != null) return attachmentError;
    }
    switch (questionType) {
      case QuestionBankType.mcq:
        if (options.length < 2) return 'MCQ needs at least two options';
        if (!options.any((option) => option.isCorrect)) {
          return 'Select at least one correct option';
        }
      case QuestionBankType.trueFalse:
        if (options.length != 2) return 'True/false needs exactly two options';
        if (options.where((option) => option.isCorrect).length != 1) {
          return 'True/false needs exactly one correct option';
        }
      case QuestionBankType.fillBlanks:
        if (fillBlanks.isEmpty) return 'Add at least one blank';
        final keys = <String>{};
        for (final blank in fillBlanks) {
          final key = blank.blankKey.trim().toLowerCase();
          if (key.isEmpty || keys.contains(key)) {
            return 'Blank keys must be unique';
          }
          keys.add(key);
        }
      case QuestionBankType.written:
      case QuestionBankType.essay:
        if (!_hasText(expectedAnswerText)) return 'Expected answer is required';
    }
    return null;
  }

  bool _childrenChanged(QuestionBankQuestionModel original) {
    if (questionType != original.questionType) return true;
    return options.length != original.options.length ||
        fillBlanks.length != original.fillBlanks.length;
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
