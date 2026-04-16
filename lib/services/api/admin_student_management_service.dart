import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/admin/admin_student_management_models.dart';
import 'core_api_client.dart';

class AdminStudentManagementService {
  final CoreApiClient _client;

  static const Set<String> _backendStatuses = <String>{
    'active',
    'inactive',
    'suspended',
    'pending',
  };

  AdminStudentManagementService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  Future<ServiceResult<AdminStudentsPageModel>> getStudents({
    int page = 1,
    int size = 10,
    String? search,
    String? status,
  }) {
    return RetryHelper.execute<AdminStudentsPageModel>(() async {
      final normalizedSearch = (search ?? '').trim();
      final normalizedStatus = (status ?? '').trim().toLowerCase();
      final backendStatus = _normalizeBackendStatus(normalizedStatus);

      final response = normalizedSearch.isNotEmpty
          ? await _client.dio.get(
              '/admin/users/search',
              queryParameters: <String, dynamic>{'query': normalizedSearch},
            )
          : await _client.dio.get(
              '/admin/users',
              queryParameters: <String, dynamic>{
                'role': 'student',
                'page': page,
                'size': size,
                if (backendStatus != null) 'status': backendStatus,
              },
            );

      final rows = _extractUsersList(response.data);
      final students = rows
          .whereType<Map<String, dynamic>>()
          .map(AdminStudentModel.fromJson)
          .toList();

      final filteredStudents = normalizedStatus.isEmpty
          ? students
          : students
                .where((student) => student.status == normalizedStatus)
                .toList();

      final meta = _extractMeta(
        response.data,
        fallbackPage: page,
        fallbackSize: size,
        fallbackTotal: filteredStudents.length,
      );

      return AdminStudentsPageModel(
        items: filteredStudents,
        page: meta.page,
        size: meta.size,
        total: meta.total,
        totalPages: meta.totalPages,
      );
    }, fallbackMessage: 'Failed to load students');
  }

  Future<ServiceResult<AdminStudentModel>> createStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) {
    return RetryHelper.execute<AdminStudentModel>(() async {
      final payload = <String, dynamic>{
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'role': 'student',
      };

      if (phone != null && phone.trim().isNotEmpty) {
        final normalizedPhone = phone.trim();
        if (!_isValidPhone(normalizedPhone)) {
          throw Exception(
            'Phone number must be in international format (e.g. +201234567890)',
          );
        }
        payload['phone'] = normalizedPhone;
      }

      final response = await _client.dio.post('/auth/register', data: payload);
      return AdminStudentModel.fromJson(_extractPrimaryMap(response.data));
    }, fallbackMessage: 'Failed to create student');
  }

  Future<ServiceResult<AdminStudentModel>> updateStudent({
    required int id,
    required Map<String, dynamic> payload,
  }) {
    return RetryHelper.execute<AdminStudentModel>(() async {
      final safePayload = _sanitizeUserUpdatePayload(payload);
      if (safePayload.isEmpty) {
        throw Exception('No valid profile fields provided for update');
      }

      final response = await _client.dio.put(
        '/admin/users/$id',
        data: safePayload,
      );
      return AdminStudentModel.fromJson(_extractPrimaryMap(response.data));
    }, fallbackMessage: 'Failed to update student');
  }

  Future<ServiceResult<AdminStudentModel>> updateStudentStatus({
    required int id,
    required String status,
  }) {
    return RetryHelper.execute<AdminStudentModel>(() async {
      final normalizedStatus = _normalizeBackendStatus(status);
      if (normalizedStatus == null) {
        throw Exception('Invalid status for backend update: $status');
      }

      final response = await _client.dio.put(
        '/admin/users/$id/status',
        data: <String, dynamic>{'status': normalizedStatus},
      );
      return AdminStudentModel.fromJson(_extractPrimaryMap(response.data));
    }, fallbackMessage: 'Failed to update student status');
  }

  Future<ServiceResult<void>> deleteStudent({required int id}) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/admin/users/$id');
    }, fallbackMessage: 'Failed to delete student');
  }

  List<dynamic> _extractUsersList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is! Map<String, dynamic>) {
      return const <dynamic>[];
    }

    final directCandidates = <dynamic>[
      payload['users'],
      payload['results'],
      payload['items'],
      payload['data'],
    ];

    for (final candidate in directCandidates) {
      if (candidate is List) {
        return candidate;
      }
    }

    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      final nestedCandidates = <dynamic>[
        data['users'],
        data['results'],
        data['items'],
        data['data'],
      ];
      for (final candidate in nestedCandidates) {
        if (candidate is List) {
          return candidate;
        }
      }
    }

    return const <dynamic>[];
  }

  _PageMeta _extractMeta(
    dynamic payload, {
    required int fallbackPage,
    required int fallbackSize,
    required int fallbackTotal,
  }) {
    if (payload is! Map<String, dynamic>) {
      return _PageMeta(
        page: fallbackPage,
        size: fallbackSize,
        total: fallbackTotal,
        totalPages: 1,
      );
    }

    Map<String, dynamic> source = payload;
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      source = data;
    }

    final meta = source['meta'];
    if (meta is Map<String, dynamic>) {
      source = meta;
    } else {
      final pagination = source['pagination'];
      if (pagination is Map<String, dynamic>) {
        source = pagination;
      }
    }

    final total = _parseInt(source['total'], fallback: fallbackTotal);
    final page = _parseInt(source['page'], fallback: fallbackPage);
    final size = _parseInt(
      source['size'] ?? source['limit'],
      fallback: fallbackSize,
    );

    final totalPagesFromSource = _parseInt(source['totalPages']);
    final computedPages = size <= 0 ? 1 : (total / size).ceil();
    final totalPages = totalPagesFromSource > 0
        ? totalPagesFromSource
        : (computedPages <= 0 ? 1 : computedPages);

    return _PageMeta(
      page: page,
      size: size,
      total: total,
      totalPages: totalPages,
    );
  }

  Map<String, dynamic> _extractPrimaryMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final candidates = <dynamic>[payload['user'], payload['data']];
      for (final candidate in candidates) {
        if (candidate is Map<String, dynamic>) {
          return candidate;
        }
      }
      return payload;
    }
    return <String, dynamic>{};
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

  String? _normalizeBackendStatus(String status) {
    final normalized = status.trim().toLowerCase();
    if (_backendStatuses.contains(normalized)) {
      return normalized;
    }
    return null;
  }

  Map<String, dynamic> _sanitizeUserUpdatePayload(
    Map<String, dynamic> payload,
  ) {
    final safe = <String, dynamic>{};

    void copyTrimmed(String key) {
      if (!payload.containsKey(key)) {
        return;
      }

      final value = payload[key];
      if (value == null) {
        return;
      }

      final text = value.toString().trim();
      if (text.isEmpty) {
        if (key == 'phone' || key == 'profilePictureUrl') {
          safe[key] = '';
        }
        return;
      }

      if (key == 'phone' && !_isValidPhone(text)) {
        throw Exception(
          'Phone number must be in international format (e.g. +201234567890)',
        );
      }

      safe[key] = text;
    }

    copyTrimmed('firstName');
    copyTrimmed('lastName');
    copyTrimmed('phone');
    copyTrimmed('profilePictureUrl');

    if (payload.containsKey('campusId')) {
      final campusId = _parseInt(payload['campusId']);
      if (campusId > 0) {
        safe['campusId'] = campusId;
      }
    }

    return safe;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
  }
}

class _PageMeta {
  final int page;
  final int size;
  final int total;
  final int totalPages;

  const _PageMeta({
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
  });
}
