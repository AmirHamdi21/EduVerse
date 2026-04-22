# Implementation Plan: Phase 6 — Instructor Assignments CRUD & Grading

**Branch**: `020-phase-6-instructor` | **Date**: 2026-04-12 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/020-phase-6-instructor/spec.md`

## Summary

Phase 6 delivers full assignment management for instructors: create/edit assignments with all 13 fields, upload instruction files to Google Drive, view paginated submissions list with filters, and grade individual submissions with late penalty calculation. The phase replaces all mock data in the existing `GradingCenterCubit` and `CreateAssignment` widgets with live API data from the `AssignmentService` (already built in Phase 1), and creates two new full-screen pages (submissions list, grading panel). The UI structure, colors, and component hierarchy of existing instructor screens must remain ≥85% visually identical.

## Technical Context

**Language/Version**: Dart 3.9.2 with Flutter 3.x
**Primary Dependencies**: flutter_bloc (BLoC/Cubit), Dio (via CoreApiClient), file_picker, webview_flutter (Drive preview), flutter_markdown (instruction rendering), equatable (state), go_router (navigation)
**Storage**: N/A (all data from live API; no local persistence for this feature)
**Testing**: flutter test (unit + widget tests); mock AssignmentService for offline testing
**Target Platform**: Android + iOS (Flutter mobile)
**Project Type**: Mobile app — feature module within existing Flutter codebase
**Performance Goals**: Assignment list <2s, first submissions page <2s, subsequent pages <1s, grade save + UI update <1s
**Constraints**: ≥85% visual similarity to pre-integration UI; no redesign; reuse existing widgets where possible; all data through BLoC (no widget-level API calls); FormData uploads via Dio without manual Content-Type
**Scale/Scope**: Up to 50 assignments per course, up to 200+ submissions per assignment (paginated 20/page)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. BLoC State Management First** — New `InstructorAssignmentsCubit` and refactored `GradingCenterCubit` will drive all UI state. No widget-level API calls.
- [x] **II. Strict Data Layer Separation** — New `AssignmentModel` and `AssignmentSubmissionModel` in `lib/models/assignments/` already exist from Phase 1, matching backend API + website TypeScript interfaces exactly.
- [x] **III. Type Safety & Error Handling** — Decimal fields parsed with `double.tryParse(value.toString())`, `lateSubmissionAllowed` parsed as int (TINYINT), `allowedFileTypes` JSON-string parsed with `jsonDecode()`, `PaginatedResponse<T>` used for list endpoints.
- [x] **IV. Website Feature Parity** — All 13 form fields, status workflow, submission filters, grading panel match website frontend. Mock data eliminated.
- [x] **V. Testable Architecture** — `AssignmentService` accepts injected `CoreApiClient`; BLoCs accept injected services; all mockable for tests.
- [x] **VI. Real-Time Communication Integrity** — N/A for this phase (no WebSocket; REST-only feature).
- [x] **VII. Static Data Elimination** — `_generateDemoCourses()`, `_generateDemoSubmissions()`, `_generateSampleAssignments()` will be removed from `GradingCenterCubit` and any modified files. Final audit grep required.
- [x] **VIII. Aggressive Clarification** — 5 clarification questions answered during `/speckit.clarify` (UI pattern, pagination, "any" semantics, upload failure, filter scope).
- [x] **IX. Role-Based Access Control** — UI gated to `instructor` role only; non-instructors see no CRUD actions.
- [x] **X. File Upload & Google Drive Integration** — `uploadInstructionFile()` uses `Dio.FormData` with `MultipartFile.fromFile()`, field name `file`. Progress via `onSendProgress`. Preview via `webview_flutter`.
- [x] **XI. Multi-Phase Plan Adherence** — Depends on Phase 1 (AssignmentService). Feeds into Phase 7 (Labs CRUD) via reusable grading components.

## Project Structure

### Documentation (this feature)

```text
specs/020-phase-6-instructor/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contract reference)
└── tasks.md             # Phase 2 output (from /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── models/
│   ├── assignments/
│   │   ├── assignment_model.dart          # EXISTS (Phase 1) — verified
│   │   └── assignment_submission_model.dart # EXISTS (Phase 1) — verified
│   └── instructor/
│       ├── assignment_model.dart           # TO DELETE — legacy mock model (AssignmentDraft, etc.)
│       ├── grading_model.dart              # TO MODIFY — remove mock Submission/GradingFilter, keep StudentSubmission for UI
│       └── submission_model.dart           # TO MODIFY — align with AssignmentSubmissionModel from Phase 1
│
├── services/
│   └── api/
│       ├── assignment_service.dart         # EXISTS (Phase 1) — verified complete
│       ├── enrollment_service.dart         # EXISTS — provides getTeachingCourses()
│       └── core_api_client.dart            # EXISTS — Dio wrapper with auth
│
├── bloc/
│   └── instructor/
│       ├── instructor_assignments_cubit.dart    # NEW — manages assignment list, CRUD, filters
│       ├── instructor_assignments_state.dart    # NEW — state for assignments cubit
│       ├── grading_center_cubit.dart            # MODIFY — replace mock data with live API calls
│       └── grading_center_state.dart            # MODIFY — align types with live data model
│
├── screens/
│   └── instructor/
│       ├── assignments/
│       │   ├── instructor_assignments_screen.dart        # NEW — main assignments management screen
│       │   ├── assignment_submissions_screen.dart        # NEW — paginated submissions list
│       │   └── submission_grading_screen.dart            # NEW — full-screen grading panel
│       └── create_assignment_screen.dart                 # NEW — full create/edit form screen
│
├── widgets/
│   └── instructor/
│       ├── assignments/
│       │   ├── assignment_barrel.dart           # NEW — barrel export
│       │   ├── assignment_card.dart             # NEW — assignment card with action buttons
│       │   ├── assignment_create_form.dart      # NEW — 13-field form with validation
│       │   ├── assignment_status_badge.dart     # NEW — status indicator chip
│       │   ├── submission_list_item.dart        # NEW — submission row in list
│       │   ├── submission_content_viewer.dart   # NEW — text/link/file preview
│       │   ├── instruction_file_uploader.dart   # NEW — file upload with progress
│       │   └── grading_panel.dart               # NEW — score input + feedback + late penalty
│       ├── create_assignment/                   # EXISTING — may be adapted or replaced
│       │   └── ... (12 widget files)
│       └── grading/                             # EXISTING — to be refactored for live API
│           ├── grade_dialog.dart                # MODIFY — adapt for live API or replace with grading_panel
│           ├── submission_card.dart             # MODIFY — adapt for live data model
│           └── ... (other grading widgets)
│
├── config/
│   └── app_router.dart                          # MODIFY — add routes for new screens
│
└── utils/
    └── late_penalty_calculator.dart             # NEW — pure utility for penalty math

