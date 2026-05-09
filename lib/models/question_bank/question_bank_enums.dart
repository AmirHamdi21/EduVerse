enum QuestionBankType {
  written('written'),
  mcq('mcq'),
  trueFalse('true_false'),
  fillBlanks('fill_blanks'),
  essay('essay');

  const QuestionBankType(this.value);
  final String value;

  static QuestionBankType fromJson(dynamic value) {
    return QuestionBankType.values.firstWhere(
      (type) => type.value == value?.toString(),
      orElse: () => QuestionBankType.written,
    );
  }
}

enum QuestionBankDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const QuestionBankDifficulty(this.value);
  final String value;

  static QuestionBankDifficulty fromJson(dynamic value) {
    return QuestionBankDifficulty.values.firstWhere(
      (difficulty) => difficulty.value == value?.toString(),
      orElse: () => QuestionBankDifficulty.medium,
    );
  }
}

enum BloomLevel {
  remembering('remembering'),
  understanding('understanding'),
  applying('applying'),
  analyzing('analyzing'),
  evaluating('evaluating'),
  creating('creating');

  const BloomLevel(this.value);
  final String value;

  static BloomLevel fromJson(dynamic value) {
    return BloomLevel.values.firstWhere(
      (level) => level.value == value?.toString(),
      orElse: () => BloomLevel.understanding,
    );
  }
}

enum QuestionBankStatus {
  draft('draft'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected'),
  archived('archived');

  const QuestionBankStatus(this.value);
  final String value;

  static QuestionBankStatus fromJson(dynamic value) {
    return QuestionBankStatus.values.firstWhere(
      (status) => status.value == value?.toString(),
      orElse: () => QuestionBankStatus.draft,
    );
  }
}

enum QuestionAttachmentType {
  image('image'),
  document('document'),
  audio('audio'),
  video('video');

  const QuestionAttachmentType(this.value);
  final String value;

  static QuestionAttachmentType fromJson(dynamic value) {
    return QuestionAttachmentType.values.firstWhere(
      (type) => type.value == value?.toString(),
      orElse: () => QuestionAttachmentType.image,
    );
  }
}

enum QuestionGroupType {
  passage('passage'),
  caseStudy('case_study'),
  imageSet('image_set'),
  multipart('multipart'),
  other('other');

  const QuestionGroupType(this.value);
  final String value;

  static QuestionGroupType fromJson(dynamic value) {
    return QuestionGroupType.values.firstWhere(
      (type) => type.value == value?.toString(),
      orElse: () => QuestionGroupType.other,
    );
  }
}
