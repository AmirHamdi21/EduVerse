import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../core/drive_file_model.dart';
import '../core/enums/assignment_enums.dart';

class AssignmentFormData extends Equatable {
  final String title;
  final String? description;
  final String? instructions;
  final List<DriveFileModel> instructionFiles;
  final DateTime? dueDate;
  final double maxScore;
  final double? weight;
  final SubmissionType submissionType;
  final int? maxFileSizeMb;
  final List<String> allowedFileTypes;
  final double? latePenaltyPercent;
  final AssignmentStatus status;
  final int courseId;

  const AssignmentFormData({
    required this.title,
    this.description,
    this.instructions,
    this.instructionFiles = const <DriveFileModel>[],
    this.dueDate,
    required this.maxScore,
    this.weight,
    required this.submissionType,
    this.maxFileSizeMb,
    this.allowedFileTypes = const <String>[],
    this.latePenaltyPercent,
    required this.status,
    required this.courseId,
  });

  factory AssignmentFormData.fromJson(Map<String, dynamic> json) {
    return AssignmentFormData(
      title: (json['title']?.toString() ?? '').trim(),
      description: _nullableText(json['description']),
      instructions: _nullableText(json['instructions']),
      instructionFiles: _parseInstructionFiles(json['instructionFiles']),
      dueDate: _parseDateTime(json['dueDate']),
      maxScore: _parseDouble(json['maxScore'], fallback: 100),
      weight: _parseNullableDouble(json['weight']),
      submissionType: SubmissionType.fromString(
        json['submissionType']?.toString() ?? SubmissionType.file.value,
      ),
      maxFileSizeMb: _parseNullableInt(json['maxFileSizeMb']),
      allowedFileTypes: _parseAllowedFileTypes(json['allowedFileTypes']),
      latePenaltyPercent: _parseNullableDouble(json['latePenaltyPercent']),
      status: AssignmentStatus.fromString(
        json['status']?.toString() ?? AssignmentStatus.draft.value,
      ),
      courseId: _parseInt(json['courseId']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title.trim(),
      if (_nullableText(description) != null)
        'description': description!.trim(),
      if (_nullableText(instructions) != null)
        'instructions': instructions!.trim(),
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'maxScore': maxScore,
      if (weight != null) 'weight': weight,
      'submissionType': submissionType.toJson(),
      if (maxFileSizeMb != null) 'maxFileSizeMb': maxFileSizeMb,
      if (allowedFileTypes.isNotEmpty)
        'allowedFileTypes': jsonEncode(allowedFileTypes),
      if (latePenaltyPercent != null) 'latePenaltyPercent': latePenaltyPercent,
      'status': status.toJson(),
      'courseId': courseId,
    };
  }

  AssignmentFormData copyWith({
    String? title,
    String? description,
    String? instructions,
    List<DriveFileModel>? instructionFiles,
    DateTime? dueDate,
    double? maxScore,
    double? weight,
    SubmissionType? submissionType,
    int? maxFileSizeMb,
    List<String>? allowedFileTypes,
    double? latePenaltyPercent,
    AssignmentStatus? status,
    int? courseId,
  }) {
    return AssignmentFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      instructions: instructions ?? this.instructions,
      instructionFiles: instructionFiles ?? this.instructionFiles,
      dueDate: dueDate ?? this.dueDate,
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      submissionType: submissionType ?? this.submissionType,
      maxFileSizeMb: maxFileSizeMb ?? this.maxFileSizeMb,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      latePenaltyPercent: latePenaltyPercent ?? this.latePenaltyPercent,
      status: status ?? this.status,
      courseId: courseId ?? this.courseId,
    );
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value, {double fallback = 0}) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static List<String> _parseAllowedFileTypes(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const <String>[];
      }

      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          return decoded
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList();
        }
      } catch (_) {
        return trimmed
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
    }

    return const <String>[];
  }

  static List<DriveFileModel> _parseInstructionFiles(dynamic value) {
    if (value is! List) {
      return const <DriveFileModel>[];
    }

    final files = <DriveFileModel>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        files.add(DriveFileModel.fromJson(item));
      } else if (item is Map) {
        files.add(DriveFileModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return files;
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    description,
    instructions,
    instructionFiles,
    dueDate,
    maxScore,
    weight,
    submissionType,
    maxFileSizeMb,
    allowedFileTypes,
    latePenaltyPercent,
    status,
    courseId,
  ];
}
