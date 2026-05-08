import '../../../generated_l10n/app_localizations.dart';
import '../../../models/exams/exam_generator_enums.dart';

String localizedDraftStatus(AppLocalizations l10n, ExamDraftStatus value) {
  switch (value) {
    case ExamDraftStatus.open:
      return l10n.enumDraftOpen;
    case ExamDraftStatus.finalized:
      return l10n.enumDraftFinalized;
    case ExamDraftStatus.expired:
      return l10n.enumDraftExpired;
    case ExamDraftStatus.cancelled:
      return l10n.enumDraftCancelled;
    case ExamDraftStatus.failed:
      return l10n.enumDraftFailed;
  }
}

String localizedExamStatus(AppLocalizations l10n, ExamStatus value) {
  switch (value) {
    case ExamStatus.draft:
      return l10n.enumExamDraft;
    case ExamStatus.published:
      return l10n.enumExamPublished;
    case ExamStatus.archived:
      return l10n.enumExamArchived;
  }
}

String localizedMarkMode(
  AppLocalizations l10n,
  ExamMarkDistributionMode value,
) {
  switch (value) {
    case ExamMarkDistributionMode.manual:
      return l10n.enumMarkManual;
    case ExamMarkDistributionMode.weightNormalized:
      return l10n.enumMarkWeightNormalized;
    case ExamMarkDistributionMode.equal:
      return l10n.enumMarkEqual;
  }
}

String localizedRounding(AppLocalizations l10n, ExamRoundingPolicy value) {
  switch (value) {
    case ExamRoundingPolicy.none:
      return l10n.enumRoundingNone;
    case ExamRoundingPolicy.nearest025:
      return l10n.enumRounding025;
    case ExamRoundingPolicy.nearest05:
      return l10n.enumRounding05;
    case ExamRoundingPolicy.nearest1:
      return l10n.enumRounding1;
  }
}

String localizedAnswerPolicy(
  AppLocalizations l10n,
  ExamSectionAnswerPolicy value,
) {
  switch (value) {
    case ExamSectionAnswerPolicy.answerAll:
      return l10n.enumAnswerAll;
    case ExamSectionAnswerPolicy.answerAny:
      return l10n.enumAnswerAny;
  }
}

String localizedGenerationScope(
  AppLocalizations l10n,
  ExamGenerationScope value,
) {
  switch (value) {
    case ExamGenerationScope.course:
      return l10n.examScopeCourse;
    case ExamGenerationScope.chapter:
      return l10n.examScopeChapter;
    case ExamGenerationScope.chapters:
      return l10n.examScopeChapters;
    case ExamGenerationScope.group:
      return l10n.examScopeGroup;
  }
}

String localizedGroupSelectionMode(
  AppLocalizations l10n,
  ExamGroupSelectionMode value,
) {
  switch (value) {
    case ExamGroupSelectionMode.independent:
      return l10n.examGroupIndependent;
    case ExamGroupSelectionMode.excludeGrouped:
      return l10n.examGroupExclude;
    case ExamGroupSelectionMode.keepGroupTogether:
      return l10n.examGroupKeepTogether;
  }
}

String localizedExportVariant(AppLocalizations l10n, ExamExportVariant value) {
  switch (value) {
    case ExamExportVariant.student:
      return l10n.examExportStudentCopy;
    case ExamExportVariant.answerKey:
      return l10n.examExportAnswerKey;
    case ExamExportVariant.combined:
      return l10n.examExportCombined;
  }
}

String localizedExportFormat(AppLocalizations l10n, ExamExportFormat value) {
  switch (value) {
    case ExamExportFormat.htmlDoc:
      return l10n.examExportWordDocument;
    case ExamExportFormat.pdf:
      return l10n.examExportPdfDocument;
  }
}

String localizedExamMessage(AppLocalizations l10n, String message) {
  switch (message) {
    case 'Course is required':
      return l10n.examValidationCourseRequired;
    case 'Title is required':
      return l10n.examValidationTitleRequired;
    case 'Total marks must be positive':
      return l10n.examValidationTotalMarksPositive;
    case 'Duration must be positive':
      return l10n.examValidationDurationPositive;
    case 'Add at least one rule':
      return l10n.examValidationAddRule;
    case 'Add at least one section':
      return l10n.examValidationAddSection;
    case 'Chapter is required':
      return l10n.examValidationChapterRequired;
    case 'Select at least one chapter':
      return l10n.examValidationSelectChapter;
    case 'Select at least one group':
      return l10n.examValidationSelectGroup;
    case 'Count must be greater than zero':
      return l10n.examValidationCountPositive;
    case 'Weight must be greater than zero':
      return l10n.examValidationWeightPositive;
    case 'Section title is required':
      return l10n.examValidationSectionTitleRequired;
    case 'Section marks must be greater than zero':
      return l10n.examValidationSectionMarksPositive;
    case 'Section marks cannot be negative':
      return l10n.examValidationSectionMarksNonNegative;
    case 'Required answer count must be positive':
      return l10n.examValidationRequiredAnswerPositive;
    case 'Replacement question is required':
      return l10n.examValidationReplacementRequired;
    case 'Section must be valid':
      return l10n.examValidationSectionValid;
    case 'Weight cannot be negative':
      return l10n.examValidationWeightNonNegative;
    case 'Weight units cannot be negative':
      return l10n.examValidationWeightUnitsNonNegative;
    case 'Marks cannot be negative':
      return l10n.examValidationMarksNonNegative;
    case 'Item order cannot be negative':
      return l10n.examValidationItemOrderNonNegative;
    case 'Question is already in draft':
    case 'Question already exists in draft':
    case 'This question is already in the draft':
      return l10n.examValidationQuestionAlreadyInDraft;
    case 'Select at least one question':
      return l10n.examSelectQuestionFirst;
    case 'Failed to move selected questions':
      return l10n.examMoveQuestionsFailed;
    case 'Selected questions moved':
      return l10n.examSelectedQuestionsMoved;
    case 'Question does not match the draft generation constraints. Provide overrideReason to intentionally override.':
    case 'Question does not match the draft generation constraints':
      return l10n.examValidationQuestionOutsideRules;
    case 'Override reason is required':
      return l10n.examOverrideReasonRequired;
    default:
      return message;
  }
}
