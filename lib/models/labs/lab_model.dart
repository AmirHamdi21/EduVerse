import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../core/drive_file_model.dart';
import '../core/enums/lab_enums.dart' as api;
import '../core/lab_instruction_model.dart';
import '../core/shared_models.dart';

class LabModel extends Equatable {
  final String id;
  final int? labId;
  final int courseId;
  final String title;
  final String? description;
  final int? labNumber;
  final DateTime? dueDate;
  final DateTime? availableFrom;
  final double maxScore;
  final double weight;
  final api.LabStatus status;
  final int? createdBy;
  final String? allowedFileTypes;
  final double? maxFileSizeMb;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CourseInfo? course;
  final List<LabInstructionModel> instructions;
  final List<DriveFileModel> instructionFiles;

  const LabModel({
    required this.id,
    this.labId,
    required this.courseId,
    required this.title,
    this.description,
    this.labNumber,
    this.dueDate,
    this.availableFrom,
    required this.maxScore,
    this.weight = 0,
    this.status = api.LabStatus.unknown,
    this.createdBy,
    this.allowedFileTypes,
    this.maxFileSizeMb,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.instructions = const <LabInstructionModel>[],
    this.instructionFiles = const <DriveFileModel>[],
  });

  factory LabModel.fromJson(Map<String, dynamic> json) {
    final parsedInstructions = _parseInstructions(json['instructions']);
    final parsedInstructionFiles =
        _parseDriveFiles(json['instructionFiles']) ?? const <DriveFileModel>[];

    return LabModel(
      id: _parseString(json['id'] ?? json['labId']),
      labId: _parseNullableInt(json['labId'] ?? json['id']),
      courseId: _parseInt(
        json['courseId'] ??
            ((json['course'] as Map<String, dynamic>?)?['id']) ??
            0,
      ),
      title: _parseString(json['title']),
      description: _parseNullableString(json['description']),
      labNumber: _parseNullableInt(json['labNumber']),
      dueDate: _parseDateTime(json['dueDate']),
      availableFrom: _parseDateTime(json['availableFrom']),
      maxScore: _parseDouble(json['maxScore']),
      weight: _parseDouble(json['weight']),
      status: api.LabStatus.fromString(_parseString(json['status'])),
      createdBy: _parseNullableInt(json['createdBy']),
      allowedFileTypes: _parseAllowedFileTypes(json['allowedFileTypes']),
      maxFileSizeMb: _parseNullableDouble(json['maxFileSizeMb']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      course: json['course'] is Map<String, dynamic>
          ? CourseInfo.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      instructions: parsedInstructions,
      instructionFiles: parsedInstructionFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'labId': labId,
      'courseId': courseId,
      'title': title,
      'description': description,
      'labNumber': labNumber,
      'dueDate': dueDate?.toIso8601String(),
      'availableFrom': availableFrom?.toIso8601String(),
      'maxScore': maxScore,
      'weight': weight,
      'status': status.toJson(),
      'createdBy': createdBy,
      'allowedFileTypes': allowedFileTypes,
      'maxFileSizeMb': maxFileSizeMb,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'course': course?.toJson(),
      'instructions': instructions.map((item) => item.toJson()).toList(),
      'instructionFiles': instructionFiles
          .map((item) => item.toJson())
          .toList(),
    };
  }

  LabModel copyWith({
    String? id,
    int? labId,
    int? courseId,
    String? title,
    String? description,
    int? labNumber,
    DateTime? dueDate,
    DateTime? availableFrom,
    double? maxScore,
    double? weight,
    api.LabStatus? status,
    int? createdBy,
    String? allowedFileTypes,
    double? maxFileSizeMb,
    DateTime? createdAt,
    DateTime? updatedAt,
    CourseInfo? course,
    List<LabInstructionModel>? instructions,
    List<DriveFileModel>? instructionFiles,
    bool clearDescription = false,
    bool clearDueDate = false,
    bool clearAvailableFrom = false,
    bool clearLabNumber = false,
    bool clearAllowedFileTypes = false,
    bool clearMaxFileSizeMb = false,
  }) {
    return LabModel(
      id: id ?? this.id,
      labId: labId ?? this.labId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      labNumber: clearLabNumber ? null : (labNumber ?? this.labNumber),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      availableFrom: clearAvailableFrom
          ? null
          : (availableFrom ?? this.availableFrom),
      maxScore: maxScore ?? this.maxScore,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      allowedFileTypes: clearAllowedFileTypes
          ? null
          : (allowedFileTypes ?? this.allowedFileTypes),
      maxFileSizeMb: clearMaxFileSizeMb
          ? null
          : (maxFileSizeMb ?? this.maxFileSizeMb),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      course: course ?? this.course,
      instructions: instructions ?? this.instructions,
      instructionFiles: instructionFiles ?? this.instructionFiles,
    );
  }

  bool get isPastDue => dueDate != null && dueDate!.isBefore(DateTime.now());

  bool get isAcceptingSubmissions => status == api.LabStatus.published;

  String get formattedDueDate {
    if (dueDate == null) {
      return 'No due date';
    }

    final value = dueDate!;
    final months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = value.hour > 12 ? value.hour - 12 : value.hour;
    final suffix = value.hour >= 12 ? 'PM' : 'AM';

    return '${months[value.month - 1]} ${value.day}, ${value.year} • '
        '${hour == 0 ? 12 : hour}:${value.minute.toString().padLeft(2, '0')} $suffix';
  }

  int? get daysUntilDue {
    if (dueDate == null) {
      return null;
    }
    return dueDate!.difference(DateTime.now()).inDays;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
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

  static double _parseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final parsed = value.toString().trim();
    return parsed.isEmpty ? null : parsed;
  }

  static String? _parseAllowedFileTypes(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is List) {
      final items = value
          .map((item) => item.toString().trim().toLowerCase())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
      return items.isEmpty ? null : items.join(',');
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final items = decoded
            .map((item) => item.toString().trim().toLowerCase())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
        return items.isEmpty ? null : items.join(',');
      }
    } catch (_) {
      // Fallback to plain comma-separated parsing when value is not JSON.
    }

    final splitValues = raw
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return splitValues.isEmpty ? null : splitValues.join(',');
  }

  static List<DriveFileModel>? _parseDriveFiles(dynamic value) {
    if (value is! List) {
      return null;
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(DriveFileModel.fromJson)
        .toList();
  }

  static List<LabInstructionModel> _parseInstructions(dynamic value) {
    if (value is! List) {
      return const <LabInstructionModel>[];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(LabInstructionModel.fromJson)
        .toList();
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    labId,
    courseId,
    title,
    description,
    labNumber,
    dueDate,
    availableFrom,
    maxScore,
    weight,
    status,
    createdBy,
    allowedFileTypes,
    maxFileSizeMb,
    createdAt,
    updatedAt,
    course,
    instructions,
    instructionFiles,
  ];
}
