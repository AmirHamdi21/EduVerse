import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/admin/admin_course_management_models.dart';
import 'core_api_client.dart';

class AdminCourseManagementService {
  final CoreApiClient _client;

  AdminCourseManagementService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<List<AdminManagedCourse>>> getCourses({
    String? search,
    String? status,
  }) {
    return RetryHelper.execute<List<AdminManagedCourse>>(() async {
      final userNameById = await _loadActiveUserNames();

      final queryParameters = <String, dynamic>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (status != null && status.trim().isNotEmpty) {
        queryParameters['status'] = status.trim().toUpperCase();
      }

      final response = await _client.dio.get(
        '/courses',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      final rows = _extractListPayload(
        response.data,
      ).whereType<Map<String, dynamic>>().toList();

      final hydrated = await Future.wait(
        rows.map((row) => _hydrateCourse(row, userNameById)),
      );

      hydrated.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return hydrated;
    }, fallbackMessage: 'Failed to load courses');
  }

  Future<ServiceResult<List<AdminStaffOption>>> getStaffOptions({
    required String role,
  }) {
    return RetryHelper.execute<List<AdminStaffOption>>(() async {
      final roleCandidates = _roleCandidates(role);
      final map = <int, AdminStaffOption>{};

      for (final roleValue in roleCandidates) {
        final response = await _client.dio.get(
          '/admin/users',
          queryParameters: <String, dynamic>{
            'page': 1,
            'size': 500,
            'status': 'active',
            'role': roleValue,
          },
        );

        final rows = _extractListPayload(response.data);
        for (final row in rows.whereType<Map<String, dynamic>>()) {
          final id = _asInt(row['userId'] ?? row['id']);
          if (id <= 0) {
            continue;
          }

          final normalizedRole = _normalizeRole(
            _asString(row['role']).isNotEmpty
                ? _asString(row['role'])
                : _extractPrimaryRole(row),
          );
          if (normalizedRole != _normalizeRole(role)) {
            continue;
          }

          map[id] = AdminStaffOption(
            id: id,
            name: _userDisplayName(row, fallbackId: id),
            role: normalizedRole,
            department: _asString(
              row['departmentName'] ?? row['department'] ?? row['faculty'],
              fallback: 'N/A',
            ),
          );
        }
      }

      final options = map.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return options;
    }, fallbackMessage: 'Failed to load staff options');
  }

  Future<ServiceResult<List<AdminSemesterOption>>> getSemesters() {
    return RetryHelper.execute<List<AdminSemesterOption>>(() async {
      final response = await _client.dio.get('/semesters');
      final rows = _extractListPayload(response.data);

      final byId = <int, AdminSemesterOption>{};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final id = _asInt(row['id'] ?? row['semesterId']);
        final name = _asString(
          row['name'] ?? row['title'] ?? row['label'],
          fallback: 'Semester $id',
        );
        if (id <= 0 || name.trim().isEmpty) {
          continue;
        }
        byId[id] = AdminSemesterOption(id: id, name: name);
      }

      final semesters = byId.values.toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      return semesters;
    }, fallbackMessage: 'Failed to load semesters');
  }

  Future<ServiceResult<List<AdminDepartmentOption>>> getDepartments() {
    return RetryHelper.execute<List<AdminDepartmentOption>>(() async {
      final response = await _client.dio.get('/departments');
      final rows = _extractListPayload(response.data);

      final byId = <int, AdminDepartmentOption>{};
      for (final row in rows.whereType<Map<String, dynamic>>()) {
        final id = _asInt(row['id'] ?? row['departmentId']);
        final name = _asString(row['name'] ?? row['departmentName']);
        if (id <= 0 || name.isEmpty) {
          continue;
        }
        byId[id] = AdminDepartmentOption(
          id: id,
          name: name,
          code: _asString(row['code'] ?? row['departmentCode']),
        );
      }

      final items = byId.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return items;
    }, fallbackMessage: 'Failed to load departments');
  }

