# Tasks: Instructor — Courses & Materials Management

**Input**: Design documents from `/specs/019-instructor-courses-materials/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: INCLUDED — Unit tests for BLoCs/services/models, widget tests for screens/widgets, integration tests for API flows per Phase 5 specification.

**Organization**: Tasks grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single Flutter project**: `lib/` for source, `test/` for tests at repository root

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization — verify existing dependencies and services from Phase 1 are in place

- [x] T001 Verify `pubspec.yaml` has required dependencies: flutter_bloc, dio, youtube_player_flutter, webview_flutter, file_picker, path_provider, shared_preferences
- [x] T002 [P] Verify existing `CoreApiClient` in `lib/services/api/core_api_client.dart` supports Dio FormData uploads with `onSendProgress`
- [x] T003 [P] Verify existing `MaterialService` in `lib/services/api/material_service.dart` and `CourseService` in `lib/services/api/course_service.dart` compile and extend `CoreApiClient`
- [x] T004 [P] Verify existing `EnrollmentService` in `lib/services/api/enrollment_service.dart` has `getTeachingCourses()` method
- [x] T005 Run `flutter analyze` and `flutter test` to confirm baseline workspace health

**Checkpoint**: Existing services compile, tests pass, dependencies available

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models, BLoCs, service extensions, and utilities that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Models & Entities

- [x] T006 [P] Update `TeachingCourseModel` in `lib/models/instructor/instructor_course_model.dart` with fields: sectionId, userId, courseId, role, nested course/section/semester objects, enrolledCount, capacity, averageGrade, attendanceRate; add robust `fromJson` factory with `double.tryParse` for decimals
- [x] T007 [P] Update `CourseMaterialModel` in `lib/models/materials/course_material_model.dart` with all backend fields: id, courseId, title, type (MaterialType enum), weekNumber, url, externalUrl, driveFileId, isPublished (parse as num==1), viewCount, downloadCount, createdAt, updatedAt
- [x] T008 [P] Update `MaterialBundleModel` in `lib/models/materials/material_bundle_model.dart` with fields: baseTitle, weekNumber, videoMaterial, companionMaterials, allMaterials computed; prepare for bundle detection algorithm
- [x] T009 [P] Update `CourseStructureItemModel` in `lib/models/core/course_structure_model.dart` with fields: id, courseId, title, weekNumber, sortOrder, description, createdAt
- [x] T010 [P] Create `UploadProgressState` model in `lib/models/instructor/upload_materials_model.dart` with fields: uploadId, fileName, fileSize, bytesSent, totalBytes, status (UploadStatus enum), stepLabel, errorMessage, startedAt, completedAt; add progressPercent computed property
- [x] T011 [P] Create `DeadlineCardModel` in `lib/models/instructor/instructor_course_model.dart` (co-locate with teaching course) with fields: id, title, type (DeadlineType enum), dueDate, status (DeadlineStatus enum), courseId
- [x] T012 [P] Create `EngagementMetricsModel` in `lib/models/instructor/instructor_course_model.dart` with fields: totalMaterialViews, totalMaterialDownloads, assignmentSubmissionRate, totalSubmissions, totalEnrolledStudents

### Service Extensions

- [x] T013 Extend `MaterialService` in `lib/services/api/material_service.dart` with: `uploadDocument()` (FormData, field `document`), `uploadVideo()` (FormData, field `video`, `onSendProgress`), `uploadTextLink()` (JSON), `updateMaterial()` (PUT), `deleteMaterial()` (DELETE), `toggleVisibility()` (PATCH)
- [x] T014 Extend `CourseService` in `lib/services/api/course_service.dart` with: `getStructure()`, `createStructureItem()`, `updateStructureItem()` (PUT), `deleteStructureItem()`, `reorderStructureItems()` (PATCH)
- [x] T015 Implement or verify `EnrollmentService.getSectionStudents(sectionId)` returns list with name, email, enrollmentStatus, grade, attendanceRate fields

### Utilities

- [x] T016 [P] Create `BundleDetector` in `lib/utils/bundle_detector.dart` — pure function `groupMaterialsIntoBundles(List<CourseMaterialModel>)` that strips suffixes (" - Video", " - Slides", " - Notes", " - {filename}") and groups by matching base title + weekNumber; returns `List<MaterialBundleModel>`; normalize base titles by trimming whitespace, collapsing runs, and case-insensitive comparison
- [x] T017 [P] Create `FileValidator` in `lib/utils/file_validator.dart` — client-side validation: documents max 50MB (pdf, docx, pptx, xlsx), images max 10MB (jpg, png, gif, webp), videos no client limit; validate MIME types and extensions

### BLoC Scaffolding

- [x] T018 [P] Create `InstructorCoursesBloc` class in `lib/bloc/instructor/instructor_courses_bloc.dart` with injected `EnrollmentService`; implement `init`/`close` lifecycle
- [x] T019 [P] Create `InstructorCoursesEvent` classes in `lib/bloc/instructor/instructor_courses_event.dart`: `LoadTeachingCourses`, `SelectCourse(courseId)`, `LoadDeadlines(courseId)`
- [x] T020 [P] Create `InstructorCoursesState` classes in `lib/bloc/instructor/instructor_courses_state.dart`: `InstructorCoursesLoading`, `InstructorCoursesLoaded(List<TeachingCourseModel>)`, `InstructorCoursesError(String)`, `DeadlinesLoaded(List<DeadlineCardModel>)`
- [x] T021 [P] Create `MaterialsBloc` in `lib/bloc/materials/materials_bloc.dart` with events: `LoadMaterials`, `UploadMaterial`, `UpdateMaterial`, `DeleteMaterial`, `ToggleMaterialVisibility`; states: `MaterialsLoading`, `MaterialsLoaded`, `MaterialsError`, `UploadProgress`; inject `MaterialService`
- [x] T022 [P] Create `CourseStructureBloc` in `lib/bloc/course_structure/course_structure_bloc.dart` with events: `LoadStructure`, `CreateStructureItem`, `UpdateStructureItem`, `DeleteStructureItem`, `ReorderStructureItems`; states: `StructureLoading`, `StructureLoaded`, `StructureError`; inject `CourseService`

### Tests for Foundational Layer

- [x] T023 [P] Model unit tests: `TeachingCourseModel` parsing in `test/models/instructor_course_model_test.dart` — test `isPublished` as 0/1, decimal fields as strings, nested objects
- [x] T024 [P] Model unit tests: `CourseMaterialModel` parsing in `test/models/course_material_model_phase5_test.dart` — test all enum parsing, URL fields, null handling
- [x] T025 [P] Model unit tests: `MaterialBundleModel` in `test/models/material_bundle_model_phase5_test.dart` — test bundle grouping logic
- [x] T026 [P] Utility tests: `BundleDetector` in `test/utils/bundle_detector_test.dart` — test suffix stripping, same-week grouping, edge cases (no match, single item, all same base)
- [x] T027 [P] Utility tests: `FileValidator` in `test/utils/file_validator_test.dart` — test size limits, allowed types, rejected types
- [x] T028 [P] BLoC unit tests: `InstructorCoursesBloc` in `test/bloc/instructor/instructor_courses_bloc_test.dart` — test loading success, empty list, API error
- [x] T029 [P] BLoC unit tests: `MaterialsBloc` in `test/bloc/materials/materials_bloc_test.dart` — test upload success, upload failure, CRUD operations
- [x] T030 [P] BLoC unit tests: `CourseStructureBloc` in `test/bloc/course_structure/course_structure_bloc_test.dart` — test CRUD operations, reorder

**Checkpoint**: Foundation ready — all models parse correctly, services have all methods, BLoCs scaffolded, tests pass

---

## Phase 3: User Story 1 — View Teaching Courses List (Priority: P1) 🎯 MVP

**Goal**: Instructor sees live API-driven teaching courses list with enrollment stats, empty state for no assignments, error state with retry

**Independent Test**: Login as instructor, open Courses screen, verify real course data from `GET /enrollments/teaching` renders correctly; verify empty state when no courses; verify error state with retry on API failure

### Tests for User Story 1

- [x] T031 [P] [US1] Service integration test: `getTeachingCourses()` in `test/services/api/enrollment_service_phase5_test.dart` — verify correct response parsing with nested course/section/semester objects
- [x] T032 [P] [US1] Widget test: `InstructorCoursesScreen` in `test/widgets/instructor/instructor_courses_screen_test.dart` — test loading state, loaded state with courses, empty state, error state with retry

### Implementation for User Story 1

- [x] T033 [P] [US1] Create `CourseListCard` widget in `lib/widgets/instructor/courses/course_list_card.dart` — displays teaching course data from `TeachingCourseModel` with course code, name, semester, enrolled count, capacity; preserve existing card layout/colors/spacing
- [x] T034 [P] [US1] Create `CourseGridCard` widget in `lib/widgets/instructor/courses/course_grid_card.dart` — grid variant for tablet/desktop; preserve existing visual design
- [x] T035 [P] [US1] Create `CourseCompactCard` widget in `lib/widgets/instructor/courses/course_compact_card.dart` — compact variant for mobile; preserve existing visual design
- [x] T036 [US1] Update `InstructorCoursesScreen` in `lib/screens/instructor/courses/instructor_courses_screen.dart` — remove mock data, wire `InstructorCoursesBloc` via `BlocBuilder`, dispatch `LoadTeachingCourses` on init; show loading/empty/error states; preserve ≥85% visual similarity
- [x] T037 [US1] Add empty state widget in `lib/widgets/instructor/courses/empty_courses_message.dart` — illustration + "No courses assigned yet" message
- [x] T038 [US1] Add route `/instructor/courses/:courseId` → `CourseManagementScreen` in `lib/config/app_router.dart` with `courseId` (int) path param; wire course card tap navigation via `GoRouter.pushNamed`
- [x] T039 [US1] Verify existing instructor navigation routes in `lib/config/app_router.dart` are not broken by new route additions

**Checkpoint**: Teaching courses list fully functional from live API, independently testable

---

## Phase 4: User Story 2 — Upload Course Materials (All 4 Types) (Priority: P1) 🎯 MVP

**Goal**: Instructor uploads materials via 4 types (text/link, file/document, video, bundle) with real-time progress, file validation, and materials appearing in library

**Independent Test**: Upload each of the 4 material types independently, verify each appears in materials library afterward with correct metadata; verify file validation rejects oversized files before upload; verify video upload shows progress bar; verify bundle upload shows step-by-step progress

### Tests for User Story 2

- [x] T040 [P] [US2] Service integration test: `uploadDocument()` in `test/services/api/material_service_phase5_test.dart` — verify FormData with `document` field, response parsing
- [x] T041 [P] [US2] Service integration test: `uploadVideo()` in `test/services/api/material_service_phase5_test.dart` — verify FormData with `video` field, `onSendProgress` callback fires
- [x] T042 [P] [US2] Service integration test: `uploadTextLink()` in `test/services/api/material_service_phase5_test.dart` — verify JSON body, response parsing
- [x] T043 [P] [US2] Widget test: `UploadMaterialsScreen` in `test/widgets/instructor/upload_materials_screen_test.dart` — test all 4 upload flows, progress UI, error states, file validation rejection

### Implementation for User Story 2

- [x] T044 [P] [US2] Create `VideoUploadSection` widget in `lib/widgets/instructor/upload_materials/video_upload_section.dart` — video file picker, real-time progress bar via `UploadProgressState` (throttled to 500ms updates), step-by-step labels, error handling with retry; include `weekNumber` from selector in FormData
- [x] T045 [P] [US2] Create `BundleUploadSection` widget in `lib/widgets/instructor/upload_materials/bundle_upload_section.dart` — multi-file picker (video + documents), sequential upload with step labels, manual grouping option (instructor selects files, enters bundle name in text field, confirms — materials tagged with bundle name during upload); include `weekNumber` in FormData for all uploads
- [x] T046 [P] [US2] Update `UploadSelectors` widget in `lib/widgets/instructor/upload_materials/upload_selectors.dart` — populate course selector dropdown from `InstructorCoursesBloc` teaching courses, add week number selector, material type picker
- [x] T047 [P] [US2] Update `UploadQueueCard` widget in `lib/widgets/instructor/upload_materials/upload_queue_card.dart` — show queued uploads with progress, status badges, error indicators
- [x] T048 [US2] Update `UploadMaterialsScreen` in `lib/screens/instructor/upload_materials/upload_materials_screen.dart` — remove mock data/static upload confirmations, wire `MaterialsBloc` via `BlocConsumer`, dispatch upload events, handle `UploadProgress` states; integrate `FileValidator` before upload; include `weekNumber` in all upload FormData/JSON bodies; preserve ≥85% visual similarity
- [x] T049 [US2] Implement bundle upload flow in `MaterialsBloc` — sequential upload: video first, then documents; emit `UploadProgress` state for each step; if any document upload fails, keep successfully uploaded documents, emit error for failed items with retry option; on full completion, emit refresh event for materials library
- [x] T050 [US2] Implement YouTube OAuth error handling in `MaterialsBloc` — catch 401 from video upload, emit error with message "YouTube not authorized. Contact admin."
- [x] T051 [US2] After upload success, dispatch `LoadMaterials` event to refresh library from API (do NOT optimistically append per Constitution Principle X); apply same refresh-after-operation pattern for edit/delete operations in US3

**Checkpoint**: All 4 upload types functional, progress tracking works, file validation enforced, materials appear in library after upload

---

## Phase 5: User Story 3 — Manage Materials Library (Priority: P2)

**Goal**: Instructor views materials library grouped by week with auto-detected bundles, toggles visibility, edits titles, deletes materials/bundles with confirmation, sees YouTube thumbnails and type badges

**Independent Test**: View materials library with existing materials, verify week grouping and bundle detection; toggle a material's visibility and verify backend change; edit a title and verify persistence; delete a material with confirmation; delete a bundle and verify parallel API calls with partial-failure handling

### Tests for User Story 3

- [x] T052 [P] [US3] BLoC test: `MaterialsBloc` toggle visibility in `test/bloc/materials/materials_bloc_test.dart` — test successful toggle, API error; assert operation completes within 1 second (SC-005)
- [x] T053 [P] [US3] BLoC test: `MaterialsBloc` delete bundle in `test/bloc/materials/materials_bloc_test.dart` — test parallel delete calls, partial failure (some succeed, some fail)
- [x] T054 [P] [US3] Widget test: `MaterialsTab` in `test/widgets/instructor/course_management/materials_tab_test.dart` — test week grouping, bundle display, toggle visibility UI, edit dialog, delete confirmation

### Implementation for User Story 3

- [x] T055 [P] [US3] Update `MaterialsTab` widget in `lib/widgets/instructor/course_management/materials_tab.dart` — remove static material list, wire `MaterialsBloc` via `BlocBuilder`; `MaterialsBloc` calls `BundleDetector.groupMaterialsIntoBundles()` in its `LoadMaterials` handler and emits already-grouped `List<MaterialBundleModel>`; display materials grouped by week number; show YouTube thumbnails via `img.youtube.com/vi/{videoId}/mqdefault.jpg`; show type badges; preserve ≥85% visual similarity
- [x] T056 [P] [US3] Update `MaterialItemCard` widget in `lib/widgets/instructor/upload_materials/material_item_card.dart` — add visibility toggle button (eye icon), edit title button, delete button; show "unpublished" indicator (e.g., faded opacity + badge) for hidden materials to satisfy FR-018 (instructors see both published/unpublished with clear visual distinction)
- [x] T057 [P] [US3] Create bundle card widget in `lib/widgets/instructor/course_management/bundle_card.dart` — displays video thumbnail + companion document list; bulk toggle visibility, edit all titles, delete entire bundle
- [x] T058 [US3] Implement visibility toggle in `MaterialsBloc` — dispatch `ToggleMaterialVisibility` event, call `MaterialService.toggleVisibility()`, then dispatch `LoadMaterials` to refresh from API (no optimistic append per Constitution Principle X); emit updated `MaterialsLoaded` state
- [x] T059 [US3] Implement edit title in `MaterialsBloc` — dispatch `UpdateMaterial` event with title change; for bundle-level edits, fire parallel `UpdateMaterial` calls per material; track partial failures; dispatch `LoadMaterials` to refresh from API after completion
- [x] T060 [US3] Implement delete in `MaterialsBloc` — dispatch `DeleteMaterial` event with confirmation; for bundle-level deletes, fire parallel `DeleteMaterial` calls per material; track successes vs failures; emit partial-failure state with retry option for failed items; dispatch `LoadMaterials` to refresh from API after completion
- [x] T061 [US3] Add partial-failure UI in `MaterialsTab` — snackbar/bottom sheet showing "X of Y materials deleted — Z failed, retry?" with retry button for failed items only

**Checkpoint**: Materials library fully functional with week grouping, bundle detection, visibility toggle, edit, delete, and partial-failure handling

---

## Phase 6: User Story 4 — Manage Course Structure (Priority: P2)

**Goal**: Instructor creates, edits, reorders, and deletes week-based structure items; materials associate with structure items by week number; deletion warns if materials associated

**Independent Test**: Create a structure item, verify it appears; edit its title, verify persistence; reorder items, verify new order persists; delete an item with no materials, verify removal; attempt to delete an item with materials, verify warning dialog

### Tests for User Story 4

- [x] T062 [P] [US4] Service integration test: `CourseService` structure CRUD in `test/services/api/course_service_phase5_test.dart` — test create, update, delete, reorder endpoints
- [x] T063 [P] [US4] BLoC test: `CourseStructureBloc` in `test/bloc/course_structure/course_structure_bloc_test.dart` — test all CRUD events, reorder event, error handling
- [x] T064 [P] [US4] Widget test: Course structure editor in `test/widgets/instructor/course_management/course_structure_editor_test.dart` — test create dialog, edit inline, reorder controls, delete confirmation with warning

### Implementation for User Story 4

- [x] T065 [P] [US4] Create `CourseStructureEditor` widget in `lib/widgets/instructor/course_management/course_structure_editor.dart` — list of structure items with title, week number badge; add button, edit button, reorder controls (up/down arrows or drag), delete button; warning dialog if item has associated materials
- [x] T066 [P] [US4] Create `StructureItemCard` widget in `lib/widgets/instructor/course_management/structure_item_card.dart` — displays structure item title, week number, material count; edit/delete action buttons
- [x] T067 [US4] Wire `CourseStructureBloc` to `CourseStructureEditor` via `BlocBuilder` — dispatch `LoadStructure` on init, display `StructureLoaded` state
- [x] T068 [US4] Implement create structure item flow — dialog with title + week number inputs; dispatch `CreateStructureItem` event; on success, dispatch `LoadStructure` to refresh
- [x] T069 [US4] Implement edit structure item — inline edit or dialog; dispatch `UpdateStructureItem` event; on success, refresh
- [x] T070 [US4] Implement reorder structure items — up/down arrow buttons dispatch `ReorderStructureItems` event with new itemIds order; on success, refresh
- [x] T071 [US4] Implement delete structure item — confirmation dialog with warning "Materials in this week will become ungrouped (not deleted)"; dispatch `DeleteStructureItem` event; on success, refresh

**Checkpoint**: Course structure CRUD fully functional, materials can be associated with weeks, deletion warns appropriately

---

## Phase 7: User Story 5 — View Course Detail with Live Data (Priority: P3)

**Goal**: Instructor drills into course detail with 5 sub-tabs (Overview, Lectures, Assignments, Grading, Students); Overview shows live stats, deadlines, schedules, engagement metrics; Assignments/Grading show "coming soon" placeholders

**Independent Test**: Navigate to course detail, verify all 5 sub-tabs present; verify Overview tab loads live data (student count, avg grade, schedules, engagement metrics, deadlines); verify Lectures tab shows materials by week; verify Assignments/Grading tabs show "coming soon" placeholders

### Tests for User Story 5

- [x] T072 [P] [US5] Service integration test: Deadlines fetch via `InstructorCoursesBloc.LoadDeadlines` in `test/bloc/instructor/instructor_courses_bloc_test.dart` — verify `GET /assignments?courseId={id}` and `GET /labs?courseId={id}` read-only response parsing, `DeadlineCardModel` emission
- [x] T073 [P] [US5] Widget test: `CourseManagementScreen` in `test/widgets/instructor/course_management_screen_test.dart` — test 5 sub-tabs present, Overview loads live data using `EngagementMetricsModel` and `DeadlineCardModel` from `instructor_course_model.dart`, placeholders for Assignments/Grading

### Implementation for User Story 5

- [x] T074 [US5] Update `CourseManagementScreen` in `lib/screens/instructor/course_management/course_management_screen.dart` — ensure 5 sub-tabs (Overview, Lectures, Assignments, Grading, Students); wire live data to each tab; preserve TabBar layout/colors/structure; preserve ≥85% visual similarity
- [x] T075 [P] [US5] Update `OverviewTab` widget in `lib/widgets/instructor/course_management/overview_tab.dart` — remove mock stats, wire live data using `EngagementMetricsModel` and `DeadlineCardModel` from `instructor_course_model.dart`: student count from section enrollment, average grade percentage, engagement metrics (material views/downloads + assignment submission rate capped at first 20 assignments for performance, fetched in parallel), section schedules (FR-013: day, time, room, building, schedule type), upcoming deadlines from `InstructorCoursesBloc.LoadDeadlines`; preserve card layout/colors
- [x] T076 [P] [US5] Verify `MaterialsTab` renders correctly as Lectures sub-tab in `CourseManagementScreen` — confirm week grouping and bundle detection display properly when accessed via Lectures tab navigation (manual QA step)
- [x] T077 [P] [US5] Create `AssignmentsTab` placeholder in `lib/widgets/instructor/course_management/assignments_tab.dart` — display "Assignments management coming soon" placeholder state; preserve tab layout structure
- [x] T078 [P] [US5] Create `GradingTab` placeholder in `lib/widgets/instructor/course_management/grading_tab.dart` — display "Grading coming soon" placeholder state; preserve tab layout structure
- [x] T079 [US5] Wire deadlines fetch in `InstructorCoursesBloc` — `LoadDeadlines(courseId)` event calls read-only `GET /assignments?courseId={id}` and `GET /labs?courseId={id}`, filters for upcoming due dates, emits `DeadlineCardModel` list via `DeadlinesLoaded` state for Overview tab consumption
- [x] T080 [US5] Wire engagement metrics computation in `OverviewTab` — (1) sum viewCount/downloadCount across all materials from `MaterialsBloc`; (2) compute assignment submission rate: fetch enrolled student count from section data, fetch up to 20 assignments via `GET /assignments?courseId={id}` (cap for performance), count unique students with submissions from `GET /assignments/{id}/submissions` per assignment (fetch in parallel), calculate (unique submitters / total enrolled) × 100; use `EngagementMetricsModel` from `instructor_course_model.dart`

**Checkpoint**: Course detail screen fully functional with live data in Overview/Lectures/Students tabs, placeholders for Assignments/Grading

---

## Phase 8: User Story 6 — View Section Students (Priority: P3)

**Goal**: Instructor views enrolled students list with name, email, enrollment status, grade, attendance rate; empty state when no students enrolled

**Independent Test**: View Students tab for a course section with enrolled students, verify student list renders from `GET /sections/{sectionId}/students`; verify empty state when no students

### Tests for User Story 6

- [x] T081 [P] [US6] Service integration test: `getSectionStudents()` in `test/services/api/enrollment_service_phase5_test.dart` — verify response parsing with name, email, grade, attendanceRate
- [x] T082 [P] [US6] Widget test: `StudentsTab` in `test/widgets/instructor/course_management/students_tab_test.dart` — test loaded state with students, empty state, error state

### Implementation for User Story 6

- [x] T083 [P] [US6] Update `StudentsTab` widget in `lib/widgets/instructor/course_management/students_tab.dart` — remove mock student roster, wire `EnrollmentService.getSectionStudents(sectionId)` via BLoC; display student name, email, enrollment status badge, grade, attendance rate; preserve existing card/table layout; preserve ≥85% visual similarity
- [x] T084 [US6] Add empty state for Students tab — "No students enrolled yet" message when API returns empty list

**Checkpoint**: Students tab fully functional with live API data, empty state works

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, final verification, and orphan cleanup

### Responsive Design Verification

- [x] T085 [P] Verify all Phase 5 screens responsive at 375px (mobile portrait), 768px (tablet portrait), 1024px+ (desktop)
- [x] T086 [P] Verify all interactive elements maintain minimum 48x48px touch targets
- [x] T087 [P] Verify no horizontal scrolling on mobile viewports

### UI Parity Verification

- [x] T088 Visual parity audit: Compare before/after screenshots for `InstructorCoursesScreen`, `UploadMaterialsScreen`, `CourseManagementScreen` — verify ≥85% visual similarity
- [x] T089 Verify no color, spacing, or typography changes in modified screens
- [x] T090 Verify widget tree nesting order preserved (no unnecessary reorganizations)

### Mock Data Elimination Audit

- [x] T091 Grep all files listed in plan.md "Source Code" section under MODIFIED labels for residual mock patterns: `_generateSample`, `_mockData`, `mockCourses`, `_loadMockData`, `Future.delayed` fake responses, hardcoded `List<Course>` literals
- [x] T092 Grep all files listed in plan.md "Source Code" section under MODIFIED labels for `setState(() =>` patterns that bypass BLoC
- [x] T093 Grep all files listed in plan.md "Source Code" section under MODIFIED labels for `TODO: Replace with API` comments — must be resolved

### Orphan File Cleanup (Pre-Phase 5 Legacy Files)

- [x] T094 Audit pre-Phase 5 instructor files for orphans: (a) grep `lib/` for files in `lib/widgets/instructor/` and `lib/screens/instructor/` not imported by any active screen or `app_router.dart`; (b) grep for mock patterns: `_generateSample`, `_mockData`, `mockCourses`, `_loadMockData`; (c) cross-reference with website frontend docs — files with no website equivalent are orphans
- [x] T095 Delete orphan widget files with no website equivalent (per Constitution Principle IV + VII); candidate orphans to review: files under `lib/widgets/instructor/create_assignment/` (Phase 6 scope), `lib/widgets/instructor/grading/` (Phase 6 scope) — confirm no Phase 5 imports before deletion
- [x] T096 Delete orphan model files no longer referenced after Phase 5 model updates; candidate orphans: check `lib/models/instructor/` for models not used by `InstructorCoursesBloc`, `MaterialsBloc`, or `CourseStructureBloc`
- [x] T097 Run `flutter analyze` after orphan deletion — verify no broken imports
- [x] T098 Run `flutter test` after orphan deletion — verify all tests pass

### Final Validation

- [x] T099 Run full `flutter analyze` — verify no new errors introduced
- [x] T100 Run full `flutter test` — verify all Phase 5 tests pass
- [x] T101 Run quickstart.md verification checklist from `specs/019-instructor-courses-materials/quickstart.md`
- [x] T102 Verify role-based access control (Constitution IX): add role check in `InstructorCoursesScreen` and `UploadMaterialsScreen` — confirm screens are inaccessible to student role (redirect or show "Access Denied"); confirm TA role can upload materials but cannot delete courses or course structure
- [x] T103 Fix spec.md SC-002: update "progress bar that updates at least every 2 seconds" → "progress bar that updates at least every 500ms" to align with plan.md implementation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS all user stories (Phases 3-8)**
- **Phase 3 (US1 - Teaching Courses List)**: Depends on Phase 2 — no dependencies on other stories
- **Phase 4 (US2 - Upload Materials)**: Depends on Phase 2 — no dependencies on other stories
- **Phase 5 (US3 - Materials Library)**: Depends on Phase 2 AND Phase 4 (needs materials uploaded to manage)
- **Phase 6 (US4 - Course Structure)**: Depends on Phase 2 — no dependencies on other stories
- **Phase 7 (US5 - Course Detail)**: Depends on Phase 3 (needs course list), Phase 5 (needs materials tab), Phase 8 (needs students tab)
- **Phase 8 (US6 - Section Students)**: Depends on Phase 2 — no dependencies on other stories
- **Phase 9 (Polish)**: Depends on all user story phases complete

### User Story Dependencies

```
Phase 2 (Foundation)
  ├── Phase 3: US1 (Teaching Courses) ──┐
  ├── Phase 4: US2 (Upload Materials) ──┤
  ├── Phase 6: US4 (Course Structure)   │
  ├── Phase 8: US6 (Section Students)   │
  └── Phase 5: US3 (Materials Library) ─┘ (depends on US2)
        └── Phase 7: US5 (Course Detail) (depends on US1, US3, US6)
```

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services (already done in Phase 2)
- Services before BLoCs (already done in Phase 2)
- BLoCs before widgets
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Phase 1 tasks marked [P] can run in parallel
- All Phase 2 tasks marked [P] can run in parallel (models, services, utilities, BLoCs)
- Once Phase 2 completes: US1 (T031-T037), US2 (T042-T049), US4 (T063-T069), US6 (T082-T083) can start in parallel
- US3 (T053-T059) can start after US2 completes
- US5 (T073-T079) can start after US1, US3, US6 complete
- All Phase 9 polish tasks marked [P] can run in parallel

### Parallel Example: Foundational Phase

```bash
# Launch all model updates together:
Task T006: TeachingCourseModel
Task T007: CourseMaterialModel
Task T008: MaterialBundleModel
Task T009: CourseStructureItemModel
Task T010: UploadProgressState
Task T011: DeadlineCardModel
Task T012: EngagementMetricsModel

# Launch all BLoC scaffolds together:
Task T018: InstructorCoursesBloc
Task T019: MaterialsBloc
Task T020: CourseStructureBloc

# Launch all utility creations together:
Task T016: BundleDetector
Task T017: FileValidator
```

### Parallel Example: User Story 1

```bash
# Launch all widgets in parallel:
Task T031: CourseListCard
Task T032: CourseGridCard
Task T033: CourseCompactCard
```

### Parallel Example: User Story 2

```bash
# Launch all upload section widgets in parallel:
Task T042: VideoUploadSection
Task T043: BundleUploadSection
Task T044: UploadSelectors update
Task T045: UploadQueueCard update
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1 (Teaching Courses List)
4. **STOP and VALIDATE**: Verify live API data renders, empty state works, error state with retry
5. Demo: Instructor sees real teaching courses

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Teaching Courses) → Test independently → Demo
3. Add US2 (Upload Materials) → Test independently → Demo
4. Add US3 (Materials Library) → Test independently → Demo
5. Add US4 (Course Structure) → Test independently → Demo
6. Add US6 (Section Students) → Test independently → Demo
7. Add US5 (Course Detail) → Test independently → Demo
8. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Phase 1 + Phase 2 together
2. Once Foundational is done:
   - Developer A: US1 (Teaching Courses)
   - Developer B: US2 (Upload Materials)
   - Developer C: US4 (Course Structure)
   - Developer D: US6 (Section Students)
3. After US2 completes → Developer B or E starts US3 (Materials Library)
4. After US1, US3, US6 complete → Developer A starts US5 (Course Detail)
5. Phase 9 (Polish) after all user stories complete

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- ≥85% visual similarity is a non-negotiable gate (Constitution Principle XII)
- Zero mock/static data must remain in modified files (Constitution Principle VII)
- All upload FormData field names: `document` for docs, `video` for videos (Constitution Principle X)
- After orphan deletion (T093-T097), run `flutter analyze` + `flutter test` to verify no breakage
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