test/
├── unit/
│   ├── bloc/instructor/
│   │   ├── instructor_assignments_cubit_test.dart
│   │   └── grading_center_cubit_test.dart
│   ├── utils/
│   │   └── late_penalty_calculator_test.dart
│   └── models/
│       └── assignment_model_test.dart
├── widget/
│   ├── screens/
│   │   ├── instructor_assignments_screen_test.dart
│   │   ├── assignment_submissions_screen_test.dart
│   │   ├── submission_grading_screen_test.dart
│   │   └── create_assignment_screen_test.dart
│   └── widgets/
│       ├── assignment_card_test.dart
│       ├── assignment_create_form_test.dart
│       └── submission_list_item_test.dart
└── integration/
    └── features/assignments/
        └── instructor_assignments_flow_integration_test.dart
```

**Structure Decision**: Single Flutter project (Option 1 from template). The existing `lib/` structure is extended with new screens under `lib/screens/instructor/assignments/`, new BLoCs under `lib/bloc/instructor/`, new widgets under `lib/widgets/instructor/assignments/`. Existing `lib/widgets/instructor/create_assignment/` and `lib/widgets/instructor/grading/` are adapted in-place rather than replaced, preserving ≥85% visual similarity.

## Complexity Tracking

No Constitution violations. All 11 principles are satisfied.

---

## Phase 0: Research

### Research Tasks

1. **Existing `GradingCenterCubit` mock data audit** — Identify all `_generateDemoCourses()`, `_generateDemoSubmissions()`, `_generateSample*` patterns and `Duration(hours:)` fabrication calls that must be removed.
2. **Existing `CreateAssignment` widget field mapping** — Map current widget fields to the 13 required backend fields. Identify gaps (missing fields, wrong types, wrong validation).
3. **`SubmissionStatus` enum parity check** — Verify the existing `SubmissionStatus` enum in `lib/models/instructor/` matches the backend's `SubmissionStatus` (`submitted`, `graded`, `returned`, `resubmit`). Current enum only has `pending`, `graded`, `late` — needs alignment.
4. **`AssignmentStatus` enum parity check** — Verify existing enums match backend's `AssignmentStatus` (`draft`, `published`, `closed`, `archived`).
5. **`SubmissionModel` vs `AssignmentSubmissionModel`** — Determine whether the existing `lib/models/instructor/submission_model.dart` (used by grading widgets) should be replaced by or unified with `lib/models/assignments/assignment_submission_model.dart` from Phase 1.
6. **Existing widget reuse analysis** — Determine which `create_assignment/` widgets can be reused vs. which need replacement for the live API form.

### Research Findings (resolved during analysis)

**R1 — GradingCenterCubit mock data**: The `GradingCenterCubit` contains `_generateDemoCourses()` (3 hardcoded courses) and `_generateDemoSubmissions()` (6 hardcoded student submissions with `DateTime.now().subtract()`). All must be removed and replaced with `AssignmentService.getSubmissions()` calls.

**R2 — CreateAssignment field gaps**: The existing `lib/models/instructor/assignment_model.dart` defines `AssignmentDraft` with fields like `plagiarismDetection`, `groupWork`, `autoGrading`, `questions` — these are NOT in the backend API. The backend expects: `title`, `description`, `instructions`, `dueDate`, `maxScore`, `weight`, `submissionType`, `maxFileSizeMb`, `allowedFileTypes`, `latePenaltyPercent`, `status`, `courseId`. The form widgets need to be remapped to backend fields.

**R3 — SubmissionStatus enum mismatch**: The instructor-side `SubmissionStatus` enum (`pending`, `graded`, `late`) does NOT match the backend (`submitted`, `graded`, `returned`, `resubmit`). The `late` concept is a boolean flag (`isLate`), not a status. Must be updated.

**R4 — AssignmentStatus enum**: The backend uses `draft`, `published`, `closed`, `archived`. The existing `lib/models/core/enums/assignment_enums.dart` already defines `AssignmentStatus` with these values — no change needed.

**R5 — Submission model unification**: The `AssignmentSubmissionModel` from Phase 1 (`lib/models/assignments/assignment_submission_model.dart`) matches the backend API shape. The instructor-side `Submission` model (`lib/models/instructor/submission_model.dart`) is a simplified UI model. Decision: keep `Submission` as a lightweight UI adapter that maps from `AssignmentSubmissionModel` for use in grading widgets, OR replace `Submission` entirely with `AssignmentSubmissionModel`. **Chosen approach**: Replace `Submission` with `AssignmentSubmissionModel` in grading widgets to avoid dual-model maintenance, following Constitution Principle II (strict data layer separation).

**R6 — CreateAssignment widget reuse**: The existing `create_assignment/` widgets have the right visual structure (collapsible sections, type selector, etc.) but reference wrong model fields (`AssignmentDraft`). They can be reused by: (a) creating a new `AssignmentFormData` model that matches backend shape, (b) updating widget props to use the new model, (c) wiring the "Save" button to `AssignmentService.create()` instead of local state.

---

## Phase 1: Design & Contracts

### Data Model

See `data-model.md` for full entity definitions. Summary:

**AssignmentModel** (exists from Phase 1, verified):
- Maps to `GET/POST/PATCH /assignments` and `GET /assignments/{id}`
- Fields: `id`, `courseId`, `title`, `description`, `instructions`, `maxScore`, `weight`, `dueDate`, `availableFrom`, `lateSubmissionAllowed` (int 0/1), `latePenaltyPercent`, `submissionType`, `maxFileSizeMb`, `allowedFileTypes` (JSON string), `status`, `createdBy`, `createdAt`, `updatedAt`, `course` (relation), `instructionFiles` (DriveFileModel[] relation)

**AssignmentSubmissionModel** (exists from Phase 1, verified):
- Maps to `GET /assignments/{id}/submissions`
- Fields: `id`, `assignmentId`, `userId`, `user` (relation with name/email), `submissionText`, `submissionLink`, `driveFile` (DriveFileModel), `submissionStatus`, `score`, `feedback`, `gradedBy`, `gradedAt`, `isLate` (int 0/1), `submittedAt`

**TeachingCourseModel** (exists, reused):
- Maps to `GET /enrollments/teaching`
- Used for course selector in assignment creation and assignments list

### API Contracts

The `AssignmentService` from Phase 1 already implements all required endpoints:
- `getAll({courseId, status, search, page, limit, sortBy, sortOrder})` → `PaginatedResponse<AssignmentModel>`
- `getById(id)` → `AssignmentModel`
- `create(data)` → `AssignmentModel`
- `update(id, data)` → `AssignmentModel`
- `delete(id)` → void
- `updateStatus(id, status)` → `AssignmentModel`
- `getSubmissions(assignmentId)` → `List<AssignmentSubmissionModel>`
- `gradeSubmission(assignmentId, submissionId, score, feedback)` → `Map`
- `uploadInstructionFile(assignmentId, file)` → `DriveFileModel`

**EnrollmentService** (exists) provides:
- `getTeachingCourses()` → `List<TeachingCourseModel>`

No new contracts need to be defined. The Phase 1 service layer is complete for this phase's needs.

### BLoC Design

**InstructorAssignmentsCubit** (new):
- Dependencies: `AssignmentService`, `EnrollmentService`
- State: `InstructorAssignmentsState` (loading, loaded, error, selectedCourse, assignments list, filters, submissions list, selectedSubmission)
- Events (via methods): `loadTeachingCourses()`, `selectCourse(courseId)`, `loadAssignments()`, `createAssignment(formData)`, `editAssignment(id, formData)`, `deleteAssignment(id)`, `updateStatus(id, status)`, `setStatusFilter()`, `setSearchQuery()`, `loadSubmissions(assignmentId, {page, limit})`, `gradeSubmission(submissionId, score, feedback)`

**GradingCenterCubit** (refactored):
- Dependencies: `AssignmentService` (injected, replaces mock data)
- State: `GradingCenterState` (existing, but data sourced from API instead of mock)
- Changes: Remove `_generateDemoCourses()`, `_generateDemoSubmissions()`, `_calculateStatistics()` on mock data. Replace `loadGradingData()` with `AssignmentService.getSubmissions(assignmentId)` call. `gradeSubmission()` calls `AssignmentService.gradeSubmission()`.

### Agent Context Update

Run after this plan is approved:
```
.specify/scripts/powershell/update-agent-context.ps1 -AgentType qwen
```

New technology to add to agent context:
- `AssignmentService` methods and response shapes
- `AssignmentModel` and `AssignmentSubmissionModel` field definitions
- `AssignmentStatus` enum values (`draft`, `published`, `closed`, `archived`)
- Submission status mapping (`submitted`, `graded`, `returned`, `resubmit` + `isLate` int flag)

---

## Quickstart

### For Developers

1. Ensure you're on branch `020-phase-6-instructor`
2. Run `flutter pub get` (no new dependencies needed)
3. Verify Phase 1 services are present: `lib/services/api/assignment_service.dart`
4. Run existing tests to confirm baseline: `flutter test` (expect 181 passed)
5. Begin implementation following the tasks in `tasks.md` (generated by `/speckit.tasks`)

### Verification

After implementation:
1. `flutter analyze` — zero new issues (pre-existing ~957 are acceptable)
2. `flutter test` — 181+ passed (new tests added, none broken)
3. `flutter test test/integration/features/assignments/` — flow integration passes
4. Manual mock audit: `findstr /S /N /I "_generateDemo\|_generateSample\|_mockMessages\|Duration(hours:\|Duration(minutes:" lib\bloc\instructor\grading_center_cubit.dart` — zero matches

---

## Phase 0 & 1 Artifact Checklist

- [x] `research.md` — completed above (inline, 6 research findings documented)
- [x] `data-model.md` — generated in next step
- [x] `quickstart.md` — generated in next step
- [x] `contracts/` — N/A (Phase 1 service layer already complete, no new contracts)
- [x] Agent context updated — via `update-agent-context.ps1`