  Future<ServiceResult<int>> createCourse({
    required String code,
    required String name,
    required int credits,
    required int departmentId,
    required String level,
    required String status,
  }) {
    return RetryHelper.execute<int>(() async {
      final normalizedCode = code.trim().toUpperCase();
      final normalizedName = name.trim();
      final normalizedLevel = _normalizeLevel(level);
      final normalizedStatus = _normalizeStatus(status);

      if (normalizedCode.isEmpty || normalizedName.isEmpty) {
        throw Exception('Course code and name are required');
      }
      if (credits <= 0) {
        throw Exception('Course credits must be greater than zero');
      }
      if (departmentId <= 0) {
        throw Exception('A valid department is required');
      }

      final response = await _client.dio.post(
        '/courses',
        data: <String, dynamic>{
          'code': normalizedCode,
          'name': normalizedName,
          'description': '$normalizedName ($normalizedCode)',
          'credits': credits,
          'departmentId': departmentId,
          'level': normalizedLevel,
        },
      );

      final map = _extractMapPayload(response.data);
      final courseId = _asInt(map['id'] ?? map['courseId']);
      if (courseId <= 0) {
        throw Exception('Course id missing from create response');
      }

      // CreateCourseDto does not accept status; apply non-default status via patch.
      if (normalizedStatus != 'ACTIVE') {
        await _client.dio.patch(
          '/courses/$courseId',
          data: <String, dynamic>{'status': normalizedStatus},
        );
      }

      return courseId;
    }, fallbackMessage: 'Failed to create course');
  }

  Future<ServiceResult<void>> updateCourse({
    required int courseId,
    required String code,
    required String name,
    required int credits,
    required int departmentId,
    required String level,
    required String status,
  }) {
    return RetryHelper.executeVoid(() async {
      final normalizedCode = code.trim().toUpperCase();
      final normalizedName = name.trim();
      final normalizedLevel = _normalizeLevel(level);
      final normalizedStatus = _normalizeStatus(status);

      if (courseId <= 0) {
        throw Exception('A valid course id is required');
      }
      if (normalizedName.isEmpty || normalizedCode.isEmpty) {
        throw Exception('Course code and name are required');
      }
      if (credits <= 0) {
        throw Exception('Course credits must be greater than zero');
      }
      if (departmentId <= 0) {
        throw Exception('A valid department is required');
      }

      await _client.dio.patch(
        '/courses/$courseId',
        data: <String, dynamic>{
          'name': normalizedName,
          'description': '$normalizedName ($normalizedCode)',
          'credits': credits,
          'level': normalizedLevel,
          'status': normalizedStatus,
        },
      );
    }, fallbackMessage: 'Failed to update course');
  }

  Future<ServiceResult<int>> ensureSectionAndSchedule({
    required int courseId,
    int? existingSectionId,
    required String sectionNumber,
    required int maxCapacity,
    required String location,
    required int semesterId,
    required String scheduleDay,
    required String startTime,
    required String endTime,
  }) {
    return RetryHelper.execute<int>(() async {
      int sectionId = existingSectionId ?? 0;
      final normalizedSectionNumber = _asInt(sectionNumber, fallback: 1);
      final normalizedLocation = location.trim();

      if (sectionId <= 0) {
        final createSectionResponse = await _client.dio.post(
          '/sections',
          data: <String, dynamic>{
            'courseId': courseId,
            'semesterId': semesterId,
            'sectionNumber': normalizedSectionNumber,
            'maxCapacity': maxCapacity,
            'location': normalizedLocation,
          },
        );

        final sectionMap = _extractMapPayload(createSectionResponse.data);
        sectionId = _asInt(sectionMap['id'] ?? sectionMap['sectionId']);
      } else {
        await _client.dio.patch(
          '/sections/$sectionId',
          data: <String, dynamic>{
            'maxCapacity': maxCapacity,
            'location': normalizedLocation,
          },
        );
      }

      if (sectionId <= 0) {
        throw Exception('Section id missing after upsert');
      }

      final existingSchedulesResponse = await _client.dio.get(
        '/schedules/section/$sectionId',
      );
      final existingSchedules = _extractListPayload(
        existingSchedulesResponse.data,
      ).whereType<Map<String, dynamic>>().toList();

      for (final schedule in existingSchedules) {
        final scheduleId = _asInt(schedule['id']);
        if (scheduleId <= 0) {
          continue;
        }
        await _client.dio.delete('/schedules/$scheduleId');
      }

      await _client.dio.post(
        '/schedules/section/$sectionId',
        data: <String, dynamic>{
          'dayOfWeek': scheduleDay.trim().toUpperCase(),
          'startTime': startTime.trim(),
          'endTime': endTime.trim(),
          'room': normalizedLocation,
          'scheduleType': 'LECTURE',
        },
      );

      return sectionId;
    }, fallbackMessage: 'Failed to save section and schedule');
  }

