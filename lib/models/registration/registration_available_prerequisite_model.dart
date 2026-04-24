import 'package:equatable/equatable.dart';

class RegistrationAvailablePrerequisiteModel extends Equatable {
  final int id;
  final int courseId;
  final int prerequisiteCourseId;
  final String courseCode;
  final String courseName;
  final bool isMandatory;

  const RegistrationAvailablePrerequisiteModel({
    required this.id,
    required this.courseId,
    required this.prerequisiteCourseId,
    required this.courseCode,
    required this.courseName,
    required this.isMandatory,
  });

  factory RegistrationAvailablePrerequisiteModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegistrationAvailablePrerequisiteModel(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['courseId']),
      prerequisiteCourseId: _parseInt(json['prerequisiteCourseId']),
      courseCode: json['courseCode']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      isMandatory: json['isMandatory'] == true,
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
    };
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
    courseId,
    prerequisiteCourseId,
    courseCode,
    courseName,
    isMandatory,
  ];
}
