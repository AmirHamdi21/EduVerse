import '../../../generated_l10n/app_localizations.dart';
import '../../../models/question_bank/question_bank_enums.dart';

String localizedQuestionType(AppLocalizations l10n, QuestionBankType value) {
  switch (value) {
    case QuestionBankType.written:
      return l10n.enumQuestionWritten;
    case QuestionBankType.mcq:
      return l10n.enumQuestionMcq;
    case QuestionBankType.trueFalse:
      return l10n.enumQuestionTrueFalse;
    case QuestionBankType.fillBlanks:
      return l10n.enumQuestionFillBlanks;
    case QuestionBankType.essay:
      return l10n.enumQuestionEssay;
  }
}

String localizedDifficulty(
  AppLocalizations l10n,
  QuestionBankDifficulty value,
) {
  switch (value) {
    case QuestionBankDifficulty.easy:
      return l10n.enumDifficultyEasy;
    case QuestionBankDifficulty.medium:
      return l10n.enumDifficultyMedium;
    case QuestionBankDifficulty.hard:
      return l10n.enumDifficultyHard;
  }
}

String localizedBloomLevel(AppLocalizations l10n, BloomLevel value) {
  switch (value) {
    case BloomLevel.remembering:
      return l10n.enumBloomRemembering;
    case BloomLevel.understanding:
      return l10n.enumBloomUnderstanding;
    case BloomLevel.applying:
      return l10n.enumBloomApplying;
    case BloomLevel.analyzing:
      return l10n.enumBloomAnalyzing;
    case BloomLevel.evaluating:
      return l10n.enumBloomEvaluating;
    case BloomLevel.creating:
      return l10n.enumBloomCreating;
  }
}

String localizedQuestionStatus(
  AppLocalizations l10n,
  QuestionBankStatus value,
) {
  switch (value) {
    case QuestionBankStatus.draft:
      return l10n.enumQuestionStatusDraft;
    case QuestionBankStatus.underReview:
      return l10n.enumQuestionStatusUnderReview;
    case QuestionBankStatus.approved:
      return l10n.enumQuestionStatusApproved;
    case QuestionBankStatus.rejected:
      return l10n.enumQuestionStatusRejected;
    case QuestionBankStatus.archived:
      return l10n.enumQuestionStatusArchived;
  }
}

String localizedAttachmentType(
  AppLocalizations l10n,
  QuestionAttachmentType value,
) {
  switch (value) {
    case QuestionAttachmentType.image:
      return l10n.enumAttachmentImage;
    case QuestionAttachmentType.document:
      return l10n.enumAttachmentDocument;
    case QuestionAttachmentType.audio:
      return l10n.enumAttachmentAudio;
    case QuestionAttachmentType.video:
      return l10n.enumAttachmentVideo;
  }
}

String localizedGroupType(AppLocalizations l10n, QuestionGroupType value) {
  switch (value) {
    case QuestionGroupType.passage:
      return l10n.enumGroupPassage;
    case QuestionGroupType.caseStudy:
      return l10n.enumGroupCaseStudy;
    case QuestionGroupType.imageSet:
      return l10n.enumGroupImageSet;
    case QuestionGroupType.multipart:
      return l10n.enumGroupMultipart;
    case QuestionGroupType.other:
      return l10n.enumGroupOther;
  }
}

String localizedQuestionBankMessage(AppLocalizations l10n, String message) {
  switch (message) {
    case 'chapterCreated':
      return l10n.qbChapterCreated;
    case 'chapterUpdated':
      return l10n.qbChapterUpdated;
    case 'chapterDeleted':
      return l10n.qbChapterDeleted;
    case 'bulkMaxRows':
      return l10n.qbMaxRowsWarning;
    case 'bulkRowsInvalid':
      return l10n.qbBulkRowsInvalid;
    case 'bulkCreateSuccess':
      return l10n.qbBulkCreateSuccess;
    case 'bulkCreatePartialSuccess':
      return l10n.qbBulkCreatePartialSuccess;
    case 'questionImageUploaded':
      return l10n.qbUploadQuestionImage;
    case 'questionImageRemoved':
      return l10n.qbQuestionImageRemoved;
    case 'groupImageUploaded':
      return l10n.qbGroupImageUploaded;
    case 'questionUpdated':
      return l10n.questionBankQuestionDetails;
    case 'questionDeleted':
      return l10n.qbDeleteQuestion;
    case 'questionsBatchUpdated':
      return l10n.qbQuestionsBatchUpdated;
    case 'attachmentUpdated':
      return l10n.qbEditAttachment;
    case 'attachmentRemoved':
      return l10n.qbRemoveAttachment;
    case 'groupSaved':
      return l10n.qbEditGroup;
    case 'groupDeleted':
      return l10n.qbDeleteGroup;
    case 'groupQuestionsAdded':
      return l10n.qbGroupedBatchCreate;
    case 'groupReordered':
      return l10n.qbReorderGroupQuestions;
    default:
      return message;
  }
}
