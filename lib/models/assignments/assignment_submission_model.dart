import 'package:equatable/equatable.dart';

import '../core/drive_file_model.dart';
import '../core/enums/assignment_enums.dart';
import '../core/shared_models.dart';

class AssignmentSubmissionModel extends Equatable {
  final int id;
  final int assignmentId;
  final int userId;
  final String? submissionText;
  final String? submissionLink;
  final int? fileId;
  final SubmissionStatus submissionStatus;
  final bool isLate;
  final int attemptNumber;
  final DateTime submittedAt;
  final double? score;
  final String? feedback;
  final int? gradedBy;
  final DateTime? gradedAt;
  final UserInfo? user;
  final DriveFileModel? driveFile;

  const AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.userId,
    this.submissionText,
    this.submissionLink,
    this.fileId,
    required this.submissionStatus,
    required this.isLate,
    required this.attemptNumber,
    required this.submittedAt,
    this.score,
    this.feedback,
    this.gradedBy,
    this.gradedAt,
    this.user,
    this.driveFile,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawDriveFile = json['driveFile'];

    return AssignmentSubmissionModel(
      id: _parseInt(json['id']),
      assignmentId: _parseInt(json['assignmentId']),
      userId: _parseInt(json['userId']),
      submissionText: json['submissionText']?.toString(),
      submissionLink: json['submissionLink']?.toString(),
      fileId: _parseNullableInt(json['fileId']),
      submissionStatus: SubmissionStatus.fromString(
        json['submissionStatus']?.toString() ?? 'unknown',
      ),
      isLate: _parseInt(json['isLate']) == 1,
      attemptNumber: _parseInt(json['attemptNumber']),
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
      'assignmentId': assignmentId,
      'userId': userId,
      'submissionText': submissionText,
      'submissionLink': submissionLink,
      'fileId': fileId,
      'submissionStatus': submissionStatus.toJson(),
      'isLate': isLate ? 1 : 0,
      'attemptNumber': attemptNumber,
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
    assignmentId,
    userId,
    submissionText,
    submissionLink,
    fileId,
    submissionStatus,
    isLate,
    attemptNumber,
    submittedAt,
    score,
    feedback,
    gradedBy,
    gradedAt,
    user,
    driveFile,
  ];
}
