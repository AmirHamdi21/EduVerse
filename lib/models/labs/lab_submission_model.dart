import 'package:equatable/equatable.dart';

import '../core/drive_file_model.dart';
import '../core/enums/assignment_enums.dart';
import '../core/shared_models.dart';

class LabSubmissionModel extends Equatable {
  final int id;
  final int labId;
  final int userId;
  final String? submissionText;
  final int? fileId;
  final SubmissionStatus submissionStatus;
  final bool isLate;
  final DateTime submittedAt;
  final double? score;
  final String? feedback;
  final int? gradedBy;
  final DateTime? gradedAt;
  final UserInfo? user;
  final DriveFileModel? driveFile;
  final double? latePenaltyPercent;

  const LabSubmissionModel({
    required this.id,
    required this.labId,
    required this.userId,
    this.submissionText,
    this.fileId,
    required this.submissionStatus,
    required this.isLate,
    required this.submittedAt,
    this.score,
    this.feedback,
    this.gradedBy,
    this.gradedAt,
    this.user,
    this.driveFile,
    this.latePenaltyPercent,
  });

  factory LabSubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawDriveFile = json['driveFile'];
    final rawStatus = json['submissionStatus'] ?? json['status'];

    return LabSubmissionModel(
      id: _parseInt(json['id']),
      labId: _parseInt(json['labId']),
      userId: _parseInt(json['userId']),
      submissionText: json['submissionText']?.toString(),
      fileId: _parseNullableInt(json['fileId']),
      submissionStatus: SubmissionStatus.fromString(
        rawStatus?.toString() ?? 'unknown',
      ),
      isLate: _parseLateFlag(json['isLate']),
      submittedAt: _parseDateTime(json['submittedAt']) ?? DateTime.now(),
      score: _parseNullableDouble(json['score']),
      feedback: json['feedback']?.toString(),
      gradedBy: _parseNullableInt(json['gradedBy']),
      gradedAt: _parseDateTime(json['gradedAt']),
      user: rawUser is Map<String, dynamic> ? UserInfo.fromJson(rawUser) : null,
      driveFile: rawDriveFile is Map<String, dynamic>
          ? DriveFileModel.fromJson(rawDriveFile)
          : null,
      latePenaltyPercent: _parseNullableDouble(json['latePenaltyPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'labId': labId,
      'userId': userId,
      'submissionText': submissionText,
      'fileId': fileId,
      'submissionStatus': submissionStatus.toJson(),
      'isLate': isLate,
      'submittedAt': submittedAt.toIso8601String(),
      'score': score,
      'feedback': feedback,
      'gradedBy': gradedBy,
      'gradedAt': gradedAt?.toIso8601String(),
      'user': user?.toJson(),
      'driveFile': driveFile?.toJson(),
      'latePenaltyPercent': latePenaltyPercent,
    };
  }

  LabSubmissionModel copyWith({
    int? id,
    int? labId,
    int? userId,
    String? submissionText,
    int? fileId,
    SubmissionStatus? submissionStatus,
    bool? isLate,
    DateTime? submittedAt,
    double? score,
    String? feedback,
    int? gradedBy,
    DateTime? gradedAt,
    UserInfo? user,
    DriveFileModel? driveFile,
    double? latePenaltyPercent,
    bool clearSubmissionText = false,
    bool clearFileId = false,
    bool clearScore = false,
    bool clearFeedback = false,
    bool clearGradedBy = false,
    bool clearGradedAt = false,
    bool clearUser = false,
    bool clearDriveFile = false,
    bool clearLatePenaltyPercent = false,
  }) {
    return LabSubmissionModel(
      id: id ?? this.id,
      labId: labId ?? this.labId,
      userId: userId ?? this.userId,
      submissionText: clearSubmissionText
          ? null
          : (submissionText ?? this.submissionText),
      fileId: clearFileId ? null : (fileId ?? this.fileId),
      submissionStatus: submissionStatus ?? this.submissionStatus,
      isLate: isLate ?? this.isLate,
      submittedAt: submittedAt ?? this.submittedAt,
      score: clearScore ? null : (score ?? this.score),
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      gradedBy: clearGradedBy ? null : (gradedBy ?? this.gradedBy),
      gradedAt: clearGradedAt ? null : (gradedAt ?? this.gradedAt),
      user: clearUser ? null : (user ?? this.user),
      driveFile: clearDriveFile ? null : (driveFile ?? this.driveFile),
      latePenaltyPercent: clearLatePenaltyPercent
          ? null
          : (latePenaltyPercent ?? this.latePenaltyPercent),
    );
  }

  bool get isGraded => submissionStatus == SubmissionStatus.graded;

  String? scoreDisplay(double maxScore) {
    if (score == null) {
      return null;
    }
    return '${score!.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(0)}';
  }

  String get formattedSubmittedAt {
    final date = submittedAt;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final suffix = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $suffix';
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

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  static bool _parseLateFlag(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value == 1;
    }

    final parsed = num.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed == 1;
    }

    return false;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    labId,
    userId,
    submissionText,
    fileId,
    submissionStatus,
    isLate,
    submittedAt,
    score,
    feedback,
    gradedBy,
    gradedAt,
    user,
    driveFile,
    latePenaltyPercent,
  ];
}
