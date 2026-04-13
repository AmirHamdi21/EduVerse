# Implementation Plan: Phase 7 — Instructor Labs CRUD & Grading

**Branch**: `021-instructor-labs` | **Date**: 2026-04-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/021-instructor-labs/spec.md`

## Summary

Build the complete instructor-facing lab management system: labs list with search/filter, create/edit/delete lab forms, instruction management (text + file uploads with Google Drive), submission viewing/grading with auto-calculated late penalty (manual override), and attendance marking. All screens reuse Phase 6 instructor assignment patterns (card widgets, grading panel, create forms, status badges) adapted for lab-specific data models. Zero instructor lab screens currently exist — all are new builds. Shared infrastructure (LabService, LabModel, LabSubmissionModel, LabInstructionModel, LabAttendanceModel, enums) already exists from Phase 1 and Phase 4 (student labs).

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.x
**Primary Dependencies**: flutter_bloc (BLoC/Cubit), Dio (HTTP client with CoreApiClient), webview_flutter (Drive preview), flutter_markdown (instruction rendering), file_picker (file selection)
**Storage**: N/A (all data via live API; lightweight caching via shared_preferences)
**Testing**: flutter test (unit tests for cubits, widget tests for screens, integration tests for flows)
**Target Platform**: Android/iOS mobile app (responsive: mobile <600px, tablet 600-1024px, desktop >1024px)
**Project Type**: Mobile app feature (instructor-facing lab management module)
**Performance Goals**: Labs list loads in <2s for 50 labs; grading panel opens in <500ms; search/filter responds in <500ms
**Constraints**: UI must maintain ≥85% visual similarity with existing screens; no mock data; all API-driven; BLoC-only state management
**Scale/Scope**: 19 new files (17 source + 2 test), 3 modified files (routes, 2 models). 9 widget files (instruction_manager split into 4 sub-tasks for drag-and-drop, numeric index, and move buttons).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **I. BLoC State Management First** — no widget-level API/WebSocket calls? → YES: Two cubits (InstructorLabsCubit, LabDetailCubit) drive all UI state
- [x] Is there **II. Strict Data Layer Separation** — models match backend API + website TypeScript interfaces exactly? → YES: LabModel, LabSubmissionModel, LabInstructionModel, LabAttendanceModel mirror backend shapes + website TS interfaces
- [x] Is **III. Type Safety & Error Handling** fully accounted for? → YES: decimal parsing via double.tryParse(), isLate bool handling, allowedFileTypes comma-separated parsing, safe enum parsing with orElse defaults
- [x] Does the plan enforce **IV. Website Feature Parity** — features added/removed to match website 1:1? → YES: Matches website LabsDashboard, LabCreate, LabDetail, GradingPanel, AttendanceSheet components
- [x] Is **V. Testable Architecture** ensured — services injectable, BLoCs mockable? → YES: LabService injected into cubits, cubits testable independently of UI
- [x] Does the plan enforce **VI. Real-Time Communication Integrity**? → N/A (no WebSocket for labs — REST only)
- [x] Is **VII. Static Data Elimination** accounted for? → YES: Zero mock data by construction; all new files use live API; mock removal audit included in verification
- [x] Was **VIII. Aggressive Clarification** performed? → YES: 3 clarification questions asked and answered (late penalty, file restrictions, instruction reordering)
- [x] Does the plan enforce **IX. Role-Based Access Control Enforcement**? → YES: Instructor-only UI gating; all CRUD buttons hidden for non-instructor roles
- [x] Is **X. File Upload & Google Drive/YouTube Integration** accounted for? → YES: FormData with `file` field name, Drive preview URLs, client-side file validation
- [x] Does the plan follow **XI. Multi-Phase Plan Adherence**? → YES: Phase 7 of 10; depends on Phase 1 (LabService); reusable by Phase 8 (TA grading)
- [x] Does the plan follow **XII. UI Consistency & Visual Preservation**? → YES: ≥85% visual similarity; reuses Phase 6 assignment component patterns; no redesigns

## Project Structure

### Documentation (this feature)

```text
specs/021-instructor-labs/
├── plan.md              # This file (/speckit.plan command output)
├── spec.md              # Feature specification (from /speckit.specify)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── api-contracts.md # API endpoint contracts for labs CRUD, instructions, submissions, attendance
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── screens/instructor/labs/
│   ├── instructor_labs_screen.dart          # Main labs list with search/filter/create
│   └── lab_detail_screen.dart               # Lab detail + instructions + submissions + attendance
├── widgets/instructor/labs/
│   ├── lab_barrel.dart                       # Barrel export file
│   ├── lab_card.dart                         # Lab list item card (reuses AssignmentCard pattern)
│   ├── lab_status_badge.dart                 # Status badge (reuses AssignmentStatusBadge pattern)
│   ├── lab_create_form.dart                  # Create/edit lab form (reuses AssignmentCreateForm pattern)
│   ├── instruction_manager.dart              # Add/edit/delete/reorder instructions
│   ├── instruction_file_uploader.dart        # File upload for instructions (reuses from assignments)
│   ├── submissions_list.dart                 # Submissions list with filter/search
│   ├── grading_panel.dart                    # Slide-over grading panel (adapts assignment GradingPanel)
│   └── attendance_sheet.dart                 # Attendance marking sheet
├── bloc/instructor/
│   ├── instructor_labs_cubit.dart            # Labs list state management
│   ├── instructor_labs_state.dart            # Labs list states (loading, loaded, error, filtering)
│   ├── lab_detail_cubit.dart                 # Lab detail state management
│   └── lab_detail_state.dart                 # Lab detail states (lab, instructions, submissions, attendance)
├── config/
│   └── app_router.dart                       # MODIFIED: Add /instructor/labs routes
├── models/labs/
│   ├── lab_model.dart                        # MODIFIED: Add allowedFileTypes, maxFileSizeMb
│   └── lab_submission_model.dart             # MODIFIED: Add latePenaltyPercent field
└── services/api/
    └── lab_service.dart                      # EXISTING (Phase 1) — no changes needed

test/
├── unit/bloc/instructor/
│   ├── instructor_labs_cubit_test.dart       # Unit tests for labs list cubit
│   └── lab_detail_cubit_test.dart            # Unit tests for lab detail cubit
└── integration/features/labs/
    └── instructor_labs_flow_integration_test.dart  # End-to-end flow test (optional)
```

**Structure Decision**: Single-project mobile app structure. Phase 7 adds instructor-facing lab management to the existing Flutter app. All new code lives under `lib/` following the project's established feature-module pattern (screens → widgets → bloc → models). Services are reused from Phase 1. No backend or frontend separation needed — this is purely a mobile app feature.

## Complexity Tracking

No constitution principle violations require justification. All 12 applicable constitution checks pass.
