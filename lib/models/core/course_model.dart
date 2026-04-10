import 'package:equatable/equatable.dart';

import 'enums/course_enums.dart';
import 'section_model.dart';
import 'shared_models.dart';

class CourseModel extends Equatable {
  final int id;
  final int departmentId;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final CourseLevel courseLevel;
  final String? syllabusUrl;
  final int? instructorId;
  final List<int>? taIds;
  final CourseStatus courseStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DepartmentInfo? department;
  final List<CoursePrerequisite>? prerequisites;
  final List<SectionModel>? sections;

  const CourseModel({
    required this.id,
    required this.departmentId,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    required this.courseLevel,
    this.syllabusUrl,
    this.instructorId,
    this.taIds,
    required this.courseStatus,
    this.createdAt,
    this.updatedAt,
    this.department,
    this.prerequisites,
    this.sections,
  });

  int get courseId => id;

  String get courseCode => code;

  String get courseName => name;

  String? get departmentName => department?.name;

  String? get level => courseLevel.toJson();

  String? get status => courseStatus.toJson();

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawDepartment = json['department'];
    final rawPrerequisites = json['prerequisites'];
    final rawSections = json['sections'];
    final rawTaIds = json['taIds'];

    return CourseModel(
      id: _parseInt(json['id'] ?? json['courseId']),
      departmentId: _parseInt(json['departmentId']),
      code: _parseString(json['code'] ?? json['courseCode']),
      name: _parseString(json['name'] ?? json['courseName']),
      description: json['description']?.toString(),
      credits: _parseInt(json['credits']),
      courseLevel: CourseLevel.fromString(_parseString(json['level'])),
      syllabusUrl: json['syllabusUrl']?.toString(),
      instructorId: _parseNullableInt(json['instructorId']),
      taIds: rawTaIds is List
          ? rawTaIds.map<int>((dynamic id) => _parseInt(id)).toList()
          : null,
      courseStatus: CourseStatus.fromString(_parseString(json['status'])),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      department: rawDepartment is Map<String, dynamic>
          ? DepartmentInfo.fromJson(rawDepartment)
          : _fromLegacyDepartmentFields(json),
      prerequisites: rawPrerequisites is List
          ? rawPrerequisites
                .whereType<Map<String, dynamic>>()
                .map(CoursePrerequisite.fromJson)
                .toList()
          : null,
      sections: rawSections is List
          ? rawSections
                .whereType<Map<String, dynamic>>()
                .map(SectionModel.fromJson)
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'departmentId': departmentId,
      'code': code,
      'name': name,
      'description': description,
      'credits': credits,
      'level': courseLevel.toJson(),
      'syllabusUrl': syllabusUrl,
      'instructorId': instructorId,
      'taIds': taIds,
      'status': courseStatus.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'department': department?.toJson(),
      'prerequisites': prerequisites?.map((e) => e.toJson()).toList(),
      'sections': sections?.map((e) => e.toJson()).toList(),
      // Compatibility keys
      'courseId': id,
      'courseCode': code,
      'courseName': name,
      'departmentName': departmentName,
    };
  }

  static DepartmentInfo? _fromLegacyDepartmentFields(
    Map<String, dynamic> json,
  ) {
    final departmentName = json['departmentName']?.toString();
    if (departmentName == null || departmentName.isEmpty) {
      return null;
    }

    return DepartmentInfo(
      id: _parseInt(json['departmentId']),
      name: departmentName,
      code: _parseString(json['departmentCode']),
    );
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

  static String _parseString(dynamic value) {
    return value?.toString() ?? '';
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
    departmentId,
    code,
    name,
    description,
    credits,
    courseLevel,
    syllabusUrl,
    instructorId,
    taIds,
    courseStatus,
    createdAt,
    updatedAt,
    department,
    prerequisites,
    sections,
  ];
}

class DepartmentInfo extends Equatable {
  final int id;
  final String name;
  final String code;

  const DepartmentInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) {
    return DepartmentInfo(
      id: CourseModel._parseInt(json['id']),
      name: CourseModel._parseString(json['name']),
      code: CourseModel._parseString(json['code']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'code': code};
  }

  @override
  List<Object?> get props => <Object?>[id, name, code];
}

class CoursePrerequisite extends Equatable {
  final int id;
  final int courseId;
  final int prerequisiteCourseId;
  final bool isMandatory;
  final CourseInfo? prerequisiteCourse;
  final DateTime? createdAt;

  const CoursePrerequisite({
    required this.id,
    required this.courseId,
    required this.prerequisiteCourseId,
    required this.isMandatory,
    this.prerequisiteCourse,
    this.createdAt,
  });

  factory CoursePrerequisite.fromJson(Map<String, dynamic> json) {
    final rawPrerequisiteCourse = json['prerequisiteCourse'];

    return CoursePrerequisite(
      id: CourseModel._parseInt(json['id']),
      courseId: CourseModel._parseInt(json['courseId']),
      prerequisiteCourseId: CourseModel._parseInt(json['prerequisiteCourseId']),
      isMandatory: json['isMandatory'] == true,
      prerequisiteCourse: rawPrerequisiteCourse is Map<String, dynamic>
          ? CourseInfo.fromJson(rawPrerequisiteCourse)
          : null,
      createdAt: CourseModel._parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'courseId': courseId,
      'prerequisiteCourseId': prerequisiteCourseId,
      'isMandatory': isMandatory,
      'prerequisiteCourse': prerequisiteCourse?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    courseId,
    prerequisiteCourseId,
    isMandatory,
    prerequisiteCourse,
    createdAt,
  ];
}