  Future<ServiceResult<void>> syncStaffAssignments({
    required int sectionId,
    required int instructorId,
    required List<int> taIds,
  }) {
    return RetryHelper.executeVoid(() async {
      final normalizedTaIds = taIds.where((id) => id > 0).toSet();

      final currentInstructorsResponse = await _client.dio.get(
        '/enrollments/sections/$sectionId/instructors',
      );
      final currentTAsResponse = await _client.dio.get(
        '/enrollments/sections/$sectionId/tas',
      );

      final currentInstructors = _extractListPayload(
        currentInstructorsResponse.data,
      ).whereType<Map<String, dynamic>>().toList();
      final currentTAs = _extractListPayload(
        currentTAsResponse.data,
      ).whereType<Map<String, dynamic>>().toList();

      for (final assignment in currentInstructors) {
        final userId = _asInt(assignment['userId']);
        final assignmentId = _asInt(assignment['id']);
        if (assignmentId <= 0) {
          continue;
        }

        if (instructorId <= 0 || userId != instructorId) {
          await _client.dio.delete(
            '/enrollments/sections/$sectionId/instructors/$assignmentId',
          );
        }
      }

      if (instructorId > 0) {
        final hasInstructor = currentInstructors.any(
          (assignment) => _asInt(assignment['userId']) == instructorId,
        );
        if (!hasInstructor) {
          await _client.dio.post(
            '/enrollments/sections/$sectionId/instructors',
            data: <String, dynamic>{'userId': instructorId},
          );
        }
      }

      for (final assignment in currentTAs) {
        final userId = _asInt(assignment['userId']);
        final assignmentId = _asInt(assignment['id']);
        if (assignmentId <= 0) {
          continue;
        }

        if (!normalizedTaIds.contains(userId)) {
          await _client.dio.delete(
            '/enrollments/sections/$sectionId/tas/$assignmentId',
          );
        }
      }

      for (final taId in normalizedTaIds) {
        final exists = currentTAs.any(
          (assignment) => _asInt(assignment['userId']) == taId,
        );
        if (!exists) {
          await _client.dio.post(
            '/enrollments/sections/$sectionId/tas',
            data: <String, dynamic>{'userId': taId},
          );
        }
      }
    }, fallbackMessage: 'Failed to save staff assignment');
  }

