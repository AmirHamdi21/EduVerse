import 'package:equatable/equatable.dart';
import 'course_model.dart';
import 'enums/enrollment_enums.dart';
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
  final EnrollmentStatus enrollmentStatus;
  final String? grade;
  final double? finalScore;
  final DateTime enrollmentDate;
  final bool canDrop;
  final DateTime? dropDeadline;
  final int? materialsViewed;
  final int? totalMaterials;
  final double? progressPercentage;
  final String
  role; // kept for backward compat — 'student' | 'instructor' | 'ta'

  // Nested relationships
  final CourseModel? course;
  final SectionModel? section;
  final SemesterModel? semester;
  final UserLite? instructor;
  final List<EnrollmentPrerequisite>? prerequisites;

  const CourseEnrollmentModel({
    required this.id,
    required this.userId,
    required this.sectionId,
    required this.enrollmentStatus,
    this.grade,
    this.finalScore,
    required this.enrollmentDate,
    this.canDrop = false,
    this.dropDeadline,
    this.materialsViewed,
    this.totalMaterials,
    this.progressPercentage,
    this.role = 'student',
    this.course,
    this.section,
    this.semester,
    this.instructor,
    this.prerequisites,
  });

  String get status => enrollmentStatus.toJson();

  /// Derived courseId for backward compatibility with widgets that use it.
  String get courseId => course?.courseId.toString() ?? '';

  factory CourseEnrollmentModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawInstructor = json['instructor'];
    final dynamic rawPrerequisites = json['prerequisites'];

    return CourseEnrollmentModel(
      id: (json['id'] ?? json['enrollmentId'] ?? '').toString(),
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      sectionId: json['sectionId'] is int
          ? json['sectionId'] as int
          : int.tryParse(json['sectionId']?.toString() ?? '') ?? 0,
      enrollmentStatus: EnrollmentStatus.fromString(
        json['status']?.toString() ?? 'unknown',
      ),
      grade: json['grade'] as String?,
      finalScore: json['finalScore'] is num
          ? (json['finalScore'] as num).toDouble()
          : json['finalScore'] != null
          ? double.tryParse(json['finalScore'].toString())
          : null,
      enrollmentDate: _parseDate(json['enrollmentDate'] ?? json['createdAt']),
      canDrop: json['canDrop'] == true,
      dropDeadline: json['dropDeadline'] != null
          ? DateTime.tryParse(json['dropDeadline'].toString())
          : null,
      materialsViewed: _parseNullableInt(json['materialsViewed']),
      totalMaterials: _parseNullableInt(json['totalMaterials']),
      progressPercentage: _parseNullableDouble(json['progressPercentage']),
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
      instructor: rawInstructor is Map<String, dynamic>
          ? UserLite.fromJson(rawInstructor)
          : null,
      prerequisites: rawPrerequisites is List
          ? rawPrerequisites
                .whereType<Map<String, dynamic>>()
                .map(EnrollmentPrerequisite.fromJson)
                .toList()
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sectionId': sectionId,
      'status': enrollmentStatus.toJson(),
      'grade': grade,
      'finalScore': finalScore,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'canDrop': canDrop,
      'dropDeadline': dropDeadline?.toIso8601String(),
      'materialsViewed': materialsViewed,
      'totalMaterials': totalMaterials,
      'progressPercentage': progressPercentage,
      'role': role,
      'course': course?.toJson(),
      'section': section?.toJson(),
      'semester': semester?.toJson(),
      'instructor': instructor == null
          ? null
          : {
              'id': instructor!.userId,
              'firstName': instructor!.firstName,
              'lastName': instructor!.lastName,
              'email': instructor!.email,
            },
      'prerequisites': prerequisites?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    sectionId,
    enrollmentStatus,
    grade,
    finalScore,
    enrollmentDate,
    canDrop,
    dropDeadline,
    materialsViewed,
    totalMaterials,
    progressPercentage,
    role,
    course,
    section,
    semester,
    instructor,
    prerequisites,
  ];
}

class EnrollmentPrerequisite extends Equatable {
  final int id;
  final int courseId;
  final int prerequisiteCourseId;
  final String courseCode;
  final String courseName;
  final bool isMandatory;
  final bool studentCompleted;
  final String? studentGrade;

  const EnrollmentPrerequisite({
    required this.id,
    required this.courseId,
    required this.prerequisiteCourseId,
    required this.courseCode,
    required this.courseName,
    required this.isMandatory,
    required this.studentCompleted,
    this.studentGrade,
  });

  factory EnrollmentPrerequisite.fromJson(Map<String, dynamic> json) {
    return EnrollmentPrerequisite(
      id: EnrollmentModel._parseInt(json['id']),
      courseId: EnrollmentModel._parseInt(json['courseId']),
      prerequisiteCourseId: EnrollmentModel._parseInt(
        json['prerequisiteCourseId'],
      ),
      courseCode: json['courseCode']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      isMandatory: json['isMandatory'] == true,
      studentCompleted: json['studentCompleted'] == true,
      studentGrade: json['studentGrade']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'prerequisiteCourseId': prerequisiteCourseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'isMandatory': isMandatory,
      'studentCompleted': studentCompleted,
      'studentGrade': studentGrade,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    prerequisiteCourseId,
    courseCode,
    courseName,
    isMandatory,
    studentCompleted,
    studentGrade,
  ];
}

class EnrollmentModel extends Equatable {
  final int id;
  final int userId;
  final int sectionId;
  final EnrollmentStatus enrollmentStatus;
  final String role;
  final UserLite? user;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.sectionId,
    required this.enrollmentStatus,
    required this.role,
    this.user,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    return EnrollmentModel(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      sectionId: _parseInt(json['sectionId']),
      enrollmentStatus: EnrollmentStatus.fromString(
        json['status']?.toString() ?? 'unknown',
      ),
      role: json['role']?.toString() ?? '',
      user: rawUser is Map<String, dynamic> ? UserLite.fromJson(rawUser) : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    sectionId,
    enrollmentStatus,
    role,
    user,
  ];
}

class UserLite extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;

  const UserLite({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserLite.fromJson(Map<String, dynamic> json) {
    return UserLite(
      userId: EnrollmentModel._parseInt(json['userId'] ?? json['id']),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => <Object?>[userId, firstName, lastName, email];
}
