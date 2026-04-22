# Implementation Plan: Student Courses Phase 1 - Design System Foundation and Courses Shell

**Branch**: `025-courses-shell-foundation` | **Date**: 2026-04-16 | **Spec**: `C:\Users\Friends\Desktop\Graduation\EduVerse\specs\025-courses-shell-foundation\spec.md`
**Input**: Feature specification from `C:\Users\Friends\Desktop\Graduation\EduVerse\specs\025-courses-shell-foundation\spec.md`

## Summary

Implement Phase 1 of the student courses redesign by introducing a shared design-token utility, rebuilding the Courses screen shell and related controls to match the redesign documentation, and enforcing backend-first integration behavior. The implementation preserves current Join Course behavior, adds a semester filter wired to `GET /api/enrollments/my-courses?semester=`, introduces a dedicated auth/session state for `401/403`, and aligns service/model parsing to audited backend contracts from `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend`.

## Technical Context

**Language/Version**: Dart 3.9.2 / Flutter stable  
**Primary Dependencies**: flutter_bloc, equatable, dio, shared_preferences, go_router, intl  
**Storage**: Backend API + in-memory BLoC state + SharedPreferences cache for course enrollments  
**Testing**: flutter_test (bloc tests, service tests, widget tests), flutter analyze  
**Target Platform**: Android and iOS (Flutter mobile app)
**Project Type**: Mobile application  
**Performance Goals**: initial shell render with cached data under 2s; search/filter/sort interactions meeting p50 <= 2.0s and p95 <= 10.0s on the defined standard dataset and target device profile; smooth 60fps scroll/animations  
**Constraints**: strict BLoC data flow, backend contract alignment, no static/mock fallback in modified files, explicit `401/403` auth-session state, semester filter integration, and UI alignment with Phase 1 redesign doc  
**Scale/Scope**: one primary screen (`CoursesScreen`), seven related course widgets, course BLoC/event/state updates, enrollment service integration adjustments, and targeted tests

## Constitution Check (Pre-Research Gate)

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. BLoC State Management First**: all data fetches remain in `CoursesBloc`; widgets remain presentation-focused.
- [x] **II. Strict Data Layer Separation**: endpoint parsing remains in service/model layers (`EnrollmentService`, `CourseEnrollmentModel`), not UI widgets.
- [x] **III. Type Safety & Error Handling**: plan includes backend-shape parsing review and explicit `401/403` session handling path.
- [x] **IV. Website Feature Parity**: references `Courses_Assignments_Labs_Frontend_Documentation.md` and redesign plan as source guides.
- [x] **V. Testable Architecture**: non-trivial transform logic (status mapping/filter/sort) remains in named functions; targeted tests added.
- [x] **VI. Real-Time Communication Integrity**: N/A for this feature scope (no websocket behavior changes).
- [x] **VII. Static Data Elimination**: includes final audit of modified files and removal of temporary fallback/static branches.
- [x] **VIII. Aggressive Clarification**: spec contains 12 resolved clarifications for this redesign scope.
- [x] **IX. Role-Based Access Control Enforcement**: student-only endpoint behavior and auth/role failure handling (`403`) are explicitly planned.
- [x] **X. File Upload & Google Drive/YouTube Integration**: N/A for this phase scope.
- [x] **XI. Multi-Phase Plan Adherence**: this plan targets only Phase 1 scope and preserves later-phase boundaries.
- [x] **XII. UI Consistency & Visual Preservation**: shell redesign follows documented Phase 1 structure/tokens and keeps overall continuity.
- [x] **Student Courses/Course Details Redesign Contract Audit**: plan mandates endpoint/DTO/service verification against backend source path.

## Project Structure

### Documentation (this feature)

```text
C:\Users\Friends\Desktop\Graduation\EduVerse\specs\025-courses-shell-foundation\
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts\
│   └── student-courses-shell-endpoints.md
└── tasks.md                 # created later by /speckit.tasks
```

### Source Code (repository root)

```text
C:\Users\Friends\Desktop\Graduation\EduVerse\
├── lib\
│   ├── common\utils\
│   ├── screens\student\
│   ├── widgets\student\courses\
│   ├── bloc\courses\
│   ├── services\api\
│   └── models\core\
└── test\
    ├── bloc\
    ├── services\api\
    └── widgets\student\courses\
```

**Structure Decision**: single Flutter mobile project centered on `lib/` and `test/`; no backend code changes are planned in this phase.

## Phase 0: Research Output

