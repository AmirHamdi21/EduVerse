# Implementation Plan: Phase 1 — Foundation (API Services & Domain Models)

**Branch**: `015-phase-1-foundation` | **Date**: 2026-04-10 | **Spec**: [spec.md](../015-phase-1-foundation/spec.md)
**Input**: Feature specification from `specs/015-phase-1-foundation/spec.md`

## Summary

Create 6 API services + 14 domain models + 13 enums to replace all mock/static data for Courses, Assignments, and Labs in the EduVerse Flutter app. All services use the existing `CoreApiClient` with Dio, implement retry with exponential backoff (3 attempts for 5xx/timeouts), and return typed `ServiceResult<T>` wrappers. No UI changes — purely service/model layer work.

## Technical Context

**Language/Version**: Dart 3.x (Flutter)
**Primary Dependencies**: Dio (HTTP), existing `CoreApiClient`, `StorageService`, `equatable` package
**Storage**: N/A (service layer only — no local storage changes)
**Testing**: `flutter test` with mocked Dio via `DioAdapter`
**Target Platform**: Flutter mobile app (Android/iOS)
**Project Type**: Mobile app — service/repository layer
**Performance Goals**: Retry up to 3 attempts with exponential backoff (1s→2s→4s) for 5xx/timeouts; all service calls complete within 30s including retries
**Constraints**: No UI changes; all services injectable for testing; models match backend API docs exactly; `isLate` diverges between assignments (int 0/1) and labs (bool)
**Scale**: 6 services, ~60 service methods, 14 models, 13 enums

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

- [x] **I. BLoC State Management First** — Services feed BLoCs; no widget-level API calls. BLoCs will be built in later phases.
- [x] **II. Strict Data Layer Separation** — All 14 models match backend API response shapes + website TypeScript interfaces. File uploads use `Dio.FormData` with `MultipartFile.fromFile()`, no manual `Content-Type`.
- [x] **III. Type Safety & Error Handling** — `isLate` int/bool divergence handled, `allowedFileTypes` JSON-string parsing, decimal field parsing via `double.tryParse()`, `PaginatedResponse<T>` generic.
- [x] **IV. Website Feature Parity** — All models, field names, enum values match website TypeScript interfaces from `Courses_Assignments_Labs_Frontend_Documentation.md`.
- [x] **V. Testable Architecture** — All services accept injected `CoreApiClient`; `CoreApiClient.test` constructor available for mocked Dio.
- [x] **VI. Real-Time Communication Integrity** — N/A for this phase (no WebSocket endpoints).
- [x] **VII. Static Data Elimination** — All mock data in modified model files will be replaced with live API parsing. Final audit grep for residual patterns.
- [x] **VIII. Aggressive Clarification** — 6 clarification questions answered in spec's Clarifications section.
- [x] **IX. Role-Based Access Control Enforcement** — Services return typed errors; 403 surfaces as `auth` error type. UI gating in later phases.
- [x] **X. File Upload & Google Drive/YouTube Integration** — Upload methods use `Dio.FormData`; `DriveFileModel` maps `webContentLink`→`downloadUrl`, computes `iframeUrl`.
- [x] **XI. Multi-Phase Plan Adherence** — This is Phase 1 per `courses_assignments_labs_integration_plan.md`. Phase 1 must complete before Phases 2-9.

## Project Structure

### Documentation (this feature)

```text
specs/015-phase-1-foundation/
├── spec.md              # Feature specification (completed)
├── plan.md              # This file
├── research.md          # Phase 0 output (completed)
├── data-model.md        # Phase 1 output (completed)
├── quickstart.md        # Phase 1 output (completed)
├── contracts/
│   └── services.md      # Phase 1 output (completed)
└── tasks.md             # Phase 2 output (/speckit.tasks - completed)
```

### Source Code (repository root)

```text
lib/
├── models/
│   ├── core/
│   │   ├── course_model.dart              # UPDATE — Align with backend
│   │   ├── enrollment_model.dart          # UPDATE — Add missing fields
│   │   ├── section_model.dart             # UPDATE — Add relations
│   │   ├── semester_model.dart            # UPDATE — Add fields (registrationStart/End, status; map semesterName→name, semesterStart→startDate, semesterEnd→endDate)
│   │   ├── drive_file_model.dart          # NEW
│   │   ├── lab_instruction_model.dart     # NEW
│   │   ├── lab_attendance_model.dart      # NEW
│   │   ├── paginated_response.dart        # NEW
│   │   ├── shared_models.dart             # NEW — CourseInfo, UserInfo helpers
│   │   └── enums/
│   │       ├── course_enums.dart          # NEW — CourseLevel, CourseStatus, SectionStatus
│   │       ├── schedule_enums.dart        # NEW — ScheduleType, DayOfWeek
│   │       ├── assignment_enums.dart      # NEW — AssignmentStatus, SubmissionType, SubmissionStatus
│   │       ├── lab_enums.dart             # NEW — LabStatus, LabAttendanceStatus
│   │       └── enrollment_enums.dart      # NEW — EnrollmentStatus, DropReason
│   ├── assignments/
│   │   ├── assignment_model.dart          # FULL REWRITE — replace with backend shape
│   │   └── assignment_submission_model.dart  # NEW (separate from existing SubmissionModel)
│   └── labs/
│       ├── lab_model.dart                 # FULL REWRITE — replace with backend shape
│       └── lab_submission_model.dart      # NEW
├── services/
│   └── api/
│       ├── core_api_client.dart           # UPDATE — Add retry config (test constructor already exists)
│       ├── enrollment_service.dart        # UPDATE — Add section management methods
│       ├── assignment_service.dart        # NEW
│       ├── lab_service.dart              # NEW
│       ├── section_service.dart           # NEW
│       ├── schedule_service.dart          # NEW
│       └── semester_service.dart          # NEW — calls GET /api/enrollments/periods
└── common/
    ├── service_error.dart                 # NEW — ServiceResult<T> + ServiceError + ServiceErrorType
    └── retry_helper.dart                  # NEW — exponential backoff + error classification mapper
```

**Structure Decision**: Single project (Flutter app). All new code lives under `lib/models/`, `lib/services/`, and `lib/common/`. No UI files (`lib/screens/`, `lib/widgets/`, `lib/bloc/`) are modified in this phase.

## Complexity Tracking

> No Constitution violations requiring justification. All work follows established patterns.
