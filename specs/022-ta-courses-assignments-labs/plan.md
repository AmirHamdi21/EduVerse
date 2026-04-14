# Implementation Plan: TA — Courses, Assignments & Labs Integration

**Branch**: `022-ta-courses-assignments-labs` | **Date**: 2026-04-14 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/022-ta-courses-assignments-labs/spec.md`

## Summary

Phase 8 wires the TA role to the live backend. All mock data is removed from four TA screens
(`ta_courses_list_screen`, `ta_course_detail_screen`, `ta_labs_list_screen`,
`ta_lab_detail_screen`). Two new global Cubits (`TACoursesCubit`, `TALabsCubit`) and one locally-scoped cubit
(`TAAssignmentSubmissionsCubit`) are introduced to manage state. Instructor CRUD components from Phases 6 and 7 (`assignment_create_form`,
`lab_create_form`, `grading_panel`, `attendance_sheet`, `instruction_file_uploader`) are reused
without modification. Eight new sub-tab widgets and one updated sub-tab widget (T008 overview update) are added to the TA course detail screen for full
course visibility. All four screens must maintain ≥85% visual similarity to their
pre-integration state per Constitution Principle XII.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: `flutter_bloc`, `Dio` via `CoreApiClient`, `AssignmentService` (Phase 6),
`LabService` (Phase 7), `EnrollmentService`, `CourseService`, `MaterialService`, `SectionService`
**Storage**: No new persistence; existing token storage in `CoreApiClient` via `SharedPreferences`
**Testing**: `flutter test` (unit for Cubits and models, widget for sub-tab widgets)
**Target Platform**: Android / iOS mobile (primary); responsive web/desktop secondary
**Project Type**: Mobile app — Flutter multi-role educational platform
**Performance Goals**: Course list <2s (SC-001), assignment create <3s (SC-002), grade save <2s
(SC-003/004), attendance batch save <5s (SC-007), 95% grading API success (SC-008)
**Constraints**: No new pub.dev dependencies beyond those already installed; reuse all Instructor
CRUD widgets unchanged; ≥85% visual similarity per Principle XII
**Scale/Scope**: 4 TA screens rewritten, 8 new sub-tab widgets created + 1 updated (T008),
3 Cubits (2 globally registered in `lib/main.dart` + 1 locally-scoped `TAAssignmentSubmissionsCubit` in Phase 5),
61 tasks across 10 phases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls?
  → All data fetching flows through named `TACoursesCubit`/`TALabsCubit`/`TAAssignmentSubmissionsCubit` methods.
  All mutation calls (delete assignment, delete lab, grade lab submission) also route through cubit methods —
  `deleteAssignment()`, `deleteLab()`, `gradeLabSubmission()`. No direct service or API calls from the widget layer.
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly?
  → All TA screens replace local mock classes with canonical models: `LabModel`,
  `AssignmentModel`, `TeachingCourseModel`, `LabAttendanceModel`, `AssignmentSubmissionModel`.
- [x] Is **III. Type Safety & Error Handling** fully accounted for — including optimistic updates, WebSocket reconnect fallback, isLate int/bool divergence, and decimal field parsing?
  → T027/T038 add model unit tests validating `isLate` parsing; decimal fields use
  `double.tryParse()` per data-model.md validation rules.
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1?
  → Constitution v6.0.0 amended to allow TA CRUD on assignments and labs, matching the intended
  backend role permissions. TA screens mirror the Instructor CRUD flow.
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable?
  → `TACoursesCubit` and `TALabsCubit` accept injected service dependencies; all referenced
  services are already testable from Phases 6 and 7.
- [x] Does the plan enforce **VI. Real-Time Communication Integrity** — WebSocket lifecycle, auto-reconnect, event idempotency?
  → N/A: this phase has no WebSocket features.
- [x] Is **VII. Static Data Elimination** accounted for — mock removal audit included in verification (including hardcoded lists, _generateSample patterns, setState bypasses)?
  → T049 (Phase 10 unified audit) runs the full mock pattern grep; T029/T030/T034/T043
  explicitly replace all identified local mock classes.
- [x] Was **VIII. Aggressive Clarification** performed — minimum 5 clarification questions on field parity, roles, edge cases, deletions, and API/event coverage?
  → 5 targeted questions answered in spec.md: (1) TA screen reuse strategy, (2) live vs managed data strategy for 9 sub-tabs, (3) section-scope definition, (4) attendance summary aggregation approach (N sequential per-lab calls, client-side aggregation), (5) `TACoursesCubit` required service injection list (6 services). Additional field-parity clarification captured in data-model.md compatibility notes and api-contracts.md.
- [x] Does the plan enforce **IX. Role-Based Access Control Enforcement** — UI buttons/forms conditionally rendered per role matrix?
  → T055 verifies role-gated UI; all CRUD actions gated to `teaching_assistant` role; 403
  responses handled by T022 (assignments) and T031–T033 (labs).
- [x] Is **X. File Upload & Google Drive/YouTube Integration** accounted for — correct FormData field names, progress tracking, preview URL logic, client-side validation?
  → T046/T047/T048 follow Principle X upload rules with FormData `file` field, `onSendProgress`,
  and 50MB/10MB client-side validation limits.
- [x] Does the plan follow **XI. Multi-Phase Plan Adherence** — phase gating, completion criteria, dependency order per integration plan?
  → Phase 2 (Cubits) gates all subsequent phases; Instructor components from Phases 6 and 7
  are confirmed prerequisites (verified in QWEN.md Phase 6/7 completion summaries).

## Project Structure

### Documentation (this feature)

```text
specs/022-ta-courses-assignments-labs/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Background research
├── data-model.md        # Canonical model references and local-to-canonical replacement table
├── quickstart.md        # Running and testing guide
├── contracts/
│   └── api-contracts.md # API endpoint contracts for this phase
└── tasks.md             # 61 implementation tasks across 10 phases
```

### Source Code (repository root)

```text
lib/
├── bloc/ta/
│   ├── ta_courses_cubit.dart      (NEW — Phase 2)
│   ├── ta_courses_state.dart      (NEW — Phase 2)
│   ├── ta_labs_cubit.dart         (NEW — Phase 2)
│   ├── ta_labs_state.dart         (NEW — Phase 2)
│   └── ta_assignment_submissions_cubit.dart  (NEW — Phase 5, locally scoped to submissions screen)
├── screens/ta/
│   ├── courses/
│   │   ├── ta_courses_list_screen.dart    (REWRITE — Phase 3)
│   │   └── ta_course_detail_screen.dart   (REWRITE — Phase 3)
│   └── labs/
│       ├── ta_labs_list_screen.dart       (REWRITE — Phase 6)
│       └── ta_lab_detail_screen.dart      (REWRITE — Phase 6)
└── widgets/ta/courses/
    ├── ta_course_overview_tab.dart        (UPDATE — Phase 3)
    ├── ta_course_sections_labs_tab.dart   (NEW — Phase 3)
    ├── ta_course_lectures_tab.dart        (NEW — Phase 3)
    ├── ta_course_materials_tab.dart       (NEW — Phase 3)
    ├── ta_course_assignments_tab.dart     (NEW — Phase 3)
    ├── ta_course_grading_tab.dart         (NEW — Phase 3)
    ├── ta_course_attendance_tab.dart      (NEW — Phase 3)
    ├── ta_course_students_tab.dart        (NEW — Phase 3)
    └── ta_course_announcements_tab.dart   (NEW — Phase 3)

