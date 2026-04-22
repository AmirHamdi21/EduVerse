# Implementation Plan: Student Courses & Lecture Viewer

**Branch**: `016-student-courses-lecture` | **Date**: April 10, 2026 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/016-student-courses-lecture/spec.md`

## Summary

Replace static/mock course data in the Flutter mobile app with live backend API integration for student course viewing, including enrolled courses list, week-based course structure accordion, embedded YouTube video playback, Google Drive document preview, material bundle viewer, and view tracking. All state managed via BLoC pattern with 1:1 feature parity to the website frontend.

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.x
**Primary Dependencies**: Dio (HTTP client), youtube_player_flutter (video playback), webview_flutter (document preview), path_provider + flutter_downloader (downloads), shared_preferences or hive (caching), flutter_bloc (state management)
**Storage**: Local cache for course structure (shared_preferences or hive), downloaded files in app documents directory
**Testing**: flutter test (unit tests for BLoCs/services, widget tests for UI components, integration tests for API flows)
**Target Platform**: iOS 13+ / Android 8.0+ (mobile-first), responsive for iPad/tablet via adaptive layouts
**Project Type**: Mobile app feature module (Flutter)
**Performance Goals**: Course list loads in <2s, course structure in <3s, 60fps scrolling with 20+ weeks of materials, video playback starts within 1s on stable connection, UI rendering target <200ms per frame
**Constraints**: 10s timeout for standard endpoints, 30s for material-related calls (network timeouts), minimum 48x48px touch targets, responsive at 375px/768px/1024px+ breakpoints
**Scale/Scope**: Student role only (view-only permissions), courses with up to 20+ weeks of materials, each week containing 5-10 materials (videos, documents, bundles)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. BLoC State Management First** — All course list, structure, material viewing, and progress tracking states driven by BLoC/Cubit. No widget-level API calls.
- [x] **II. Strict Data Layer Separation** — Models (CourseModel, CourseStructureModel, CourseMaterialModel, MaterialBundle) match backend API response shapes AND website TypeScript interfaces exactly. Repository pattern via CourseService, MaterialService, EnrollmentService extending CoreApiClient with Dio.
- [x] **III. Type Safety & Error Handling** — All decimal fields parsed with `double.tryParse()`, paginated responses use `PaginatedResponse<T>`, API timeouts (10s/30s) with retry states, bundle prefix matching algorithm handles edge cases.
- [x] **IV. Website Feature Parity** — Student course list, week accordion, video player, document preview, bundle viewer all match website frontend (`CourseView.tsx`, `ClassTab.tsx`). Static mock data eliminated.
- [x] **V. Testable Architecture** — All services accept injected Dio instance, BLoCs accept injected services, mock services for testing without live API.
- [x] **VI. Real-Time Communication Integrity** — N/A for this phase (no WebSocket required for course viewing). Applies to chat features only.
- [x] **VII. Static Data Elimination** — Mock removal targets identified: hardcoded course lists, mock week modules, static material lists, `_generateSample*` patterns in student course widgets. Audit included in verification.
- [x] **VIII. Aggressive Clarification** — 3 clarification questions completed in spec session (navigation flow, API timeouts, bundle matching).
- [x] **IX. Role-Based Access Control Enforcement** — Student role can ONLY view courses, view materials, track views. NO create/edit/delete buttons visible. UI gated to read-only.
- [x] **X. File Upload & Google Drive/YouTube Integration** — YouTube videos via `youtube_player_flutter` or WebView embed. Google Drive documents via WebView with `/preview` URL. Thumbnails via `img.youtube.com/vi/{videoId}/mqdefault.jpg`. Downloads via flutter_download_manager with progress tracking.
- [x] **XI. Multi-Phase Plan Adherence** — This is Phase 2 (Student scope) per `courses_assignments_labs_integration_plan.md`. Depends on Phase 1 (Foundation) completion. Produces separate specification via `/speckit.specify`.

## Project Structure

### Documentation (this feature)

```text
specs/016-student-courses-lecture/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── courses-api.yaml
│   ├── materials-api.yaml
│   └── enrollments-api.yaml
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── features/
│   └── courses/
│       ├── models/
│       │   ├── course_model.dart              # Course entity matching backend
│       │   ├── course_structure_model.dart    # CourseStructure with week grouping
│       │   ├── course_material_model.dart     # CourseMaterial (video/doc/link)
│       │   └── material_bundle_model.dart     # MaterialBundle (prefix matching)
│       ├── services/
│       │   ├── course_service.dart            # GET /courses/{id}/structure
│       │   ├── material_service.dart          # GET /courses/{id}/materials, POST /materials/{id}/view
│       │   └── enrollment_service.dart        # GET /enrollments/my-courses
│       ├── bloc/
│       │   ├── course_list/
│       │   │   ├── course_list_bloc.dart
│       │   │   ├── course_list_event.dart
│       │   │   └── course_list_state.dart
│       │   ├── course_detail/
│       │   │   ├── course_detail_bloc.dart
│       │   │   ├── course_detail_event.dart
│       │   │   └── course_detail_state.dart
│       │   └── material_viewer/
│       │       ├── material_viewer_bloc.dart
│       │       ├── material_viewer_event.dart
│       │       └── material_viewer_state.dart
│       └── screens/
│           ├── course_list_screen.dart        # Enrolled courses list (replaces static)
│           └── course_detail_screen.dart      # Tabbed detail screen (Structure, Materials, Progress)
└── widgets/
    └── student/
        ├── course_list/
        │   ├── course_card.dart               # Course list item with schedule info
        │   └── empty_courses_message.dart     # No enrollments state
        ├── course_details/
        │   ├── course_tab_content.dart        # Tab content (replaces mock data)
        │   ├── week_accordion.dart            # Expandable week sections
        │   ├── material_card.dart             # Material item with type badge/thumbnail
        │   ├── bundle_viewer.dart             # Video + companion documents group
        │   ├── video_player_widget.dart       # YouTube embedded player
        │   └── document_preview_widget.dart   # Google Drive WebView preview
        └── progress/
            └── progress_indicator.dart        # Material view progress tracker

tests/
├── unit/
│   └── features/
│       └── courses/
│           ├── models/
│           │   ├── course_model_test.dart
│           │   ├── course_structure_model_test.dart
│           │   ├── course_material_model_test.dart
│           │   └── material_bundle_model_test.dart
│           ├── services/
│           │   ├── enrollment_service_test.dart
│           │   ├── course_service_test.dart
│           │   └── material_service_test.dart
│           └── bloc/
│               ├── course_list_bloc_test.dart
│               ├── course_detail_bloc_test.dart
│               └── material_viewer_bloc_test.dart
├── widget/
│   └── features/
│       └── courses/
│           ├── course_list_screen_test.dart
│           ├── course_detail_screen_test.dart
│           ├── week_accordion_test.dart
│           ├── bundle_viewer_test.dart
│           ├── video_player_widget_test.dart
│           └── document_preview_widget_test.dart
└── integration/
    └── features/
        └── courses/
            ├── course_list_api_test.dart
            ├── course_structure_api_test.dart
            ├── material_view_tracking_test.dart
            └── material_download_test.dart
```

**Structure Decision**: Single Flutter project feature module using the existing `lib/` structure. All course-related code isolated under `lib/features/courses/` with BLoC pattern. UI widgets under `lib/widgets/student/` matching existing student widget organization. Tests mirror source structure under `tests/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
