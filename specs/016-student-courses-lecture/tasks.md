# Tasks: Student Courses & Lecture Viewer

**Input**: Design documents from `/specs/016-student-courses-lecture/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/api-contracts.md, research.md, quickstart.md

**Tests**: Included — this feature requires comprehensive testing per Constitution Principle V (Testable Architecture) and Principle VII (Static Data Elimination).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add dependencies, configure platform settings, initialize download manager

- [X] T001 Add new dependencies to pubspec.yaml (youtube_player_flutter, webview_flutter, flutter_downloader, path_provider, shared_preferences) per research.md
- [X] T002 [P] Configure Android platform settings: add internet/storage permissions to android/app/src/main/AndroidManifest.xml, enable Java 8 desugaring in android/app/build.gradle per quickstart.md
- [X] T003 [P] Configure iOS platform settings: add NSDownloadsFolderUsageDescription to ios/Runner/Info.plist per quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models, services, BLoC infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 [P] Create CourseModel in lib/features/courses/models/course_model.dart with all 15 fields, enum parsing (CourseLevel, CourseStatus), factory fromJson per data-model.md
- [X] T005 [P] Create CourseSectionModel in lib/features/courses/models/course_section_model.dart with SectionStatus enum, Schedule parsing per data-model.md
- [X] T006 Create CourseStructureModel in lib/features/courses/models/course_structure_model.dart with list parsing per data-model.md. Note: WeekStructureModel/StructureItemModel folded into single CourseStructureModel with weekNumber field — functional equivalent.
- [X] T007 [P] Create CourseMaterialModel with DriveFile nested object, MaterialType enum, helper methods (youtubeVideoId, thumbnailUrl, drivePreviewUrl) in lib/features/courses/models/course_material_model.dart per data-model.md
- [X] T008 [P] Create MaterialBundleModel with prefix matching algorithm (normalizeTitle, detectBundles, fromMaterials) in lib/features/courses/models/material_bundle_model.dart per data-model.md
- [X] T009 Update EnrollmentService to call GET /enrollments/my-courses with proper response parsing in lib/services/enrollment_service.dart per contracts/api_contracts.md
- [X] T010 Update CourseService to call GET /courses/{id}/structure with proper response parsing in lib/services/course_service.dart per contracts/api_contracts.md
- [X] T011 Update MaterialService to call GET /courses/{id}/materials and POST /materials/{id}/view with proper request/response handling in lib/services/material_service.dart per contracts/api_contracts.md
- [X] T012 Configure API timeout settings in CoreApiClient: 10s for standard endpoints, 30s for material-related calls per spec.md clarifications

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 1 — View Enrolled Courses List (Priority: P1) 🎯 MVP

**Goal**: Student sees live enrolled courses from backend with course code, name, instructor, schedule info. Tapping a course opens tabbed detail screen.

**Independent Test**: Can be fully tested by fetching enrolled courses from API and displaying them in a list. Delivers immediate value by showing students their real course roster. Verifiable by: course list loads in <2s, shows real data, tapping course opens detail screen with tabs.

### Tests for User Story 1

- [X] T013 [P] [US1] Write unit tests for EnrollmentService.getMyCourses() mocking Dio response in tests/unit/features/courses/services/enrollment_service_test.dart
- [X] T014 [P] [US1] Write unit tests for CourseListBloc (loading → loaded → error states) in test/bloc/course_list_bloc_test.dart
- [X] T015 [P] [US1] Write widget test for CourseListScreen showing loading, loaded, error states in test/widgets/course_list_screen_test.dart

### Implementation for User Story 1

- [X] T016 [US1] Create CourseListState class with courses, isLoading, error, hasMore, currentPage fields in lib/features/courses/bloc/course_list/course_list_state.dart
- [X] T017 [US1] Create CourseListEvent classes (FetchCourses, RefreshCourses) in lib/features/courses/bloc/course_list/course_list_event.dart
- [X] T018 [US1] Create CourseListBloc that calls EnrollmentService.getMyCourses(), emits loading/loaded/error states in lib/features/courses/bloc/course_list/course_list_bloc.dart
- [X] T019 [US1] Create CourseListScreen with BlocBuilder showing loading indicator, course list, or empty state in lib/features/courses/screens/course_list_screen.dart
- [X] T020 [P] [US1] Create CourseCard widget displaying course code, name, instructor, schedule info with 48x48px touch target in lib/widgets/student/course_list/course_card.dart
- [X] T021 [P] [US1] Create EmptyCoursesMessage widget with friendly guidance text in lib/widgets/student/course_list/empty_courses_message.dart
- [X] T022 [US1] Wire CourseListScreen tap navigation: tapping course pushes CourseDetailScreen in lib/features/courses/screens/course_list_screen.dart
- [X] T023 [US1] Replace static/hardcoded course list with BlocBuilder<CoursesBloc> in lib/screens/student/courses_screen.dart per Constitution Principle VII

**Checkpoint**: Student can view enrolled courses from live API, tap to enter course detail. US1 independently testable.

---

## Phase 4: User Story 2 — Browse Course Structure with Week-Based Accordion (Priority: P2)

**Goal**: Student sees course structure organized by week in expandable accordion. Materials grouped with type badges. Bundles detected via prefix matching.

**Independent Test**: Can be fully tested by fetching course structure from GET /courses/{id}/structure and displaying materials grouped by week. Verifiable by: accordion expands/collapses, materials show type badges, bundles grouped correctly, first week auto-expanded.

### Tests for User Story 2

- [X] T024 [P] [US2] Write unit tests for CourseService.getCourseStructure() mocking Dio response in tests/unit/features/courses/services/course_service_test.dart
- [X] T025 [P] [US2] Write unit tests for MaterialBundleModel.detectBundles() with various title patterns in tests/unit/features/courses/models/material_bundle_model_test.dart
- [X] T026 [P] [US2] Write unit tests for CourseDetailBloc (fetch structure, expand week, switch tab) in tests/unit/features/courses/bloc/course_detail_bloc_test.dart
- [X] T027 [P] [US2] Write widget test for WeekAccordion expand/collapse behavior in tests/widget/features/courses/week_accordion_test.dart
- [X] T028 [P] [US2] Write widget test for BundleViewer grouping logic display in tests/widget/features/courses/bundle_viewer_test.dart

### Implementation for User Story 2

- [X] T029 [US2] Create CourseDetailState with course, structure, materials, bundles, selectedWeekIndex, isLoadingStructure, isLoadingMaterials, error, selectedTabIndex fields in lib/features/courses/bloc/course_detail/course_detail_state.dart
- [X] T030 [US2] Create CourseDetailEvent classes (LoadCourseDetail, LoadStructure, LoadMaterials, ExpandWeek, SwitchTab) in lib/features/courses/bloc/course_detail/course_detail_event.dart
- [X] T031 [US2] Create CourseDetailBloc that calls CourseService.getStructure(), MaterialService.getMaterials(), runs bundle detection, emits states in lib/features/courses/bloc/course_detail/course_detail_bloc.dart
- [X] T032 [US2] Create CourseDetailScreen with TabBar (Structure, Materials, Progress) and TabBarView in lib/features/courses/screens/course_detail_screen.dart
- [X] T033 [US2] Implement Structure tab content: WeekAccordion list with auto-expand first week (FR-016) in lib/widgets/student/course_details/course_tab_content.dart (replace mock data)
- [X] T034 [P] [US2] Create WeekAccordion widget with expandable sections showing week number, title, material count in lib/widgets/student/course_details/week_accordion.dart
- [X] T035 [P] [US2] Create MaterialCard widget with type badges (VIDEO/DOCUMENT/LINK/TEXT), YouTube thumbnails (img.youtube.com/vi/{videoId}/mqdefault.jpg), view/download counts in lib/widgets/student/course_details/material_card.dart
- [X] T036 [P] [US2] Create BundleViewer widget that groups materials by prefix matching, shows video as primary with companion docs list in lib/widgets/student/course_details/bundle_viewer.dart
- [X] T037 [US2] Implement local caching for course structure using shared_preferences (key: course_structure_{courseId}_{hash}, TTL 7 days, max 10 courses) in lib/features/courses/services/course_service.dart
- [X] T038 [US2] Replace static/mock week modules in existing course_tab_content.dart with BlocBuilder<CourseDetailBloc> per Constitution Principle VII
- [ ] T039 [P] [US2] Implement lazy-loading for week accordion sections: fetch week materials only when expanded, show loading skeleton during fetch (covers edge case: 20+ weeks performance) — NOTE: loading skeleton exists in course_tab_content.dart, but week-level lazy fetch not yet implemented

**Checkpoint**: Student can browse course structure by week, see materials with type badges, view bundles. US2 independently testable.

---

## Phase 5: User Story 3 — Watch Lecture Videos (Priority: P3)

**Goal**: Student taps video material → YouTube video plays in embedded player with standard controls. View tracked automatically.

**Independent Test**: Can be fully tested by tapping a video material and verifying YouTube playback in embedded player with play/pause/seek/fullscreen controls. Verifiable by: 95% of videos play on first attempt, view recorded via POST /materials/{id}/view, player adjusts on orientation change.

### Tests for User Story 3

- [X] T040 [P] [US3] Write unit tests for MaterialService.recordView() mocking POST response, verifying 99% tracking accuracy (covers SC-008) in tests/unit/features/courses/services/material_service_test.dart
- [X] T041 [P] [US3] Write unit tests for MaterialViewerBloc (play video → record view → loaded state) in tests/unit/features/courses/bloc/material_viewer_bloc_test.dart
- [X] T042 [P] [US3] Write widget test for VideoPlayerWidget showing player and controls in tests/widget/features/courses/video_player_widget_test.dart

### Implementation for User Story 3

- [X] T043 [US3] Create MaterialViewerState with currentMaterial, isViewRecorded, isLoading, error, isDownloading, downloadProgress, downloadedFilePath fields in lib/features/courses/bloc/material_viewer/material_viewer_state.dart
- [X] T044 [US3] Create MaterialViewerEvent classes (PlayVideo, RecordView, DownloadMaterial) in lib/features/courses/bloc/material_viewer/material_viewer_event.dart
- [X] T045 [US3] Create MaterialViewerBloc that calls MaterialService.recordView() on video play, emits states in lib/features/courses/bloc/material_viewer/material_viewer_bloc.dart
- [X] T046 [US3] Create VideoPlayerWidget using youtube_player_flutter package: extract videoId from externalUrl, embed player with controls (play, pause, seek, fullscreen) in lib/widgets/student/course_details/video_player_widget.dart
- [X] T047 [US3] Add orientation handling: VideoPlayerWidget adjusts to landscape filling wider screen in lib/widgets/student/course_details/video_player_widget.dart
- [X] T048 [US3] Wire view tracking: call POST /materials/{id}/view when student taps to play video, show updated view count in lib/features/courses/bloc/material_viewer/material_viewer_bloc.dart
- [X] T049 [US3] Add error handling for unavailable videos (deleted/private): show "Video unavailable — contact instructor" message in lib/widgets/student/course_details/video_player_widget.dart

**Checkpoint**: Student can watch lecture videos with embedded YouTube player, views tracked. US3 independently testable.

---

## Phase 6: User Story 4 — View and Download Course Documents (Priority: P4)

**Goal**: Student taps document material → Google Drive preview opens inline in WebView. Student can download for offline access.

**Independent Test**: Can be fully tested by tapping a document material and verifying Google Drive preview renders in WebView with download button. Verifiable by: document previews in <2s, download shows progress, downloaded file accessible offline.

### Tests for User Story 4

- [X] T050 [P] [US4] Write widget test for DocumentPreviewWidget showing WebView preview in tests/widget/features/courses/document_preview_widget_test.dart
- [X] T051 [P] [US4] Write integration test for download flow: start → progress → complete → file exists in tests/integration/features/courses/material_download_test.dart

### Implementation for User Story 4

- [X] T052 [P] [US4] Add file size/type validation before download: validate documents ≤50MB (pdf, doc, docx, ppt, pptx, xls, xlsx, txt, md, zip), images ≤10MB (jpg, jpeg, png, gif, webp, svg) per Constitution Principle X in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T053 [US4] Create DocumentPreviewWidget using webview_flutter: construct Drive preview URL (https://drive.google.com/file/d/{driveId}/preview), enable JavaScript, render in WebView in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T054 [US4] Add zoom/scroll gesture support for document preview in DocumentPreviewWidget using WebView's native gesture handling in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T055 [US4] Implement download button on document material card: call flutter_downloader with material.file.downloadUrl, show progress in UI in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T056 [US4] Handle download completion: save file path via path_provider, update MaterialViewerState.downloadedFilePath, show success notification in lib/features/courses/bloc/material_viewer/material_viewer_bloc.dart
- [X] T057 [US4] Add error handling for Drive permission denied: show "Access denied — contact instructor to grant access" message in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T058 [US4] Implement storage permission request for Android (runtime permission) before download in lib/widgets/student/course_details/document_preview_widget.dart
- [X] T059 [US4] Create DownloadsList widget showing previously downloaded materials for offline access in lib/widgets/student/course_details/downloads_list.dart
- [X] T060 [US4] Replace static material lists in existing widgets with live API data per Constitution Principle VII

**Checkpoint**: Student can preview and download course documents. US4 independently testable.

---

## Phase 7: User Story 5 — Track Material Views and See Progress (Priority: P5)

**Goal**: Student sees which materials they've accessed. Progress indicators show engagement with course content.

**Independent Test**: Can be fully tested by viewing materials and confirming view tracking records views with 99% accuracy, progress indicators update on UI. Verifiable by: viewed materials marked, progress tab shows accurate counts.

### Tests for User Story 5

_Note: View tracking test already covered in T040 (US3 phase). No additional test needed for this endpoint._

### Implementation for User Story 5

- [X] T061 [US5] Create ProgressIndicator widget showing: total materials, viewed materials count, percentage progress bar in lib/widgets/student/progress/progress_indicator.dart
- [X] T062 [US5] Implement viewed materials tracking: set hasBeenViewed=true in CourseMaterialModel when view recorded, persist in local cache (shared_preferences key: material_viewed_{materialId}) in lib/services/api/material_service.dart
- [X] T063 [US5] Implement Progress tab content in CourseDetailScreen: show ProgressIndicator with per-week breakdown (viewed/total materials per week) in lib/features/courses/screens/course_detail_screen.dart
- [X] T064 [US5] Display view count and download count badges on MaterialCard in lib/widgets/student/course_details/material_card.dart
- [X] T065 [US5] Replace any remaining static enrollment/progress data with live API data per Constitution Principle VII — verified: no static data in Phase 2 files

**Checkpoint**: Student can track material views and see progress indicators. US5 independently testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Responsive testing, mock data elimination audit, unused file cleanup, code quality, accessibility validation

**Dependencies**: MUST run AFTER all user stories (Phases 3-7) are complete

- [ ] T066 [P] Responsive testing at 375px (mobile portrait): verify all layouts, touch targets ≥48x48px, no horizontal scroll per spec.md SC-005, SC-006
- [ ] T067 [P] Responsive testing at 768px (tablet portrait): verify 2-column grids where applicable, adaptive card layouts
- [ ] T068 [P] Responsive testing at 1024px+ (desktop): verify multi-column grids, full data tables visible
- [ ] T069 [P] Text scaling verification: test all screens at 1.0x, 1.3x text scale ensuring no layout breakage (covers FR-017)
- [X] T070 Run mock data elimination audit: grep for _generateSample, _mockCourses, _mockAssignments, Duration(hours:, setState bypasses, TODO: Replace with API in all modified files — all must return zero results per Constitution Principle VII
- [X] T071 Identify and delete unused TA course files from pre-backend-integration era: search for files matching patterns `ta_courses*`, `ta_course_detail*`, `ta_labs*`, `ta_lab_detail*` in lib/widgets/student/ and lib/screens/student/, verify no website equivalent in Courses_Assignments_Labs_Frontend_Documentation.md, delete confirmed orphan screens — update imports and run flutter analyze
- [ ] T072 UX flow validation: verify core workflow (view courses → select course → watch lecture) completes in 4 taps or fewer (covers SC-007)
- [ ] T073 Performance profiling: use Flutter DevTools to verify 60fps scrolling with 20+ weeks of materials, profile build times (covers SC-009)
- [ ] T074 Run flutter analyze and fix all warnings
- [X] T075 Run dart format . to format all modified files
- [X] T076 Run full test suite: flutter test — verify all unit, widget, integration tests pass
- [ ] T077 Run quickstart.md validation: follow quickstart.md steps 1-8, verify all pass

**Note on Constitution Principle X (File Upload & Google Drive/YouTube Integration)**: Phase 2 is **view-only** (student role). Client-side file validation for uploads (size limits, allowed types) is **out of scope** for this phase and will be addressed in instructor/TA phases (Phases 5-7 per integration plan). Download validation (T052) is included here.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — **BLOCKS all user stories**
- **User Stories (Phases 3-7)**: All depend on Foundational phase completion
  - Can proceed sequentially (P1 → P2 → P3 → P4 → P5) or in parallel if team capacity allows
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) — Depends on US1's CourseDetailScreen shell (tabbed interface)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) — Integrates with US2's MaterialCard (tap to play video)
- **User Story 4 (P4)**: Can start after Foundational (Phase 2) — Integrates with US2's MaterialCard (tap to preview document)
- **User Story 5 (P5)**: Can start after Foundational (Phase 2) — Integrates with US2/US3/US4's view tracking

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models before services
- Services before BLoCs
- BLoCs before screens/widgets
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel (T002, T003)
- All Foundational model tasks marked [P] can run in parallel (T004-T008)
- All User Story tests marked [P] can run in parallel within that story
- All widgets within a story marked [P] can run in parallel (different files)
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task T013: "Write unit tests for EnrollmentService in tests/unit/.../enrollment_service_test.dart"
Task T014: "Write unit tests for CourseListBloc in tests/unit/.../course_list_bloc_test.dart"
Task T015: "Write widget test for CourseListScreen in tests/widget/.../course_list_screen_test.dart"

# Launch all widgets for User Story 1 together:
Task T020: "Create CourseCard widget in lib/widgets/student/course_list/course_card.dart"
Task T021: "Create EmptyCoursesMessage widget in lib/widgets/student/course_list/empty_courses_message.dart"
```

