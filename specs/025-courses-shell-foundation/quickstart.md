# Quickstart: Student Courses Phase 1

## Prerequisites
- Flutter SDK compatible with Dart `3.9.2`
- Access to backend environment for enrollment endpoints
- Local clone on branch `025-courses-shell-foundation`

## 1. Prepare workspace

```powershell
cd C:\Users\Friends\Desktop\Graduation\EduVerse
flutter pub get
```

## 2. Implement shell redesign foundation
- Create `lib/common/utils/student_courses_theme.dart` and define shared design tokens.
- Update shell widgets and screen:
  - `lib/screens/student/courses_screen.dart`
  - `lib/widgets/student/courses/courses_header.dart`
  - `lib/widgets/student/courses/course_search_bar.dart`
  - `lib/widgets/student/courses/filter_button.dart`
  - `lib/widgets/student/courses/sort_button.dart`
  - `lib/widgets/student/courses/course_filter_bar.dart`
  - `lib/widgets/student/courses/join_course_button.dart`

## 3. Implement backend-first semester and auth/session behavior
- Update event/state/bloc pipeline:
  - `lib/bloc/courses/courses_event.dart`
  - `lib/bloc/courses/courses_state.dart`
  - `lib/bloc/courses/courses_bloc.dart`
- Update service/model contract handling:
  - `lib/services/api/enrollment_service.dart`
  - `lib/models/core/enrollment_model.dart`

Expected behavior:
- Semester selection triggers network request with semester query.
- `401/403` routes to dedicated auth/session-required UI state.
- Unsupported static status filters are removed/adjusted to backend-supported values.

## 4. Validate with tests

```powershell
flutter test test/services/api/enrollment_service_test.dart
flutter test test/bloc/courses_bloc_test.dart
flutter test test/widgets/student/courses/courses_screen_phase1_test.dart
flutter analyze
```

## 5. Manual verification checklist
- Open student Courses screen and confirm redesigned shell renders correctly.
- Verify semester filter changes result list using backend data.
- Verify search/filter/sort interactions remain responsive and stable.
- Force `401` and `403` responses (token/session scenario) and verify dedicated auth/session UI appears.
- Confirm Join Course button behavior remains unchanged while visual style is updated.
- Confirm no static/mock fallback remains in modified Phase 1 files.

## 6. Contract audit traceability
- Review `contracts/student-courses-shell-endpoints.md` for endpoint expectations.
- Verify response-construction methods in `enrollments.service.ts` (`buildEnrollmentResponse`, `buildInstructorEnrollmentView`, `buildInstructorResponse`) and capture mapper-to-model field evidence (`backend field -> Flutter model field`) for all consumed fields.
- Ensure implementation and tests match contract notes before proceeding to `/speckit.tasks`.

## 7. SC-003 performance benchmark protocol (required)

### Standard dataset profile
- Use a fixed dataset of 120 enrollment records.
- Ensure at least 80 records are visible in Phase 1 shell states (`ENROLLED`/`COMPLETED`).
- Include at least 6 semesters and at least 12 unique course codes.
- Include at least 15 records with null optional nested fields (for example instructor or prerequisite metadata) to reflect real variability.

### Target device profile
- Mandatory gate device profile: Android Emulator `pixel_6` (Google APIs), API level 34 (Android 14), x86_64 system image, 6 GB RAM configuration.
- All SC-003 benchmark runs MUST be executed on this exact profile for pass/fail determination.
- Run measurements in profile or release mode (not debug mode).

### Measurement method
- Execute 30 runs each for search, status-filter, semester-filter, and sort interactions.
- Measure interaction latency from user action to first stable rendered frame of updated results.
- Record p50 and p95 per interaction type and aggregate values.

### Pass criteria
- p50 <= 2.0 seconds.
- p95 <= 10.0 seconds.

## 8. Website parity audit protocol (required)

- Compare implementation against `Courses_Assignments_Labs_Frontend_Documentation.md` and `Student_Courses_UI_Redesign_Documentation_Plan.md`.
- Produce a component/field parity matrix in this file with columns: `Item`, `Website Source`, `Flutter Target`, `Status (Pass/Fail)`, `Notes`.
- Include all in-scope Phase 1 shell controls and states (header, search, filter/sort, semester control, empty/no-results/error/auth-session states, join button behavior).
- Phase closure requires 100% pass for all in-scope matrix rows.

## 9. Visual parity audit protocol (required)

- Capture before/after screenshots for light and dark themes for the shell landing state and an interaction state.
- Score checklist items for layout structure, spacing, typography hierarchy, color usage, and control placement.
- Compute similarity using: `similarity_percent = (passed_checklist_items / total_checklist_items) * 100`.
- Phase closure pass threshold: similarity >= 85%.

## 10. Evidence log template

Record evidence for T053-T057 in this file using:

```text
Date:
Executor:
Dataset profile used:
Device profile used:
SC-002 result:
SC-003 p50/p95 result:
SC-004 result:
Website parity matrix status:
Visual parity score:
Links/paths to screenshots and artifacts:
```

## 11. Phase 1 static/mock/fallback inventory (T012)

| File | Static/mock/fallback artifact | Action taken | Status |
|---|---|---|---|
| `lib/screens/student/courses_screen.dart` | Inline filter/sort/status logic tied to UI assumptions and non-semester-aware fallback branches | Moved filtering/sorting/search precedence to `student_course_filters.dart`; wired semester-aware fetch and dedicated auth/session state rendering | Completed |
| `lib/services/api/enrollment_service.dart` | Duplicate non-semester `getMyCourses()` path diverging from `getMyEnrollments()` | Consolidated `getMyCourses()` to delegate to semester-aware flow | Completed |
| `lib/models/core/enrollment_model.dart` | Missing optional nested mapper fields (`instructor`, `prerequisites`) from backend response builder | Added optional parsing/nullability for audited nested fields | Completed |
| `lib/widgets/student/courses/filter_button.dart` | Status-only filter sheet with no semester source policy | Added semester section derived from `enrollment.semester` plus All-semesters fallback | Completed |

## 12. Contract reconciliation note (T045)

- Post-T005 contract-consuming code paths changed (`enrollment_service.dart`, `enrollment_model.dart`, `courses_bloc.dart`, `courses_screen.dart`), so delta reconciliation audit was executed.
- Re-verified backend controller/service/DTO sources under `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments`.
- Outcome: frontend now aligns with audited DTO+mapper field names for consumed Phase 1 payloads; no additional endpoint shape deltas were detected beyond the documented optional `instructor` nullability and mapper-computed `prerequisites` structure.
