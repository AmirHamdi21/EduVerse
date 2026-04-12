# Research: Phase 6 — Instructor Assignments CRUD & Grading

**Date**: 2026-04-12
**Branch**: `020-phase-6-instructor`

---

## Research Findings

### R1 — GradingCenterCubit Mock Data Audit

**File**: `lib/bloc/instructor/grading_center_cubit.dart`

**Mock patterns found**:
- `_generateDemoCourses()` — returns 3 hardcoded `InstructorCourseModel` objects with IDs '1', '2', '3' and fake course names (Operating Systems, Data Structures, Database Systems)
- `_generateDemoSubmissions()` — returns 6 hardcoded `StudentSubmission` objects with fake student names (Ahmed Mohamed, Sara Ahmed, etc.) and `DateTime.now().subtract(Duration(hours: ...))` timestamps
- `_calculateStatistics()` — calculates stats from the mock submissions list

**Action required**: Remove all three methods. Replace `loadGradingData()` with a call to `AssignmentService.getSubmissions(assignmentId)`. Inject `AssignmentService` into the cubit constructor.

---

### R2 — CreateAssignment Widget Field Mapping

**Existing model**: `lib/models/instructor/assignment_model.dart`

The `AssignmentDraft` class has fields that do NOT exist in the backend API:
- `plagiarismDetection` — NOT in backend
- `groupWork` — NOT in backend
- `autoGrading` — NOT in backend
- `questions` (List<AssignmentQuestion>) — NOT in backend (this is a quiz feature, not assignment)
- `difficulty` (DifficultyLevel) — NOT in backend
- `type` (AssignmentType: assignment/lab/project) — NOT in backend (backend uses a single Assignment entity)
- `moduleId`, `moduleName` — NOT in backend
- `shortDescription` — NOT in backend (backend has `description`)

**Backend expects** (from `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`):
- `title` (string, required)
- `description` (string, optional)
- `instructions` (string, optional, Markdown)
- `dueDate` (string, ISO 8601, required)
- `maxScore` (decimal, required)
- `weight` (decimal, optional, default 10)
- `submissionType` (enum: file/text/link/multiple, required)
- `maxFileSizeMb` (integer, optional)
- `allowedFileTypes` (JSON string, optional)
- `latePenaltyPercent` (decimal, optional, 0-100)
- `status` (enum: draft/published/closed/archived, required)
- `courseId` (integer, required — set via route context, not form)

**Action required**: Create a new `AssignmentFormData` class matching the backend shape. Update `create_assignment/` widgets to use the new model. Remove non-backend fields.

---

### R3 — SubmissionStatus Enum Mismatch

**Current instructor-side enum** (`lib/models/instructor/grading_model.dart`):
```dart
enum SubmissionStatus { pending, graded, late }
```

**Backend enum** (`COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`):
```dart
enum SubmissionStatus { submitted, graded, returned, resubmit }
```

**Key difference**: `late` is NOT a status in the backend — it's a boolean flag (`isLate: 0/1`). `pending` maps to `submitted`. `returned` and `resubmit` are missing from the current enum.

**Action required**: Update the enum to match the backend. Add `submitted`, `returned`, `resubmit`. Remove `pending` and `late` as status values (late becomes a separate `isLate` bool field on the submission model). The existing `SubmissionStatus` in `lib/models/instructor/submission_model.dart` also needs updating.

**Clarification from spec**: The "ungraded" filter includes `submitted` + `resubmit` only — `returned` is excluded because those submissions are already graded.

---

### R4 — AssignmentStatus Enum Parity

**Backend enum**: `draft`, `published`, `closed`, `archived`
**Existing enum**: `lib/models/core/enums/assignment_enums.dart` already defines `AssignmentStatus` with these exact values.

**Action required**: No change needed. The Phase 1 enum is correct.

---

### R5 — Submission Model Unification

**Two models exist**:
1. `lib/models/assignments/assignment_submission_model.dart` (Phase 1) — matches backend API shape exactly, has `AssignmentSubmissionModel` with all backend fields
2. `lib/models/instructor/submission_model.dart` — simplified UI model with `Submission` class, has wrong enum (`SubmissionStatus.pending/graded/late`), missing backend fields (`driveFile`, `submissionText`, `submissionLink`)

**Decision**: Replace `Submission` with `AssignmentSubmissionModel` in grading widgets. This eliminates dual-model maintenance and follows Constitution Principle II (strict data layer separation — models match backend exactly).

**Migration path**:
- Update `grading_model.dart` to remove the `Submission` class
- Update `grading_center_cubit.dart` to use `AssignmentSubmissionModel`
- Update `submission_card.dart`, `grade_dialog.dart` to accept `AssignmentSubmissionModel` instead of `Submission`
- Update all widget props and references

---

### R6 — CreateAssignment Widget Reuse Strategy

**Existing widgets** (`lib/widgets/instructor/create_assignment/`):
- `create_assignment.dart` — barrel export (12 files)
- `basic_details_section.dart` — title, description inputs
- `instructions_section.dart` — instructions textarea
- `deadline_settings_section.dart` — due date picker
- `assignment_type_selector.dart` — type buttons
- `collapsible_section.dart` — accordion wrapper
- `attachments_section.dart` — file attachments
- `questions_section.dart` — quiz questions (NOT needed for assignments)
- `action_buttons.dart` — save/cancel buttons
- `lab_details_section.dart` — lab-specific fields (NOT needed)
- `project_details_section.dart` — project-specific fields (NOT needed)
- `create_assignment_colors.dart` — color constants

**Reusable**:
- `collapsible_section.dart` — generic accordion, no changes
- `create_assignment_colors.dart` — preserves visual design (≥85% rule)
- `action_buttons.dart` — save/cancel pattern works, wire to API
- `basic_details_section.dart` — needs prop type update to new model
- `instructions_section.dart` — needs prop type update to new model
- `deadline_settings_section.dart` — needs prop type update to new model
- `assignment_type_selector.dart` — needs prop type update (backend uses `file/text/link/multiple`)

**Not reusable**:
- `questions_section.dart` — quiz feature, not assignment
- `lab_details_section.dart` — lab feature, not assignment
- `project_details_section.dart` — project feature, not assignment

**Action required**: Create new `assignment_create_form.dart` widget that composes the reusable sections with the correct backend model. Keep the colors and collapsible section patterns. Drop quiz/lab/project sections.

---

## Decision Summary

| Decision | What was chosen | Rationale | Alternatives considered |
|----------|----------------|-----------|------------------------|
| **Submission model** | Replace `Submission` with `AssignmentSubmissionModel` | Single source of truth, follows Constitution Principle II | Keep both with adapter (more maintenance, inconsistency risk) |
| **Enum alignment** | Update `SubmissionStatus` to backend values (`submitted/graded/returned/resubmit`) | Backend is truth, prevents data corruption | Keep old enum with mapping layer (fragile, divergent) |
| **Widget reuse** | Reuse 6/12 create_assignment widgets, drop 3, adapt 3 | Preserves ≥85% visual similarity, avoids redesign | Full rewrite (violates UI preservation rule) |
| **Mock removal** | Replace with injected `AssignmentService` in cubit | BLoC architecture, testable | Direct API calls in widgets (violates Principle I) |
| **Late penalty** | Separate `isLate` bool field, not a status | Matches backend API shape (`TINYINT(1)`) | Keep `late` as status (wrong, causes API mismatch) |