---

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together:
Task T024: "Write unit tests for CourseService in tests/unit/.../course_service_test.dart"
Task T025: "Write unit tests for MaterialBundleModel in tests/unit/.../material_bundle_model_test.dart"
Task T026: "Write unit tests for CourseDetailBloc in tests/unit/.../course_detail_bloc_test.dart"
Task T027: "Write widget test for WeekAccordion in tests/widget/.../week_accordion_test.dart"
Task T028: "Write widget test for BundleViewer in tests/widget/.../bundle_viewer_test.dart"

# Launch all widgets for User Story 2 together:
Task T034: "Create WeekAccordion widget in lib/widgets/student/course_details/week_accordion.dart"
Task T035: "Create MaterialCard widget in lib/widgets/student/course_details/material_card.dart"
Task T036: "Create BundleViewer widget in lib/widgets/student/course_details/bundle_viewer.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (3 tasks)
2. Complete Phase 2: Foundational (9 tasks) — **CRITICAL — blocks all stories**
3. Complete Phase 3: User Story 1 (10 tasks)
4. **STOP and VALIDATE**: Test enrolled courses list loads from API, tapping opens detail screen
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP: students see real courses!)
3. Add User Story 2 → Test independently → Deploy/Demo (students browse structure!)
4. Add User Story 3 → Test independently → Deploy/Demo (students watch videos!)
5. Add User Story 4 → Test independently → Deploy/Demo (students preview/download docs!)
6. Add User Story 5 → Test independently → Deploy/Demo (students track progress!)
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (P1) — Course list
   - Developer B: User Story 2 (P2) — Course structure
   - Developer C: User Story 3 (P3) — Video player
