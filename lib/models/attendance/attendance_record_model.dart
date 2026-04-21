import 'package:equatable/equatable.dart';

/// Maps nested records[] from GET /attendance/sessions/:id.
/// Matches web LectureAttendanceFlow.tsx types L38-51 (AttUser, AttRecord).
class AttendanceRecordModel extends Equatable {
  final int userId;
  final String attendanceStatus; // "present" | "absent" | "late" | "excused"
  final String? markedBy; // "manual" | "ai"
  final double? confidenceScore; // 0.0–1.0 from AI, null for manual
  final String? notes;
  final String? checkinTime;
  final String? firstName;
  final String? lastName;
  final String? email;

  const AttendanceRecordModel({
    required this.userId,
    required this.attendanceStatus,
    this.markedBy,
    this.confidenceScore,
    this.notes,
    this.checkinTime,
    this.firstName,
    this.lastName,
    this.email,
  });

  /// Handles both flat fields and nested user object.
  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AttendanceRecordModel(
      userId: _toInt(json['userId']),
      attendanceStatus: normalizeStatus(json['attendanceStatus']?.toString()),
      markedBy: json['markedBy']?.toString(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      checkinTime: json['checkinTime']?.toString(),
      firstName:
          user?['firstName']?.toString() ?? json['firstName']?.toString(),
      lastName: user?['lastName']?.toString() ?? json['lastName']?.toString(),
      email: user?['email']?.toString() ?? json['email']?.toString(),
    );
  }

  String get displayName {
    final parts = [
      firstName,
      lastName,
    ].where((s) => s != null && s.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (email != null && email!.isNotEmpty) return email!;
    return 'Student #$userId';
  }

  static String normalizeStatus(String? s) {
    final x = (s ?? 'absent').toLowerCase();
    const valid = ['present', 'absent', 'late', 'excused'];
    return valid.contains(x) ? x : 'absent';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    userId,
    attendanceStatus,
    markedBy,
    confidenceScore,
    notes,
    checkinTime,
    firstName,
    lastName,
    email,
  ];
}
