# Codex Prompt — Attendance API Integration (Definitive)

> **Context**: EduVerse Flutter app. All attendance screens use hardcoded mock data.
> Create `AttendanceService`, new models, new/updated cubits, shared widgets, and rewrite screens
> to call the real NestJS backend API. Follow patterns from `enrollment_service.dart`.
>
> **Reference Files (Web Frontend)**:
> - `attendanceService.ts` — L1–131 (TypeScript interfaces + API methods)
> - `LectureAttendanceFlow.tsx` — L1–1143 (Instructor 3-view attendance flow)
> - `AttendancePage.tsx` — L1–1041 (TA AI-first attendance flow)
> - `AttendanceOverview.tsx` — L1–719 (Student attendance overview)
> - `AttendanceManagementPage.tsx` — L1–511 (Admin attendance management)
>
> **Reference Files (Flutter Patterns)**:
> - `enrollment_service.dart` — L1–440 (`CoreApiClient` + `RetryHelper` + `ServiceResult` pattern)
> - `attendance_state.dart` — L1–282 (existing student state models)
> - `attendance_cubit.dart` — L1–333 (existing student cubit with mock generators)

---

## 1. Data Models — Complete Code

### 1A. `lib/models/attendance/attendance_session_model.dart`

```dart
import 'package:equatable/equatable.dart';
import 'attendance_record_model.dart';

/// Maps backend session entity and web's LectureAttendanceFlow.tsx types (L30-53).
///
/// Used by: GET /attendance/sessions, GET /attendance/sessions/:id,
///          POST /attendance/sessions responses.
class AttendanceSessionModel extends Equatable {
  final int id;
  final int sectionId;
  final String sessionDate;       // "YYYY-MM-DD"
  final String? sessionType;      // "lecture" | "lab" | "tutorial" | "exam"
  final String status;            // "scheduled" | "in_progress" | "completed" | "cancelled"
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;
  final int? totalMinutes;
  final List<AttendanceRecordModel> records;

  const AttendanceSessionModel({
    required this.id,
    required this.sectionId,
    required this.sessionDate,
    this.sessionType,
    required this.status,
    this.presentCount = 0,
    this.absentCount = 0,
    this.lateCount = 0,
    this.excusedCount = 0,
    this.totalMinutes,
    this.records = const [],
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    final recordsList = json['records'];
    return AttendanceSessionModel(
      id: json['id'] as int? ?? 0,
      sectionId: json['sectionId'] as int? ?? 0,
      sessionDate: json['sessionDate']?.toString() ?? '',
      sessionType: json['sessionType']?.toString(),
      status: json['status']?.toString() ?? 'scheduled',
      presentCount: json['presentCount'] as int? ?? 0,
      absentCount: json['absentCount'] as int? ?? 0,
      lateCount: json['lateCount'] as int? ?? 0,
      excusedCount: json['excusedCount'] as int? ?? 0,
      totalMinutes: json['totalMinutes'] as int?,
      records: recordsList is List
          ? recordsList
              .whereType<Map<String, dynamic>>()
              .map(AttendanceRecordModel.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'sessionDate': sessionDate,
        'sessionType': sessionType,
        'status': status,
        'totalMinutes': totalMinutes,
      };

  /// Web: LectureAttendanceFlow.tsx L310 filters for these statuses
  bool get isOpen => status == 'scheduled' || status == 'in_progress';

  /// Web: LectureAttendanceFlow.tsx L340 checks for these
  bool get isClosed => status == 'completed' || status == 'cancelled';

  int get totalRecords => records.length;

  AttendanceSessionModel copyWith({
    int? id,
    int? sectionId,
    String? sessionDate,
    String? sessionType,
    String? status,
    int? presentCount,
    int? absentCount,
    int? lateCount,
    int? excusedCount,
    int? totalMinutes,
    List<AttendanceRecordModel>? records,
  }) {
    return AttendanceSessionModel(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionType: sessionType ?? this.sessionType,
      status: status ?? this.status,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      excusedCount: excusedCount ?? this.excusedCount,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      records: records ?? this.records,
    );
  }

  @override
  List<Object?> get props => [
        id, sectionId, sessionDate, sessionType, status,
        presentCount, absentCount, lateCount, excusedCount,
        totalMinutes, records,
      ];
}
```