3. After US1-3 complete:
   - Developer A: User Story 4 (P4) — Document preview
   - Developer B: User Story 5 (P5) — Progress tracking
   - Developer C: Phase 8 Polish & cleanup
4. Stories complete and integrate independently

---

## Mock Data Elimination Targets (Constitution Principle VII)

The following patterns MUST be searched for and eliminated in all modified files:

```bash
grep -r "_generateSample" lib/features/courses/ lib/widgets/student/
grep -r "_mockCourses\|_mockAssignments\|_mockLabs\|_mockMaterials" lib/
grep -r "_simulateReply\|_mockMessages" lib/widgets/student/
grep -r "Duration(hours:\|Duration(minutes:" lib/features/courses/ lib/widgets/student/
grep -r "setState(() =>" lib/features/courses/ lib/widgets/student/ | grep -v "BLoC-triggered"
grep -r "TODO: Replace with API" lib/features/courses/ lib/widgets/student/
grep -r "static.*List<Course>\|static.*List<Material>" lib/
```

**Verification**: All commands must return **zero results** before Phase 8 is complete.

---

## Unused File Cleanup Targets

Before completing Phase 8, identify and delete:

1. **Orphan student screens**: Any screen in `lib/screens/student/` or `lib/widgets/student/` that has no equivalent in the website frontend (`Courses_Assignments_Labs_Frontend_Documentation.md`)
2. **Static data generators**: Any `_generateSample*` functions in student course widgets
3. **Unused BLoCs/Cubits**: Any BLoC not referenced by the new feature architecture
4. **Duplicate models**: Any old model files replaced by the new `lib/features/courses/models/` models
5. **Legacy services**: Any service file replaced by the new `lib/features/courses/services/` services

**Process**:
1. Cross-reference existing Flutter student screens with website feature docs
2. Mark screens as "DELETE" if no website equivalent exists (except mobile-specific patterns like pull-to-refresh)
3. Verify no imports reference files marked for deletion
4. Delete files and update imports
5. Run `flutter analyze` to confirm no broken imports

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [US1]-[US5] labels map task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- **CRITICAL**: Constitution Principle VII — zero mock/static data remaining is a hard gate
- **CRITICAL**: Constitution Principle IX — student role is READ-ONLY only, no CRUD buttons visible
- All responsive layouts must support 375px, 768px, 1024px+ breakpoints
- All touch targets minimum 48x48px on mobile and tablet
