import 'package:equatable/equatable.dart';

/// Represents a course section returned in enrollment responses.
///
/// Maps to the nested `section` object in `GET /api/enrollments/my-courses`.
class SectionModel extends Equatable {
  final int id;
  final String sectionNumber;
  final int maxCapacity;
  final int currentEnrollment;
  final String? location;

  const SectionModel({
    required this.id,
    required this.sectionNumber,
    required this.maxCapacity,
    required this.currentEnrollment,
    this.location,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sectionNumber: json['sectionNumber']?.toString() ?? '',
      maxCapacity: json['maxCapacity'] is int
          ? json['maxCapacity'] as int
          : int.tryParse(json['maxCapacity']?.toString() ?? '') ?? 0,
      currentEnrollment: json['currentEnrollment'] is int
          ? json['currentEnrollment'] as int
          : int.tryParse(json['currentEnrollment']?.toString() ?? '') ?? 0,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionNumber': sectionNumber,
      'maxCapacity': maxCapacity,
      'currentEnrollment': currentEnrollment,
      'location': location,
    };
  }

  /// Available seats calculated from capacity minus current enrollment.
  int get availableSeats => maxCapacity - currentEnrollment;

  @override
  List<Object?> get props => [
        id,
        sectionNumber,
        maxCapacity,
        currentEnrollment,
        location,
      ];
}
