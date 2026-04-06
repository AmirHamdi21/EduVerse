import 'package:equatable/equatable.dart';
import '../core/course_model.dart';

/// Represents a graded assignment tied to a course.
///
/// Maps to the backend `/api/assignments` endpoints.
class AssignmentModel extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String maxScore;
  final String weight;
  final String status; // 'draft' | 'published' | 'closed'
  final String submissionType; // 'text' | 'file' | 'link' | 'any'
  final num? latePenalty;
  final CourseModel? course;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.dueDate,
    required this.maxScore,
    required this.weight,
    required this.status,
    required this.submissionType,
    this.latePenalty,
    this.course,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      maxScore: json['maxScore']?.toString() ?? '0',
      weight: json['weight']?.toString() ?? '0',
      status: json['status'] as String? ?? 'draft',
      submissionType: json['submissionType'] as String? ?? 'any',
      latePenalty: json['latePenalty'] is num
          ? json['latePenalty'] as num
          : json['latePenalty'] != null
              ? num.tryParse(json['latePenalty'].toString())
              : null,
      course: json['course'] != null
          ? CourseModel.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'maxScore': maxScore,
      'weight': weight,
      'status': status,
      'submissionType': submissionType,
      'latePenalty': latePenalty,
      'course': course?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        dueDate,
        maxScore,
        weight,
        status,
        submissionType,
        latePenalty,
        course,
        createdAt,
        updatedAt,
      ];
}
