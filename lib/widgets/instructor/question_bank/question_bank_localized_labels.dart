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
  if (message.startsWith('questionStatusUpdated:')) {
    final statusValue = message.substring('questionStatusUpdated:'.length);
    final status = QuestionBankStatus.fromJson(statusValue);
    return '${l10n.status} ${l10n.updated.toLowerCase()}: ${localizedQuestionStatus(l10n, status)}';
  }

  switch (message) {
    case 'chapterCreated':
      return l10n.qbChapterCreated;
    case 'chapterUpdated':
      return l10n.qbChapterUpdated;
    case 'chapterDeleted':
      return l10n.qbChapterDeleted;
    case 'chapterCreateFailed':
      return 'Could not create chapter.';
    case 'chapterUpdateFailed':
      return 'Could not update chapter.';
    case 'chapterDeleteFailed':
      return 'Could not delete chapter.';
    case 'bulkMaxRows':
      return l10n.qbMaxRowsWarning;
    case 'bulkRowsInvalid':
      return l10n.qbBulkRowsInvalid;
    case 'bulkCreateSuccess':
      return l10n.qbBulkCreateSuccess;
    case 'bulkCreatePartialSuccess':
      return l10n.qbBulkCreatePartialSuccess;
    case 'questionImageUploaded':
      return '${l10n.questionBankImageQuestion} ${l10n.uploaded.toLowerCase()}';
    case 'questionImageRemoved':
      return l10n.qbQuestionImageRemoved;
    case 'groupImageUploaded':
      return l10n.qbGroupImageUploaded;
    case 'draftSaved':
      return l10n.draftSaved;
    case 'questionSaved':
      return '${l10n.question} ${l10n.updated.toLowerCase()}';
    case 'questionUpdated':
      return l10n.qbQuestionsBatchUpdated;
    case 'questionStatusNotConfirmed':
      return '${l10n.operationFailed}: ${l10n.status.toLowerCase()} ${l10n.updated.toLowerCase()} was not confirmed.';
    case 'questionLoadFailed':
      return 'Could not load question details.';
    case 'questionStatusFailed':
      return 'Could not update question status.';
    case 'questionDeleteFailed':
      return 'Could not delete question.';
    case 'questionsDeleteFailed':
      return 'Could not delete selected questions.';
    case 'questionStatus:submit-for-review':
      return l10n.submitForReview;
    case 'questionStatus:approve':
      return l10n.qbApprove;
    case 'questionStatus:reject':
      return l10n.qbReject;
    case 'questionStatus:archive':
      return l10n.qbArchive;
    case 'questionStatus:restore':
      return l10n.qbRestore;
    case 'questionDeleted':
      return l10n.questionRemoved;
    case 'questionsDeleted':
      return 'Selected questions deleted';
    case 'questionsBatchUpdated':
      return l10n.qbQuestionsBatchUpdated;
    case 'questionsStatusUpdated':
      return '${l10n.questions} ${l10n.status.toLowerCase()} ${l10n.updated.toLowerCase()}';
    case 'attachmentAdded':
      return l10n.attachmentAdded;
    case 'attachmentUploaded':
      return l10n.uploadComplete;
    case 'attachmentMetadataUpdated':
      return '${l10n.examQuestionAttachments} ${l10n.updated.toLowerCase()}';
    case 'attachmentReordered':
      return '${l10n.attachments} ${l10n.updated.toLowerCase()}';
    case 'attachmentRemoved':
      return l10n.attachmentRemoved;
    case 'attachmentAddFailed':
      return 'Could not add attachment.';
    case 'attachmentUploadFailed':
      return 'Could not upload attachment.';
    case 'attachmentUpdateFailed':
      return 'Could not update attachment.';
    case 'attachmentReorderFailed':
      return 'Could not reorder attachments.';
    case 'attachmentRemoveFailed':
      return 'Could not remove attachment.';
    case 'groupSaved':
      return l10n.qbGroupSaved;
    case 'groupDeleted':
      return 'Group deleted';
    case 'groupedQuestionsCreated':
      return 'Grouped questions created';
    case 'groupQuestionsLinked':
      return 'Questions linked to group';
    case 'groupQuestionsAdded':
      return 'Questions added to group';
    case 'groupQuestionRemoved':
      return 'Question removed from group';
    case 'groupReordered':
      return 'Group question order updated';
    case 'groupLoadFailed':
      return 'Could not load group.';
    case 'groupCreateFailed':
      return 'Could not create group.';
    case 'groupUpdateFailed':
      return 'Could not update group.';
    case 'groupImageUploadFailed':
      return 'Could not upload group image.';
    case 'questionImageUploadFailed':
      return 'Could not upload question image.';
    case 'questionImageDeleteFailed':
      return 'Could not remove question image.';
    case 'groupDeleteFailed':
      return 'Could not delete group.';
    case 'groupedBatchFailed':
      return 'Could not create grouped questions.';
    case 'bulkStatusFailed':
      return 'Could not update question status.';
    case 'groupLinkQuestionsFailed':
      return 'Could not link questions to group.';
    case 'groupReorderInvalid':
      return 'Question order changed. Refresh and try again.';
    case 'groupReorderFailed':
      return 'Could not update question order.';
    case 'groupQuestionRemoveFailed':
      return 'Could not remove question from group.';
    default:
      return message;
  }
}
