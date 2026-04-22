# Tasks: Student Courses Phase 1 - Design System Foundation and Courses Screen Shell

**Input**: Design documents from `C:\Users\Friends\Desktop\Graduation\EduVerse\specs\025-courses-shell-foundation\`
**Prerequisites**: `plan.md` (required), `spec.md` (required), `research.md`, `data-model.md`, `contracts/student-courses-shell-endpoints.md`, `Student_Courses_UI_Redesign_Documentation_Plan.md`, `Courses_Assignments_Labs_Frontend_Documentation.md`

**Tests**: Include targeted tests for this feature because the specification defines independent test criteria and measurable outcomes for semester query behavior, auth/session handling, and state-specific UI rendering.

**Feature Phase Closure Gate**: Redesign feature phase closure requires explicit website parity audit evidence and visual parity scoring evidence recorded in `specs/025-courses-shell-foundation/quickstart.md`.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare shared tokens, localization, and test scaffolding used by multiple stories.

- [X] T001 Create shared courses-shell design tokens in `lib/common/utils/student_courses_theme.dart`
- [X] T002 Add or update Phase 1 shell localization strings in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
- [X] T003 [P] Create reusable enrollment fixtures for shell tests in `test/helpers/student_courses_fixture.dart`
- [X] T004 [P] Create Phase 1 widget test scaffold in `test/widgets/student/courses/courses_screen_phase1_test.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Complete contract alignment and state architecture required before user-story implementation.

**CRITICAL**: No user story work should start until this phase is complete.

- [X] T005 Perform backend endpoint contract audit for Courses shell in `specs/025-courses-shell-foundation/contracts/student-courses-shell-endpoints.md` using `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts`, `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts` (including `buildEnrollmentResponse`, `buildInstructorEnrollmentView`, and `buildInstructorResponse`), `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts`, `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts`, and `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts`, and record mapper-to-model field evidence for consumed payload fields
- [X] T006 [P] Consolidate semester-aware my-courses request handling in `lib/services/api/enrollment_service.dart`
- [X] T007 [P] Align enrollment parsing/nullability with audited response shape in `lib/models/core/enrollment_model.dart`
- [X] T008 Add semester payload support to student fetch events in `lib/bloc/courses/courses_event.dart`
- [X] T009 Add dedicated auth/session-required state for `401`/`403` in `lib/bloc/courses/courses_state.dart`
- [X] T010 Implement semester fetch flow and `401`/`403` state mapping in `lib/bloc/courses/courses_bloc.dart`
- [X] T011 [P] Add foundational BLoC coverage for semester and auth/session transitions in `test/bloc/courses_bloc_test.dart`
- [X] T012 Record static/mock/fallback inventory for Phase 1 files in `specs/025-courses-shell-foundation/quickstart.md`
- [X] T013 Define extracted filter/sort/status helper boundaries and semester-option source policy (derive from enrollment.semester with All-only fallback when missing) in `lib/common/utils/student_course_filters.dart` and wire usage in `lib/screens/student/courses_screen.dart`

**Checkpoint**: Foundation complete. User stories can now be implemented.

---

## Phase 3: User Story 1 - View My Courses in the Redesigned Shell (Priority: P1) 🎯 MVP

**Goal**: Deliver redesigned Courses shell that renders live enrolled courses with loading and empty states while preserving Join Course behavior.

**Independent Test**: Sign in as a student with active enrollments and verify shell renders live list, skeleton while loading, and empty state without static mock data.

### Tests for User Story 1

- [ ] T014 [P] [US1] Add widget tests for loading, loaded, and empty shell states in `test/widgets/student/courses/courses_screen_phase1_test.dart`
- [X] T015 [P] [US1] Add list rendering regression coverage for enrollment passthrough in `test/widgets/course_list_screen_test.dart`

### Implementation for User Story 1

- [X] T016 [US1] Rebuild header visuals and typography tokens in `lib/widgets/student/courses/courses_header.dart`
- [X] T017 [US1] Rebuild search bar visuals and clear interaction in `lib/widgets/student/courses/course_search_bar.dart`
- [X] T018 [US1] Rebuild filter button container and filter sheet visuals in `lib/widgets/student/courses/filter_button.dart`
- [X] T019 [US1] Rebuild sort button container and sort option sheet visuals in `lib/widgets/student/courses/sort_button.dart`
- [X] T020 [US1] Rebuild animated horizontal filter chips in `lib/widgets/student/courses/course_filter_bar.dart`
- [X] T021 [US1] Rebuild Join Course button styling while keeping behavior unchanged in `lib/widgets/student/courses/join_course_button.dart`
- [X] T022 [US1] Rebuild screen shell layout, skeleton loader, and empty/no-results/error sections in `lib/screens/student/courses_screen.dart`
- [X] T023 [US1] Apply shared theme tokens across shell widgets in `lib/screens/student/courses_screen.dart` and `lib/widgets/student/courses/courses_header.dart`
- [X] T024 [US1] Remove story-local static/mock/fallback UI branches from US1-modified shell rendering in `lib/screens/student/courses_screen.dart`

