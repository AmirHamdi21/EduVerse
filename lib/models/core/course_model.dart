import 'package:equatable/equatable.dart';

/// Represents a single course from the backend `/api/courses` endpoint.
///
/// Maps to the web front-end's `Course` type in `src/types/api.ts`.
class CourseModel extends Equatable {
  final int courseId;
  final String courseCode;
  final String courseName;
  final String? description;
  final int credits;
  final int? departmentId;
  final String? departmentName;
  final String? level;
  final String? status;
  final List<Map<String, dynamic>>? prerequisites;

  const CourseModel({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.description,
    required this.credits,
    this.departmentId,
    this.departmentName,
    this.level,
    this.status,
    this.prerequisites,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      // Accept both 'id' (backend) and 'courseId' (app convention)
      courseId: json['courseId'] is int
          ? json['courseId'] as int
          : json['id'] is int
              ? json['id'] as int
              : int.tryParse(
                      (json['courseId'] ?? json['id'])?.toString() ?? '') ??
                  0,
      // Accept both 'code' (backend) and 'courseCode' (app convention)
      courseCode:
          (json['courseCode'] as String?) ?? (json['code'] as String?) ?? '',
      // Accept both 'name' (backend) and 'courseName' (app convention)
      courseName:
          (json['courseName'] as String?) ?? (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      credits: json['credits'] is int
          ? json['credits'] as int
          : int.tryParse(json['credits']?.toString() ?? '') ?? 0,
      departmentId: json['departmentId'] is int
          ? json['departmentId'] as int
          : json['departmentId'] != null
              ? int.tryParse(json['departmentId'].toString())
              : null,
      departmentName: json['departmentName'] as String?,
      level: json['level']?.toString(),
      status: json['status'] as String?,
      prerequisites: json['prerequisites'] != null
          ? List<Map<String, dynamic>>.from(
              (json['prerequisites'] as List)
                  .map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'credits': credits,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'level': level,
      'status': status,
      'prerequisites': prerequisites,
    };
  }

  @override
  List<Object?> get props => [
        courseId,
        courseCode,
        courseName,
        description,
        credits,
        departmentId,
        departmentName,
        level,
        status,
        prerequisites,
      ];
}
