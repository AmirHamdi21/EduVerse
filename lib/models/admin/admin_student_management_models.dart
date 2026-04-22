class AdminStudentsPageModel {
  final List<AdminStudentModel> items;
  final int page;
  final int size;
  final int total;
  final int totalPages;

  const AdminStudentsPageModel({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
  });
}

class AdminStudentModel {
  final int id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String email;
  final String year;
  final List<String> enrolledCourses;
  final String status;
  final String? phone;
  final DateTime? createdAt;

  const AdminStudentModel({
    required this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.year,
    required this.enrolledCourses,
    required this.status,
    this.phone,
    this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Unknown Student' : name;
  }

  AdminStudentModel copyWith({
    int? id,
    String? studentId,
    String? firstName,
    String? lastName,
    String? email,
    String? year,
    List<String>? enrolledCourses,
    String? status,
    String? phone,
    DateTime? createdAt,
  }) {
    return AdminStudentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      year: year ?? this.year,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AdminStudentModel.fromJson(Map<String, dynamic> json) {
    final firstName = _asString(json['firstName']);
    final lastName = _asString(json['lastName']);
    final fallbackName = _asString(
      json['name'] ?? json['fullName'] ?? json['displayName'],
    );

    final parsedNames = _splitFallbackName(
      firstName: firstName,
      lastName: lastName,
      fallbackName: fallbackName,
    );

    final parsedId = _parseInt(
      json['userId'] ?? json['id'] ?? json['studentIdNumeric'],
    );

    final normalizedStatus = _normalizeStatus(
      _asString(json['status'], fallback: 'active'),
    );

    final parsedStudentId = _asString(
      json['studentId'] ?? json['universityId'] ?? json['registrationNumber'],
      fallback: parsedId > 0 ? 'STU-$parsedId' : 'STU-N/A',
    );

    final parsedYear = _asString(
      json['year'] ??
          json['academicYear'] ??
          json['studyYear'] ??
          json['level'] ??
          json['classYear'],
      fallback: 'N/A',
    );

    return AdminStudentModel(
      id: parsedId,
      studentId: parsedStudentId,
      firstName: parsedNames.$1,
      lastName: parsedNames.$2,
      email: _asString(json['email'], fallback: 'no-email@eduverse.local'),
      year: parsedYear,
      enrolledCourses: _parseCourseNames(json),
      status: normalizedStatus,
      phone: _nullableString(json['phone'] ?? json['phoneNumber']),
      createdAt: _parseDateTime(
        json['createdAt'] ?? json['registeredAt'] ?? json['joinDate'],
      ),
    );
  }

  static (String, String) _splitFallbackName({
    required String firstName,
    required String lastName,
    required String fallbackName,
  }) {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return (firstName, lastName);
    }

    final parts = fallbackName
        .split(' ')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return ('Unknown', 'Student');
    }

    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }

  static List<String> _parseCourseNames(Map<String, dynamic> json) {
    final direct = json['enrolledCourses'] ?? json['courses'];
    final extracted = _extractCourseNames(direct);
    if (extracted.isNotEmpty) {
      return extracted;
    }

    final enrollments = json['enrollments'];
    if (enrollments is List) {
      final names = <String>[];
      for (final item in enrollments.whereType<Map<String, dynamic>>()) {
        final course = item['course'];
        if (course is Map<String, dynamic>) {
          final name = _asString(
            course['name'] ?? course['courseName'] ?? course['code'],
          );
          if (name.isNotEmpty) {
            names.add(name);
          }
        }
      }
      return names;
    }

    return const <String>[];
  }

  static List<String> _extractCourseNames(dynamic value) {
    if (value is List) {
      final names = <String>[];
      for (final item in value) {
        if (item is String) {
          final normalized = item.trim();
          if (normalized.isNotEmpty) {
            names.add(normalized);
          }
          continue;
        }

        if (item is Map<String, dynamic>) {
          final name = _asString(
            item['name'] ?? item['courseName'] ?? item['code'] ?? item['title'],
          );
          if (name.isNotEmpty) {
            names.add(name);
          }
        }
      }
      return names;
    }
    return const <String>[];
  }

  static String _normalizeStatus(String rawStatus) {
    final value = rawStatus.trim().toLowerCase();
    if (value == 'active') {
      return 'active';
    }
    if (value == 'inactive') {
      return 'inactive';
    }
    if (value == 'on-hold' || value == 'on_hold' || value == 'hold') {
      return 'on-hold';
    }
    if (value == 'graduated') {
      return 'graduated';
    }
    if (value == 'pending') {
      return 'pending';
    }
    return value.isEmpty ? 'active' : value;
  }
}

int _parseInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }
  return value.toString();
}

String? _nullableString(dynamic value) {
  final normalized = _asString(value);
  return normalized.isEmpty ? null : normalized;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
