import 'package:equatable/equatable.dart';

/// Represents a TA's assignment to a specific course section.
///
/// Maps to the backend `GET /api/enrollments/sections/:sectionId/tas` response:
/// ```json
/// {
///   "id": 1,
///   "sectionId": 10,
///   "userId": 7,
///   "responsibilities": "Grading assignments",
///   "assignedAt": "2026-08-15T10:00:00.000Z",
///   "firstName": "Jane",
///   "lastName": "Smith",
///   "email": "jane.smith@example.com"
/// }
/// ```
class TAAssignmentModel extends Equatable {
  final int id;
  final int sectionId;
  final int userId;
  final String? responsibilities;
  final DateTime assignedAt;
  final String firstName;
  final String lastName;
  final String email;

  const TAAssignmentModel({
    required this.id,
    required this.sectionId,
    required this.userId,
    this.responsibilities,
    required this.assignedAt,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  /// Full name convenience getter.
  String get fullName => '$firstName $lastName';

  factory TAAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TAAssignmentModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      sectionId: json['sectionId'] is int
          ? json['sectionId'] as int
          : int.tryParse(json['sectionId']?.toString() ?? '') ?? 0,
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId']?.toString() ?? '') ?? 0,
      responsibilities: json['responsibilities'] as String?,
      assignedAt: DateTime.tryParse(json['assignedAt']?.toString() ?? '') ??
          DateTime.now(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionId': sectionId,
      'userId': userId,
      'responsibilities': responsibilities,
      'assignedAt': assignedAt.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [
        id,
        sectionId,
        userId,
        responsibilities,
        assignedAt,
        firstName,
        lastName,
        email,
      ];
}
