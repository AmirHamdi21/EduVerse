# Implementation Plan: Instructor — Courses & Materials Management

**Branch**: `019-instructor-courses-materials` | **Date**: April 12, 2026 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/019-instructor-courses-materials/spec.md`

## Summary

Replace mock data in instructor courses and materials upload screens with live API integration. Build BLoC-driven state management for teaching courses listing, materials CRUD (4 upload types: text/link, file, video, bundle), course structure management, and materials library with automatic bundle detection. All screens maintain ≥85% visual similarity per Constitution Principle XII.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x
**Primary Dependencies**: flutter_bloc (BLoC/Cubit), Dio (via CoreApiClient), youtube_player_flutter, webview_flutter, file_picker, path_provider, shared_preferences
**Storage**: shared_preferences (lightweight caching), platform storage paths for downloaded files
**Testing**: flutter test (unit tests for BLoCs/services/models, widget tests for screens/widgets, integration tests for API flows)
**Target Platform**: Android/iOS mobile (responsive, 375px–1024px+ breakpoints)
**Project Type**: Mobile app (Flutter) — single project
**Performance Goals**: <2s course list load, <1s material CRUD operations, upload progress updates every 500ms, bundle upload completion within 30s
**Constraints**: ≥85% UI visual similarity (Constitution XII), BLoC-only state management (Constitution I), no widget-level API calls, FormData field names: `document` for docs, `video` for videos
**Scale/Scope**: Up to 100 students per section, unlimited materials per course, up to 5 documents per bundle upload

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

- [x] **I. BLoC State Management First** — New `InstructorCoursesBloc`, `MaterialsBloc`, `CourseStructureBloc` created. No widget-level API calls. All data flows through BLoC states.
- [x] **II. Strict Data Layer Separation** — Domain models (`TeachingCourseModel`, `CourseMaterialModel`, `MaterialBundleModel`, `CourseStructureItemModel`) mirror backend API responses and website TypeScript interfaces exactly. Services extend `CoreApiClient` with Dio.
- [x] **III. Type Safety & Error Handling** — `isPublished` parsed as `(value as num) == 1`, decimal fields use `double.tryParse(value.toString())`, enum parsing with `orElse` defaults, `PaginatedResponse<T>` generic type for paginated responses, partial-failure tracking for bundle operations.
- [x] **IV. Website Feature Parity** — All features from website's `UploadMaterialsPage` and `CourseDetail` (Lectures tab) ported. Bundle detection algorithm (`groupMaterialsIntoBundles`) ported from website frontend.
- [x] **V. Testable Architecture** — All services accept injected `Dio`/`CoreApiClient`, BLoCs accept injected services, all logic independently testable without UI.
- [x] **VI. Real-Time Communication Integrity** — N/A for this phase (no WebSocket features). Not applicable.
- [x] **VII. Static Data Elimination** — Mock data audit completed in research.md. All mock data in `instructor_courses_screen.dart`, `upload_materials_screen.dart`, `course_management_screen.dart` and sub-tabs will be replaced with live API data. Empty states shown when no data.
- [x] **VIII. Aggressive Clarification** — 5 clarification questions asked and answered during `/speckit.clarify` (Q1: sub-tab scope, Q2: bundle detection algorithm, Q3: engagement metrics, Q4: bundle edit/delete pattern, Q5: deadline data source).
- [x] **IX. Role-Based Access Control** — Instructor role enforcement: UI only shows upload/edit/delete actions for instructors. TA role can upload materials but cannot delete courses. Student role cannot access any instructor screens.
- [x] **X. File Upload & Google Drive/YouTube Integration** — FormData field names: `document` (docs), `video` (videos). Progress tracking via `onSendProgress`. YouTube OAuth error handling. Client-side file validation before upload.
- [x] **XI. Multi-Phase Plan Adherence** — Phase 5 depends on Phase 1 (services/models foundation). Completes instructor courses + materials scope. Assignments CRUD deferred to Phase 6, Labs CRUD deferred to Phase 7.
- [x] **XII. UI Consistency & Visual Preservation** — ≥85% visual similarity enforced. No layout reorganizations, color changes, or widget tree restructures. Only data source changes (mock → BLoC → API) and empty state additions.

## Project Structure

### Documentation (this feature)

```text
specs/019-instructor-courses-materials/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0: Research findings
├── data-model.md        # Phase 1: Data models
├── quickstart.md        # Phase 1: Developer setup guide
├── contracts/           # Phase 1: API contracts
│   └── api-contracts.md
└── tasks.md             # Phase 2: Task breakdown (future /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── screens/instructor/
│   ├── courses/
│   │   └── instructor_courses_screen.dart          # MODIFIED: Live API data
│   ├── upload_materials/
│   │   └── upload_materials_screen.dart            # MODIFIED: Full upload integration
│   └── course_management/
│       └── course_management_screen.dart           # MODIFIED: Live tab data
├── widgets/instructor/
│   ├── courses/
│   │   ├── course_list_card.dart                   # MODIFIED: Live data binding
│   │   ├── course_grid_card.dart                   # MODIFIED: Live data binding
│   │   └── course_compact_card.dart                # MODIFIED: Live data binding
│   ├── course_management/
│   │   ├── overview_tab.dart                       # MODIFIED: Live overview data
│   │   ├── materials_tab.dart                      # MODIFIED: Materials library + bundles
│   │   ├── students_tab.dart                       # MODIFIED: Live student list
│   │   └── assignments_tab.dart                    # MODIFIED: "Coming soon" placeholder
│   └── upload_materials/
│       ├── bundle_upload_section.dart              # NEW: Bundle upload UI
│       └── video_upload_section.dart               # NEW: Video upload with progress
├── bloc/
│   ├── instructor/
│   │   ├── instructor_courses_bloc.dart            # NEW: Instructor courses BLoC
│   │   ├── instructor_courses_event.dart           # NEW
│   │   └── instructor_courses_state.dart           # NEW
│   ├── materials/
│   │   ├── materials_bloc.dart                     # NEW: Materials management BLoC
│   │   ├── materials_event.dart                    # NEW
│   │   └── materials_state.dart                    # NEW
│   └── course_structure/
│       ├── course_structure_bloc.dart              # NEW: Structure management BLoC
│       ├── course_structure_event.dart             # NEW
│       └── course_structure_state.dart             # NEW
├── services/api/
│   ├── course_service.dart                         # MODIFIED: Add structure CRUD
│   └── material_service.dart                       # MODIFIED: Add upload types
├── models/
│   ├── instructor/
│   │   ├── instructor_course_model.dart            # MODIFIED: Teaching course fields
│   │   └── upload_materials_model.dart             # MODIFIED: Upload state model
│   ├── materials/
│   │   ├── course_material_model.dart              # MODIFIED: All backend fields
│   │   └── material_bundle_model.dart              # MODIFIED: Bundle detection
│   └── core/
│       └── course_structure_model.dart             # MODIFIED: Structure item model
├── utils/
│   ├── bundle_detector.dart                        # NEW: Bundle detection algorithm
│   └── file_validator.dart                         # NEW: Client-side file validation
└── config/
    └── app_router.dart                             # MODIFIED: Route updates if needed

