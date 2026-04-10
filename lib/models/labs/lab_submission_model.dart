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
  });

  factory LabSubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawDriveFile = json['driveFile'];

    return LabSubmissionModel(
      id: _parseInt(json['id']),
      labId: _parseInt(json['labId']),
      userId: _parseInt(json['userId']),
      submissionText: json['submissionText']?.toString(),
      fileId: _parseNullableInt(json['fileId']),
      submissionStatus: SubmissionStatus.fromString(
        json['submissionStatus']?.toString() ?? 'unknown',
      ),
      isLate: json['isLate'] == true,
      submittedAt: _parseDateTime(json['submittedAt']) ?? DateTime.now(),
      score: _parseNullableDouble(json['score']),
      feedback: json['feedback']?.toString(),
      gradedBy: _parseNullableInt(json['gradedBy']),
      gradedAt: _parseDateTime(json['gradedAt']),
      user: rawUser is Map<String, dynamic> ? UserInfo.fromJson(rawUser) : null,
      driveFile: rawDriveFile is Map<String, dynamic>
          ? DriveFileModel.fromJson(rawDriveFile)
          : null,
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
    };
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
  ];
}
