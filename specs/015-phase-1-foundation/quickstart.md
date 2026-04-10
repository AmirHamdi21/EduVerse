# Quickstart: Phase 1 — Foundation (API Services & Domain Models)

**Feature**: 015-phase-1-foundation
**Date**: 2026-04-10

---

## Overview

This phase creates the service layer and domain models that replace all mock/static data for Courses, Assignments, and Labs. No UI changes — purely service/model layer work.

## What Gets Built

- **6 API Services**: `EnrollmentService` (updated), `AssignmentService` (new), `LabService` (new), `SectionService` (new), `ScheduleService` (new), `SemesterService` (new)
- **14 Domain Models**: Course, Enrollment, Section, Schedule, Semester, Assignment, AssignmentSubmission, Lab, LabSubmission, LabInstruction, LabAttendance, DriveFile, PaginatedResponse<T), UserInfo
- **13 Enums**: CourseLevel, CourseStatus, SectionStatus, ScheduleType, DayOfWeek, AssignmentStatus, SubmissionType, SubmissionStatus, LabStatus, LabAttendanceStatus, EnrollmentStatus, DropReason
- **Error handling**: `ServiceError` class with type classification (network, auth, server, parsing)
- **Retry logic**: Exponential backoff (3 attempts) for 5xx/network timeouts

## How to Use the Services

### 1. Instantiate a Service

All services accept a `CoreApiClient` for HTTP communication:

```dart
final coreClient = CoreApiClient(storageService: StorageService());
final assignmentService = AssignmentService(coreApiClient: coreClient);
final labService = LabService(coreApiClient: coreClient);
final enrollmentService = EnrollmentService(coreApiClient: coreClient);
final sectionService = SectionService(coreApiClient: coreClient);
final scheduleService = ScheduleService(coreApiClient: coreClient);
final semesterService = SemesterService(coreApiClient: coreClient);
```

### 2. Call a Service Method

All methods return `Either<ServiceError, T>` — check `isLeft()` for errors:

```dart
final result = await assignmentService.getAll(courseId: 1);

if (result.isLeft()) {
  final error = result.left;
  switch (error.type) {
    case ServiceErrorType.network:
      // Show "No internet" message
      break;
    case ServiceErrorType.auth:
      // Show "Session expired" message
      break;
    case ServiceErrorType.server:
      // Show "Server error" message
      break;
    case ServiceErrorType.parsing:
      // Log parsing failure
      break;
  }
  return;
}

final paginated = result.right;
final assignments = paginated.data; // List<AssignmentModel>
final hasNext = paginated.hasNextPage;
```

### 3. Get a Single Item

```dart
final result = await assignmentService.getById(42);
if (result.isRight()) {
  final assignment = result.right;
  print(assignment.title);
  print(assignment.instructionFiles.length);
}
```

### 4. Create/Update

```dart
final result = await assignmentService.create(CreateAssignmentDto(
  courseId: 1,
  title: 'Homework 1',
  dueDate: DateTime.now().add(Duration(days: 7)),
  maxScore: 100,
  submissionType: SubmissionType.file,
));
```

### 5. File Upload

```dart
final result = await assignmentService.uploadInstructionFile(
  assignmentId,
  File('/path/to/file.pdf'),
  title: 'Instructions',
  orderIndex: 0,
);
```

### 6. Use in BLoC

```dart
class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentService _service;

  AssignmentBloc(this._service) : super(AssignmentInitial()) {
    on<LoadAssignments>((event, emit) async {
      emit(LoadingAssignments());
      final result = await _service.getAll(courseId: event.courseId);
      if (result.isLeft()) {
        emit(ErrorAssignments(result.left));
      } else {
        emit(LoadedAssignments(result.right.data));
      }
    });
  }
}
```

## Testing

### Unit Test a Service with Mocked Dio

```dart
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test('AssignmentService.getAll parses paginated response', () async {
    final mockDio = Dio();
    // Configure mock adapter to return test response
    final client = CoreApiClient.test(dioOverride: mockDio);
    final service = AssignmentService(coreApiClient: client);

    final result = await service.getAll();
    expect(result.isRight(), isTrue);
    expect(result.right.data, isA<List<AssignmentModel>>());
    expect(result.right.hasNextPage, isA<bool>());
  });
}
```

## Files Modified Summary

| Category | Files | Action |
|---|---|---|
| **New services** | `assignment_service.dart`, `lab_service.dart`, `section_service.dart`, `schedule_service.dart`, `semester_service.dart` | CREATE |
| **Updated service** | `enrollment_service.dart`, `core_api_client.dart` | UPDATE |
| **New models** | `drive_file_model.dart`, `lab_instruction_model.dart`, `lab_attendance_model.dart`, `paginated_response.dart`, `assignment_submission_model.dart`, `lab_submission_model.dart` | CREATE |
| **Updated models** | `course_model.dart`, `enrollment_model.dart`, `section_model.dart`, `semester_model.dart`, `assignment_model.dart`, `lab_model.dart` | UPDATE |
| **New enums** | `course_enums.dart`, `schedule_enums.dart`, `assignment_enums.dart`, `lab_enums.dart`, `enrollment_enums.dart` | CREATE |
