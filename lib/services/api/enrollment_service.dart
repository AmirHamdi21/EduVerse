import 'package:dio/dio.dart';

import 'core_api_client.dart';
import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/admin/admin_periods_models.dart';
import '../../models/core/enrollment_model.dart';
import '../../models/registration/registration_available_course_model.dart';
import '../../models/instructor/teaching_course_model.dart';
import '../../models/instructor/instructor_course_model.dart';
import '../../models/courses/instructor_assignment_model.dart';
import '../../models/ta/ta_assignment_model.dart';

/// Service for Enrollment API endpoints.
///
/// Wraps all `/api/enrollments` calls.
class EnrollmentService {
  final CoreApiClient _client;

  EnrollmentService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  /// GET /api/enrollments/my-courses
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyEnrollments({
    int? semester,
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final int? normalizedSemester = (semester != null && semester > 0)
          ? semester
          : null;

      final queryParams = normalizedSemester != null
          ? <String, dynamic>{'semester': normalizedSemester}
          : null;

      final response = await _client.dio.get(
        '/enrollments/my-courses',
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your enrollments');
  }

  /// GET /api/enrollments/my-courses
  Future<ServiceResult<List<CourseEnrollmentModel>>> getMyCourses({
    int? semester,
    CancelToken? cancelToken,
  }) {
    return getMyEnrollments(semester: semester, cancelToken: cancelToken);
  }

  /// GET /api/enrollments/teaching
  Future<ServiceResult<List<TeachingCourseModel>>> getTeachingCourses({
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<TeachingCourseModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/teaching',
        cancelToken: cancelToken,
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(TeachingCourseModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load teaching courses');
  }

  /// GET /api/enrollments/available
  Future<ServiceResult<List<RegistrationAvailableCourseModel>>>
  getAvailableCourses({
    int? departmentId,
    int? semesterId,
    String? search,
    String? level,
    int page = 1,
    int limit = 20,
  }) {
    return RetryHelper.execute<List<RegistrationAvailableCourseModel>>(
      () async {
        final query = <String, dynamic>{'page': page, 'limit': limit};
        if (departmentId != null && departmentId > 0) {
          query['departmentId'] = departmentId;
        }
        if (semesterId != null && semesterId > 0) {
          query['semesterId'] = semesterId;
        }
        if (search != null && search.trim().isNotEmpty) {
          query['search'] = search.trim();
        }
        if (level != null && level.trim().isNotEmpty) {
          query['level'] = level.trim();
        }

        final response = await _client.dio.get(
          '/enrollments/available',
          queryParameters: query,
        );
        return _extractList(response.data)
            .whereType<Map<String, dynamic>>()
            .map(RegistrationAvailableCourseModel.fromJson)
            .toList();
      },
      fallbackMessage: 'Failed to load available courses',
    );
  }

  /// GET /api/enrollments/periods
  Future<ServiceResult<List<EnrollmentPeriodModel>>> getEnrollmentPeriods() {
    return RetryHelper.execute<List<EnrollmentPeriodModel>>(() async {
      final response = await _client.dio.get('/enrollments/periods');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(EnrollmentPeriodModel.fromSemesterJson)
          .toList();
    }, fallbackMessage: 'Failed to load enrollment periods');
  }

  /// GET /api/enrollments/{enrollmentId}
  Future<ServiceResult<CourseEnrollmentModel>> getEnrollmentById(
    dynamic enrollmentId,
  ) {
    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final response = await _client.dio.get('/enrollments/$enrollmentId');
      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load enrollment details');
  }

  /// GET /api/enrollments/course/{courseId}/list
  Future<ServiceResult<List<CourseEnrollmentModel>>> getCourseEnrollments(
    dynamic courseId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/course/$courseId/list',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load course enrollments');
  }

  /// GET /api/enrollments/sections/:id/students
  Future<ServiceResult<List<CourseEnrollmentModel>>> getSectionStudents(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/section/$sectionId/students',
      );

      final students = _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(SectionStudentModel.fromJson)
          .toList();

      return students
          .map(
            (student) => CourseEnrollmentModel.fromJson(<String, dynamic>{
              'id': student.userId,
              'userId': student.userId,
              'sectionId': sectionId,
              'status': student.status,
              'grade': student.grade?.toString(),
              'finalScore': student.grade,
              'enrollmentDate': DateTime.now().toIso8601String(),
            }),
          )
          .toList();
    }, fallbackMessage: 'Failed to load section students');
  }

