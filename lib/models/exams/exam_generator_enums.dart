enum ExamDraftStatus {
  open('open'),
  finalized('finalized'),
  expired('expired'),
  cancelled('cancelled'),
  failed('failed');

  const ExamDraftStatus(this.value);
  final String value;

  static ExamDraftStatus fromJson(dynamic value) {
    return ExamDraftStatus.values.firstWhere(
      (status) => status.value == value?.toString(),
      orElse: () => ExamDraftStatus.open,
    );
  }
}

enum ExamStatus {
  draft('draft'),
  published('published'),
  archived('archived');

  const ExamStatus(this.value);
  final String value;

  static ExamStatus fromJson(dynamic value) {
    return ExamStatus.values.firstWhere(
      (status) => status.value == value?.toString(),
      orElse: () => ExamStatus.draft,
    );
  }
}

enum ExamMarkDistributionMode {
  manual('manual'),
  weightNormalized('weight_normalized'),
  equal('equal');

  const ExamMarkDistributionMode(this.value);
  final String value;
}

enum ExamRoundingPolicy {
  none('none'),
  nearest025('nearest_0_25'),
  nearest05('nearest_0_5'),
  nearest1('nearest_1');

  const ExamRoundingPolicy(this.value);
  final String value;
}

enum ExamSectionAnswerPolicy {
  answerAll('answer_all'),
  answerAny('answer_any');

  const ExamSectionAnswerPolicy(this.value);
  final String value;

  static ExamSectionAnswerPolicy fromJson(dynamic value) {
    return ExamSectionAnswerPolicy.values.firstWhere(
      (policy) => policy.value == value?.toString(),
      orElse: () => ExamSectionAnswerPolicy.answerAll,
    );
  }
}

enum ExamGroupSelectionMode {
  independent('independent'),
  excludeGrouped('exclude_grouped'),
  keepGroupTogether('keep_group_together');

  const ExamGroupSelectionMode(this.value);
  final String value;

  static ExamGroupSelectionMode fromJson(dynamic value) {
    return ExamGroupSelectionMode.values.firstWhere(
      (mode) => mode.value == value?.toString(),
      orElse: () => ExamGroupSelectionMode.independent,
    );
  }
}

enum ExamExportFormat {
  htmlDoc('html_doc'),
  pdf('pdf');

  const ExamExportFormat(this.value);
  final String value;
}

enum ExamExportVariant {
  student('student'),
  answerKey('answer_key'),
  combined('combined');

  const ExamExportVariant(this.value);
  final String value;
}

enum ExamAnswerKeyStyle {
  inline('inline'),
  separate('separate');

  const ExamAnswerKeyStyle(this.value);
  final String value;

  static ExamAnswerKeyStyle fromJson(dynamic value) {
    return ExamAnswerKeyStyle.values.firstWhere(
      (style) => style.value == value?.toString(),
      orElse: () => ExamAnswerKeyStyle.inline,
    );
  }
}

enum ExamGenerationScope {
  course('course'),
  chapter('chapter'),
  chapters('chapters'),
  group('group');

  const ExamGenerationScope(this.value);
  final String value;

  static ExamGenerationScope fromJson(dynamic value) {
    return ExamGenerationScope.values.firstWhere(
      (scope) => scope.value == value?.toString(),
      orElse: () => ExamGenerationScope.chapter,
    );
  }
}
