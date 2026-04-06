import 'package:equatable/equatable.dart';

/// Represents a semester returned in enrollment responses.
///
/// Maps to the nested `semester` object in `GET /api/enrollments/my-courses`.
class SemesterModel extends Equatable {
  final int id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;

  const SemesterModel({
    required this.id,
    required this.name,
    this.startDate,
    this.endDate,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate];
}
