# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Implement Phase 3: Instructor Screens & Widgets Integration. Replace static mock instructor courses with live backend data from `GET /api/enrollments/teaching`. Implement `TeachingCourseModel` to unify data flow for the instructor role, dynamically calculating the `totalStudents` stat, and providing offline dashboard capability through caching.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart (Flutter)
**Primary Dependencies**: flutter_bloc/hydrated_bloc, dio, freezed, json_serializable
**Storage**: HydratedBloc / local storage (for offline parity)
**Testing**: flutter_test, bloc_test, mocktail
**Target Platform**: iOS, Android, Web
**Project Type**: mobile/web-app
**Performance Goals**: Smooth UI rendering at 60fps, rapid API response parsing
**Constraints**: Offline-capable for dashboard, strict UI parity with existing screens, strict data model integration
**Scale/Scope**: Instructor dashboard endpoints and related widget components

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **BLoC State Management First** without widget logic?
- [x] Is there **Strict Data Layer Separation** mapping to `eduverse_db.sql` models precisely?
- [x] Is **Type Safety & Error Handling** fully accounted for handling API responses?
- [x] Are we strictly utilizing the `courses_backend_integration_plan.md` strategy across Student, Instructor, and TA endpoints?

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
lib/
├── models/
│   ├── instructor/
│   │   ├── instructor_course_model.dart [DELETE]
│   │   └── extended_course_model.dart [DELETE]
│   └── course_models_unified.dart (or equivalent where TeachingCourseModel goes)
├── services/
│   └── api/
│       └── enrollment_service.dart [MODIFY]
├── bloc/
│   └── courses/
│       └── courses_bloc.dart [MODIFY]
├── screens/
│   └── instructor/
│       └── courses/
│           └── instructor_courses_screen.dart [MODIFY]
└── widgets/
    └── instructor/
        └── courses/
            └── courses_barrel.dart [MODIFY]
```

**Structure Decision**: Selected the Flutter lib structure mirroring the specified modifications in the integration plan, establishing standard separation of logic (Bloc, API Services, Models, Screens, Widgets).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
