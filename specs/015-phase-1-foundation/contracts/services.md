# Service Contracts: Phase 1 — Foundation

**Feature**: 015-phase-1-foundation
**Date**: 2026-04-10

---

## ServiceResult<T> (Shared Return Type)

All services return `ServiceResult<T>` instead of throwing raw exceptions or using `Either`.

```dart
class ServiceResult<T> {
  final bool isSuccess;
  final T? data;
  final ServiceError? error;

  const ServiceResult._({required this.isSuccess, this.data, this.error});

  factory ServiceResult.success(T data) => ServiceResult<T>._(isSuccess: true, data: data);
  factory ServiceResult.failure(ServiceError error) => ServiceResult<T>._(isSuccess: false, error: error);
}

enum ServiceErrorType { network, auth, server, parsing }

class ServiceError {
  final ServiceErrorType type;
  final int? statusCode;
  final String message;
  final dynamic originalError;

  const ServiceError({
    required this.type,
    this.statusCode,
    required this.message,
    this.originalError,
  });
}
```

---

## 1. EnrollmentService

**File**: `lib/services/api/enrollment_service.dart` (UPDATE existing)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getMyCourses()` | GET | `/api/enrollments/my-courses` | — | `ServiceResult<List<CourseEnrollmentModel>>` |
| `getAvailableCourses()` | GET | `/api/enrollments/available` | — | `ServiceResult<List<CourseEnrollmentModel>>` |
| `register(sectionId, data)` | POST | `/api/enrollments/register` | Body JSON | `ServiceResult<CourseEnrollmentModel>` |
| `dropEnrollment(id)` | DELETE | `/api/enrollments/:id` | — | `ServiceResult<void>` |
| `getTeachingCourses()` | GET | `/api/enrollments/teaching` | — | `ServiceResult<List<TeachingCourseModel>>` |
| `getSectionStudents(sectionId)` | GET | `/api/enrollments/sections/:id/students` | — | `ServiceResult<List<CourseEnrollmentModel>>` |
| `getSectionInstructors(sectionId)` | GET | `/api/enrollments/sections/:id/instructors` | — | `ServiceResult<List<EnrollmentModel>>` |
| `getSectionTAs(sectionId)` | GET | `/api/enrollments/sections/:id/tas` | — | `ServiceResult<List<TAAssignmentModel>>` |
| `assignInstructor(sectionId, userId)` | POST | `/api/enrollments/sections/:id/instructors` | Body `{userId}` | `ServiceResult<void>` |
| `removeInstructor(sectionId, enrollmentId)` | DELETE | `/api/enrollments/sections/:id/instructors/:enrollmentId` | — | `ServiceResult<void>` |
| `assignTA(sectionId, userId)` | POST | `/api/enrollments/sections/:id/tas` | Body `{userId}` | `ServiceResult<void>` |
| `removeTA(sectionId, enrollmentId)` | DELETE | `/api/enrollments/sections/:id/tas/:enrollmentId` | — | `ServiceResult<void>` |

---

## 2. AssignmentService

**File**: `lib/services/api/assignment_service.dart` (NEW)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getAll({courseId, sectionId, status, ...})` | GET | `/api/assignments` | Query params | `ServiceResult<PaginatedResponse<AssignmentModel>>` |
| `getById(id)` | GET | `/api/assignments/:id` | — | `ServiceResult<AssignmentModel>` |
| `create(data)` | POST | `/api/assignments` | Body JSON | `ServiceResult<AssignmentModel>` |
| `update(id, data)` | PATCH | `/api/assignments/:id` | Body JSON | `ServiceResult<AssignmentModel>` |
| `delete(id)` | DELETE | `/api/assignments/:id` | — | `ServiceResult<void>` |
| `updateStatus(id, status)` | PATCH | `/api/assignments/:id/status` | Body `{status}` | `ServiceResult<AssignmentModel>` |
| `getSubmissions(assignmentId)` | GET | `/api/assignments/:id/submissions` | — | `ServiceResult<List<AssignmentSubmissionModel>>` |
| `submit(assignmentId, data)` | POST | `/api/assignments/:id/submit` | Body JSON | `ServiceResult<AssignmentSubmissionModel>` |
| `submitFile(assignmentId, file, {text, link})` | POST | `/api/assignments/:id/submissions/upload` | FormData | `ServiceResult<AssignmentSubmissionModel>` |
| `getMySubmission(assignmentId)` | GET | `/api/assignments/:id/submissions/my` | — | `ServiceResult<AssignmentSubmissionModel>` |
| `gradeSubmission(assignmentId, submissionId, score, feedback)` | PATCH | `/api/assignments/:id/submissions/:subId/grade` | Body `{score, feedback}` | `ServiceResult<Map>` |
| `uploadInstructionFile(assignmentId, file, {title, orderIndex})` | POST | `/api/assignments/:id/instructions/upload` | FormData | `ServiceResult<DriveFileModel>` |

