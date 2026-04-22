# Qwen Code Context: EduVerse Flutter App

**Project**: EduVerse - Flutter Mobile App
**Date**: April 10, 2026
**Updated**: Phase 2 - Student Courses & Lecture Viewer

## Technology Stack

- **Language**: Dart 3.x with Flutter 3.x
- **State Management**: flutter_bloc (BLoC/Cubit pattern)
- **HTTP Client**: Dio (with CoreApiClient wrapper)
- **Video Playback**: youtube_player_flutter (YouTube embedding)
- **Document Preview**: webview_flutter (Google Drive preview)
- **Downloads**: flutter_downloader + path_provider
- **Caching**: shared_preferences (lightweight), in-memory maps for active sessions
- **Testing**: flutter test (unit, widget, integration)

## Architecture Patterns

### BLoC State Management (Constitution Principle I)
- All UI state driven by BLoC/Cubit classes
- No widget-level API calls
- States: loading, loaded, error, connectionStatus
- Events trigger service calls, emit new states

### Repository Pattern (Constitution Principle II)
- Services: CourseService, MaterialService, EnrollmentService
- All services extend/compose CoreApiClient with Dio
- Domain models separate from API responses
- Factory methods for JSON parsing with safe defaults

### Type Safety Rules (Constitution Principle III)
- Decimal fields: `double.tryParse(value.toString())`
- Enum parsing: `Enum.values.firstWhere(... orElse: default)`
- Paginated responses: `PaginatedResponse<T>` with computed properties
- Safe nullable casting throughout

## New Dependencies (Phase 2)

```yaml
youtube_player_flutter: ^8.1.2    # YouTube video playback
webview_flutter: ^4.4.2           # Google Drive document preview
flutter_downloader: ^1.11.2       # Background downloads
path_provider: ^2.1.1             # Platform storage paths
shared_preferences: ^2.2.2        # Lightweight caching
```

## API Endpoints (Phase 2 Scope)

- `GET /enrollments/my-courses` - Student's enrolled courses
- `GET /courses/{id}/structure` - Week-based course structure
- `GET /courses/{id}/materials` - Course materials list
- `POST /materials/{id}/view` - Record material view

**Timeouts**: 10s standard endpoints, 30s material-related calls

## Feature: Student Courses & Lecture Viewer

### Scope
- View enrolled courses (live API, no mock data)
- Browse course structure (week-based accordion)
- Watch lecture videos (YouTube embedded player)
- View/download documents (Google Drive preview)
- Material bundle viewer (prefix matching algorithm)
- Progress tracking (view count, access indicators)

### Key Files
- `lib/features/courses/` - Feature module (models, services, blocs, screens)
- `lib/widgets/student/course_details/` - Course detail widgets
- `lib/widgets/student/course_list/` - Course list widgets
- Tests mirror source structure under `tests/`

### Constitution Principles Applied
- I. BLoC State Management
- II. Strict Data Layer Separation
- III. Type Safety & Error Handling
- IV. Website Feature Parity (1:1 with website frontend)
- VII. Static Data Elimination (all mock data removed)
- IX. Role-Based Access Control (student read-only)
- X. File Upload & Google Drive/YouTube Integration
- XI. Multi-Phase Plan Adherence (Phase 2 of 10)

## Code Style

- Use `const` constructors for widgets where possible
- Widget classes: `PascalCase` extends `StatelessWidget` or `StatefulWidget`
- BLoC classes: `*Bloc` suffix, events: `*Event`, states: `*State`
- Service classes: `*Service` suffix
- Model classes: `*Model` suffix
- Private helpers: `_camelCase`
- String interpolation: `'Value: $value'` not `'Value: ' + value`

## Testing Standards

- Unit tests for BLoCs, services, models
- Widget tests for screens, widgets
- Integration tests for API flows
- Mock services for testing without live API
- Test files mirror source: `lib/x/y.dart` → `tests/unit/x/y_test.dart`

## Phase 4 Update: Student Labs Integration (April 11, 2026)

### Completion Summary
- Student Labs feature flow is implemented end-to-end with live API wiring (no demo/mock lab generation in labs feature files).
- Full workflow covered: course-scoped lab list, lab detail, instruction rendering, submission sheet, submission history, and attendance badge rendering.
- Legacy orphan file `lib/widgets/student/labs/lab_details_sheet.dart` is removed and references are cleared.

