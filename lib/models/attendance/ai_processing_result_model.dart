import 'package:equatable/equatable.dart';

/// Maps POST /attendance/ai-photo and GET /attendance/ai-photo/:id responses.
class AiProcessingResultModel extends Equatable {
  final int processingId;
  final String
  status; // pending | processing | completed | failed | manual_review
  final int? detectedFacesCount;
  final int? matchedStudentsCount;
  final int? unmatchedFacesCount;
  final String? errorMessage;
  final int? processingTimeMs;

  const AiProcessingResultModel({
    required this.processingId,
    required this.status,
    this.detectedFacesCount,
    this.matchedStudentsCount,
    this.unmatchedFacesCount,
    this.errorMessage,
    this.processingTimeMs,
  });

  factory AiProcessingResultModel.fromJson(Map<String, dynamic> json) {
    return AiProcessingResultModel(
      processingId: _toInt(json['processingId']),
      status: json['status']?.toString() ?? 'pending',
      detectedFacesCount: _toNullableInt(json['detectedFacesCount']),
      matchedStudentsCount: _toNullableInt(json['matchedStudentsCount']),
      unmatchedFacesCount: _toNullableInt(json['unmatchedFacesCount']),
      errorMessage: json['errorMessage']?.toString(),
      processingTimeMs: _toNullableInt(json['processingTimeMs']),
    );
  }

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isFailed => status.toLowerCase() == 'failed';

  bool get needsManualReview => status.toLowerCase() == 'manual_review';

  bool get isProcessing => !isCompleted && !isFailed && !needsManualReview;

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value is int) return value;
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    processingId,
    status,
    detectedFacesCount,
    matchedStudentsCount,
    unmatchedFacesCount,
    errorMessage,
    processingTimeMs,
  ];
}