test/
├── bloc/instructor/
│   ├── instructor_courses_bloc_test.dart           # NEW
│   ├── instructor_courses_event_test.dart          # NEW
│   └── instructor_courses_state_test.dart          # NEW
├── bloc/materials/
│   ├── materials_bloc_test.dart                    # NEW
│   ├── materials_event_test.dart                   # NEW
│   └── materials_state_test.dart                   # NEW
├── bloc/course_structure/
│   ├── course_structure_bloc_test.dart             # NEW
│   ├── course_structure_event_test.dart            # NEW
│   └── course_structure_state_test.dart            # NEW
├── services/api/
│   ├── course_service_phase5_test.dart             # NEW
│   └── material_service_phase5_test.dart           # NEW
├── models/
│   ├── instructor_course_model_test.dart           # NEW
│   ├── course_material_model_phase5_test.dart      # NEW
│   ├── material_bundle_model_phase5_test.dart      # NEW
│   └── course_structure_model_test.dart            # NEW
├── utils/
│   ├── bundle_detector_test.dart                   # NEW
│   └── file_validator_test.dart                    # NEW
├── widgets/instructor/
│   ├── instructor_courses_screen_test.dart         # NEW
│   ├── upload_materials_screen_test.dart           # NEW
│   └── course_management_screen_test.dart          # NEW
└── integration/features/phase5/
    └── instructor_courses_materials_flow_test.dart  # NEW
```

**Structure Decision**: Single Flutter project (Option 1). All Phase 5 code goes into existing `lib/` and `test/` directories. New BLoCs created under `lib/bloc/instructor/`, `lib/bloc/materials/`, `lib/bloc/course_structure/` to maintain separation of concerns. Existing `CourseService` and `MaterialService` extended with missing methods. No new packages or modules needed beyond existing dependencies.

## Complexity Tracking

> No Constitution violations requiring justification. All 12 principles satisfied with documented compliance above.