### New/Updated Labs Files
- `lib/screens/student/labs_screen.dart`
- `lib/screens/student/lab_detail_screen.dart`
- `lib/bloc/labs/labs_cubit.dart`
- `lib/bloc/labs/labs_state.dart`
- `lib/bloc/lab_detail/lab_detail_cubit.dart`
- `lib/bloc/lab_detail/lab_detail_state.dart`
- `lib/widgets/student/labs/lab_card.dart`
- `lib/widgets/student/labs/instruction_viewer.dart`
- `lib/widgets/student/labs/lab_submission_sheet.dart`
- `lib/widgets/student/labs/submission_history_view.dart`
- `lib/utils/submission_event_tracker.dart`
- `lib/models/labs/lab_model.dart`
- `lib/models/labs/lab_submission_model.dart`

### Dependencies and Libraries
- Labs instruction rendering uses `flutter_markdown`.
- File selection/upload workflow uses `file_picker`.
- Existing `webview_flutter` and `url_launcher` are used for file preview/open/download actions.

### Architecture Notes
- `LabDetailScreen` now uses dependency injection for `LabService` and `EnrollmentService` passed from the existing labs flow, instead of creating API clients inline.
- `LabSubmissionModel` intentionally reuses shared `SubmissionStatus` enum for assignment/lab submission state parity.

### Verification Snapshot
- Full workspace tests currently pass: `181 passed, 0 failed`.
- Labs integration timing test added: `test/integration/features/labs/student_labs_flow_integration_test.dart` to assert flow thresholds (`<2s` load and `<1s` graded-submission refresh in integration-style test harness).
- Full workspace analyze still reports broad pre-existing diagnostics (`957 issues`) outside this feature scope.

### April 12, 2026 Addendum (Second Verification)
- Lab detail AppBar title now uses localization (`AppLocalizations.labDetails`) instead of a hardcoded string.
- Student labs `LabCard` dead `animation` parameter removed to keep the widget API minimal and maintainable.
- Scoped analyzer run for modified labs files/tests passes with zero issues.
- Full workspace tests remain green after fixes: `181 passed, 0 failed`.
- Visual parity verification report added: `specs/018-student-labs/visual-parity-report.md`.

### April 12, 2026 Addendum (Third Verification, Corrected)
- Corrected path note: automated tests are located under `test/` (singular), not `tests/`.
- Re-ran full static analysis with `flutter analyze`: workspace still reports `957 issues found` (pre-existing, mostly warnings/info outside student labs scope).
- Re-ran full test suite with `flutter test`: `181 passed, 0 failed`.
- Re-ran labs integration test explicitly with `flutter test test/integration/features/labs/student_labs_flow_integration_test.dart`: `1 passed, 0 failed`.
- Re-ran mock/orphan audits for labs with PowerShell pattern search (fallback because `rg` is unavailable in shell): no matches for residual mock/demo lab patterns in modified labs files and no orphan mock lab artifacts in `lib/`.
- Phase 4 student labs task checklist remains complete (T001-T045 marked done), and this addendum records third-pass verification evidence.

## Phase 6 Update: Instructor Assignments CRUD & Grading (April 12, 2026)

### Completion Summary
- Instructor assignments flow is implemented end-to-end with live API wiring through `AssignmentService` and `EnrollmentService`.
- New instructor flow covers: assignments list, create/edit assignment form, submissions list, and full-screen submission grading.
- Existing grading UI (`GradeDialog`, `SubmissionCard`, grading center list wiring) is migrated to `AssignmentSubmissionModel` and decimal scoring.
- Legacy instructor assignment draft model and obsolete create-assignment section files are removed as part of orphan cleanup.

### New/Updated Instructor Files
- `lib/bloc/instructor/instructor_assignments_cubit.dart`
- `lib/bloc/instructor/instructor_assignments_state.dart`
- `lib/screens/instructor/assignments/instructor_assignments_screen.dart`
- `lib/screens/instructor/assignments/assignment_submissions_screen.dart`
- `lib/screens/instructor/assignments/submission_grading_screen.dart`
- `lib/screens/instructor/create_assignment_screen.dart`
- `lib/widgets/instructor/assignments/assignment_barrel.dart`
- `lib/widgets/instructor/assignments/assignment_card.dart`
- `lib/widgets/instructor/assignments/assignment_create_form.dart`
- `lib/widgets/instructor/assignments/assignment_status_badge.dart`
- `lib/widgets/instructor/assignments/grading_panel.dart`
- `lib/widgets/instructor/assignments/instruction_file_uploader.dart`
- `lib/widgets/instructor/assignments/submission_content_viewer.dart`
- `lib/widgets/instructor/assignments/submission_list_item.dart`
- `lib/utils/late_penalty_calculator.dart`

