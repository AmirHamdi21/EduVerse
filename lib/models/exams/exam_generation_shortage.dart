class ExamGenerationShortage {
  const ExamGenerationShortage({
    this.section,
    this.chapterId,
    this.required,
    this.available,
    this.questionType,
    this.difficulty,
    this.bloomLevel,
  });

  final String? section;
  final int? chapterId;
  final int? required;
  final int? available;
  final String? questionType;
  final String? difficulty;
  final String? bloomLevel;
}

class ExamGenerationFailure {
  const ExamGenerationFailure({
    required this.message,
    this.shortages = const <ExamGenerationShortage>[],
  });

  final String message;
  final List<ExamGenerationShortage> shortages;
}