- Generate `C:\Users\Friends\Desktop\Graduation\EduVerse\specs\025-courses-shell-foundation\research.md` with contract and UX decisions.
- Confirm endpoint contracts and response-construction mapper methods from backend source files:
  - `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts`
  - `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts` (including `buildEnrollmentResponse`, `buildInstructorEnrollmentView`, and `buildInstructorResponse`)
  - `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts`
  - `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts`
  - `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts`

## Phase 1: Design & Contracts Output

- Generate `data-model.md`, `contracts/student-courses-shell-endpoints.md`, and `quickstart.md`.
- Update AI agent context with `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`.

### Planned File Edit Manifest (Phase 1)

| File | Action | Purpose |
|------|--------|---------|
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\common\utils\student_courses_theme.dart` | Create | Centralized color/gradient/typography tokens for Phase 1 shell redesign. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\common\utils\student_course_filters.dart` | Create | Extracted, testable helper boundaries for filter/sort/status and semester-option logic. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\l10n\app_en.arb` | Modify | Preserve and extend English localization coverage for redesigned shell states and controls. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\l10n\app_ar.arb` | Modify | Preserve and extend Arabic localization parity for redesigned shell states and controls. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\screens\student\courses_screen.dart` | Modify | Rebuild shell layout/states, wire semester filter UX and auth/session state rendering. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\courses_header.dart` | Modify | Apply redesign header structure/tokens. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\course_search_bar.dart` | Modify | Apply redesign search control styles and interactions. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\filter_button.dart` | Modify | Align filter UI to backend-supported statuses and integrate semester filter entrypoint. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\sort_button.dart` | Modify | Apply redesign sort control styles/behavior. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\course_filter_bar.dart` | Modify | Apply redesign chip styling and status options parity with backend-supported values. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\join_course_button.dart` | Modify | Redesign visuals only; preserve behavior. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\courses_list_view.dart` | Modify | Verify metadata rendering/search field parity with audited backend contract and redesigned shell behavior. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\bloc\courses\courses_event.dart` | Modify | Add semester-aware fetch event payload (student fetch by semester). |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\bloc\courses\courses_state.dart` | Modify | Add explicit auth/session-required state or equivalent typed state signaling. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\bloc\courses\courses_bloc.dart` | Modify | Use semester parameterized fetch path and map `401/403` to auth/session state. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\services\api\enrollment_service.dart` | Modify | Standardize `my-courses` request handling with optional semester parameter as primary path. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\models\core\enrollment_model.dart` | Modify | Tighten backend-shape mapping and remove/limit compatibility logic where safe. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\widgets\student\courses\course_model.dart` | Delete | Remove legacy pre-backend-integration artifact after deterministic deletion criteria pass. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\lib\features\courses\screens\course_detail_screen.dart` | Delete | Remove obsolete legacy detail screen only when deterministic deletion checks pass. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\test\helpers\student_courses_fixture.dart` | Create | Deterministic fixture set for reliability, edge-case, and performance validation. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\test\services\api\enrollment_service_test.dart` | Modify | Verify semester query behavior and contract parsing outcomes. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\test\bloc\courses_bloc_test.dart` | Modify | Verify semester fetch flow, auth/session state on `401/403`, and loaded/error transitions. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\test\widgets\student\courses\courses_screen_phase1_test.dart` | Create | Verify redesigned shell states, semester filter behavior, and auth/session UI rendering. |
| `C:\Users\Friends\Desktop\Graduation\EduVerse\test\widgets\course_list_screen_test.dart` | Modify | Keep list-rendering regression coverage aligned with enrollment passthrough expectations. |

### Backend Files to Audit (Read-Only)

| Backend File | Audit Focus |
|--------------|-------------|
| `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts` | Endpoint paths, role guards, query/body signatures for in-scope endpoints. |
| `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts` | Effective filtering behavior, returned status domain for my-courses, and response-construction mapper methods (`buildEnrollmentResponse`, `buildInstructorEnrollmentView`, `buildInstructorResponse`) with mapper-to-model field evidence. |
| `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts` | Response field names/types/nullability contract. |
| `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts` | Optional query parameters and available-course shape. |
| `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts` | Required register payload fields and validation rules. |

## Post-Design Constitution Check (Re-evaluation)

- [x] BLoC-driven architecture retained; no widget-level API calls introduced.
- [x] Service/model parsing explicitly aligned to backend contract audit outputs.
- [x] Error handling includes dedicated auth/session state for `401/403`.
- [x] Static/mock/fallback removal mandated for all modified files.
- [x] UI scope constrained to Phase 1 shell with documented design-token alignment.
- [x] Endpoint audit artifacts generated in `contracts/` and referenced by quickstart checks.

## Complexity Tracking

No constitutional violations requiring exception handling are expected for this plan.
