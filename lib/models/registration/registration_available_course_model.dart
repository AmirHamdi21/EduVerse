import 'package:equatable/equatable.dart';

import 'registration_available_prerequisite_model.dart';
import 'registration_available_section_model.dart';

class RegistrationAvailableCourseModel extends Equatable {
  final int id;
  final String name;
  final String code;
  final String description;
  final int credits;
  final String level;
  final int departmentId;
  final String departmentName;
  final bool canEnroll;
  final String? enrollmentStatus;
  final List<RegistrationAvailablePrerequisiteModel> prerequisites;
  final List<RegistrationAvailableSectionModel> sections;

  const RegistrationAvailableCourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.credits,
    required this.level,
    required this.departmentId,
    required this.departmentName,
    required this.canEnroll,
    required this.enrollmentStatus,
    required this.prerequisites,
    required this.sections,
  });

  factory RegistrationAvailableCourseModel.fromJson(Map<String, dynamic> json) {
    final dynamic sectionsData = json['sections'];
    final dynamic prerequisitesData = json['prerequisites'];

    return RegistrationAvailableCourseModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      credits: _parseInt(json['credits']),
      level: json['level']?.toString() ?? '',
      departmentId: _parseInt(json['departmentId']),
      departmentName: json['departmentName']?.toString() ?? '',
      canEnroll: json['canEnroll'] == true,
      enrollmentStatus: json['enrollmentStatus']?.toString(),
      sections: sectionsData is List
          ? sectionsData
                .whereType<Map<String, dynamic>>()
                .map(RegistrationAvailableSectionModel.fromJson)
                .toList()
          : const <RegistrationAvailableSectionModel>[],
      prerequisites: prerequisitesData is List
          ? prerequisitesData
                .whereType<Map<String, dynamic>>()
                .map(RegistrationAvailablePrerequisiteModel.fromJson)
                .toList()
          : const <RegistrationAvailablePrerequisiteModel>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'credits': credits,
      'level': level,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'canEnroll': canEnroll,
      'enrollmentStatus': enrollmentStatus,
      'sections': sections.map((e) => e.toJson()).toList(),
      'prerequisites': prerequisites.map((e) => e.toJson()).toList(),
    };
  }

  String get normalizedEnrollmentStatus {
    final String value = enrollmentStatus?.trim().toLowerCase() ?? '';
    if (value.isEmpty) {
      return 'not_enrolled';
    }
    return value;
  }

  bool get isAlreadyEnrolled {
    final String status = normalizedEnrollmentStatus;
    return status == 'enrolled' ||
        status == 'completed' ||
        status == 'waitlisted' ||
        status == 'waitlist';
  }

  RegistrationAvailableSectionModel? get primarySection {
    if (sections.isEmpty) {
      return null;
    }

    final List<RegistrationAvailableSectionModel> sorted =
        List<RegistrationAvailableSectionModel>.from(sections)..sort((a, b) {
          final int bySeat = b.availableSeats.compareTo(a.availableSeats);
          if (bySeat != 0) {
            return bySeat;
          }
          return a.sectionNumber.compareTo(b.sectionNumber);
        });

    return sorted.first;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    code,
    description,
    credits,
    level,
    departmentId,
    departmentName,
    canEnroll,
    enrollmentStatus,
    prerequisites,
    sections,
  ];
}
