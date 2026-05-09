import '../question_bank/question_bank_enums.dart';
import 'exam_generator_enums.dart';

class ExamGenerationRuleModel {
  const ExamGenerationRuleModel({
    this.scope = ExamGenerationScope.chapter,
    this.chapterId,
    this.chapterIds = const <int>[],
    this.groupIds = const <int>[],
    required this.count,
    required this.weightPerQuestion,
    this.questionType,
    this.difficulty,
    this.bloomLevel,
  });

  final ExamGenerationScope scope;
  final int? chapterId;
  final List<int> chapterIds;
  final List<int> groupIds;
  final int count;
  final double weightPerQuestion;
  final QuestionBankType? questionType;
  final QuestionBankDifficulty? difficulty;
  final BloomLevel? bloomLevel;

  ExamGenerationRuleModel copyWith({
    ExamGenerationScope? scope,
    int? chapterId,
    bool clearChapter = false,
    List<int>? chapterIds,
    List<int>? groupIds,
    int? count,
    double? weightPerQuestion,
    QuestionBankType? questionType,
    bool clearQuestionType = false,
    QuestionBankDifficulty? difficulty,
    bool clearDifficulty = false,
    BloomLevel? bloomLevel,
    bool clearBloomLevel = false,
  }) {
    return ExamGenerationRuleModel(
      scope: scope ?? this.scope,
      chapterId: clearChapter ? null : chapterId ?? this.chapterId,
      chapterIds: chapterIds ?? this.chapterIds,
      groupIds: groupIds ?? this.groupIds,
      count: count ?? this.count,
      weightPerQuestion: weightPerQuestion ?? this.weightPerQuestion,
      questionType: clearQuestionType ? null : questionType ?? this.questionType,
      difficulty: clearDifficulty ? null : difficulty ?? this.difficulty,
      bloomLevel: clearBloomLevel ? null : bloomLevel ?? this.bloomLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scope': scope.value,
      if (scope == ExamGenerationScope.chapter && chapterId != null)
        'chapterId': chapterId,
      if (scope == ExamGenerationScope.chapters)
        'chapterIds': _uniquePositive(chapterIds),
      if (scope == ExamGenerationScope.group) 'groupIds': _uniquePositive(groupIds),
      'count': count,
      'weightPerQuestion': weightPerQuestion,
      if (questionType != null) 'questionType': questionType!.value,
      if (difficulty != null) 'difficulty': difficulty!.value,
      if (bloomLevel != null) 'bloomLevel': bloomLevel!.value,
    };
  }

  String? validate() {
    switch (scope) {
      case ExamGenerationScope.course:
        break;
      case ExamGenerationScope.chapter:
        if (chapterId == null || chapterId! <= 0) return 'Chapter is required';
      case ExamGenerationScope.chapters:
        if (_uniquePositive(chapterIds).isEmpty) {
          return 'Select at least one chapter';
        }
      case ExamGenerationScope.group:
        if (_uniquePositive(groupIds).isEmpty) {
          return 'Select at least one group';
        }
    }
    if (count <= 0) return 'Count must be greater than zero';
    if (weightPerQuestion <= 0) return 'Weight must be greater than zero';
    return null;
  }

  static List<int> _uniquePositive(List<int> values) {
    final seen = <int>{};
    return [
      for (final value in values)
        if (value > 0 && seen.add(value)) value,
    ];
  }
}
