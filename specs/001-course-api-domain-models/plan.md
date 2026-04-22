# Implementation Plan: Phase 1: API Client, Domain Models & Global Config

**Branch**: `001-course-api-domain-models` | **Date**: 2026-04-05 | **Spec**: [spec.md](file:///d:/Graduation/EduVerse/edu_verse/specs/001-course-api-domain-models/spec.md)
**Input**: Feature specification from `specs/001-course-api-domain-models/spec.md`

## Summary
The goal is to map the backend database schemas and REST APIs to unified Dart models, create the necessary service/repository classes securely tailored for the Flutter app via `dio`, and broadcast state universally through `flutter_bloc`.

## Technical Context
**Language/Version**: Dart (Flutter 3.9.2)
**Primary Dependencies**: `dio` (for api/interceptors), `flutter_bloc` (state), `shared_preferences`
**Storage**: `shared_preferences` (for offline caching resilience)
**Testing**: `flutter_test`
**Target Platform**: iOS / Android
**Project Type**: Mobile App feature layer
**Performance Goals**: < 1s UI transitions for state broadcasts
**Constraints**: Requires seamless offline resilience and silent token auto-refresh handling.
**Scale/Scope**: Core data layer serving three application roles (Student, Instructor, TA).

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Does the plan enforce **BLoC State Management First** without widget logic? Yes, raw responses map to abstract States.
- [x] Is there **Strict Data Layer Separation** mapping to `eduverse_db.sql` models precisely? Yes.
- [x] Is **Type Safety & Error Handling** fully accounted for handling API responses? Yes, via strongly typed JSON serialization.
- [x] Are we strictly utilizing the `courses_backend_integration_plan.md` strategy across Student, Instructor, and TA endpoints? Yes.

## Project Structure

### Documentation (this feature)
```text
specs/001-course-api-domain-models/
├── plan.md              # This file
├── research.md          # Technical decisions mapped
├── data-model.md        # Entities schema
├── quickstart.md        # Developer setup docs
└── contracts/
    └── api-contracts.md # Backend endpoint mappings
```

### Source Code
```text
lib/
├── models/
│   ├── core/course_model.dart
│   ├── core/enrollment_model.dart
│   ├── materials/course_material_model.dart
│   ├── materials/assignment_model.dart
│   └── materials/announcement_model.dart
├── services/
│   └── api/
│       ├── core_api_client.dart (Dio config + Token interceptors)
│       ├── course_service.dart (Courses & Structure)
│       ├── enrollment_service.dart (Enrollments)
│       ├── material_service.dart (Course Materials)
│       └── communication_service.dart (Announcements & Assignments)
├── bloc/
│   └── courses/
│       ├── courses_bloc.dart
│       ├── courses_state.dart
│       └── courses_event.dart
```

**Structure Decision**: Standard Flutter Clean Architecture mapping domain models inside `lib/models`, API repositories in `lib/services/api/`, and State management directly inside `lib/bloc/`.
