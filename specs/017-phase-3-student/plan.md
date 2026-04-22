# Implementation Plan: Phase 3 — Student Assignments

**Branch**: `017-phase-3-student` | **Date**: 2026-04-11 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/017-phase-3-student/spec.md`

## Summary

Integrate the student assignment workflow (list → detail → submit → view grade) by replacing the mock-based `AssignmentsCubit` with a real `AssignmentBloc` wired to the existing `AssignmentService`. All static data (the `_generateDemoAssignments()` method with 8 hardcoded assignments) is eliminated. Four new widgets are created: assignment detail screen, markdown instruction renderer, submission form modal bottom sheet, and grade/submission viewer. UI preservation ≥85% is mandatory — the existing `assignments_screen.dart` layout, colors, card structure, and header are preserved; only mock data is replaced with live BLoC-driven states.

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.x
**Primary Dependencies**: flutter_bloc (BLoC/Cubit), Dio (via CoreApiClient), file_picker, webview_flutter (Drive preview), flutter_markdown, equatable
**Storage**: N/A (no local persistence — live API only)
**Testing**: flutter test (unit tests for BLoCs/services/models, widget tests for screens)
**Target Platform**: Android and iOS (Flutter mobile app)
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Assignment list loads within 3 seconds; submission completes within 2 minutes; 95% first-attempt submission success rate; file uploads up to 10MB complete within 30 seconds
**Constraints**: UI must maintain ≥85% visual similarity to pre-integration state; all state via BLoC (no widget-level API calls); file uploads via Dio FormData with progress tracking; client-side file size/type validation before upload
**Scale/Scope**: Single screen (assignments_screen.dart) with detail route; supports all enrolled courses for a student; paginated API responses with client-side filtering

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls? → **YES**: `AssignmentBloc` drives all UI state; `AssignmentService` calls flow through BLoC events/states only.
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly? → **YES**: `AssignmentModel` and `AssignmentSubmissionModel` already exist with backend field mapping. No model changes needed — only wiring.
- [x] Is **III. Type Safety & Error Handling** fully accounted for? → **YES**: Models already handle `lateSubmissionAllowed` as TINYINT, `isLate` as int/bool divergence, `allowedFileTypes` as JSON string, decimal field parsing with `double.tryParse()`. Service has retry logic.
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1? → **YES**: Student assignment list, detail, submission, and grade view match website `AssignmentList`, `AssignmentView`, `SubmissionForm`, `MySubmission` components.
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable? → **YES**: `AssignmentService` accepts `CoreApiClient` via constructor; BLoC will accept service via constructor for easy mocking.
- [ ] Does the plan enforce **VI. Real-Time Communication Integrity** → **N/A**: This feature has no WebSocket/real-time requirements. Assignment updates are via REST polling (manual refresh).
- [x] Is **VII. Static Data Elimination** accounted for? → **YES**: Current `assignments_screen.dart` contains 8 hardcoded demo assignments and a placeholder submission dialog. All will be replaced with BLoC-driven live data. T069–T075 handle the audit.
- [x] Was **VIII. Aggressive Clarification** performed? → **YES**: 5 clarification questions answered in spec session: assignment visibility, navigation pattern, filter semantics, form placement, file sources.
- [x] Does the plan enforce **IX. Role-Based Access Control Enforcement** → **YES**: This phase is student-only. Student role can only view own submissions and submit — no create/edit/delete buttons will be rendered.
- [x] Is **X. File Upload & Google Drive/YouTube Integration** accounted for? → **YES**: File submission uses `AssignmentService.submitFile()` with Dio FormData. Google Drive file picking via webview-based Drive picker. Client-side validation for file size/type before upload.
- [x] Does the plan follow **XI. Multi-Phase Plan Adherence** → **YES**: This is Phase 3 (Student Assignments). Depends on Phase 1 (AssignmentService, models — already built). Independent of Phases 4-10.

## Project Structure

### Documentation (this feature)

```text
specs/017-phase-3-student/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output — 7 design decisions
├── data-model.md        # Phase 1 output — 3 entities documented
├── quickstart.md        # Phase 1 output — setup, run, test
├── contracts/
│   └── assignment_api.md  # Phase 1 output — 5 API contracts
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output — 88 tasks
```

### Source Code (repository root)

```text
lib/
├── models/
│   ├── assignments/
│   │   ├── assignment_model.dart              # EXISTS — no changes (already has all backend fields)
│   │   └── assignment_submission_model.dart    # EXISTS — no changes
│   └── core/
│       ├── enums/
│       │   └── assignment_enums.dart           # EXISTS — SubmissionType, AssignmentStatus
│       └── shared_models.dart                  # EXISTS — CourseInfo, UserInfo, DriveFileModel
├── services/
│   └── api/
│       └── assignment_service.dart             # EXISTS — all student endpoints implemented
├── bloc/
│   └── assignments/
│       ├── assignments_cubit.dart              # EXISTS — DELETE (mock-based, replaced)
│       ├── assignments_state.dart              # EXISTS — DELETE (legacy state, replaced)
│       ├── assignment_bloc.dart                # CREATE — real BLoC with AssignmentService
│       ├── assignment_event.dart               # CREATE — events
│       └── assignment_state.dart               # CREATE — new state (replaces legacy)
├── screens/
│   └── student/
│       ├── assignments_screen.dart             # MODIFY — replace mock BLoC with real BLoC
│       └── assignment_detail_screen.dart       # CREATE — full-screen detail route
├── widgets/
│   └── student/
│       └── assignments/
│           ├── assignment_card.dart            # MODIFY — adapt to backend-driven model
│           ├── assignment_details_sheet.dart   # MODIFY — adapt for markdown/Drive preview
│           ├── assignments_filter_sheet.dart   # MODIFY — simplify to All/Submitted/Pending/Overdue
│           ├── assignment_detail_body.dart     # CREATE — detail content layout
│           ├── submission_form_sheet.dart      # CREATE — modal bottom sheet for submission
│           ├── drive_file_picker.dart          # CREATE — Google Drive file browser
│           └── my_submission_view.dart         # CREATE — display existing submission/grade
└── common/
    ├── service_error.dart                      # EXISTS — ServiceResult<T>, ServiceError
    └── retry_helper.dart                       # EXISTS — retry logic for API calls

tests/
├── unit/
│   ├── bloc/assignments/
│   │   └── assignment_bloc_test.dart           # CREATE — BLoC event/state tests
│   ├── services/
│   │   └── assignment_service_test.dart        # CREATE — service endpoint tests
│   └── models/
│       └── assignment_model_test.dart          # CREATE — JSON parsing tests
└── widget/
    ├── screens/
    │   ├── assignments_screen_test.dart        # CREATE — loading/loaded/empty states
    │   └── assignment_detail_screen_test.dart  # CREATE — detail content tests
    └── widgets/
        └── my_submission_view_test.dart        # CREATE — grade display tests
```

**Structure Decision**: Single Flutter project (mobile app). The existing `AssignmentService` and models from Phase 1 are already in place. This phase creates the BLoC layer, refactors the existing `assignments_screen.dart` to use BLoC-driven states, and adds submission/grade viewing widgets. No new directories outside the existing project structure are needed. Files that already exist and are complete will NOT be modified — only new files, the existing `assignments_screen.dart`, and three existing widget files will change.

## Complexity Tracking

> No Constitution Check violations requiring justification. All principles are satisfied by the existing architecture (Phase 1 services + models) and this phase's incremental additions (BLoC + UI wiring). Principle VI (Real-Time Communication) is N/A for this feature.
