# Implementation Plan: Student Screens & Widgets Integration

**Branch**: `002-student-screens-integration` | **Date**: 2026-04-05 | **Spec**: [spec.md](../spec.md)
**Input**: Feature specification from `/specs/002-student-screens-integration/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Replace static initialization in the Student Dashboard and Courses screens with dynamic `CoursesBloc` states consuming live data. Establish robust offline UX gracefully handling null images, network resets, and filtering natively without invoking networking trips to guarantee cross-platform `<100ms` parity.

## Technical Context

**Language/Version**: Dart 3+, Flutter  
**Primary Dependencies**: `flutter_bloc`, `dio`, `equatable`, `shared_preferences`  
**Storage**: `SharedPreferences` (offline persistence via Bloc)
**Testing**: `flutter_test`, `bloc_test`  
**Target Platform**: iOS, Android
**Project Type**: mobile-app
**Performance Goals**: <100ms UI filter resolution, seamless load within 2s  
**Constraints**: Strict parity with `Eduverse-Frontend` React app design  
**Scale/Scope**: Dashboard mapping across full Student course loads

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **BLoC State Management First** without widget logic? *(Yes, strict provider usage and data consumption via BlocBuilder.)*
- [x] Is there **Strict Data Layer Separation** mapping to `eduverse_db.sql` models precisely? *(Yes, relying completely on Phase 1 unified models.)*
- [x] Is **Type Safety & Error Handling** fully accounted for handling API responses? *(Yes, Snackbar traps fallback caches robustly on BLoC state errors.)*
- [x] Are we strictly utilizing the `courses_backend_integration_plan.md` strategy across Student, Instructor, and TA endpoints? *(Yes, completely deleting mock data as outlined by the phases.)*

## Project Structure

### Documentation (this feature)

```text
specs/002-student-screens-integration/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── screens/
│   └── student/
│       ├── courses_screen.dart
│       └── course_details_screen.dart
└── widgets/
    └── student/
        └── courses/
            ├── courses_list_view.dart
            ├── course_filter_bar.dart
            ├── course_search_bar.dart
            ├── filter_button.dart
            └── sort_button.dart
```

**Structure Decision**: Selected standard Flutter widget isolation. Project will delete existing hard-coded arrays inside `widgets/student/courses/` and modify screens structurally above it to consume Provider states.

## Complexity Tracking

*No constitution violations present. Bypassing tracking.*
