class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: _parseInt(json['page'], fallback: 1),
      limit: _parseInt(json['limit'], fallback: 10),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['totalPages'], fallback: 1),
    );
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta meta;

  const PaginatedResult({required this.items, required this.meta});
}

class EnrollmentPeriodModel {
  final int id;
  final String semester;
  final String department;
  final DateTime? registrationStart;
  final DateTime? registrationEnd;
  final int totalStudents;
  final int registeredStudents;
  final String description;
  final String status;

  const EnrollmentPeriodModel({
    required this.id,
    required this.semester,
    required this.department,
    required this.registrationStart,
    required this.registrationEnd,
    required this.totalStudents,
    required this.registeredStudents,
    required this.description,
    required this.status,
  });

  factory EnrollmentPeriodModel.fromSemesterJson(Map<String, dynamic> json) {
    final departmentMap = json['department'] is Map<String, dynamic>
        ? json['department'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final start = _parseDateTime(
      json['registrationStart'] ?? json['startDate'],
    );
    final end = _parseDateTime(json['registrationEnd'] ?? json['endDate']);
    final now = DateTime.now();
    final serverStatus = _nullableString(json['status'])?.toLowerCase();

    String status;
    if (serverStatus == 'active' ||
        serverStatus == 'closed' ||
        serverStatus == 'upcoming') {
      status = serverStatus!;
    } else {
      status = 'upcoming';
      if (start != null && end != null) {
        if (now.isAfter(end)) {
          status = 'closed';
        } else if (now.isBefore(start)) {
          status = 'upcoming';
        } else {
          status = 'active';
        }
      }
    }

    return EnrollmentPeriodModel(
      id: _parseInt(json['id'] ?? json['semesterId']),
      semester: _asString(
        json['semester'] ?? json['semesterName'] ?? json['name'],
        fallback: 'Unnamed Semester',
      ),
      department: _asString(
        json['departmentName'] ??
            departmentMap['departmentName'] ??
            departmentMap['name'] ??
            json['department'],
        fallback: 'General',
      ),
      registrationStart: start,
      registrationEnd: end,
      totalStudents: _parseInt(
        json['totalStudents'] ?? json['capacity'] ?? json['total'],
      ),
      registeredStudents: _parseInt(
        json['registeredStudents'] ??
            json['enrolledStudents'] ??
            json['registrationCount'],
      ),
      description: _asString(
        json['description'] ?? json['notes'],
        fallback: 'No description provided.',
      ),
      status: status,
    );
  }
}

class CampusEventModel {
  final int eventId;
  final String title;
  final String? description;
  final String eventType;
  final int? scopeId;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final String? building;
  final String? room;
  final bool isMandatory;
  final bool registrationRequired;
  final int? maxAttendees;
  final String color;
  final String status;
  final List<String> tags;
  final int registrationCount;
  final int? spotsRemaining;

  const CampusEventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.scopeId,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    required this.building,
    required this.room,
    required this.isMandatory,
    required this.registrationRequired,
    required this.maxAttendees,
    required this.color,
    required this.status,
    required this.tags,
    required this.registrationCount,
    required this.spotsRemaining,
  });

  factory CampusEventModel.fromJson(Map<String, dynamic> json) {
    final parsedMaxAttendees = _parseNullableInt(
      json['maxAttendees'] ?? json['capacity'],
    );
    final parsedRegistrationCount = _parseInt(
      json['registrationCount'] ??
          json['attendeesCount'] ??
          json['registeredCount'],
    );

    final parsedSpotsRemaining = _parseNullableInt(
      json['spotsRemaining'] ?? json['remainingSpots'],
    );

    return CampusEventModel(
      eventId: _parseInt(json['eventId'] ?? json['id']),
      title: _asString(json['title'], fallback: 'Untitled Event'),
      description: _nullableString(json['description']),
      eventType: _asString(
        json['eventType'] ?? json['type'],
        fallback: 'GENERAL',
      ),
      scopeId: _parseNullableInt(json['scopeId']),
      startDateTime: _parseDateTime(
        json['startDatetime'] ?? json['startDateTime'] ?? json['startDate'],
      ),
      endDateTime: _parseDateTime(
        json['endDatetime'] ?? json['endDateTime'] ?? json['endDate'],
      ),
      location: _nullableString(
        json['location'] ??
            _joinNonEmpty(<String?>[
              _nullableString(json['building']),
              _nullableString(json['room']),
            ]),
      ),
      building: _nullableString(json['building']),
      room: _nullableString(json['room']),
      isMandatory: _parseBool(json['isMandatory'] ?? json['mandatory']),
      registrationRequired: _parseBool(
        json['registrationRequired'] ?? json['requiresRegistration'],
      ),
      maxAttendees: parsedMaxAttendees,
      color: _asString(json['color'], fallback: '#2B7FFF'),
      status: _asString(json['status'], fallback: 'draft'),
      tags: _parseStringList(json['tags']),
      registrationCount: parsedRegistrationCount,
      spotsRemaining:
          parsedSpotsRemaining ??
          (parsedMaxAttendees == null
              ? null
              : (parsedMaxAttendees - parsedRegistrationCount).clamp(
                  0,
                  parsedMaxAttendees,
                )),
    );
  }
}

