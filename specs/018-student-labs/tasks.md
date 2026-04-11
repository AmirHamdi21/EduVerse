# Tasks: Student Labs Integration

**Input**: Design documents from `/specs/018-student-labs/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api-contracts.md
**Tests**: Yes — unit tests for Cubits, widget tests for screens/sheets
**Organization**: Tasks grouped by user story for independent implementation and testing

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- Source: `lib/` at repository root
- Tests: `tests/` at repository root
- Single Flutter project structure

---

## Phase 1: Setup (Dependencies)

**Purpose**: Add required Flutter packages for this feature

- [ ] T001 Add `flutter_markdown: ^0.6.18` and `file_picker: ^6.1.1` to `pubspec.yaml` and run `flutter pub get`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model and state cleanup that ALL user stories depend on. MUST complete before any user story work begins.

- [ ] T002 [P] Clean `LabModel` in `lib/models/labs/lab_model.dart` — remove legacy UI-only fields (`courseName`, `courseCode`, `instructorName`, `location`, `virtualLink`, `type`/`LabType`, `scheduledDate`, `duration`, `materials`, `objectives`, `isBookmarked`), keep all backend API fields, ensure `fromJson` maps all backend response fields, update `toJson` accordingly
- [ ] T003 [P] Fix `LabSubmissionModel` in `lib/models/labs/lab_submission_model.dart` — ensure `isLate` parses as boolean with safe fallback: `json['isLate'] is bool ? json['isLate'] as bool : (json['isLate'] as num?) == 1`; ensure `score` parses via `double.tryParse(value.toString())`; ensure `status` field maps from `submissionStatus` or `status` JSON key with `SubmissionStatus.fromString(... orElse: SubmissionStatus.unknown)`
- [ ] T004 Update `LabsState` in `lib/bloc/labs/labs_state.dart` — add `selectedCourseId` (int?), `enrolledCourses` (List<CourseModel>), `selectedCourse` (CourseModel?) fields; update constructor, props, and `copyWith` method; update `filteredLabs` getter to filter by `selectedCourseId`; update computed getters (`upcomingCount`, `inProgressCount`, `completedCount`, `missedCount`) to use backend `LabStatus` (published/closed/archived) and due date logic instead of legacy enum values: `published` + future due → upcoming, `published` + past due → in progress/missed, `closed` → completed
- [ ] T005 Add computed properties to cleaned `LabModel`: `isPastDue`, `isAcceptingSubmissions`, `formattedDueDate`, `daysUntilDue` in `lib/models/labs/lab_model.dart`

**Checkpoint**: Foundation ready — LabsCubit rewiring and all user stories can begin

---

## Phase 3: User Story 1 — Browse and View Labs List (Priority: P1) 🎯 MVP

**Goal**: Student sees enrolled courses in a dropdown, selects one, and views its labs from the live backend API with correct metadata and status badges. No mock data.

**Independent Test**: Enroll a student in a course with published labs, navigate to Labs screen, select the course, and verify labs list displays correctly with title, lab number, due date, max score, and status badge. Empty state shows for courses with no labs.

### Tests for User Story 1

- [ ] T006 [P] [US1] Write unit test for `LabsCubit.loadEnrolledCourses()` in `tests/unit/bloc/labs/labs_cubit_test.dart` — verify it calls `EnrollmentService.getMyCourses()` and emits state with enrolled courses
- [ ] T007 [P] [US1] Write unit test for `LabsCubit.selectCourse(courseId)` in `tests/unit/bloc/labs/labs_cubit_test.dart` — verify it calls `LabService.getAll(courseId: courseId)` and emits loaded state with labs
- [ ] T008 [P] [US1] Write unit test for `LabsState.filteredLabs` in `tests/unit/bloc/labs/labs_state_test.dart` — verify filtering by selected course, search query, status filter, and sorting all work correctly
- [ ] T009 [US1] Write unit test for `LabsCubit` error handling in `tests/unit/bloc/labs/labs_cubit_test.dart` — verify API failure emits error state with correct error message

### Implementation for User Story 1

- [ ] T010 Rewrite `LabsCubit` in `lib/bloc/labs/labs_cubit.dart` — remove `_generateDemoLabs()` and all demo data generation methods; add `loadEnrolledCourses()` that calls `EnrollmentService.getMyCourses()`, emits state with enrolled courses, and auto-selects first course; add `selectCourse(courseId)` that calls `LabService.getAll(courseId: courseId)` and emits loaded state; keep existing `setSearchQuery`, `setFilter`, `clearFilters`, `setSortBy`, `setSelectedTab` methods (they already work with `filteredLabs` getter); inject `EnrollmentService` and `LabService` into constructor
- [ ] T011 Update `LabsScreen` in `lib/screens/student/labs_screen.dart` — replace existing tab-based filter logic with course selector dropdown at top of screen (populated from `LabsState.enrolledCourses`); wire `BlocBuilder` to display labs from `state.filteredLabs` (live API data); add loading builder showing progress indicator while `state.isLoading` is true; add error builder with retry button when `state.error` is not null; add empty state builder showing "No labs available" when `state.filteredLabs.isEmpty` and not loading; update tab stat counters to map backend statuses to display categories: `published` + future due date → "Upcoming" count, `published` + past due date → "In Progress" or "Missed" count, `closed` → "Completed" count; update LabsState computed getters if needed to use backend `LabStatus` (published/closed/archived) instead of legacy enum values
- [ ] T012 Update `LabCard` in `lib/widgets/student/labs/lab_card.dart` — update to use cleaned `LabModel` backend-facing fields (replace legacy `courseName`/`courseCode` with `lab.course?.code`/`lab.course?.name`; replace legacy `LabStatus` upcoming/inProgress/completed/missed with backend `LabStatus` published/closed/archived mapped to display labels); preserve all existing visual design (colors, padding, border radius, typography); update status badge logic: `published` → green "Active" badge, `closed` → gray "Closed" badge, `archived` → muted "Archived" badge; show due date via `lab.formattedDueDate`, show days-until via `lab.daysUntilDue`; remove bookmark button (per research.md Decision 1: bookmark is legacy UI-only field with no backend equivalent)
- [ ] T013 Wire `LabCard` tap handler in `LabsScreen` to navigate to `LabDetailScreen` (full screen, not bottom sheet) — push `Navigator.push(context, MaterialPageRoute(builder: (_) => LabDetailScreen(labId: lab.id, lab: lab)))` passing the selected lab model

**Checkpoint**: At this point, the student can browse enrolled courses, select one, and see its labs from the live API. Tapping a lab navigates to the detail screen (placeholder for now). Independently testable.

---

## Phase 4: User Story 2 — View Lab Instructions and Materials (Priority: P2)

**Goal**: Student opens a lab detail screen showing full metadata, ordered text instructions (markdown rendered), instruction file grid with Open/Download buttons, WebView file previews, and attendance badge if present.

**Independent Test**: Select any lab from the list, verify the full-screen detail view opens with lab title/metadata, text instructions render with markdown formatting, instruction files display in a grid with working Open/Download buttons, file previews load in WebView, and attendance badge shows if marked present.

### Tests for User Story 2

- [ ] T014 [P] [US2] Write unit test for `LabDetailCubit.loadLab(labId)` in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify it calls `LabService.getById(labId)` and emits loaded state with lab details
- [ ] T015 [P] [US2] Write unit test for `LabDetailCubit.loadInstructions(labId)` in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify it calls `LabService.getInstructions(labId)` and emits state with ordered instructions
- [ ] T016 [US2] Write unit test for `LabDetailCubit` error handling in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify API failure emits error state
- [ ] T017 [P] [US2] Write widget test for `InstructionViewer` in `tests/widget/student/labs/instruction_viewer_test.dart` — verify markdown text renders, file grid shows Open/Download buttons, empty state displays when no instructions; also test attendance badge renders in `LabDetailScreen` when `attendanceStatus == LabAttendanceStatus.present` (FR-007)

### Implementation for User Story 2

- [ ] T018 [P] [US2] Create `LabDetailState` in `lib/bloc/lab_detail/lab_detail_state.dart` — define states: `LabDetailInitial`, `LabDetailLoading`, `LabDetailLoaded` (with lab, instructions, attendanceStatus, mySubmissions), `LabDetailError` (with message); include `isLoadingInstructions`, `isLoadingSubmissions` flags for progressive loading
- [ ] T019 [P] [US2] Create `LabDetailCubit` in `lib/bloc/lab_detail/lab_detail_cubit.dart` — inject `LabService`, `EnrollmentService`; implement `loadLab(labId)` calling `LabService.getById(labId)`; implement `loadInstructions(labId)` calling `LabService.getInstructions(labId)`; implement `loadMySubmissions(labId)` calling `LabService.getMySubmission(labId)` (returns array); implement `loadAttendance(labId)` calling `LabService.getAttendance(labId)` for FR-007 attendance badge; implement `checkEnrollment(courseId)` — verify student has `status == EnrollmentStatus.enrolled` for the lab's course using cached enrolled courses from LabsCubit (avoid re-fetching via `EnrollmentService.getMyCourses()`); inject `LabService` into constructor
- [ ] T020 [P] [US2] Create `InstructionViewer` widget in `lib/widgets/student/labs/instruction_viewer.dart` — accepts `List<LabInstructionModel>`, sorts by `orderIndex` ascending; for text instructions (`instructionText != null`), renders `MarkdownBody` from `flutter_markdown` package; for file instructions (`file != null`), renders card with `file.fileName`, "Open" button (launches `file.webViewLink` in browser), "Download" button (launches `file.downloadUrl`), and "Preview" button (opens WebView dialog with `file.iframeUrl`); uses responsive layout: single column on mobile, 2-column grid on tablet
- [ ] T021 Create `LabDetailScreen` in `lib/screens/student/lab_detail_screen.dart` — accepts `labId`, optional pre-fetched `LabModel`, and `enrolledCourses` (passed from LabsScreen via BlocBuilder on LabsCubit state for enrollment validation); wraps in `BlocProvider` with `LabDetailCubit`; calls `cubit.loadLab(labId)`, then `cubit.loadInstructions(labId)`, then `cubit.loadAttendance(labId)`, then `cubit.loadMySubmissions(labId)`; displays AppBar with lab title; shows lab metadata section (lab number, due date, max score, weight, status badge); renders `InstructionViewer` for instructions; shows attendance badge if `attendanceStatus == LabAttendanceStatus.present`; shows "Submit Work" button if `lab.isAcceptingSubmissions` is true, disabled/hidden if `lab.status == LabStatus.closed || lab.status == LabStatus.archived`; preserves existing app colors and theme (≥85% visual similarity to lab list screen); handles loading and error states
- [ ] T022 Wire file preview WebView in `InstructionViewer` — when user taps "Preview" on a file instruction, show a modal bottom sheet with `WebView` widget loading `file.iframeUrl`; add loading indicator and error state with "Open in Drive" fallback link; ensure JavaScript is enabled in WebView settings; show size warning for files >50MB indicating preview may take time to load (spec edge case)
- [ ] T023 [P] [US2] Ensure `LabDetailScreen` and `LabSubmissionSheet` are fully responsive across mobile (<600px), tablet (600px-1024px), and desktop (>1024px) viewports — use `LayoutBuilder`/`MediaQuery` for adaptive layouts; single-column on mobile, multi-column grids on tablet; all touch targets ≥48x48px; no horizontal scrolling (FR-021)

**Checkpoint**: At this point, the student can view complete lab instructions (text + files) in a full-screen detail view. Independently testable from US1 (can be tested by directly navigating to LabDetailScreen with a known lab ID).

---

## Phase 5: User Story 3 — Submit Lab Work (Priority: P3)

**Goal**: Student submits lab work via text input and/or file upload using a bottom sheet form. Submission is sent to backend with proper FormData or JSON. Late submissions show warning. Closed/archived labs prevent submission. Frontend validates enrollment before submission.

**Independent Test**: Open a published lab, tap "Submit Work", fill in text and/or upload a file, submit, and verify the backend records the submission. Verify late warning shows for past-due labs. Verify submission is blocked for closed/archived labs.

### Tests for User Story 3

- [ ] T024 [P] [US3] Write unit test for `LabDetailCubit.submitText(labId, text)` in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify it calls `LabService.submit(labId, submissionText: text)` and emits submitted state
- [ ] T025 [P] [US3] Write unit test for `LabDetailCubit.submitFile(labId, file)` in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify it calls `LabService.submitFile(labId, file)` and emits submitted state
- [ ] T026 [US3] Write unit test for `SubmissionEventTracker.logSubmission()` in `tests/unit/utils/submission_event_tracker_test.dart` — verify it logs timestamp, lab ID, success status to shared_preferences
- [ ] T027 [US3] Write unit test for `SubmissionEventTracker.logFailure()` in `tests/unit/utils/submission_event_tracker_test.dart` — verify it logs error details; test `getSuccessRate()` returns correct percentage
- [ ] T028 [P] [US3] Write widget test for `LabSubmissionSheet` in `tests/widget/student/labs/lab_submission_sheet_test.dart` — verify text input and file picker UI render, submit button disabled when empty, late warning shows when applicable

### Implementation for User Story 3

- [ ] T029 [P] [US3] Create `SubmissionEventTracker` utility in `lib/utils/submission_event_tracker.dart` — uses `SharedPreferences` for persistence; implement `logSubmission(labId)` storing `{timestamp, labId, success: true}`; implement `logSubmissionFailure(labId, error)` storing `{timestamp, labId, success: false, error}`; implement `getEvents()` returning all events as list; implement `getSuccessRate()` returning `(successCount / totalCount * 100)`; implement `_pruneOldEvents()` removing events older than 30 days on each write; use JSON encoding for storage
- [ ] T030 [P] [US3] Create `LabSubmissionSheet` widget in `lib/widgets/student/labs/lab_submission_sheet.dart` — modal bottom sheet with: text input section (expandable `ExpansionTile` containing multiline `TextFormField` for `submissionText`, expanded by default); file upload section (expandable `ExpansionTile` containing "Choose File" button using `FilePicker`, showing selected file name and size, collapsed by default; with file type/size validation: documents max 50MB, supported types: pdf/doc/docx/ppt/pptx/xls/xlsx/txt/md/zip — reject files with unrecognized extensions or MIME types with a clear error message before upload attempt); "Submit" button at bottom; if `lab.isPastDue` is true, show orange warning banner: "This lab is past the due date. Your submission will be marked as late."; show loading indicator during submission; on success, pop sheet and show success SnackBar; on error, show error SnackBar with retry option; accept `lab` (LabModel), `onSubmitText` callback, `onSubmitFile` callback, `isSubmitting` state
- [ ] T031 Wire submission methods in `LabDetailCubit` — add `submitText(labId, text)` calling `LabService.submit(labId, submissionText: text)`, then `SubmissionEventTracker.logSubmission(labId)` on success or `logSubmissionFailure(labId, error)` on failure, then reload my submissions; add `submitFile(labId, filePath)` calling `LabService.submitFile(labId, file)` with `Dio.FormData` and `MultipartFile.fromFile()` (Constitution Principle X: do NOT manually set Content-Type header — Dio auto-generates multipart boundary), track progress via `onSendProgress` emitted to UI state, then same event tracking and reload logic
- [ ] T032 Wire "Submit Work" button in `LabDetailScreen` to open `LabSubmissionSheet` — `showModalBottomSheet(context, builder: (_) => LabSubmissionSheet(lab: lab, onSubmitText: cubit.submitText, onSubmitFile: cubit.submitFile))`; on submission success, trigger `BlocListener` to show success SnackBar and refresh submission history; on failure, show error SnackBar with retry option
- [ ] T033 Implement frontend enrollment validation gating in `LabDetailCubit` — gate `submitText()` and `submitFile()` methods behind the `checkEnrollment(courseId)` validation already defined in T019 (which uses cached enrolled courses from LabsCubit, avoiding re-fetch); if not enrolled, emit error state with message "You must be enrolled in this course to submit lab work" before attempting submission (FR-012)

**Checkpoint**: At this point, the student can submit lab work (text and/or file) with late warnings and enrollment validation. Independently testable from US1/US2 (can test submission by directly opening LabSubmissionSheet with a known lab).

---

## Phase 6: User Story 4 — View Submission Grades and Feedback (Priority: P4)

**Goal**: Student sees all their submission attempts for a lab with scores, feedback, submission dates, late indicators, and graded status. Multiple attempts are distinguishable.

**Independent Test**: Submit lab work, have it graded by an instructor, then verify the student can see their score (e.g., "85/100"), feedback text, graded date, and "Graded" badge. Ungraded submissions show "Submitted" status with date. Multiple attempts are all visible.

### Tests for User Story 4

- [ ] T034 [P] [US4] Write unit test for `LabDetailCubit.loadMySubmissions(labId)` in `tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart` — verify it calls `LabService.getMySubmission(labId)` and emits state with submission attempts list
- [ ] T035 [P] [US4] Write widget test for `SubmissionHistoryView` in `tests/widget/student/labs/submission_history_view_test.dart` — verify graded submissions show score/feedback, pending submissions show status badge, late submissions show "Late" indicator, multiple attempts render as distinct cards

### Implementation for User Story 4

- [ ] T036 [P] [US4] Create `SubmissionHistoryView` widget in `lib/widgets/student/labs/submission_history_view.dart` — accepts `List<LabSubmissionModel>` and `maxScore` (double); renders each attempt as a card showing: submission date (`formattedSubmittedAt`), status badge (`submitted` → blue "Submitted", `graded` → green "Graded", `returned` → orange "Returned", `resubmit` → purple "Resubmit"), late indicator (`isLate == true` → red "Late" badge), score display (`scoreDisplay` like "85.0 / 100" if graded), feedback text (if `feedback != null`), submission text preview (truncated if `submissionText` exists), file info (if `driveFile != null`, show file name with download link); sort attempts by `submittedAt` descending (newest first); show "No submissions yet" empty state if list is empty
- [ ] T037 Integrate `SubmissionHistoryView` into `LabDetailScreen` — add an expandable "My Submissions" section below the instructions and Submit button; use `BlocBuilder` to read `state.mySubmissions` from `LabDetailLoaded` state; render `SubmissionHistoryView(submissions: state.mySubmissions, maxScore: lab.maxScore)`; section should be collapsible (initially collapsed if no graded submissions, expanded if graded submissions exist)

**Checkpoint**: All 4 user stories are complete. Student can browse labs, view instructions, submit work, and see grades/feedback. Full labs workflow functional end-to-end.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Mock data elimination audit, orphan file cleanup, visual parity verification, and final quality checks

- [ ] T038 Mock data audit — grep all modified files for residual patterns: `_generateDemoLabs`, `_generateSample`, `_mockLabs`, `_mockAssignments`, `Duration(hours:`, `Duration(minutes:`, `setState(() =>` bypassing BLoC, hardcoded `List<Lab>` literals, `TODO: Replace with API` comments; verify ZERO residuals in `lib/bloc/labs/labs_cubit.dart`, `lib/screens/student/labs_screen.dart`, `lib/widgets/student/labs/lab_card.dart`, `lib/models/labs/lab_model.dart`
- [ ] T039 Delete orphan file `lib/widgets/student/labs/lab_details_sheet.dart` — replaced by `LabDetailScreen` (full screen); grep for all imports of `lab_details_sheet.dart` across `lib/` directory; if imports exist in other files, either update import to reference `LabDetailScreen` or confirm the importing file is also being deleted; verify zero remaining references before deleting
- [ ] T040 Verify no other orphan static/mock lab data files exist — search for files with `_generateMockLabs`, `_mockLabs`, `mock_labs`, `demo_labs` patterns across entire `lib/` directory; delete any files found that are no longer referenced
- [ ] T041 Visual parity check — compare pre-integration and post-integration screenshots of `LabsScreen` and `LabDetailScreen`; verify ≥85% visual similarity (same colors, spacing, card layouts, typography, status badge styles); document any deviations and justify or fix
- [ ] T042 Run `flutter analyze` — ensure zero errors and zero warnings across all new and modified files
- [ ] T043 Run `flutter test` — ensure all unit tests and widget tests pass; verify test coverage for Cubits, models, and key widgets; include widget tests verifying instruction render completes without errors (SC-002: 100% render correctness)
- [ ] T044 Integration test — manually verify end-to-end flow: Labs screen → course selector → labs list → tap lab → detail screen → view instructions → submit work → view submission history; confirm all 4 user stories work together; measure LabsScreen and LabDetailScreen load times (verify <2s per SC-001) and time from LabDetailScreen open to grade display for pre-graded submissions (verify <1s per SC-005)
- [ ] T045 Update `QWEN.md` project context — add note about Phase 4 completion, new files created (`lab_detail_screen.dart`, `lab_detail_cubit.dart`, `lab_detail_state.dart`, `instruction_viewer.dart`, `lab_submission_sheet.dart`, `submission_history_view.dart`, `submission_event_tracker.dart`), cleaned `LabModel` fields, and any new dependencies added

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — BLOCKS all user stories
- **Phase 3 (US1)**: Depends on Phase 2 completion
- **Phase 4 (US2)**: Depends on Phase 2 completion; depends on US1 for `LabDetailScreen` navigation wiring (T013)
- **Phase 5 (US3)**: Depends on Phase 2 and US2 (needs `LabDetailScreen` with Submit button wired)
- **Phase 6 (US4)**: Depends on Phase 2 and US3 (needs submission data from US3 to display)
- **Phase 7 (Polish)**: Depends on all user stories (US1-US4) being complete

### User Story Dependencies

```
Phase 2 (Foundational)
    ↓
US1 (P1) — Browse labs list ────────────────────→ MVP
    ↓
US2 (P2) — View instructions ────────────────────→ Readable lab content
    ↓
US3 (P3) — Submit lab work ──────────────────────→ Functional submissions
    ↓
US4 (P4) — View grades/feedback ─────────────────→ Complete feedback loop
```

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Models/states before Cubits
- Cubits before screens/widgets
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- T002, T003, T004, T005 in Phase 2 can run in parallel (different files)
- T006, T007, T008, T009 in US1 tests can run in parallel
- T014, T015, T017 in US2 tests can run in parallel
- T018, T019, T020 in US2 implementation can run in parallel (state, cubit, widget are different files)
- T024, T025, T026, T027, T028 in US3 tests can run in parallel
- T029, T030 in US3 implementation can run in parallel (different files: tracker utility + widget)
- T034, T035 in US4 tests can run in parallel
- T036, T037 in US4 implementation can run in parallel (widget creation + integration into existing screen)

### Parallel Example: User Story 2

```bash
# Launch all US2 tests together:
Task T014: "Unit test for LabDetailCubit.loadLab() in tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart"
Task T015: "Unit test for LabDetailCubit.loadInstructions() in tests/unit/bloc/lab_detail/lab_detail_cubit_test.dart"
Task T017: "Widget test for InstructionViewer in tests/widget/student/labs/instruction_viewer_test.dart"

# Launch all US2 implementation components together:
Task T018: "Create LabDetailState in lib/bloc/lab_detail/lab_detail_state.dart"
Task T019: "Create LabDetailCubit in lib/bloc/lab_detail/lab_detail_cubit.dart"
Task T020: "Create InstructionViewer widget in lib/widgets/student/labs/instruction_viewer.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002-T005) — CRITICAL, blocks all stories
3. Complete Phase 3: User Story 1 (T006-T013)
4. **STOP and VALIDATE**: Navigate to Labs screen, select a course, see live labs list
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add US1 (browse labs) → Test independently → Labs list works with API
3. Add US2 (view instructions) → Test independently → Lab detail screen works
4. Add US3 (submit work) → Test independently → Submissions functional
5. Add US4 (view grades) → Test independently → Full feedback loop
6. Polish phase → Mock audit, cleanup, parity check
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (labs list)
   - Developer B: User Story 2 (lab detail/instructions) — starts after T013 wires navigation
3. After US1 + US2 complete:
   - Developer A: User Story 3 (submissions)
   - Developer B: User Story 4 (grades/history)
4. Polish phase completed together

---

## Mock Data & Orphan File Cleanup Summary

### Files with Mock Data to Remove (during Phase 2 & 3)

| File | Mock Pattern | Replacement |
|------|-------------|-------------|
| `lib/bloc/labs/labs_cubit.dart` | `_generateDemoLabs()` (8 hardcoded labs) | `LabService.getAll(courseId)` |
| `lib/bloc/labs/labs_cubit.dart` | `_generateSampleLabs()` helpers | Deleted entirely |
| `lib/screens/student/labs_screen.dart` | Any fallback hardcoded labs list | Empty state widget |

### Orphan Files to Delete (during Phase 7)

| File | Reason |
|------|--------|
| `lib/widgets/student/labs/lab_details_sheet.dart` | Replaced by `LabDetailScreen` (full screen per clarification) |

### Files to Verify No Longer Import Legacy LabModel Fields

| File | Verify |
|------|--------|
| `lib/widgets/student/labs/lab_card.dart` | No imports of `LabType`, `location`, `virtualLink`, `scheduledDate` |
| `lib/screens/student/labs_screen.dart` | No references to `_generateDemoLabs`, legacy status mapping |

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [US1-US4] labels map tasks to specific user stories for traceability
- Each user story is independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Constitution Principle XII (UI Consistency): All modified screens must maintain ≥85% visual similarity. No redesigns. Colors, spacing, and component hierarchy preserved.
- Constitution Principle VII (Static Data Elimination): Zero mock/static data permitted in modified files after Phase 7 audit.
- Constitution Principle III (Type Safety): `isLate` in labs is boolean (NOT number); decimal fields use `double.tryParse(value.toString())`; enums use `fromString(... orElse: default)`.
- File uploads MUST use `Dio.FormData` with `MultipartFile.fromFile()` — do NOT manually set `Content-Type` header (Dio auto-generates multipart boundary).
- Google Drive previews use `WebView` with `iframeUrl` from `DriveFileModel`.
- Markdown rendering uses `flutter_markdown` package's `MarkdownBody` widget.