---

## 3. LabService

**File**: `lib/services/api/lab_service.dart` (NEW)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getAll({courseId})` | GET | `/api/labs` | Query params | `ServiceResult<List<LabModel>>` |
| `getById(id)` | GET | `/api/labs/:id` | — | `ServiceResult<LabModel>` |
| `create(data)` | POST | `/api/labs` | Body JSON | `ServiceResult<LabModel>` |
| `update(id, data)` | PATCH | `/api/labs/:id` | Body JSON | `ServiceResult<LabModel>` |
| `delete(id)` | DELETE | `/api/labs/:id` | — | `ServiceResult<void>` |
| `getInstructions(labId)` | GET | `/api/labs/:id/instructions` | — | `ServiceResult<List<LabInstructionModel>>` |
| `addInstruction(labId, data)` | POST | `/api/labs/:id/instructions` | Body JSON | `ServiceResult<LabInstructionModel>` |
| `uploadInstructionFile(labId, file, {title, orderIndex})` | POST | `/api/labs/:id/instructions/upload` | FormData | `ServiceResult<DriveFileModel>` |
| `getSubmissions(labId)` | GET | `/api/labs/:id/submissions` | — | `ServiceResult<List<LabSubmissionModel>>` |
| `submit(labId, data)` | POST | `/api/labs/:id/submit` | Body JSON | `ServiceResult<LabSubmissionModel>` |
| `submitFile(labId, file, {text})` | POST | `/api/labs/:id/submissions/upload` | FormData | `ServiceResult<LabSubmissionModel>` |
| `getMySubmission(labId)` | GET | `/api/labs/:id/my-submission` | — | `ServiceResult<LabSubmissionModel>` |
| `gradeSubmission(labId, submissionId, score, feedback)` | PATCH | `/api/labs/:labId/submissions/:subId/grade` | Body `{score, feedback}` | `ServiceResult<Map>` |
| `getAttendance(labId)` | GET | `/api/labs/:id/attendance` | — | `ServiceResult<List<LabAttendanceModel>>` |
| `markAttendance(labId, data)` | POST | `/api/labs/:id/attendance` | Body JSON | `ServiceResult<LabAttendanceModel>` |
| `uploadTaMaterial(labId, file)` | POST | `/api/labs/:id/ta-materials/upload` | FormData | `ServiceResult<DriveFileModel>` |

---

## 4. SectionService

**File**: `lib/services/api/section_service.dart` (NEW)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getByCourse(courseId, {semesterId})` | GET | `/api/sections/course/:courseId` | Query | `ServiceResult<List<SectionModel>>` |
| `getById(id)` | GET | `/api/sections/:id` | — | `ServiceResult<SectionModel>` |
| `create(data)` | POST | `/api/sections` | Body JSON | `ServiceResult<SectionModel>` |
| `update(id, data)` | PATCH | `/api/sections/:id` | Body JSON | `ServiceResult<SectionModel>` |
| `updateEnrollment(id, count)` | PATCH | `/api/sections/:id/enrollment` | Body `{currentEnrollment}` | `ServiceResult<SectionModel>` |

---

## 5. ScheduleService

**File**: `lib/services/api/schedule_service.dart` (NEW)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getBySection(sectionId)` | GET | `/api/schedules/section/:sectionId` | — | `ServiceResult<List<ScheduleModel>>` |
| `getById(id)` | GET | `/api/schedules/:id` | — | `ServiceResult<ScheduleModel>` |
| `create(sectionId, data)` | POST | `/api/schedules/section/:sectionId` | Body JSON | `ServiceResult<ScheduleModel>` |
| `delete(id)` | DELETE | `/api/schedules/:id` | — | `ServiceResult<void>` |

---

## 6. SemesterService

**File**: `lib/services/api/semester_service.dart` (NEW)
**Dependency**: `CoreApiClient`

| Method | HTTP | Endpoint | Params | Returns |
|---|---|---|---|---|
| `getAll()` | GET | `/api/enrollments/periods` | — | `ServiceResult<List<SemesterModel>>` |

---

## Error Classification Rules

| HTTP Status | ServiceError Type | Retry? |
|---|---|---|
| 401 | `auth` | No (token refresh handled by CoreApiClient) |
| 403 | `auth` | No |
| 404 | `server` (client-side not-found) | No |
| 409 | `server` (conflict) | No |
| 500-599 | `server` | Yes (up to 3 retries) |
| Timeout | `network` | Yes (up to 3 retries) |
| No internet | `network` | No |
| JSON parse failure | `parsing` | No |

---

## Retry Policy

- **Max attempts**: 3
- **Backoff**: Exponential (1s → 2s → 4s)
- **Trigger**: HTTP 5xx responses, Dio `SocketException` (network), `DioExceptionType.connectionTimeout`, `DioExceptionType.receiveTimeout`
- **Excluded**: 401, 403, 404, 409, parsing errors