class CampusEventRegistrationModel {
  final int registrationId;
  final String attendeeName;
  final String attendeeEmail;
  final String status;

  const CampusEventRegistrationModel({
    required this.registrationId,
    required this.attendeeName,
    required this.attendeeEmail,
    required this.status,
  });

  factory CampusEventRegistrationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final firstName = _asString(user['firstName']);
    final lastName = _asString(user['lastName']);

    return CampusEventRegistrationModel(
      registrationId: _parseInt(json['registrationId'] ?? json['id']),
      attendeeName: _asString(
        json['attendeeName'],
        fallback: [
          firstName,
          lastName,
        ].where((part) => part.trim().isNotEmpty).join(' ').trim(),
      ),
      attendeeEmail: _asString(json['attendeeEmail'] ?? user['email']),
      status: _asString(json['status'], fallback: 'registered'),
    );
  }
}

class ScheduleTemplateSlotModel {
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String slotType;
  final String? building;
  final String? room;

  const ScheduleTemplateSlotModel({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotType,
    required this.building,
    required this.room,
  });

  factory ScheduleTemplateSlotModel.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplateSlotModel(
      dayOfWeek: _asString(json['dayOfWeek'], fallback: 'MONDAY'),
      startTime: _asString(json['startTime'], fallback: '08:00'),
      endTime: _asString(json['endTime'], fallback: '09:00'),
      slotType: _asString(
        json['slotType'] ?? json['scheduleType'],
        fallback: 'LECTURE',
      ),
      building: _nullableString(json['building']),
      room: _nullableString(json['room']),
    );
  }
}

class ScheduleTemplateModel {
  final int templateId;
  final String name;
  final String? description;
  final String departmentName;
  final String scheduleType;
  final bool isActive;
  final String creatorName;
  final int slotCount;
  final List<ScheduleTemplateSlotModel> slots;

  const ScheduleTemplateModel({
    required this.templateId,
    required this.name,
    required this.description,
    required this.departmentName,
    required this.scheduleType,
    required this.isActive,
    required this.creatorName,
    required this.slotCount,
    required this.slots,
  });