### 1B. `lib/models/attendance/attendance_record_model.dart`

```dart
import 'package:equatable/equatable.dart';

/// Maps nested records[] from GET /attendance/sessions/:id.
/// Matches web LectureAttendanceFlow.tsx types L38-51 (AttUser, AttRecord).
class AttendanceRecordModel extends Equatable {
  final int userId;
  final String attendanceStatus;  // "present" | "absent" | "late" | "excused"
  final String? markedBy;         // "manual" | "ai"
  final double? confidenceScore;  // 0.0–1.0 from AI, null for manual
  final String? notes;
  final String? checkinTime;
  // Nested user info from backend JOIN
  final String? firstName;
  final String? lastName;
  final String? email;

  const AttendanceRecordModel({
    required this.userId,
    required this.attendanceStatus,
    this.markedBy,
    this.confidenceScore,
    this.notes,
    this.checkinTime,
    this.firstName,
    this.lastName,
    this.email,
  });

  /// Handles both flat fields and nested user object.
  /// Web equivalent: LectureAttendanceFlow.tsx displayName() L90-96.
  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AttendanceRecordModel(
      userId: json['userId'] as int? ?? 0,
      attendanceStatus: json['attendanceStatus']?.toString() ?? 'absent',
      markedBy: json['markedBy']?.toString(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      checkinTime: json['checkinTime']?.toString(),
      firstName: user?['firstName']?.toString() ?? json['firstName']?.toString(),
      lastName: user?['lastName']?.toString() ?? json['lastName']?.toString(),
      email: user?['email']?.toString() ?? json['email']?.toString(),
    );
  }

  /// Matches web's displayName() at LectureAttendanceFlow.tsx L90-96
  String get displayName {
    final parts = [firstName, lastName]
        .where((s) => s != null && s!.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    if (email != null && email!.isNotEmpty) return email!;
    return 'Student #$userId';
  }

  /// Normalize status matching web's normalizeStatus() at L98-101
  static String normalizeStatus(String? s) {
    final x = (s ?? 'absent').toLowerCase();
    const valid = ['present', 'absent', 'late', 'excused'];
    return valid.contains(x) ? x : 'absent';
  }

  @override
  List<Object?> get props => [
        userId, attendanceStatus, markedBy, confidenceScore,
        notes, checkinTime, firstName, lastName, email,
      ];
}
```

### 1C. `lib/models/attendance/student_attendance_summary_model.dart`

```dart
import 'package:equatable/equatable.dart';

/// Maps GET /attendance/my and GET /attendance/by-student/:id responses.
/// MUST match web AttendanceRecord interface at attendanceService.ts L3-14.
class StudentAttendanceSummaryModel extends Equatable {
  final int courseId;
  final String courseName;
  final String courseCode;
  final int totalClasses;
  final int attended;
  final int absent;
  final int lateCount;       // Named lateCount to avoid Dart keyword 'late'
  final int excused;
  final double percentage;
  final String? lastClassDate;

  const StudentAttendanceSummaryModel({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalClasses,
    required this.attended,
    required this.absent,
    this.lateCount = 0,
    this.excused = 0,
    required this.percentage,
    this.lastClassDate,
  });

  /// Handles percentage computation fallback matching web
  /// AttendanceOverview.tsx L225: r.percentage ?? (r.totalClasses > 0 ? ...)
  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final total = json['totalClasses'] as int? ?? 0;
    final att = json['attended'] as int? ?? 0;
    final pct = json['percentage'] as num?;
    return StudentAttendanceSummaryModel(
      courseId: json['courseId'] as int? ?? 0,
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      totalClasses: total,
      attended: att,
      absent: json['absent'] as int? ?? 0,
      lateCount: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
      percentage: pct?.toDouble() ?? (total > 0 ? (att / total) * 100 : 0),
      lastClassDate: json['lastClassDate']?.toString(),
    );
  }

  /// Matches web AttendanceOverview.tsx L235
  String get statusLabel {
    if (percentage >= 90) return 'excellent';
    if (percentage >= 80) return 'good';
    return 'warning';
  }

  @override
  List<Object?> get props => [
        courseId, courseName, courseCode, totalClasses,
        attended, absent, lateCount, excused, percentage, lastClassDate,
      ];
}
```