### Refactors and Cleanup
- Updated: `lib/config/app_router.dart` with assignments/submissions/grading routes and create/edit assignment extras parsing.
- Updated: `lib/bloc/instructor/grading_center_cubit.dart` and `lib/bloc/instructor/grading_center_state.dart` for live submissions and backend enums.
- Updated: `lib/models/instructor/grading_model.dart` and `lib/models/instructor/submission_model.dart` to align with assignment backend models.
- Updated: `lib/widgets/instructor/grading/grade_dialog.dart` and `lib/widgets/instructor/grading/submission_card.dart` for backend submission model + late-penalty/decimal score support.
- Deleted legacy files:
	- `lib/models/instructor/assignment_model.dart`
	- `lib/screens/instructor/create_assignment/create_assignment_screen.dart`
	- `lib/widgets/instructor/create_assignment/assignment_type_selector.dart`
	- `lib/widgets/instructor/create_assignment/attachments_section.dart`
	- `lib/widgets/instructor/create_assignment/basic_details_section.dart`
	- `lib/widgets/instructor/create_assignment/deadline_settings_section.dart`
	- `lib/widgets/instructor/create_assignment/questions_section.dart`
	- `lib/widgets/instructor/create_assignment/lab_details_section.dart`
	- `lib/widgets/instructor/create_assignment/project_details_section.dart`

### Validation Snapshot
- Mock/orphan audit (Phase 6 pattern set, scoped to required grading files + modified Dart files): no matches.
- Full `flutter analyze`: `930 issues found` (no new blocking analyzer errors introduced for this phase; workspace still has broad pre-existing diagnostics).
- Full `flutter test`: all tests passed (`+300`, `All tests passed!`).

## Phase 7 Update: Instructor Labs CRUD & Grading (April 13, 2026)

### Completion Summary
- Instructor labs flow is implemented with live API integration and role-gated instructor actions.
- Coverage includes: labs list/search/filter/pagination, create/edit/delete lab form, lab detail tabs, instruction management (text + file upload + reorder), submissions grading UI with late penalty support, and attendance marking.
- Runtime stability updates were applied after initial scaffold generation (provider initialization, async context guards, analyzer cleanup).

### New/Updated Files
- `lib/bloc/instructor/instructor_labs_cubit.dart`
- `lib/bloc/instructor/instructor_labs_state.dart`
- `lib/bloc/instructor/lab_detail_cubit.dart`
- `lib/bloc/instructor/lab_detail_state.dart`
- `lib/screens/instructor/labs/instructor_labs_screen.dart`
- `lib/screens/instructor/labs/lab_detail_screen.dart`
- `lib/widgets/instructor/labs/lab_barrel.dart`
- `lib/widgets/instructor/labs/lab_card.dart`
- `lib/widgets/instructor/labs/lab_create_form.dart`
- `lib/widgets/instructor/labs/lab_status_badge.dart`
- `lib/widgets/instructor/labs/instruction_file_uploader.dart`
- `lib/widgets/instructor/labs/instruction_manager.dart`
- `lib/widgets/instructor/labs/submissions_list.dart`
- `lib/widgets/instructor/labs/grading_panel.dart`
- `lib/widgets/instructor/labs/attendance_sheet.dart`
- `lib/services/api/lab_service.dart`
- `lib/models/labs/lab_model.dart`
- `lib/models/labs/lab_submission_model.dart`
- `lib/models/core/lab_attendance_model.dart`
- `lib/utils/late_penalty_calculator.dart`
- `lib/config/app_router.dart`

### Added Tests
- `test/unit/bloc/instructor/instructor_labs_cubit_test.dart`
- `test/unit/bloc/instructor/lab_detail_cubit_test.dart`

### Validation Snapshot
- Scoped analyzer run for Phase 7 files: `No issues found`.
- New Phase 7 unit tests: `8 passed, 0 failed`.
- Mock/orphan audits for instructor-labs module: no residual mock-data patterns or extra legacy instructor-labs files detected in feature scope.
- Remaining manual checks tracked in `specs/021-instructor-labs/tasks.md`: T036-T040.