  /// GET /api/enrollments/section/{sectionId}/students
  Future<ServiceResult<List<SectionStudentModel>>> getSectionStudentsLite(
    dynamic sectionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<SectionStudentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/section/$sectionId/students',
        cancelToken: cancelToken,
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(SectionStudentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section students');
  }

  /// GET /api/enrollments/section/{sectionId}/students/count
  Future<ServiceResult<int>> getSectionStudentsCount(dynamic sectionId) {
    return RetryHelper.execute<int>(() async {
      final response = await _client.dio.get(
        '/enrollments/section/$sectionId/students/count',
      );
      final payload = _extractMap(response.data);
      return payload['count'] as int;
    }, fallbackMessage: 'Failed to get student count');
  }

  /// GET /api/enrollments/course/{courseId}/enrolled-students
  Future<ServiceResult<List<SectionStudentModel>>> getCourseStudents(
    dynamic courseId,
  ) {
    return RetryHelper.execute<List<SectionStudentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/course/$courseId/enrolled-students',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(SectionStudentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load course students');
  }

  /// GET /api/enrollments/section/{sectionId}/waitlist
  Future<ServiceResult<List<CourseEnrollmentModel>>> getSectionWaitlist(
    dynamic sectionId,
  ) {
    return RetryHelper.execute<List<CourseEnrollmentModel>>(() async {
      final response = await _client.dio.get(
        '/enrollments/section/$sectionId/waitlist',
      );
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CourseEnrollmentModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load section waitlist');
  }

  /// GET /api/enrollments/sections/{sectionId}/tas
  Future<ServiceResult<List<TAAssignmentModel>>> getSectionTAs(
    dynamic sectionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<TAAssignmentModel>>(() async {
      dynamic response;
      try {
        response = await _client.dio.get(
          '/enrollments/sections/$sectionId/tas',
          cancelToken: cancelToken,
        );
      } on Exception {
        response = await _client.dio.get(
          '/enrollments/section/$sectionId/tas',
          cancelToken: cancelToken,
        );
      }
      return _extractStaffMaps(
        response.data,
      ).map(TAAssignmentModel.fromJson).toList();
    }, fallbackMessage: 'Failed to load section TAs');
  }

  /// GET /api/enrollments/sections/:id/instructors
  Future<ServiceResult<List<InstructorAssignmentModel>>> getSectionInstructors(
    dynamic sectionId, {
    CancelToken? cancelToken,
  }) {
    return RetryHelper.execute<List<InstructorAssignmentModel>>(() async {
      dynamic response;
      try {
        response = await _client.dio.get(
          '/enrollments/sections/$sectionId/instructors',
          cancelToken: cancelToken,
        );
      } on Exception {
        response = await _client.dio.get(
          '/enrollments/section/$sectionId/instructor',
          cancelToken: cancelToken,
        );
      }

      final payload = response.data;
      final summaryMap = _extractMap(payload);
      final staffMaps = _extractStaffMaps(payload);

      final normalized = staffMaps
          .map((item) {
            if (summaryMap['instructor'] == item) {
              return <String, dynamic>{
                'id':
                    summaryMap['instructorId'] ?? item['userId'] ?? item['id'],
                'sectionId': _parseInt(sectionId),
                'userId':
                    summaryMap['instructorId'] ?? item['userId'] ?? item['id'],
                'role': 'primary',
                ...item,
              };
            }
            return item;
          })
          .toList(growable: false);

      return normalized.map(InstructorAssignmentModel.fromJson).toList();
    }, fallbackMessage: 'Failed to load section instructors');
  }

  /// POST /api/enrollments/register
  Future<ServiceResult<CourseEnrollmentModel>> registerForSection({
    required int sectionId,
  }) {
    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final response = await _client.dio.post(
        '/enrollments/register',
        data: <String, dynamic>{'sectionId': sectionId},
      );
      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to register enrollment');
  }

  /// POST /api/enrollments/register
  Future<ServiceResult<CourseEnrollmentModel>> register(
    dynamic sectionId,
    Map<String, dynamic> data,
  ) {
    final int parsedSectionId = _parseInt(sectionId);
    if (data.isEmpty) {
      return registerForSection(sectionId: parsedSectionId);
    }

    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final body = <String, dynamic>{'sectionId': parsedSectionId, ...data};
      final response = await _client.dio.post(
        '/enrollments/register',
        data: body,
      );
      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to register enrollment');
  }

  /// POST /api/enrollments/admin/enroll (admin workflow)
  Future<ServiceResult<CourseEnrollmentModel>> adminRegisterStudent({
    required dynamic sectionId,
    required int userId,
    bool force = false,
  }) {
    return RetryHelper.execute<CourseEnrollmentModel>(() async {
      final body = <String, dynamic>{'sectionId': sectionId, 'userId': userId};
      if (force) {
        body['force'] = true;
      }

      dynamic response;
      try {
        response = await _client.dio.post(
          '/enrollments/admin/enroll',
          data: body,
        );
      } catch (_) {
        // Backward compatibility for environments that still route admin
        // enrollment through the legacy register endpoint.
        response = await _client.dio.post('/enrollments/register', data: body);
      }

      return CourseEnrollmentModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to enroll student');
  }

  /// DELETE /api/enrollments/:id
  Future<ServiceResult<void>> dropEnrollment(dynamic id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/enrollments/$id');
    }, fallbackMessage: 'Failed to drop enrollment');
  }

  /// DELETE /api/enrollments/:id (admin workflow)
  Future<ServiceResult<void>> adminDropEnrollment({
    required dynamic enrollmentId,
    String? reason,
    bool force = false,
  }) {
    return RetryHelper.executeVoid(() async {
      final body = <String, dynamic>{};
      if (reason != null && reason.trim().isNotEmpty) {
        body['reason'] = reason.trim();
      }
      if (force) {
        body['force'] = true;
      }

      await _client.dio.delete(
        '/enrollments/$enrollmentId',
        data: body.isEmpty ? null : body,
      );
    }, fallbackMessage: 'Failed to drop enrollment');
  }

  /// POST /api/enrollments/sections/:id/instructors
  Future<ServiceResult<void>> assignInstructor(dynamic sectionId, int userId) {
    return assignInstructorWithDetails(sectionId, userId);
  }

  /// POST /api/enrollments/sections/:id/instructors
  Future<ServiceResult<void>> assignInstructorWithDetails(
    dynamic sectionId,
    int userId, {
    String? role,
  }) {
    return RetryHelper.executeVoid(() async {
      final body = <String, dynamic>{'userId': userId};
      if (role != null && role.trim().isNotEmpty) {
        body['role'] = role.trim();
      }

      await _client.dio.post(
        '/enrollments/sections/$sectionId/instructors',
        data: body,
      );
    }, fallbackMessage: 'Failed to assign instructor');
  }

  /// DELETE /api/enrollments/sections/:id/instructors/:enrollmentId
  Future<ServiceResult<void>> removeInstructor(
    dynamic sectionId,
    dynamic enrollmentId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/enrollments/sections/$sectionId/instructors/$enrollmentId',
      );
    }, fallbackMessage: 'Failed to remove instructor');
  }

  /// POST /api/enrollments/sections/:id/tas
  Future<ServiceResult<void>> assignTA(dynamic sectionId, int userId) {
    return assignTAWithDetails(sectionId, userId);
  }

  /// POST /api/enrollments/sections/:id/tas
  Future<ServiceResult<void>> assignTAWithDetails(
    dynamic sectionId,
    int userId, {
    String? responsibilities,
  }) {
    return RetryHelper.executeVoid(() async {
      final body = <String, dynamic>{'userId': userId};
      if (responsibilities != null && responsibilities.trim().isNotEmpty) {
        body['responsibilities'] = responsibilities.trim();
      }

      await _client.dio.post(
        '/enrollments/sections/$sectionId/tas',
        data: body,
      );
    }, fallbackMessage: 'Failed to assign TA');
  }

  /// DELETE /api/enrollments/sections/:id/tas/:enrollmentId
  Future<ServiceResult<void>> removeTA(
    dynamic sectionId,
    dynamic enrollmentId,
  ) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete(
        '/enrollments/sections/$sectionId/tas/$enrollmentId',
      );
    }, fallbackMessage: 'Failed to remove TA');
  }

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _extractStaffMaps(dynamic payload) {
    final listPayload = _extractList(
      payload,
    ).whereType<Map<String, dynamic>>().toList();
    if (listPayload.isNotEmpty) {
      return listPayload;
    }

    if (payload is! Map<String, dynamic>) {
      return const <Map<String, dynamic>>[];
    }

    final dynamicData = payload['data'];
    if (dynamicData is Map<String, dynamic> &&
        _looksLikeStaffItem(dynamicData)) {
      return <Map<String, dynamic>>[dynamicData];
    }

    final nestedKeys = <String>['instructor', 'ta', 'staff', 'teacher'];
    for (final key in nestedKeys) {
      final nested = payload[key];
      if (nested is Map<String, dynamic> && _looksLikeStaffItem(nested)) {
        return <Map<String, dynamic>>[nested];
      }
    }

    if (_looksLikeStaffItem(payload)) {
      return <Map<String, dynamic>>[payload];
    }

    return const <Map<String, dynamic>>[];
  }

  static bool _looksLikeStaffItem(Map<String, dynamic> item) {
    return item.containsKey('userId') ||
        item.containsKey('user') ||
        item.containsKey('email') ||
        item.containsKey('firstName') ||
        item.containsKey('lastName');
  }

  static List<dynamic> _extractList(dynamic payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }

      for (final value in payload.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return <dynamic>[];
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
}