**Checkpoint**: User Story 1 is independently functional and testable.

---

## Phase 4: User Story 2 - Find Courses with Search, Filter, and Sort (Priority: P1)

**Goal**: Deliver backend-shape-driven search/filter/sort plus semester filtering wired to endpoint query parameters.

**Independent Test**: With mixed enrollment data, validate search, status filter, semester selection, and sort all update results correctly.

### Tests for User Story 2

- [X] T025 [P] [US2] Add widget tests for search, status filter, and sort flows in `test/widgets/student/courses/courses_screen_phase1_test.dart`, including a dedicated semester-empty-versus-global-empty differentiation case with evidence notes in `specs/025-courses-shell-foundation/quickstart.md`
- [X] T026 [P] [US2] Add semester query serialization tests in `test/services/api/enrollment_service_test.dart`
- [X] T049 [P] [US2] Add Join Course behavior parity regression tests (happy path plus representative failure path unchanged) in `test/widgets/student/courses/courses_screen_phase1_test.dart` and `test/services/api/enrollment_service_test.dart`

### Implementation for User Story 2

- [X] T027 [US2] Add semester selection state and event dispatch in `lib/screens/student/courses_screen.dart`
- [X] T028 [US2] Add semester filter UI integration with options derived from enrollment.semester payload values and All-only fallback when metadata is missing in `lib/widgets/student/courses/filter_button.dart` and `lib/widgets/student/courses/course_filter_bar.dart`
- [X] T029 [US2] Implement backend-supported status normalization and filtering helpers in `lib/common/utils/student_course_filters.dart`
- [X] T030 [US2] Move search/filter/sort logic to extracted helpers and call them in `lib/screens/student/courses_screen.dart`, enforcing case-insensitive search over `course.code`, `course.name`, `section.sectionNumber`, `semester.name`, and optional instructor full name with precedence `exact/prefix code > title contains > section/semester/instructor contains`
- [X] T031 [US2] Preserve Join Course behavior while validating audited endpoint compatibility in `lib/widgets/student/courses/join_course_button.dart` and `lib/services/api/enrollment_service.dart`
- [X] T032 [US2] Update filter/sort callback contracts for semester-aware control state in `lib/widgets/student/courses/filter_button.dart` and `lib/widgets/student/courses/sort_button.dart`

**Checkpoint**: User Story 2 is independently functional and testable.

---

## Phase 5: User Story 3 - Recover from Network and Data Variations (Priority: P2)

**Goal**: Deliver robust offline/cache/error/auth-session feedback with explicit recovery paths.

**Independent Test**: Simulate offline, no-cache failure, and `401`/`403` responses; verify state-specific feedback and retry/re-auth actions.

### Tests for User Story 3

- [X] T033 [P] [US3] Add BLoC tests for cache fallback, generic error, and auth/session-required states in `test/bloc/courses_bloc_test.dart`
- [ ] T034 [P] [US3] Add widget tests for offline warning, generic error, and auth/session recovery UI in `test/widgets/student/courses/courses_screen_phase1_test.dart`
- [X] T050 [P] [US3] Add targeted edge-case tests for null nested enrollment fields and rapid search/filter/sort interactions during loading transitions in `test/widgets/student/courses/courses_screen_phase1_test.dart` and `test/bloc/courses_bloc_test.dart`
- [ ] T051 [P] [US3] Add widget-level RBAC tests for authenticated non-student access, restricted control visibility, and forbidden-state rendering in `test/widgets/student/courses/courses_screen_phase1_test.dart`

### Implementation for User Story 3

