import 'package:equatable/equatable.dart';

/// Represents a semester returned in enrollment responses.
///
/// Maps to the nested `semester` object in `GET /api/enrollments/my-courses`.
class SemesterModel extends Equatable {
  final int id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final String status;

  const SemesterModel({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
    this.registrationStart,
    this.registrationEnd,
    this.status = 'unknown',
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['semesterName'] ?? json['name'])?.toString() ?? '',
      startDate: (json['semesterStart'] ?? json['startDate']) != null
          ? DateTime.tryParse(
              (json['semesterStart'] ?? json['startDate']).toString(),
            )
          : null,
      endDate: (json['semesterEnd'] ?? json['endDate']) != null
          ? DateTime.tryParse(
              (json['semesterEnd'] ?? json['endDate']).toString(),
            )
          : null,
      registrationStart: json['registrationStart'] != null
          ? DateTime.tryParse(json['registrationStart'].toString())
          : null,
      registrationEnd: json['registrationEnd'] != null
          ? DateTime.tryParse(json['registrationEnd'].toString())
          : null,
      status: json['status']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'semesterName': name,
      'startDate': startDate?.toIso8601String(),
      'semesterStart': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'semesterEnd': endDate?.toIso8601String(),
      'registrationStart': registrationStart?.toIso8601String(),
      'registrationEnd': registrationEnd?.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    endDate,
    registrationStart,
    registrationEnd,
    status,
  ];
}