### 1D. `lib/models/attendance/ai_processing_result_model.dart`

```dart
import 'package:equatable/equatable.dart';

/// Maps POST /attendance/ai-photo and GET /attendance/ai-photo/:id responses.
/// MUST match web AiProcessingResult interface at attendanceService.ts L38-46.
class AiProcessingResultModel extends Equatable {
  final int processingId;
  final String status;              // "pending" | "processing" | "completed" | "failed" | "manual_review"
  final int? detectedFacesCount;
  final int? matchedStudentsCount;
  final int? unmatchedFacesCount;
  final String? errorMessage;
  final int? processingTimeMs;

  const AiProcessingResultModel({
    required this.processingId,
    required this.status,
    this.detectedFacesCount,
    this.matchedStudentsCount,
    this.unmatchedFacesCount,
    this.errorMessage,
    this.processingTimeMs,
  });

  factory AiProcessingResultModel.fromJson(Map<String, dynamic> json) {
    return AiProcessingResultModel(
      processingId: json['processingId'] as int? ?? 0,
      status: json['status']?.toString() ?? 'pending',
      detectedFacesCount: json['detectedFacesCount'] as int?,
      matchedStudentsCount: json['matchedStudentsCount'] as int?,
      unmatchedFacesCount: json['unmatchedFacesCount'] as int?,
      errorMessage: json['errorMessage']?.toString(),
      processingTimeMs: json['processingTimeMs'] as int?,
    );
  }

  /// Status checks matching web LectureAttendanceFlow.tsx L489-500
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get needsManualReview => status.toLowerCase() == 'manual_review';
  bool get isProcessing => !isCompleted && !isFailed && !needsManualReview;

  @override
  List<Object?> get props => [
        processingId, status, detectedFacesCount,
        matchedStudentsCount, unmatchedFacesCount,
        errorMessage, processingTimeMs,
      ];
}
```

### 1E. `lib/models/attendance/student_face_reference_model.dart`

```dart
import 'package:equatable/equatable.dart';

/// Maps GET /attendance/face-references/me response items.
/// MUST match web StudentFaceReference interface at attendanceService.ts L27-36.
class StudentFaceReferenceModel extends Equatable {
  final int id;
  final int userId;
  final String storagePath;
  final String? mimeType;
  final int? fileSize;
  final bool isPrimary;
  final String? createdAt;
  final String? signedUrl;       // Pre-signed S3/storage URL for thumbnail display

  const StudentFaceReferenceModel({
    required this.id,
    required this.userId,
    required this.storagePath,
    this.mimeType,
    this.fileSize,
    this.isPrimary = false,
    this.createdAt,
    this.signedUrl,
  });

  factory StudentFaceReferenceModel.fromJson(Map<String, dynamic> json) {
    return StudentFaceReferenceModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      storagePath: json['storagePath']?.toString() ?? '',
      mimeType: json['mimeType']?.toString(),
      fileSize: json['fileSize'] as int?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
      signedUrl: json['signedUrl']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id, userId, storagePath, mimeType, fileSize,
        isPrimary, createdAt, signedUrl,
      ];
}
```

---

## 2. Attendance Service — Complete Code

### `lib/services/api/attendance_service.dart`

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'core_api_client.dart';
import '../../common/retry_helper.dart';
import '../../common/service_error.dart';
import '../../models/attendance/attendance_session_model.dart';
import '../../models/attendance/attendance_record_model.dart';
import '../../models/attendance/student_attendance_summary_model.dart';
import '../../models/attendance/ai_processing_result_model.dart';
import '../../models/attendance/student_face_reference_model.dart';

/// Service for Attendance API endpoints.
///
/// Wraps all `/api/attendance` calls. Pattern matches enrollment_service.dart.
class AttendanceService {
  final CoreApiClient _client;

