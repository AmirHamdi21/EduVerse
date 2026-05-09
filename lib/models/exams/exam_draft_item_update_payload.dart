class ExamDraftItemUpdatePayload {
  const ExamDraftItemUpdatePayload({
    this.replacementQuestionId,
    this.draftSectionId,
    this.weight,
    this.weightUnits,
    this.marks,
    this.itemOrder,
    this.overrideReason,
  });

  final int? replacementQuestionId;
  final int? draftSectionId;
  final double? weight;
  final double? weightUnits;
  final double? marks;
  final int? itemOrder;
  final String? overrideReason;

  String? validate({bool requiresOverrideReason = false}) {
    if (replacementQuestionId != null && replacementQuestionId! <= 0) {
      return 'Replacement question is required';
    }
    if (draftSectionId != null && draftSectionId! <= 0) {
      return 'Section must be valid';
    }
    if (weight != null && weight! < 0) return 'Weight cannot be negative';
    if (weightUnits != null && weightUnits! < 0) {
      return 'Weight units cannot be negative';
    }
    if (marks != null && marks! < 0) return 'Marks cannot be negative';
    if (itemOrder != null && itemOrder! < 0) {
      return 'Item order cannot be negative';
    }
    if (requiresOverrideReason &&
        (overrideReason == null || overrideReason!.trim().isEmpty)) {
      return 'Override reason is required';
    }
    return null;
  }
}
