class ExamReplacementCheckModel {
  const ExamReplacementCheckModel({
    required this.matchesOriginalRules,
    this.reasons = const <String>[],
    required this.requiresOverrideReason,
  });

  final bool matchesOriginalRules;
  final List<String> reasons;
  final bool requiresOverrideReason;

  factory ExamReplacementCheckModel.fromJson(Map<String, dynamic> json) {
    return ExamReplacementCheckModel(
      matchesOriginalRules: json['matchesOriginalRules'] == true,
      reasons: _asList(json['reasons']).map((item) => item.toString()).toList(),
      requiresOverrideReason: json['requiresOverrideReason'] == true,
    );
  }
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];