  AttendanceService({required CoreApiClient coreApiClient})
    : _client = coreApiClient;

  // ────────────────────────────────────────────────────────────────────
  // Student Endpoints
  // ────────────────────────────────────────────────────────────────────

  /// GET /api/attendance/my
  /// Web: AttendanceService.getMyAttendance() at attendanceService.ts L49
  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getMyAttendance() {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get('/attendance/my');
      final payload = response.data;
      // Web handles multiple shapes at attendanceService.ts L53-57:
      // Array directly, or {data: [...]}, or {summary: [...]}
      List<dynamic> list;
      if (payload is List) {
        list = payload;
      } else if (payload is Map<String, dynamic>) {
        if (payload['summary'] is List) {
          list = payload['summary'] as List;
        } else if (payload['data'] is List) {
          list = payload['data'] as List;
        } else {
          list = <dynamic>[];
        }
      } else {
        list = <dynamic>[];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(StudentAttendanceSummaryModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load your attendance');
  }

  /// GET /api/attendance/by-student/:userId
  /// Web: AttendanceService.getByStudent(id) at attendanceService.ts L60
  Future<ServiceResult<List<StudentAttendanceSummaryModel>>> getByStudent(
    int userId,
  ) {
    return RetryHelper.execute<List<StudentAttendanceSummaryModel>>(() async {
      final response = await _client.dio.get(
        '/attendance/by-student/$userId',
      );
      final payload = response.data;
      // Same normalization as getMyAttendance — web AttendanceOverview.tsx L221-222
      List<dynamic> list;
      if (payload is Map<String, dynamic> && payload['summary'] is List) {
        list = payload['summary'] as List;
      } else {
        list = _extractList(payload);
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map(StudentAttendanceSummaryModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load student attendance');
  }

  // ────────────────────────────────────────────────────────────────────
  // Session Endpoints
  // ────────────────────────────────────────────────────────────────────

  /// GET /api/attendance/sessions
  /// Web: AttendanceService.getSessions(params) at attendanceService.ts L64
  /// Web usage: LectureAttendanceFlow.tsx L298-308:
  ///   params: {sectionId, limit:30, sortBy:'sessionDate', sortOrder:'DESC'}
  Future<ServiceResult<List<AttendanceSessionModel>>> getSessions({
    int? sectionId,
    int? courseId,
    String? status,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) {
    return RetryHelper.execute<List<AttendanceSessionModel>>(() async {
      final params = <String, dynamic>{};
      if (sectionId != null) params['sectionId'] = sectionId;
      if (courseId != null) params['courseId'] = courseId;
      if (status != null) params['status'] = status;
      if (limit != null) params['limit'] = limit;
      if (sortBy != null) params['sortBy'] = sortBy;
      if (sortOrder != null) params['sortOrder'] = sortOrder;

      final response = await _client.dio.get(
        '/attendance/sessions',
        queryParameters: params.isEmpty ? null : params,
      );

      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(AttendanceSessionModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load attendance sessions');
  }

  /// POST /api/attendance/sessions
  /// Web: AttendanceService.createSession(data) at attendanceService.ts L72
  Future<ServiceResult<AttendanceSessionModel>> createSession({
    required int sectionId,
    required String sessionDate,
    required String sessionType,
    int? totalMinutes,
  }) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final body = <String, dynamic>{
        'sectionId': sectionId,
        'sessionDate': sessionDate,
        'sessionType': sessionType,
      };
      if (totalMinutes != null) body['totalMinutes'] = totalMinutes;

      final response = await _client.dio.post(
        '/attendance/sessions',
        data: body,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to create attendance session');
  }

  /// GET /api/attendance/sessions/:id
  /// Web: AttendanceService.getSessionDetails(id) at attendanceService.ts L89
  /// Returns session WITH nested records[] array
  Future<ServiceResult<AttendanceSessionModel>> getSessionDetails(int id) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.get('/attendance/sessions/$id');
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to load session details');
  }

  /// PUT /api/attendance/sessions/:id
  /// Web: AttendanceService.updateSession(id, data) at attendanceService.ts L81
  Future<ServiceResult<AttendanceSessionModel>> updateSession(
    int id,
    Map<String, dynamic> data,
  ) {
    return RetryHelper.execute<AttendanceSessionModel>(() async {
      final response = await _client.dio.put(
        '/attendance/sessions/$id',
        data: data,
      );
      return AttendanceSessionModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to update session');
  }

  /// DELETE /api/attendance/sessions/:id
  /// Web: AttendanceService.deleteSession(id) at attendanceService.ts L85
  Future<ServiceResult<void>> deleteSession(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/attendance/sessions/$id');
    }, fallbackMessage: 'Failed to delete session');
  }

  /// PATCH /api/attendance/sessions/:id/close
  /// Web: LectureAttendanceFlow.tsx L436: ApiClient.patch()
  /// NOTE: PATCH not PUT
  Future<ServiceResult<void>> closeSession(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.patch('/attendance/sessions/$id/close');
    }, fallbackMessage: 'Failed to close session');
  }

  // ────────────────────────────────────────────────────────────────────
  // Records Endpoints
  // ────────────────────────────────────────────────────────────────────

  /// POST /api/attendance/records/batch
  /// Web: AttendanceService.markBatchAttendance(data) at attendanceService.ts L93
  /// Web usage: LectureAttendanceFlow.tsx L414-431 (saveBatch):
  ///   body: {sessionId, records: [{userId, attendanceStatus}]}
  Future<ServiceResult<void>> markBatchAttendance({
    required int sessionId,
    required List<Map<String, dynamic>> records,
  }) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.post('/attendance/records/batch', data: {
        'sessionId': sessionId,
        'records': records,
      });
    }, fallbackMessage: 'Failed to save attendance');
  }

  /// GET /api/attendance/summary/:sectionId
  /// Web: AttendanceService.getSectionSummary(id) at attendanceService.ts L100
  Future<ServiceResult<Map<String, dynamic>>> getSectionSummary(
    int sectionId,
  ) {
    return RetryHelper.execute<Map<String, dynamic>>(() async {
      final response = await _client.dio.get(
        '/attendance/summary/$sectionId',
      );
      return _extractMap(response.data);
    }, fallbackMessage: 'Failed to load section summary');
  }

  // ────────────────────────────────────────────────────────────────────
  // Face Reference Endpoints (Student Only)
  // ────────────────────────────────────────────────────────────────────

  /// POST /api/attendance/face-references/me
  /// Web: attendanceService.ts L105 — multipart field: 'image'
  Future<ServiceResult<StudentFaceReferenceModel>> uploadMyFaceReference(
    File image,
  ) {
    return RetryHelper.execute<StudentFaceReferenceModel>(() async {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        ),
      });
      final response = await _client.dio.post(
        '/attendance/face-references/me',
        data: formData,
      );
      return StudentFaceReferenceModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload face reference');
  }

  /// GET /api/attendance/face-references/me
  /// Web: attendanceService.ts L111
  Future<ServiceResult<List<StudentFaceReferenceModel>>>
      listMyFaceReferences() {
    return RetryHelper.execute<List<StudentFaceReferenceModel>>(() async {
      final response = await _client.dio.get('/attendance/face-references/me');
      return _extractList(response.data)
          .whereType<Map<String, dynamic>>()
          .map(StudentFaceReferenceModel.fromJson)
          .toList();
    }, fallbackMessage: 'Failed to load face references');
  }

  /// DELETE /api/attendance/face-references/me/:id
  /// Web: attendanceService.ts L115
  Future<ServiceResult<void>> deleteMyFaceReference(int id) {
    return RetryHelper.executeVoid(() async {
      await _client.dio.delete('/attendance/face-references/me/$id');
    }, fallbackMessage: 'Failed to delete face reference');
  }

  // ────────────────────────────────────────────────────────────────────
  // AI Attendance Endpoints
  // ────────────────────────────────────────────────────────────────────

  /// POST /api/attendance/ai-photo
  /// Web: attendanceService.ts L120 — multipart: 'photo' + 'sessionId' (as string)
  Future<ServiceResult<AiProcessingResultModel>> uploadAiPhoto({
    required int sessionId,
    required File photo,
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split(Platform.pathSeparator).last,
        ),
        // Web sends sessionId as string: attendanceService.ts L123
        'sessionId': sessionId.toString(),
      });
      final response = await _client.dio.post(
        '/attendance/ai-photo',
        data: formData,
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to upload AI attendance photo');
  }

  /// GET /api/attendance/ai-photo/:processingId
  /// Web: attendanceService.ts L127
  Future<ServiceResult<AiProcessingResultModel>> getAiProcessingResult(
    int processingId,
  ) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final response = await _client.dio.get(
        '/attendance/ai-photo/$processingId',
      );
      return AiProcessingResultModel.fromJson(_extractMap(response.data));
    }, fallbackMessage: 'Failed to get AI processing result');
  }

  /// Polls getAiProcessingResult() until completed/failed/manual_review or timeout.
  /// Matches web's polling logic at LectureAttendanceFlow.tsx L486-500:
  ///   const deadline = Date.now() + 120_000;
  ///   while (Date.now() < deadline) { ... await sleep(2500); ... }
  Future<ServiceResult<AiProcessingResultModel>> pollAiResult(
    int processingId, {
    Duration timeout = const Duration(seconds: 120),
    Duration interval = const Duration(milliseconds: 2500),
  }) {
    return RetryHelper.execute<AiProcessingResultModel>(() async {
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        final result = await _client.dio.get(
          '/attendance/ai-photo/$processingId',
        );
        final model = AiProcessingResultModel.fromJson(
          _extractMap(result.data),
        );

        if (model.isCompleted || model.isFailed || model.needsManualReview) {
          return model;
        }

        await Future.delayed(interval);
      }

      throw Exception(
        'AI processing timed out after ${timeout.inSeconds}s. '
        'Try again or check backend logs.',
      );
    }, fallbackMessage: 'AI processing polling failed');
  }

  // ────────────────────────────────────────────────────────────────────
  // Helpers (same pattern as enrollment_service.dart L369-438)
  // ────────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
      for (final value in payload.values) {
        if (value is List) return value;
      }
    }
    return <dynamic>[];
  }
}
```

---

## 3. Student BLoC — Exact Changes

### 3A. `lib/bloc/attendance/attendance_state.dart` — Line-by-Line Changes

1. **Line 1**: Add import: `import '../../models/attendance/student_face_reference_model.dart';`
2. **Lines 49-60**: REMOVE the custom `TimeOfDay` class — use `import 'package:flutter/material.dart' show TimeOfDay;` instead
3. **Lines 62-101**: ADD `fromApi()` factory to `CourseAttendance`:
   ```dart
   factory CourseAttendance.fromApi(
     StudentAttendanceSummaryModel s,
     List<int> gradientColors,
   ) {
     return CourseAttendance(
       courseId: s.courseId.toString(),
       courseName: s.courseName,
       courseCode: s.courseCode,
       totalClasses: s.totalClasses,
       presentCount: s.attended,
       absentCount: s.absent,
       lateCount: s.lateCount,
       excusedCount: s.excused,
       gradientColors: gradientColors,
     );
   }
   ```
4. **Lines 145-222**: ADD new fields to `AttendanceState`:
   - `final List<StudentFaceReferenceModel> faceReferences;` (default `const []`)
   - `final bool isFaceUploading;` (default `false`)
   - `final String? faceUploadError;`
   - Update `copyWith()` and `props` accordingly
5. **Lines 225-281**: REMOVE `_DefaultDate` class. Replace with `DateTime.now()` default in `AttendanceState` constructor

### 3B. `lib/bloc/attendance/attendance_cubit.dart` — Line-by-Line Changes

1. **Line 1-3**: Add imports:
   ```dart
   import '../../services/api/attendance_service.dart';
   import '../../models/attendance/student_attendance_summary_model.dart';
   ```
2. **Line 5**: Change constructor to inject service:
   ```dart
   class AttendanceCubit extends Cubit<AttendanceState> {
     final AttendanceService _attendanceService;
     AttendanceCubit({required AttendanceService attendanceService})
       : _attendanceService = attendanceService,
         super(const AttendanceState());
   ```
3. **Lines 8-35**: REWRITE `loadAttendance()`:
   ```dart
   Future<void> loadAttendance() async {
     emit(state.copyWith(isLoading: true, clearError: true));
     try {
       final result = await _attendanceService.getMyAttendance();
       if (result.isSuccess && result.data != null) {
         final apiSummaries = result.data!;
         final courseAttendances = _mapApiToCourseAttendances(apiSummaries);
         final records = _mapApiToRecords(apiSummaries);
         final statistics = _calculateStatisticsFromApi(apiSummaries);
         emit(state.copyWith(
           isLoading: false,
           allRecords: records,
           filteredRecords: records,
           courseAttendances: courseAttendances,
           statistics: statistics,
         ));
       } else {
         emit(state.copyWith(
           isLoading: false,
           errorMessage: result.errorMessage ?? 'Failed to load attendance',
         ));
       }
     } catch (e) {
       emit(state.copyWith(
         isLoading: false,
         errorMessage: 'Failed to load attendance: $e',
       ));
     }
   }
   ```
4. **Lines 137-331**: REMOVE all mock generators:
   - Delete `_generateDemoRecords()` (L137-209)
   - Delete `_generateCourseAttendances()` (L212-265)
   - Delete `_calculateStatistics()` (L268-297)
   - Delete `_calculateWeeklyTrend()` (L300-331)
5. **ADD** new mapping methods (replacing deleted generators):
   ```dart
   List<CourseAttendance> _mapApiToCourseAttendances(
     List<StudentAttendanceSummaryModel> summaries,
   ) {
     final gradientColors = [
       [0xFF6366F1, 0xFF8B5CF6], [0xFF3B82F6, 0xFF06B6D4],
       [0xFF10B981, 0xFF059669], [0xFFF59E0B, 0xFFEF4444],
       [0xFFEC4899, 0xFF8B5CF6], [0xFF14B8A6, 0xFF22D3EE],
     ];
     return summaries.asMap().entries.map((entry) {
       return CourseAttendance.fromApi(
         entry.value,
         gradientColors[entry.key % gradientColors.length],
       );
     }).toList();
   }
   ```
6. **ADD** face reference methods:
   ```dart
   Future<void> loadFaceReferences() async { ... }
   Future<void> uploadFaceReference(File image) async { ... }
   Future<void> deleteFaceReference(int id) async { ... }
   ```
7. **KEEP UNCHANGED**: Lines 37-109 — all filter/search/tab methods (they filter in-memory)

---

## 4. Instructor Cubit — Structure

### `lib/bloc/attendance/instructor_attendance_state.dart`

See Phase 4 in implementation plan for full state definition with `InstructorAttendanceView` enum,
`RosterRow` class, and `InstructorAttendanceState` with all fields.

### `lib/bloc/attendance/instructor_attendance_cubit.dart`

Every method maps 1:1 to a `LectureAttendanceFlow.tsx` callback. See Phase 4 table in implementation plan. Key methods:

- `loadTeachingSections()` → `EnrollmentService.getTeachingCourses()` (already exists)
- `loadSessionsForSection(sectionId)` → `AttendanceService.getSessions(sectionId: ..., limit: 30, sortBy: 'sessionDate', sortOrder: 'DESC')`
- `createSession()` → `AttendanceService.createSession(...)`
- `loadRosterData(sessionId, readOnly)` → `AttendanceService.getSessionDetails(sessionId)` → map records to `RosterRow`
- `saveBatch()` → `AttendanceService.markBatchAttendance(sessionId: ..., records: rosterRows.map(...))`
- `closeSession()` → `AttendanceService.closeSession(activeSession.id)`
- `runAiAttendance(File photo)` → `AttendanceService.uploadAiPhoto(...)` → `pollAiResult(...)` → `loadRosterData(...)` → build AI review

---

## 5. TA Cubit — Structure

### `lib/bloc/attendance/ta_attendance_state.dart`

See Phase 5 in implementation plan for `TAAttendanceView` enum and `TAAttendanceState`.

### `lib/bloc/attendance/ta_attendance_cubit.dart`

Every method maps 1:1 to `AttendancePage.tsx` callbacks. Key methods:

- `loadAvailableLabs()` → `EnrollmentService.getTeachingCourses()` (filter for TA assignments)
- `processAttendance()` → `AttendanceService.createSession(...)` + `uploadAiPhoto(...)` + `pollAiResult(...)`
- `saveResults()` → `AttendanceService.markBatchAttendance(...)`
- `loadHistory()` → `AttendanceService.getSessions(status: 'completed')`

---

## 6. Admin Cubit — Structure

### `lib/bloc/attendance/admin_attendance_state.dart`

See Phase 6 in implementation plan for `AdminAttendanceTab` enum and `AdminAttendanceState`.

### `lib/bloc/attendance/admin_attendance_cubit.dart`

Methods:
- `loadOverviewStats()` → aggregate from `AttendanceService.getSessions()` + `getSectionSummary()`
- `loadCourses()` → `AttendanceService.getSessions()` grouped by course
- `loadStudents()` → `AttendanceService.getByStudent()` for flagged students
- `setCourseSearch(query)`, `setDepartmentFilter(dept)` → in-memory filtering
- `setStudentSearch(query)`, `setStatusFilter(status)` → in-memory filtering

---

## 7. Shared Widgets

### `lib/widgets/shared/attendance/status_toggle_widget.dart`

```dart
/// 4-way attendance status toggle matching web's StatusFourToggle
/// at LectureAttendanceFlow.tsx L108-204.
///
/// Layout: Row of 4 buttons in rounded container (grid-cols-4)
/// Each button: Icon + (label when selected)
/// Colors:
///   present → emerald (#10B981) — Icon: CheckCircle
///   absent  → red (#EF4444) — Icon: XCircle
///   late    → amber (#F59E0B) — Icon: Clock
///   excused → sky (#0EA5E9) — Icon: HelpCircle
/// Selected: filled bg with border ring + label appears
/// Unselected: transparent with hover tint
/// Animated: 200ms ease-out transitions
class StatusToggleWidget extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;
  final bool isDisabled;
  final bool isDark;

  const StatusToggleWidget({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.isDisabled = false,
    this.isDark = false,
  });
}
```

### `lib/widgets/shared/attendance/ai_attendance_panel.dart`

```dart
/// Reusable AI attendance panel for Instructor and TA screens.
/// Matches the AI section from LectureAttendanceFlow.tsx L244-517.
///
/// States:
///   idle: shows photo picker + "Run AI" button
///   loading: CircularProgressIndicator + "Processing..." text
///   error: red card with error message + retry button
///   completed: detected/matched/unmatched stats + "Apply" button
class AiAttendancePanel extends StatelessWidget {
  final int? sessionId;
  final bool isReadOnly;
  final bool isLoading;
  final String? error;
  final AiProcessingResultModel? result;
  final File? selectedPhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback onRunAi;
  final VoidCallback onApplyResults;

  const AiAttendancePanel({...});
}
```

---

## 8. Execution Order

```
1. Create all 5 model files (1A–1E)
2. Create AttendanceService (Section 2)
3. Register service in DI (wherever EnrollmentService is registered)
4. Update attendance_state.dart (Section 3A — add face fields, remove custom TimeOfDay)
5. Update attendance_cubit.dart (Section 3B — inject service, replace mocks)
6. Update attendance_screen.dart (inject service into cubit, add face setup section)
7. Create StatusToggleWidget (Section 7)
8. Create AiAttendancePanel (Section 7)
9. Create InstructorAttendanceState + InstructorAttendanceCubit (Section 4)
10. Rewrite attendance_manager_screen.dart (3-view flow)
11. Create TAAttendanceState + TAAttendanceCubit (Section 5)
12. Rewrite ta_attendance_screen.dart (AI-first flow)
13. Create AdminAttendanceState + AdminAttendanceCubit (Section 6)
14. Rewrite admin_attendance_screen.dart (3-tab overview)
15. flutter analyze — fix any issues
16. Manual smoke test per verification plan
```