  factory ScheduleTemplateModel.fromJson(Map<String, dynamic> json) {
    final department = json['department'] is Map<String, dynamic>
        ? json['department'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final creator = json['creator'] is Map<String, dynamic>
        ? json['creator'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final slots = (json['slots'] is List)
        ? (json['slots'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ScheduleTemplateSlotModel.fromJson)
              .toList()
        : <ScheduleTemplateSlotModel>[];

    final creatorName = [
      _asString(creator['firstName']),
      _asString(creator['lastName']),
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();

    final directCreatorName = _nullableString(
      json['creatorName'] ?? json['createdByName'],
    );

    return ScheduleTemplateModel(
      templateId: _parseInt(json['templateId'] ?? json['id']),
      name: _asString(json['name'], fallback: 'Unnamed Template'),
      description: _nullableString(json['description']),
      departmentName: _asString(
        json['departmentName'] ??
            department['departmentName'] ??
            department['name'],
        fallback: 'General',
      ),
      scheduleType: _asString(json['scheduleType'], fallback: 'LECTURE'),
      isActive: _parseBool(json['isActive'], fallback: true),
      creatorName:
          directCreatorName ?? (creatorName.isEmpty ? 'System' : creatorName),
      slotCount: _parseInt(
        json['slotCount'] ?? json['slotsCount'] ?? slots.length,
      ),
      slots: slots,
    );
  }
}

class OfficeHourSlotModel {
  final int slotId;
  final int instructorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String location;
  final String mode;
  final int maxAppointments;
  final int currentAppointments;
  final bool isActive;
  final String? notes;

  const OfficeHourSlotModel({
    required this.slotId,
    required this.instructorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.mode,
    required this.maxAppointments,
    required this.currentAppointments,
    required this.isActive,
    required this.notes,
  });

  factory OfficeHourSlotModel.fromJson(Map<String, dynamic> json) {
    final statusValue = _nullableString(json['status'])?.toLowerCase();
    final isActiveFromStatus = statusValue == null
        ? null
        : statusValue == 'active' || statusValue == 'enabled';

    return OfficeHourSlotModel(
      slotId: _parseInt(json['slotId'] ?? json['id']),
      instructorId: _parseInt(json['instructorId'] ?? json['userId']),
      dayOfWeek: _asString(
        json['dayOfWeek'] ?? json['day'],
        fallback: 'MONDAY',
      ),
      startTime: _asString(json['startTime'], fallback: '08:00'),
      endTime: _asString(json['endTime'], fallback: '09:00'),
      location: _asString(
        json['location'] ??
            _joinNonEmpty(<String?>[
              _nullableString(json['building']),
              _nullableString(json['room']),
            ]),
        fallback: 'TBD',
      ),
      mode: _asString(
        json['mode'] ?? json['deliveryMode'],
        fallback: 'in_person',
      ),
      maxAppointments: _parseInt(
        json['maxAppointments'] ?? json['maxSlots'],
        fallback: 0,
      ),
      currentAppointments: _parseInt(
        json['currentAppointments'] ??
            json['appointmentCount'] ??
            json['bookedAppointments'],
      ),
      isActive: _parseBool(
        json['isActive'] ?? isActiveFromStatus,
        fallback: true,
      ),
      notes: _nullableString(json['notes']),
    );
  }
}

class OfficeHourAppointmentModel {
  final int appointmentId;
  final String studentName;
  final String topic;
  final DateTime? appointmentDate;
  final String status;

  const OfficeHourAppointmentModel({
    required this.appointmentId,
    required this.studentName,
    required this.topic,
    required this.appointmentDate,
    required this.status,
  });

  factory OfficeHourAppointmentModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] is Map<String, dynamic>
        ? json['student'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final studentName = _joinNonEmpty(<String?>[
      _nullableString(student['firstName']),
      _nullableString(student['lastName']),
    ]);

    return OfficeHourAppointmentModel(
      appointmentId: _parseInt(json['appointmentId'] ?? json['id']),
      studentName: _asString(
        json['studentName'],
        fallback: studentName.isEmpty ? 'Unknown Student' : studentName,
      ),
      topic: _asString(json['topic'], fallback: 'No topic provided'),
      appointmentDate: _parseDateTime(
        json['appointmentDate'] ?? json['scheduledAt'] ?? json['date'],
      ),
      status: _asString(json['status'], fallback: 'pending'),
    );
  }
}

class AdminStaffSummaryModel {
  final int userId;
  final String fullName;
  final String email;
  final List<String> roles;

  const AdminStaffSummaryModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  factory AdminStaffSummaryModel.fromJson(Map<String, dynamic> json) {
    final firstName = _asString(json['firstName']);
    final lastName = _asString(json['lastName']);

    final fullName = _joinNonEmpty(<String?>[firstName, lastName]);

    return AdminStaffSummaryModel(
      userId: _parseInt(json['userId'] ?? json['id']),
      fullName: fullName.isEmpty ? 'Unknown User' : fullName,
      email: _asString(json['email']),
      roles: _parseRoles(json),
    );
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
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  final parsed = _parseInt(value, fallback: -1);
  return parsed < 0 ? null : parsed;
}

bool _parseBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
  }
  if (value is num) {
    return value != 0;
  }
  return fallback;
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

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) {
    return fallback;
  }

  final output = value.toString().trim();
  if (output.isEmpty) {
    return fallback;
  }

  return output;
}

String? _nullableString(dynamic value) {
  final output = _asString(value);
  return output.isEmpty ? null : output;
}

String _joinNonEmpty(List<String?> parts) {
  return parts
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(' ')
      .trim();
}

List<String> _parseStringList(dynamic value) {
  if (value is String) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  if (value is! List) {
    return const <String>[];
  }

  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _parseRoles(Map<String, dynamic> json) {
  final roles = <String>[];

  final role = json['role'];
  if (role != null && role.toString().trim().isNotEmpty) {
    roles.add(role.toString().trim().toLowerCase());
  }

  final userType = json['userType'];
  if (userType != null && userType.toString().trim().isNotEmpty) {
    roles.add(userType.toString().trim().toLowerCase());
  }

  final rawRoles = json['roles'];
  if (rawRoles is List) {
    for (final entry in rawRoles) {
      if (entry is String && entry.trim().isNotEmpty) {
        roles.add(entry.trim().toLowerCase());
      }
      if (entry is Map<String, dynamic>) {
        final roleName = entry['roleName']?.toString().trim();
        if (roleName != null && roleName.isNotEmpty) {
          roles.add(roleName.toLowerCase());
        }
      }
    }
  }

  return roles.toSet().toList();
}
