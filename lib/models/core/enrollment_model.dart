import 'package:equatable/equatable.dart';
import 'course_model.dart';
import 'section_model.dart';
import 'semester_model.dart';

/// Represents a user's enrollment to a specific course section.
///
/// Maps to the backend `GET /api/enrollments/my-courses` response shape:
/// ```json
/// {
///   "id": 150,
///   "userId": 42,
///   "sectionId": 5,
///   "status": "enrolled",
///   "grade": null,
///   "finalScore": null,
///   "enrollmentDate": "2026-08-15T10:00:00.000Z",
///   "canDrop": true,
///   "dropDeadline": "2026-09-01T23:59:59.000Z",
///   "course": { ... },
///   "section": { ... },
///   "semester": { ... }
/// }
/// ```
class CourseEnrollmentModel extends Equatable {
  final String id;
  final int userId;
  final int sectionId;
  final String status; // 'enrolled' | 'waitlisted' | 'dropped' | 'completed' | 'failed'
  final String? grade;
  final double? finalScore;
  final DateTime enrollmentDate;
  final bool canDrop;
  final DateTime? dropDeadline;
  final String role; // kept for backward compat — 'student' | 'instructor' | 'ta'

  // Nested relationships
  final CourseModel? course;
  final SectionModel? section;
  final SemesterModel? semester;

  const CourseEnrollmentModel({
    required this.id,
    required this.userId,
    required this.sectionId,
    required this.status,
    this.grade,
    this.finalScore,
    required this.enrollmentDate,
    this.canDrop = false,
    this.dropDeadline,
    this.role = 'student',
    this.course,
    this.section,
    this.semester,
  });

  /// Derived courseId for backward compatibility with widgets that use it.
  String get courseId => course?.courseId.toString() ?? '';

  factory CourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return CourseEnrollmentModel(
      id: (json['id'] ?? json['enrollmentId'] ?? '').toString(),
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      sectionId: json['sectionId'] is int
          ? json['sectionId'] as int
          : int.tryParse(json['sectionId']?.toString() ?? '') ?? 0,
      status: json['status'] as String? ?? 'enrolled',
      grade: json['grade'] as String?,
      finalScore: json['finalScore'] is num
          ? (json['finalScore'] as num).toDouble()
          : json['finalScore'] != null
              ? double.tryParse(json['finalScore'].toString())
              : null,
      enrollmentDate: _parseDate(
        json['enrollmentDate'] ?? json['createdAt'],
      ),
      canDrop: json['canDrop'] == true,
      dropDeadline: json['dropDeadline'] != null
          ? DateTime.tryParse(json['dropDeadline'].toString())
          : null,
      role: json['role'] as String? ?? 'student',
      course: json['course'] != null
          ? CourseModel.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      section: json['section'] != null
          ? SectionModel.fromJson(json['section'] as Map<String, dynamic>)
          : null,
      semester: json['semester'] != null
          ? SemesterModel.fromJson(json['semester'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Safe date parser — returns DateTime.now() as fallback if value is null/invalid.
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sectionId': sectionId,
      'status': status,
      'grade': grade,
      'finalScore': finalScore,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'canDrop': canDrop,
      'dropDeadline': dropDeadline?.toIso8601String(),
      'role': role,
      'course': course?.toJson(),
      'section': section?.toJson(),
      'semester': semester?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        sectionId,
        status,
        grade,
        finalScore,
        enrollmentDate,
        canDrop,
        dropDeadline,
        role,
        course,
        section,
        semester,
      ];
}