- [X] T035 [US3] Implement dedicated auth/session-required UI state and action in `lib/screens/student/courses_screen.dart`
- [X] T036 [US3] Separate empty, no-filter-results, offline-cache, and generic-error messaging in `lib/screens/student/courses_screen.dart` and both `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
- [X] T037 [US3] Ensure retry and refresh actions preserve semester-aware reload behavior in `lib/screens/student/courses_screen.dart`
- [X] T038 [US3] Refine error classification for unauthenticated/forbidden/network failures in `lib/bloc/courses/courses_bloc.dart`
- [X] T052 [US3] Implement widget-level RBAC gating and authorization-restricted UI state in `lib/screens/student/courses_screen.dart` and related shell controls

**Checkpoint**: User Story 3 is independently functional and testable.

---

## Phase 6: User Story 4 - Keep Visual Continuity During Redesign (Priority: P2)

**Goal**: Preserve continuity and readability across themes while matching Phase 1 redesign spacing and styling intent.

**Independent Test**: Compare before/after shell structure in light/dark themes and verify spacing/tokens remain consistent with redesign documentation.

### Tests for User Story 4

- [X] T039 [US4] Add light/dark visual regression assertions for shell tokens in `test/widgets/student/courses/courses_screen_phase1_test.dart`
- [X] T040 [US4] Add layout spacing/structure assertions for shell sections in `test/widgets/student/courses/courses_screen_phase1_test.dart`

### Implementation for User Story 4

- [X] T041 [US4] Align spacing, radii, shadows, and animation timing to Phase 1 spec in `lib/screens/student/courses_screen.dart` and `lib/widgets/student/courses/course_filter_bar.dart`
- [X] T042 [US4] Align labels and semantics hints for redesigned controls in `lib/widgets/student/courses/course_search_bar.dart` and `lib/widgets/student/courses/filter_button.dart`
- [X] T043 [US4] Verify metadata field rendering compatibility with audited enrollment shape in `lib/widgets/student/courses/courses_list_view.dart` and `lib/models/core/enrollment_model.dart`

**Checkpoint**: User Story 4 is independently functional and testable.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, cleanup, and deletion of obsolete pre-integration artifacts.

- [X] T044 Run Phase 1 validation commands and record outcomes in `specs/025-courses-shell-foundation/quickstart.md`
- [X] T045 Run delta/reconciliation endpoint audit against `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend` only if post-T005 changes affect contract-consuming code paths (service/model/BLoC/UI bindings), then update findings in `specs/025-courses-shell-foundation/contracts/student-courses-shell-endpoints.md`; otherwise record explicit skip rationale in `specs/025-courses-shell-foundation/quickstart.md`
- [X] T046 Run global grep-based final static/mock/fallback verification across all Phase 1 scope files (final cross-feature check, not story-local cleanup)
- [ ] T047 Detect and delete unused legacy pre-backend-integration files in `lib/widgets/student/courses/course_model.dart` and `lib/features/courses/screens/course_detail_screen.dart` only after deterministic checks pass: zero global usages in `lib/` and `test/`, route graph verification, `flutter analyze` pass, targeted tests pass, and cleanup owner approval documented in `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T048 Document cleanup proof (deleted files, removed imports, and no-unused-artifact check results) in `specs/025-courses-shell-foundation/research.md` and `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T053 Execute SC-002 reliability matrix with at least 100 first-load runs; record numerator/denominator and pass only if valid-state load rate is >=95% in `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T054 Execute SC-003 performance benchmark using the quickstart-defined dataset composition and target device profile; record p50/p95 and pass only if p50 <= 2.0s and p95 <= 10.0s in `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T055 Execute SC-004 transient-failure recovery matrix with at least 30 injected transient failures; pass only if one-retry recovery is >=90% and record evidence in `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T056 Run website parity audit for Phase 1 Courses shell against `Courses_Assignments_Labs_Frontend_Documentation.md` and `Student_Courses_UI_Redesign_Documentation_Plan.md`, and record component/field pass-fail matrix evidence in `specs/025-courses-shell-foundation/quickstart.md`
- [ ] T057 Run visual parity audit with required before/after screenshot pairs and checklist scoring formula; record score and pass only if similarity is >=85% in `specs/025-courses-shell-foundation/quickstart.md`

---

## Dependencies & Execution Order

### Phase Order

- Setup (Phase 1) must complete before Foundational (Phase 2).
- Foundational (Phase 2) blocks all user stories.
- User Story phases execute in priority order: US1 (Phase 3) -> US2 (Phase 4) -> US3 (Phase 5) -> US4 (Phase 6).
- Polish (Phase 7) runs after all targeted user stories are complete and is not complete until T056 and T057 parity evidence is recorded.
- T045 is conditional and executes only when post-T005 changes affect contract-consuming code paths.

### User Story Dependency Graph

- US1 depends on Phase 2 only.
- US2 depends on US1 and Phase 2 because controls build on shell structure.
- US3 depends on US2 and Phase 2 because auth/session and retry behavior rely on semester-aware fetch flow.
- US4 depends on US1 and US2 for final visual continuity alignment.

---

## Parallel Execution Examples

### User Story 1

- Run T014 and T015 in parallel (different test files).

### User Story 2

- Run T025 and T026 in parallel (widget vs service tests), then run T049 parity regression coverage.

### User Story 3

- Run T033 and T034 in parallel (BLoC vs widget tests), then run T050 and T051 for edge-case and RBAC-specific coverage.

### Foundational Phase

- Run T006 and T007 in parallel (service vs model alignment).

---

## Implementation Strategy

### MVP First

- Complete Phase 1 and Phase 2.
- Complete Phase 3 (US1) and validate independently.
- Demo/deploy MVP shell before expanding scope.

### Incremental Delivery

- Add US2 after MVP validation, then validate independently.
- Add US3 and validate reliability states independently.
- Add US4 and validate visual continuity independently.
- Execute Phase 7 cleanup and audits before closure.

### Team Parallelization

- One engineer handles service/model/BLoC contract alignment (T006-T011).
- One engineer handles shell widget redesign tasks (T016-T023).
- One engineer handles test implementation across stories (T014-T015, T025-T026, T033-T034, T039-T040, T049-T051).
