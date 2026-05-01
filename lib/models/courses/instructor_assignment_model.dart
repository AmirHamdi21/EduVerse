import 'package:equatable/equatable.dart';

class InstructorAssignmentModel extends Equatable {
  final int id;
  final int sectionId;
  final int userId;
  final String role;
  final String? responsibilities;
  final DateTime? assignedAt;
  final String firstName;
  final String lastName;
  final String email;

  const InstructorAssignmentModel({
    required this.id,
    required this.sectionId,
    required this.userId,
    required this.role,
    this.responsibilities,
    this.assignedAt,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName {
    final value = '$firstName $lastName'.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return 'User #$userId';
  }

  factory InstructorAssignmentModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userMap = rawUser is Map<String, dynamic>
        ? rawUser
        : <String, dynamic>{};
    final rawFullName =
        json['fullName']?.toString() ?? userMap['fullName']?.toString() ?? '';
    final parsedName = _splitFullName(rawFullName);

    return InstructorAssignmentModel(
      id: _parseInt(json['id']),
      sectionId: _parseInt(json['sectionId']),
      userId: _parseInt(json['userId'] ?? userMap['userId'] ?? userMap['id']),
      role: json['role']?.toString() ?? 'primary',
      responsibilities: json['responsibilities']?.toString(),
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : null,
      firstName:
          json['firstName']?.toString() ??
          userMap['firstName']?.toString() ??
          parsedName.$1 ??
          '',
      lastName:
          json['lastName']?.toString() ??
          userMap['lastName']?.toString() ??
          parsedName.$2 ??
          '',
      email: json['email']?.toString() ?? userMap['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sectionId': sectionId,
      'userId': userId,
      'role': role,
      'responsibilities': responsibilities,
      'assignedAt': assignedAt?.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static (String?, String?) _splitFullName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return (null, null);
    }

    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    sectionId,
    userId,
    role,
    responsibilities,
    assignedAt,
    firstName,
    lastName,
    email,
  ];
}
