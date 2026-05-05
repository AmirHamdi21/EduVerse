import '../instructor/question_bank_exam_models.dart';

export '../instructor/question_bank_exam_models.dart'
    show ExamGenerationRuleModel, ExamGenerationSectionModel;

class ExamGenerationFormData {
  const ExamGenerationFormData({
    required this.courseId,
    required this.title,
    this.instructions,
    this.totalMarks,
    this.markDistributionMode = ExamMarkDistributionMode.manual,
    this.roundingPolicy = ExamRoundingPolicy.nearest05,
    this.rules = const <ExamGenerationRuleModel>[],
    this.sections = const <ExamGenerationSectionModel>[],
    this.seed,
  });

  final int courseId;
  final String title;
  final String? instructions;
  final double? totalMarks;
  final ExamMarkDistributionMode markDistributionMode;
  final ExamRoundingPolicy roundingPolicy;
  final List<ExamGenerationRuleModel> rules;
  final List<ExamGenerationSectionModel> sections;
  final String? seed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'courseId': courseId,
      'title': title.trim(),
      'markDistributionMode': markDistributionMode.toJson(),
      'roundingPolicy': roundingPolicy.toJson(),
      'groupSelectionMode': 'independent',
      if (_hasText(instructions)) 'instructions': instructions!.trim(),
      if (totalMarks != null) 'totalMarks': totalMarks,
      if (rules.isNotEmpty)
        'rules': rules.map((item) => item.toJson()).toList(growable: false),
      if (sections.isNotEmpty)
        'sections': sections
            .map((item) => item.toJson())
            .toList(growable: false),
      if (_hasText(seed)) 'seed': seed!.trim(),
    };
  }
}

class DraftSectionFormData {
  const DraftSectionFormData({
    required this.title,
    this.instructions,
    this.totalMarks,
    this.answerPolicy = ExamSectionAnswerPolicy.answerAll,
    this.requiredAnswerCount,
  });

  final String title;
  final String? instructions;
  final double? totalMarks;
  final ExamSectionAnswerPolicy answerPolicy;
  final int? requiredAnswerCount;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      'answerPolicy': answerPolicy.toJson(),
      if (_hasText(instructions)) 'instructions': instructions!.trim(),
      if (totalMarks != null) 'totalMarks': totalMarks,
      if (requiredAnswerCount != null)
        'requiredAnswerCount': requiredAnswerCount,
    };
  }
}

class DraftItemFormData {
  const DraftItemFormData({
    required this.questionId,
    this.draftSectionId,
    this.weightUnits,
    this.marks,
    this.overrideReason,
  });

  final int questionId;
  final int? draftSectionId;
  final double? weightUnits;
  final double? marks;
  final String? overrideReason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'questionId': questionId,
      if (draftSectionId != null) 'draftSectionId': draftSectionId,
      if (weightUnits != null) 'weightUnits': weightUnits,
      if (marks != null) 'marks': marks,
      if (_hasText(overrideReason)) 'overrideReason': overrideReason!.trim(),
    };
  }
}

class DraftItemUpdateFormData {
  const DraftItemUpdateFormData({
    this.replacementQuestionId,
    this.draftSectionId,
    this.clearDraftSection = false,
    this.weight,
    this.weightUnits,
    this.marks,
    this.itemOrder,
    this.overrideReason,
  });

  final int? replacementQuestionId;
  final int? draftSectionId;
  final bool clearDraftSection;
  final double? weight;
  final double? weightUnits;
  final double? marks;
  final int? itemOrder;
  final String? overrideReason;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (replacementQuestionId != null)
        'replacementQuestionId': replacementQuestionId,
      if (clearDraftSection) 'draftSectionId': null,
      if (!clearDraftSection && draftSectionId != null)
        'draftSectionId': draftSectionId,
      if (weight != null) 'weight': weight,
      if (weightUnits != null) 'weightUnits': weightUnits,
      if (marks != null) 'marks': marks,
      if (itemOrder != null) 'itemOrder': itemOrder,
      if (_hasText(overrideReason)) 'overrideReason': overrideReason!.trim(),
    };
  }
}

class DraftSectionOrderItem {
  const DraftSectionOrderItem({
    required this.sectionId,
    required this.sectionOrder,
  });

  final int sectionId;
  final int sectionOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sectionId': sectionId,
      'sectionOrder': sectionOrder,
    };
  }
}

class DraftItemOrderItem {
  const DraftItemOrderItem({required this.itemId, required this.itemOrder});

  final int itemId;
  final int itemOrder;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'itemId': itemId, 'itemOrder': itemOrder};
  }
}

Map<String, dynamic> examGenerationFormDataToJson(Object data) {
  if (data is ExamGenerationFormData) return data.toJson();
  if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
  throw ArgumentError.value(data, 'data', 'Unsupported exam generation data');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
