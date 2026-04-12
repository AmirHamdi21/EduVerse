import 'package:equatable/equatable.dart';
import '../materials/course_material_model.dart';

/// Represents organizational structure items within a course timeline
/// (lectures, labs, sections, tutorials).
///
/// Maps to the backend `/api/courses/{courseId}/structure` endpoints.
class CourseStructureModel extends Equatable {
  final String organizationId;
  final String courseId;
  final String? materialId;
  final CourseMaterialModel? material;
  final String organizationType; // 'lecture' | 'lab' | 'section' | 'tutorial'
  final String title;
  final int weekNumber;
  final int orderIndex;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CourseStructureModel({
    required this.organizationId,
    required this.courseId,
    this.materialId,
    this.material,
    required this.organizationType,
    required this.title,
    required this.weekNumber,
    required this.orderIndex,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CourseStructureModel.fromJson(Map<String, dynamic> json) {
    return CourseStructureModel(
      organizationId: (json['organizationId'] ?? json['id'])?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      materialId: json['materialId']?.toString(),
      material: json['material'] != null
          ? CourseMaterialModel.fromJson(
              json['material'] as Map<String, dynamic>,
            )
          : null,
      organizationType:
          (json['organizationType'] ?? json['contentType']) as String? ??
          'lecture',
      title: json['title'] as String? ?? '',
      weekNumber: json['weekNumber'] is int
          ? json['weekNumber'] as int
          : int.tryParse(json['weekNumber']?.toString() ?? '') ?? 0,
      orderIndex: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : json['orderIndex'] is int
          ? json['orderIndex'] as int
          : int.tryParse(
                  json['sortOrder']?.toString() ??
                      json['orderIndex']?.toString() ??
                      '',
                ) ??
                0,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organizationId': organizationId,
      'id': organizationId,
      'courseId': courseId,
      'materialId': materialId,
      'material': material?.toJson(),
      'organizationType': organizationType,
      'title': title,
      'weekNumber': weekNumber,
      'orderIndex': orderIndex,
      'sortOrder': orderIndex,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  int get id => int.tryParse(organizationId) ?? 0;

  int get sortOrder => orderIndex;

  @override
  List<Object?> get props => [
    organizationId,
    courseId,
    materialId,
    material,
    organizationType,
    title,
    weekNumber,
    orderIndex,
    description,
    createdAt,
    updatedAt,
  ];
}
