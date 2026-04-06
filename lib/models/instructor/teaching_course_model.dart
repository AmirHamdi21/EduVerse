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
  final int courseId;
  final CourseModel course;
  final SectionModel section;
  final SemesterModel semester;

  const TeachingCourseModel({
    required this.sectionId,
    required this.courseId,
    required this.course,
    required this.section,
    required this.semester,
  });

  factory TeachingCourseModel.fromJson(Map<String, dynamic> json) {
    return TeachingCourseModel(
      sectionId: json['sectionId'] is int
          ? json['sectionId'] as int
          : int.tryParse(json['sectionId']?.toString() ?? '') ?? 0,
      courseId: json['courseId'] is int
          ? json['courseId'] as int
          : int.tryParse(json['courseId']?.toString() ?? '') ?? 0,
      course: CourseModel.fromJson(json['course'] as Map<String, dynamic>),
      section: SectionModel.fromJson(json['section'] as Map<String, dynamic>),
      semester: SemesterModel.fromJson(
        json['semester'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'courseId': courseId,
      'course': course.toJson(),
      'section': section.toJson(),
      'semester': semester.toJson(),
    };
  }

  @override
  List<Object?> get props => [sectionId, courseId, course, section, semester];
}
