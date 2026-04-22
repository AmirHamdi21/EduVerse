# Implementation Plan: TA Backend Integration

**Branch**: `004-ta-backend-integration` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)

## Summary

This phase integrates the Courses feature for the Teaching Assistant (TA) role from the backend into the EduVerse Flutter application. By replacing static mockup data with live API endpoints, TAs can view assigned courses, examine dynamic sub-tabs (overview, grading, labs, discussions), and interact securely with course materials. The implementation enforces view-only privileges implicitly where elevated permissions don't exist and strictly uses the global BLoC architecture for caching and separation of concerns.

## Technical Context

**Language/Version**: Dart <3.0  
**Primary Dependencies**: flutter_bloc, freezed, json_serializable, dio, url_launcher
**Storage**: SecureStorage (for Auth, cached tokens)  
**Testing**: flutter_test  
**Target Platform**: Android, iOS, Web  
**Project Type**: mobile-app / flutter  
**Performance Goals**: <200ms parsing latency; 60 fps static scrolling  
**Constraints**: BLoC exclusively for state, strong separation mapping to `eduverse_db.sql`  
**Scale/Scope**: TA dashboard complete refactor across ~10 widget files.  

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **BLoC State Management First** without widget logic?
- [x] Is there **Strict Data Layer Separation** mapping to `eduverse_db.sql` models precisely?
- [x] Is **Type Safety & Error Handling** fully accounted for handling API responses?
- [x] Are we strictly utilizing the `courses_backend_integration_plan.md` strategy across Student, Instructor, and TA endpoints?

## Project Structure

### Documentation (this feature)

```text
specs/004-ta-backend-integration/
├── plan.md              # This file
├── research.md          # Completed
├── data-model.md        # Completed
├── quickstart.md        # Completed
└── tasks.md             # Next step
```

### Source Code

```text
lib/
├── models/
│   ├── instructor/
│   │   └── teaching_course_model.dart
│   └── ta/
│       └── ta_assignment_model.dart
├── services/
│   └── api/
│       └── enrollment_service.dart
├── bloc/
│   └── courses/
│       └── courses_bloc.dart
└── screens/ & widgets/
    └── ta/
        └── courses/
            └── [multiple UI files]
```

**Structure Decision**: The Flutter app structure uses standard layered modules (`models/`, `services/`, `bloc/`, `screens/`), preserving existing TA folder boundaries.