# Reused without modification (from Phases 6 & 7 — confirmed in QWEN.md):
lib/widgets/instructor/assignments/
├── assignment_create_form.dart    ✅ confirmed exists
├── assignment_card.dart           ✅ confirmed exists
├── grading_panel.dart             ✅ confirmed exists
├── instruction_file_uploader.dart ✅ confirmed exists
└── submission_list_item.dart      ✅ confirmed exists

lib/widgets/instructor/labs/
├── lab_create_form.dart           ✅ confirmed exists
├── lab_card.dart                  ✅ confirmed exists
├── grading_panel.dart             ✅ confirmed exists
├── instruction_manager.dart       ✅ confirmed exists
├── instruction_file_uploader.dart ✅ confirmed exists
└── attendance_sheet.dart          ✅ confirmed exists

lib/services/api/
├── assignment_service.dart    (Phase 6, no changes needed)
└── lab_service.dart           (Phase 7, no changes needed)

# Entry point update:
lib/main.dart   (ADD TACoursesCubit + TALabsCubit to MultiBlocProvider — Phase 2, T005)
```

**Structure Decision**: Single Flutter project (mobile app). Feature files follow the established
`lib/bloc/{role}/`, `lib/screens/{role}/`, `lib/widgets/{role}/` convention. No new top-level
directories are introduced.

## Complexity Tracking

*No unresolved constitution violations in this plan (C2 resolved by constitution v6.0.0 amendment).*

| Note | Rationale |
|------|-----------|
| 4→9 sub-tab expansion in course detail | Permitted under Principle XII: the original 4 tabs are preserved at identical positions with unchanged colors and layout. 5 new tabs fill previously unused/empty slots in the tab bar — this adds content without altering the visual design language. |
| TA Assignment CRUD (FR-003–005) | Permitted under constitution v6.0.0 (role matrix amended from v5.0.0 which incorrectly restricted TAs to grade-only). TA CRUD is section-scoped and enforced by backend `@Roles()` guards. |
| No Phase 1 setup tasks | BLoC registration (`lib/main.dart`) is handled within T005 (Phase 2). No new pub.dev dependencies are required. Verify in T005 that `pubspec.yaml` requires no additions. |
