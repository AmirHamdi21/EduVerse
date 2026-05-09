import '../question_bank/question_bank_enums.dart';
import 'exam_generator_enums.dart';

class ExamAvailabilityBucketModel {
  const ExamAvailabilityBucketModel({
    required this.sectionIndex,
    required this.sectionTitle,
    required this.ruleIndex,
    required this.required,
    required this.available,
    required this.canGenerate,
    required this.scope,
    this.chapterIds = const <int>[],
    this.groupIds = const <int>[],
    this.questionType,
    this.difficulty,
    this.bloomLevel,
    required this.groupSelectionMode,
    this.skippedGroupsTooLarge = 0,
    this.matchingGroupCount = 0,
    this.largestSkippedGroupSize = 0,
    this.filters = const <String, dynamic>{},
  });

  final int? sectionIndex;
  final String? sectionTitle;
  final int ruleIndex;
  final int required;
  final int available;
  final bool canGenerate;
  final ExamGenerationScope scope;
  final List<int> chapterIds;
  final List<int> groupIds;
  final QuestionBankType? questionType;
  final QuestionBankDifficulty? difficulty;
  final BloomLevel? bloomLevel;
  final ExamGroupSelectionMode groupSelectionMode;
  final int skippedGroupsTooLarge;
  final int matchingGroupCount;
  final int largestSkippedGroupSize;
  final Map<String, dynamic> filters;

  bool get isClose => canGenerate && available <= required + 2;
  bool get hasTooLargeGroups => skippedGroupsTooLarge > 0;

  factory ExamAvailabilityBucketModel.fromJson(Map<String, dynamic> json) {
    return ExamAvailabilityBucketModel(
      sectionIndex: _nullableInt(json['sectionIndex']),
      sectionTitle: _nullableString(json['sectionTitle']),
      ruleIndex: _toInt(json['ruleIndex']),
      required: _toInt(json['required']),
      available: _toInt(json['available']),
      canGenerate: json['canGenerate'] == true,
      scope: ExamGenerationScope.fromJson(json['scope']),
      chapterIds: _intList(json['chapterIds']),
      groupIds: _intList(json['groupIds']),
      questionType: json['questionType'] == null
          ? null
          : QuestionBankType.fromJson(json['questionType']),
      difficulty: json['difficulty'] == null
          ? null
          : QuestionBankDifficulty.fromJson(json['difficulty']),
      bloomLevel:
          json['bloomLevel'] == null ? null : BloomLevel.fromJson(json['bloomLevel']),
      groupSelectionMode:
          ExamGroupSelectionMode.fromJson(json['groupSelectionMode']),
      skippedGroupsTooLarge: _toInt(json['skippedGroupsTooLarge']),
      matchingGroupCount: _toInt(json['matchingGroupCount']),
      largestSkippedGroupSize: _toInt(json['largestSkippedGroupSize']),
      filters: _map(json['filters']),
    );
  }
}

class ExamAvailabilityModel {
  const ExamAvailabilityModel({
    required this.totalRequired,
    required this.totalAvailable,
    required this.canGenerate,
    this.buckets = const <ExamAvailabilityBucketModel>[],
  });

  final int totalRequired;
  final int totalAvailable;
  final bool canGenerate;
  final List<ExamAvailabilityBucketModel> buckets;

  factory ExamAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return ExamAvailabilityModel(
      totalRequired: _toInt(json['totalRequired']),
      totalAvailable: _toInt(json['totalAvailable']),
      canGenerate: json['canGenerate'] == true,
      buckets: _asList(json['buckets'])
          .whereType<Map<String, dynamic>>()
          .map(ExamAvailabilityBucketModel.fromJson)
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

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<int> _intList(dynamic value) {
  return _asList(value).map(_toInt).where((id) => id > 0).toList();
}
