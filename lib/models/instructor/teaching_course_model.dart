import 'package:equatable/equatable.dart';
import '../core/course_model.dart';
import '../core/section_model.dart';
import '../core/semester_model.dart';

/// Represents an instructor's or TA's teaching assignment.
///
/// Maps to the backend `GET /api/enrollments/teaching` response shape:
/// ```json
/// {
///   "sectionId": 5,
///   "courseId": 10,
///   "course": { ... },
///   "section": { ... },
///   "semester": { ... }
/// }
/// ```
///
/// Unlike [CourseEnrollmentModel] (student flow), this model is streamlined
/// and does NOT include student-specific fields like `status`, `grade`, or
/// `dropDeadline`.
class TeachingCourseModel extends Equatable {
  final int sectionId;
  final int userId;
  final int courseId;
  final String role;
  final CourseModel course;
  final SectionModel section;
  final SemesterModel semester;
  final int enrolledCount;
  final int capacity;
  final double? averageGrade;
  final double? attendanceRate;

  const TeachingCourseModel({
    required this.sectionId,
    this.userId = 0,
    required this.courseId,
    this.role = 'instructor',
    required this.course,
    required this.section,
    required this.semester,
    this.enrolledCount = 0,
    this.capacity = 0,
    this.averageGrade,
    this.attendanceRate,
  });

  factory TeachingCourseModel.fromJson(Map<String, dynamic> json) {
    final rawCourse = json['course'];
    final rawSection = json['section'];
    final rawSemester = json['semester'];

    final sectionModel = rawSection is Map<String, dynamic>
        ? SectionModel.fromJson(rawSection)
        : SectionModel.fromJson(const <String, dynamic>{});

    return TeachingCourseModel(
      sectionId: _toInt(json['sectionId']),
      userId: _toInt(json['userId']),
      courseId: _toInt(json['courseId']),
      role: json['role']?.toString() ?? 'instructor',
      course: rawCourse is Map<String, dynamic>
          ? CourseModel.fromJson(rawCourse)
          : CourseModel.fromJson(const <String, dynamic>{}),
      section: sectionModel,
      semester: rawSemester is Map<String, dynamic>
          ? SemesterModel.fromJson(rawSemester)
          : SemesterModel.fromJson(const <String, dynamic>{}),
      enrolledCount: _toInt(json['enrolledCount']) == 0
          ? sectionModel.currentEnrollment
          : _toInt(json['enrolledCount']),
      capacity: _toInt(json['capacity']) == 0
          ? sectionModel.maxCapacity
          : _toInt(json['capacity']),
      averageGrade: _toDouble(json['averageGrade']),
      attendanceRate: _toDouble(json['attendanceRate']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'userId': userId,
      'courseId': courseId,
      'role': role,
      'course': course.toJson(),
      'section': section.toJson(),
      'semester': semester.toJson(),
      'enrolledCount': enrolledCount,
      'capacity': capacity,
      'averageGrade': averageGrade,
      'attendanceRate': attendanceRate,
    };
  }

  @override
  List<Object?> get props => [
    sectionId,
    userId,
    courseId,
    role,
    course,
    section,
    semester,
    enrolledCount,
    capacity,
    averageGrade,
    attendanceRate,
  ];
}
