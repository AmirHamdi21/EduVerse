# Implementation Plan: Course Detail Drill-down & Material Viewer

**Branch**: `005-course-details-viewer` | **Date**: 2026-04-06 | **Spec**: [specs/005-course-details-viewer/spec.md](specs/005-course-details-viewer/spec.md)

## Summary

The goal is to implement Phase 5 of the backend integration plan: creating a week-by-week curriculum structural view across all roles (Student, Instructor, TA). It will interface with `/api/courses/{courseId}/structure` using `CourseService` and render interactive material components that distinguish between videos, documents, and quizzes, launching them securely. Features like handling missing permissions via 403 fallbacks will be baked into the UI for restricted roles (like TAs).

## Technical Context

**Language/Version**: Dart (Flutter SDK)
**Primary Dependencies**: flutter_bloc, dio, url_launcher, freezed
**Storage**: SharedPreferences (for basic caching)
**Testing**: Flutter test
**Target Platform**: Mobile (iOS & Android)
**Project Type**: Flutter Mobile App
**Performance Goals**: Course structures load in under 2 seconds.
**Constraints**: Visual differentiation of materials; TAs access materials within their Overview tab; rely on backend rejection for disabled TA actions.
**Scale/Scope**: Extends the `CoursesBloc` to handle structured queries across all 3 dashboards.

**Unknowns**:
- NEEDS CLARIFICATION: What are the exact JSON payload schemas for `CourseStructure` and `CourseMaterial` fetched from `/api/courses/{courseId}/structure`? Must retrieve from Backend/Frontend source.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **BLoC State Management First** without widget logic?
- [x] Is there **Strict Data Layer Separation** mapping to `eduverse_db.sql` models precisely?
- [x] Is **Type Safety & Error Handling** fully accounted for handling API responses?
- [x] Are we strictly utilizing the `courses_backend_integration_plan.md` strategy across Student, Instructor, and TA endpoints?

## Project Structure

### Documentation (this feature)

```text
specs/005-course-details-viewer/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code

```text
lib/
├── models/
│   ├── course_structure_model.dart
│   └── course_material_model.dart
├── services/
│   └── api/
│       └── structure_service.dart
├── bloc/
│   └── courses/
│       ├── courses_bloc.dart
│       ├── courses_state.dart
│       └── courses_event.dart
└── screens/
    ├── student/course_details_screen.dart
    ├── instructor/course_details_screen.dart
    └── ta/courses/ta_course_overview_tab.dart
```

**Structure Decision**: Standard Flutter Clean Architecture mapping the specific services and states per widget needs.

## Complexity Tracking

*No major violations needing documentation.*