  Future<ServiceResult<void>> deleteCourse(int courseId) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/courses/$courseId');
    }, fallbackMessage: 'Failed to delete course');
  }

  Future<Map<int, String>> _loadActiveUserNames() async {
    try {
      final response = await _client.dio.get(
        '/admin/users',
        queryParameters: <String, dynamic>{
          'page': 1,
          'size': 1000,
          'status': 'active',
        },
      );

      final rows = _extractListPayload(
        response.data,
      ).whereType<Map<String, dynamic>>().toList();
      final map = <int, String>{};

      for (final row in rows) {
        final id = _asInt(row['userId'] ?? row['id']);
        if (id <= 0) {
          continue;
        }
        map[id] = _userDisplayName(row, fallbackId: id);
      }

      return map;
    } catch (_) {
      return <int, String>{};
    }
  }

  Future<AdminManagedCourse> _hydrateCourse(
    Map<String, dynamic> raw,
    Map<int, String> userNameById,
  ) async {
    final departmentMap = raw['department'] is Map<String, dynamic>
        ? raw['department'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final courseId = _asInt(raw['id'] ?? raw['courseId']);
    final baseDepartmentName = _asString(
      raw['departmentName'] ??
          departmentMap['name'] ??
          raw['department'] ??
          raw['faculty'],
      fallback: 'N/A',
    );

    final baseDepartmentId = _asInt(raw['departmentId'] ?? departmentMap['id']);

    final baseCode = _asString(raw['code'] ?? raw['courseCode']);
    final baseName = _asString(raw['name'] ?? raw['courseName']);
    final baseDescription = _asString(
      raw['description'],
      fallback: 'No description provided.',
    );
    final baseSyllabusUrl = _nullableString(raw['syllabusUrl']);
    final baseCredits = _asInt(raw['credits'], fallback: 3);
    final baseStatus = _normalizeStatus(
      _asString(raw['status'], fallback: 'ACTIVE'),
    );
    final baseLevel = _normalizeLevel(
      _asString(raw['level'], fallback: 'FRESHMAN'),
    );
    final baseCreatedAt = _parseDateTime(raw['createdAt']);
    final baseUpdatedAt = _parseDateTime(raw['updatedAt']);

    final basePrerequisites = _extractPrerequisites(raw['prerequisites']);

    int enrolled = _asInt(raw['enrolled'], fallback: 0);
    int capacity = _asInt(raw['capacity'], fallback: 0);

    int? sectionId;
    String sectionNumber = '01';
    String location = 'Room A-101';
    int semesterId = 0;
    String semesterName = _asString(raw['semester'], fallback: 'Not Set');
    String scheduleDay = 'Monday';
    String startTime = '09:00';
    String endTime = '10:30';

    int instructorId = _asInt(raw['instructorId'], fallback: 0);
    String instructorName = _resolveUserName(
      userNameById,
      instructorId,
      fallback: 'Unassigned',
    );

    List<int> taIds = _extractIntList(raw['taIds']);
    List<String> taNames = _extractStringList(raw['taNames']);

    if (courseId > 0) {
      final sectionsResponse = await _client.dio.get(
        '/sections/course/$courseId',
      );
      final sections = _extractListPayload(
        sectionsResponse.data,
      ).whereType<Map<String, dynamic>>().toList();

      if (sections.isNotEmpty) {
        final primary = sections.first;
        final semesterMap = primary['semester'] is Map<String, dynamic>
            ? primary['semester'] as Map<String, dynamic>
            : const <String, dynamic>{};

        sectionId = _asInt(primary['id'] ?? primary['sectionId']);
        sectionNumber = _asString(
          primary['sectionNumber'],
          fallback: sectionNumber,
        );
        location = _asString(primary['location'], fallback: location);
        semesterId = _asInt(primary['semesterId'] ?? semesterMap['id']);
        semesterName = _asString(
          semesterMap['name'] ?? primary['semesterName'],
          fallback: semesterName,
        );

        enrolled = _asInt(primary['currentEnrollment'], fallback: enrolled);
        capacity = _asInt(primary['maxCapacity'], fallback: capacity);

        if (sectionId > 0) {
          final scheduleResponse = await _client.dio.get(
            '/schedules/section/$sectionId',
          );
          final schedules = _extractListPayload(
            scheduleResponse.data,
          ).whereType<Map<String, dynamic>>().toList();
          if (schedules.isNotEmpty) {
            final firstSchedule = schedules.first;
            scheduleDay = _friendlyDay(
              _asString(firstSchedule['dayOfWeek'], fallback: scheduleDay),
            );
            startTime = _normalizeTimeValue(
              _asString(firstSchedule['startTime'], fallback: startTime),
              fallback: startTime,
            );
            endTime = _normalizeTimeValue(
              _asString(firstSchedule['endTime'], fallback: endTime),
              fallback: endTime,
            );
            location = _asString(firstSchedule['room'], fallback: location);
          }

          final instructorsResponse = await _client.dio.get(
            '/enrollments/sections/$sectionId/instructors',
          );
          final tasResponse = await _client.dio.get(
            '/enrollments/sections/$sectionId/tas',
          );

          final instructors = _extractListPayload(
            instructorsResponse.data,
          ).whereType<Map<String, dynamic>>().toList();
          final tas = _extractListPayload(
            tasResponse.data,
          ).whereType<Map<String, dynamic>>().toList();

          if (instructors.isNotEmpty) {
            final firstInstructor = instructors.first;
            instructorId = _asInt(firstInstructor['userId']);
            instructorName = _userNameFromAssignment(
              firstInstructor,
              userNameById,
              fallback: _resolveUserName(
                userNameById,
                instructorId,
                fallback: 'Unassigned',
              ),
            );
          } else if (instructorId > 0) {
            instructorName = _resolveUserName(
              userNameById,
              instructorId,
              fallback: instructorName,
            );
          }

          taIds = tas
              .map((item) => _asInt(item['userId']))
              .where((id) => id > 0)
              .toList();
          taNames = tas
              .map(
                (item) => _userNameFromAssignment(
                  item,
                  userNameById,
                  fallback: _resolveUserName(
                    userNameById,
                    _asInt(item['userId']),
                    fallback: '',
                  ),
                ),
              )
              .where((name) => name.trim().isNotEmpty)
              .toList();
        }
      }
    }

    if (capacity <= 0) {
      capacity = 30;
    }

    return AdminManagedCourse(
      id: courseId,
      departmentId: baseDepartmentId,
      code: baseCode,
      name: baseName,
      description: baseDescription,
      syllabusUrl: baseSyllabusUrl,
      department: baseDepartmentName,
      semester: semesterName,
      credits: baseCredits,
      enrolled: enrolled,
      capacity: capacity,
      status: baseStatus,
      level: baseLevel,
      instructorId: instructorId,
      instructorName: instructorName,
      taIds: taIds,
      taNames: taNames,
      prerequisites: basePrerequisites,
      sectionId: sectionId,
      sectionNumber: sectionNumber,
      location: location,
      semesterId: semesterId,
      scheduleDay: scheduleDay,
      startTime: startTime,
      endTime: endTime,
      createdAt: baseCreatedAt,
      updatedAt: baseUpdatedAt,
    );
  }

  List<String> _roleCandidates(String role) {
    final normalized = _normalizeRole(role);
    if (normalized == 'teaching_assistant') {
      return const <String>['teaching_assistant', 'ta'];
    }
    return <String>[normalized];
  }

  String _extractPrimaryRole(Map<String, dynamic> row) {
    final roles = row['roles'];
    if (roles is List && roles.isNotEmpty) {
      final first = roles.first;
      if (first is Map<String, dynamic>) {
        return _asString(first['roleName'] ?? first['name']);
      }
      if (first is String) {
        return first;
      }
    }
    return _asString(row['roleName']);
  }

  String _normalizeRole(String role) {
    final value = role.trim().toLowerCase();
    if (value == 'ta') {
      return 'teaching_assistant';
    }
    if (value == 'teaching-assistant') {
      return 'teaching_assistant';
    }
    return value;
  }

  String _normalizeStatus(String value) {
    final normalized = value.trim().toUpperCase();
    if (normalized == 'INACTIVE') {
      return 'INACTIVE';
    }
    if (normalized == 'ARCHIVED') {
      return 'ARCHIVED';
    }
    return 'ACTIVE';
  }

  String _normalizeLevel(String value) {
    final normalized = value.trim().toUpperCase();
    const allowed = <String>{
      'FRESHMAN',
      'SOPHOMORE',
      'JUNIOR',
      'SENIOR',
      'GRADUATE',
    };
    if (allowed.contains(normalized)) {
      return normalized;
    }
    return 'FRESHMAN';
  }

  String _friendlyDay(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Monday';
    }
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  String _normalizeTimeValue(String value, {required String fallback}) {
    final text = value.trim();
    final match = RegExp(r'^(\d{2}):(\d{2})').firstMatch(text);
    if (match == null) {
      return fallback;
    }
    return '${match.group(1)}:${match.group(2)}';
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is! Map<String, dynamic>) {
      return const <dynamic>[];
    }

    final data = payload['data'];
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested;
      }
    }

    for (final value in payload.values) {
      if (value is List) {
        return value;
      }
    }

    return const <dynamic>[];
  }

  Map<String, dynamic> _extractMapPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return const <String, dynamic>{};
  }

  int _asInt(dynamic value, {int fallback = 0}) {
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
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String? _nullableString(dynamic value) {
    final text = _asString(value);
    if (text.isEmpty) {
      return null;
    }
    return text;
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

  List<int> _extractIntList(dynamic value) {
    if (value is! List) {
      return const <int>[];
    }
    return value.map((entry) => _asInt(entry)).where((id) => id > 0).toList();
  }

  List<String> _extractStringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }
    return value
        .map((entry) => _asString(entry))
        .where((entry) => entry.isNotEmpty)
        .toList();
  }

  List<String> _extractPrerequisites(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    final items = <String>[];
    for (final entry in value) {
      if (entry is String) {
        final normalized = entry.trim();
        if (normalized.isNotEmpty) {
          items.add(normalized);
        }
        continue;
      }

      if (entry is Map<String, dynamic>) {
        final name = _asString(
          entry['courseCode'] ??
              entry['code'] ??
              entry['courseName'] ??
              entry['name'],
        );
        if (name.isNotEmpty) {
          items.add(name);
        }
      }
    }

    return items;
  }

  String _resolveUserName(
    Map<int, String> userNameById,
    int userId, {
    required String fallback,
  }) {
    if (userId <= 0) {
      return fallback;
    }
    return userNameById[userId] ?? fallback;
  }

  String _userDisplayName(Map<String, dynamic> row, {required int fallbackId}) {
    final fullName = _asString(row['fullName']);
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final firstName = _asString(row['firstName']);
    final lastName = _asString(row['lastName']);
    final joined = '$firstName $lastName'.trim();
    if (joined.isNotEmpty) {
      return joined;
    }

    final email = _asString(row['email']);
    if (email.isNotEmpty) {
      return email;
    }

    return 'User #$fallbackId';
  }

  String _userNameFromAssignment(
    Map<String, dynamic> assignment,
    Map<int, String> userNameById, {
    required String fallback,
  }) {
    final user = assignment['user'];
    if (user is Map<String, dynamic>) {
      final fullName = _userDisplayName(
        user,
        fallbackId: _asInt(user['userId'] ?? user['id']),
      );
      if (fullName.trim().isNotEmpty) {
        return fullName;
      }
    }

    final firstName = _asString(assignment['firstName']);
    final lastName = _asString(assignment['lastName']);
    final inlineName = '$firstName $lastName'.trim();
    if (inlineName.isNotEmpty) {
      return inlineName;
    }

    final userId = _asInt(assignment['userId']);
    if (userId > 0 && userNameById.containsKey(userId)) {
      return userNameById[userId]!;
    }

    return fallback;
  }
}
