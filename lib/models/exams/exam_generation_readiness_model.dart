class ExamGenerationReadinessBucketModel {
  const ExamGenerationReadinessBucketModel({
    this.id,
    required this.label,
    required this.count,
  });

  final int? id;
  final String label;
  final int count;

  factory ExamGenerationReadinessBucketModel.fromChapterJson(
    Map<String, dynamic> json,
  ) {
    return ExamGenerationReadinessBucketModel(
      id: _nullableInt(json['chapterId']),
      label: json['chapterName']?.toString() ?? 'Chapter ${json['chapterId']}',
      count: _toInt(json['count']),
    );
  }

  factory ExamGenerationReadinessBucketModel.fromValueJson(
    Map<String, dynamic> json,
  ) {
    return ExamGenerationReadinessBucketModel(
      label: json['value']?.toString() ?? '',
      count: _toInt(json['count']),
    );
  }
}

class ExamGenerationReadinessModel {
  const ExamGenerationReadinessModel({
    this.totalApproved = 0,
    this.grouped = 0,
    this.standalone = 0,
    this.byChapter = const <ExamGenerationReadinessBucketModel>[],
    this.byType = const <ExamGenerationReadinessBucketModel>[],
    this.byDifficulty = const <ExamGenerationReadinessBucketModel>[],
    this.byBloom = const <ExamGenerationReadinessBucketModel>[],
  });

  final int totalApproved;
  final int grouped;
  final int standalone;
  final List<ExamGenerationReadinessBucketModel> byChapter;
  final List<ExamGenerationReadinessBucketModel> byType;
  final List<ExamGenerationReadinessBucketModel> byDifficulty;
  final List<ExamGenerationReadinessBucketModel> byBloom;

  factory ExamGenerationReadinessModel.fromJson(Map<String, dynamic> json) {
    return ExamGenerationReadinessModel(
      totalApproved: _toInt(json['totalApproved']),
      grouped: _toInt(json['grouped']),
      standalone: _toInt(json['standalone']),
      byChapter: _asList(json['byChapter'])
          .whereType<Map<String, dynamic>>()
          .map(ExamGenerationReadinessBucketModel.fromChapterJson)
          .toList(),
      byType: _asList(json['byType'])
          .whereType<Map<String, dynamic>>()
          .map(ExamGenerationReadinessBucketModel.fromValueJson)
          .toList(),
      byDifficulty: _asList(json['byDifficulty'])
          .whereType<Map<String, dynamic>>()
          .map(ExamGenerationReadinessBucketModel.fromValueJson)
          .toList(),
      byBloom: _asList(json['byBloom'])
          .whereType<Map<String, dynamic>>()
          .map(ExamGenerationReadinessBucketModel.fromValueJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];
