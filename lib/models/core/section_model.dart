import 'package:equatable/equatable.dart';

import 'enums/course_enums.dart';
import 'schedule_model.dart';
import 'semester_model.dart';
import 'shared_models.dart';

/// Represents a course section returned in enrollment responses.
///
/// Maps to the nested `section` object in `GET /api/enrollments/my-courses`.
class SectionModel extends Equatable {
  final int id;
  final int courseId;
  final int semesterId;
  final String sectionNumber;
  final int maxCapacity;
  final int currentEnrollment;
  final String? location;
  final SectionStatus sectionStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CourseInfo? course;
  final SemesterModel? semester;
  final List<ScheduleModel>? schedules;

  const SectionModel({
    required this.id,
    required this.courseId,
    required this.semesterId,
    required this.sectionNumber,
    required this.maxCapacity,
    required this.currentEnrollment,
    this.location,
    required this.sectionStatus,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.semester,
    this.schedules,
  });

  String get status => sectionStatus.toJson();

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    final rawCourse = json['course'];
    final rawSemester = json['semester'];
    final rawSchedules = json['schedules'];

    return SectionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      courseId: json['courseId'] is int
          ? json['courseId'] as int
          : int.tryParse(json['courseId']?.toString() ?? '') ??
                (rawCourse is Map<String, dynamic>
                    ? int.tryParse(rawCourse['id']?.toString() ?? '') ?? 0
                    : 0),
      semesterId: json['semesterId'] is int
          ? json['semesterId'] as int
          : int.tryParse(json['semesterId']?.toString() ?? '') ??
                (rawSemester is Map<String, dynamic>
                    ? int.tryParse(rawSemester['id']?.toString() ?? '') ?? 0
                    : 0),
      sectionNumber: json['sectionNumber']?.toString() ?? '',
      maxCapacity: json['maxCapacity'] is int
          ? json['maxCapacity'] as int
          : int.tryParse(json['maxCapacity']?.toString() ?? '') ?? 0,
      currentEnrollment: json['currentEnrollment'] is int
          ? json['currentEnrollment'] as int
          : int.tryParse(json['currentEnrollment']?.toString() ?? '') ?? 0,
      location: json['location'] as String?,
      sectionStatus: SectionStatus.fromString(
        json['status']?.toString() ?? 'unknown',
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      course: rawCourse is Map<String, dynamic>
          ? CourseInfo.fromJson(rawCourse)
          : null,
      semester: rawSemester is Map<String, dynamic>
          ? SemesterModel.fromJson(rawSemester)
          : null,
      schedules: rawSchedules is List
          ? rawSchedules
                .whereType<Map<String, dynamic>>()
                .map(ScheduleModel.fromJson)
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'semesterId': semesterId,
      'sectionNumber': sectionNumber,
      'maxCapacity': maxCapacity,
      'currentEnrollment': currentEnrollment,
      'location': location,
      'status': sectionStatus.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'course': course?.toJson(),
      'semester': semester?.toJson(),
      'schedules': schedules?.map((e) => e.toJson()).toList(),
    };
  }

  /// Available seats calculated from capacity minus current enrollment.
  int get availableSeats => maxCapacity - currentEnrollment;

  @override
  List<Object?> get props => [
    id,
    courseId,
    semesterId,
    sectionNumber,
    maxCapacity,
    currentEnrollment,
    location,
    sectionStatus,
    createdAt,
    updatedAt,
    course,
    semester,
    schedules,
  ];
}
