# Tasks: Phase 6 — Instructor Assignments CRUD & Grading

**Input**: Design documents from `/specs/020-phase-6-instructor/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md
**Branch**: `020-phase-6-instructor`

**Tests**: Included — unit, widget, and integration tests as specified in the plan.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: Model alignment, enum fixes, and legacy model removal that ALL user stories depend on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T001 [P] Create `AssignmentFormData` model in `lib/models/assignments/assignment_form_data.dart` matching backend shape (title, description, instructions, dueDate, maxScore, weight, submissionType, maxFileSizeMb, allowedFileTypes, latePenaltyPercent, status, courseId) with `toJson()` and `fromJson()` factory, using `double.tryParse()` for decimals and `jsonDecode()` for allowedFileTypes. **`AssignmentFormData` is used for both create and edit operations. For edit, the assignment's existing `id` is passed separately (not part of the form data) via route arguments.**
- [X] T002 [P] Update `SubmissionStatus` enum usage in `lib/models/instructor/submission_model.dart` — remove old `SubmissionStatus` enum (pending/graded/late) and old `Submission` class from this file; re-export `SubmissionStatus` from `lib/models/core/enums/assignment_enums.dart` instead; replace `Submission` class references with `AssignmentSubmissionModel` from `lib/models/assignments/assignment_submission_model.dart`
- [X] T003 [P] Update `lib/models/instructor/grading_model.dart` — remove any remaining legacy submission types or enums that conflict with `AssignmentSubmissionModel`; verify no duplicate `Submission` or `SubmissionStatus` definitions remain
- [X] T004 Create `LatePenaltyCalculator` utility in `lib/utils/late_penalty_calculator.dart` with pure function `calculateFinalScore({required double originalScore, required double latePenaltyPercent, required int daysLate})` returning final score per formula: `Original Score × (1 - (latePenaltyPercent × daysLate / 100))`
- [X] T005 Create `InstructorAssignmentsState` in `lib/bloc/instructor/instructor_assignments_state.dart` with Equatable: loading, loaded (assignments list + teaching courses), error, selectedCourseId, assignments (PaginatedResponse), filters (status, search), currentPage, hasMorePages, **submissions list, selectedSubmission, submissionsLoading, submissionsPage, hasMoreSubmissions** (for US2/US3 submissions view within same cubit). **When navigating to submissions view, assignments data persists in state (does not get cleared). Use separate loading states: `isLoading` for assignments, `submissionsLoading` for submissions.**
- [X] T006 Create `InstructorAssignmentsCubit` in `lib/bloc/instructor/instructor_assignments_cubit.dart` with injected `AssignmentService` + `EnrollmentService`, methods: `loadTeachingCourses()`, `selectCourse(courseId)`, `loadAssignments({page, limit})`, `createAssignment(AssignmentFormData)`, `updateAssignment(id, AssignmentFormData)`, `deleteAssignment(id)`, `updateStatus(id, AssignmentStatus)`, `setSearchQuery()`, `setStatusFilter()`, `loadMore()`, **`loadSubmissions(assignmentId, {page, limit})`**, **`gradeSubmission(submissionId, score, feedback)`**. **Assignment list uses pagination (page/limit from `AssignmentService.getAll()`): initial load page 1, limit 20; "Load More" for subsequent pages, matching submissions pagination pattern.**
- [X] T007 Refactor `GradingCenterCubit` in `lib/bloc/instructor/grading_center_cubit.dart` — remove `_generateDemoCourses()`, `_generateDemoSubmissions()`, `_calculateStatistics()` mock methods; inject `AssignmentService`; replace `loadGradingData()` with `AssignmentService.getSubmissions(assignmentId)` call; update `gradeSubmission()` to call `AssignmentService.gradeSubmission()`. **Update constructor: `GradingCenterCubit({required AssignmentService assignmentService})`. Update all cubit instantiation sites in the codebase to pass the service.**
- [X] T008 [P] Refactor `GradingCenterState` in `lib/bloc/instructor/grading_center_state.dart` — replace `StudentSubmission` type with `AssignmentSubmissionModel`, update `GradingFilter` to use backend `SubmissionStatus` enum, update filtering logic for "ungraded" = `submitted` + `resubmit` only. **Keep `GradingCenterState` as a separate state for the EXISTING grading center screen (from instructor dashboard) — do NOT merge with `InstructorAssignmentsState`. They serve different screens.**
- [X] T009 Delete legacy model `lib/models/instructor/assignment_model.dart` (AssignmentDraft with non-backend fields: plagiarismDetection, groupWork, autoGrading, questions, difficulty)
- [X] T010 Audit and update `app_router.dart` — add route entries for 4 new screens (assignments list, submissions list, grading panel, create/edit assignment) with proper route names and parameters

**Checkpoint**: Foundation ready — all models aligned with backend, mock data removed from cubits, new cubit/state created, routes registered.

---

## Phase 2: User Story 1 — Create and Manage Assignments (Priority: P1) 🎯 MVP

**Goal**: Instructor can select a teaching course, create assignments with all 13 fields, edit them, upload instruction files, and transition status through the workflow (draft → published → closed → archived).

**Independent Test**: Can be fully tested by creating an assignment with all fields, verifying it appears in the assignment list, editing it, uploading an instruction file, and changing status — all via live API.

### Tests for User Story 1

- [X] T011 [P] [US1] Unit test for `AssignmentFormData.toJson()` and `fromJson()` in `test/unit/models/assignment_form_data_test.dart` covering all 13 fields, decimal parsing, JSON-string parsing for allowedFileTypes
- [X] T012 [P] [US1] Unit test for `InstructorAssignmentsCubit.createAssignment()` in `test/unit/bloc/instructor/instructor_assignments_cubit_test.dart` — mock `AssignmentService.create()` returns success, verify state emits loaded with new assignment
- [X] T013 [P] [US1] Unit test for `InstructorAssignmentsCubit.updateStatus()` — mock `AssignmentService.updateStatus()` returns updated assignment, verify state reflects new status
- [X] T014 [US1] Unit test for `LatePenaltyCalculator.calculateFinalScore()` in `test/unit/utils/late_penalty_calculator_test.dart` — test on-time (0 days), 1-day late, multi-day late, zero penalty, 100% penalty edge case

### Implementation for User Story 1

- [X] T015 [P] [US1] Create `AssignmentCard` widget in `lib/widgets/instructor/assignments/assignment_card.dart` — displays title, status badge (color-coded: draft=gray, published=green, closed=orange, archived=blue), due date, submission type icon, max score, action buttons (Edit, Delete, View Submissions, status dropdown); use existing `create_assignment_colors.dart` for color parity; **status dropdown shows only the NEXT valid transition (draft→published, published→closed, closed→archived) — no reverse transitions**
- [X] T016 [P] [US1] Create `AssignmentStatusBadge` widget in `lib/widgets/instructor/assignments/assignment_status_badge.dart` — chip widget showing status with color from `create_assignment_colors.dart`, follows existing app badge patterns
- [X] T017 [P] [US1] Create `InstructionFileUploader` widget in `lib/widgets/instructor/assignments/instruction_file_uploader.dart` — file picker + `file_picker` integration, `AssignmentService.uploadInstructionFile()` call with progress bar via `onSendProgress`, error display with "Retry" button (no auto-retry), shows uploaded files with Open/Download actions using `webview_flutter` for preview; **uploaded files are immediately added to the assignment's `instructionFiles` array on the server — no additional save action needed**
- [X] T018 [US1] Create `AssignmentCreateForm` widget in `lib/widgets/instructor/assignments/assignment_create_form.dart` — 13-field form **composing the existing reusable sections** from `lib/widgets/instructor/create_assignment/`: `basic_details_section.dart` (title, description), `instructions_section.dart` (Markdown textarea + InstructionFileUploader), `deadline_settings_section.dart` (due date picker via `intl`), `assignment_type_selector.dart` (file/text/link/multiple buttons — **note: backend enum value is `multiple`, NOT `any`**); plus new inputs for: status buttons (draft/published), **late penalty number input (0-100, pre-populated to 0)**, **file size number input (MB, pre-populated to 10)**, **allowed types text input (comma-separated, pre-populated empty = no restriction)**; validation per data-model.md rules; emits `AssignmentFormData` on save; **Do NOT reorganize the widget tree of reused sections (Rows, Columns, Stacks order must be preserved).**
- [X] T019 [US1] Create `InstructorAssignmentsScreen` in `lib/screens/instructor/assignments/instructor_assignments_screen.dart` — full-screen page with: course selector dropdown (from `EnrollmentService.getTeachingCourses()`), assignment list via `SliverList` of `AssignmentCard`s (paginated: page 1, limit 20, "Load More" for subsequent pages), "Create Assignment" FAB, **search bar with 300ms debounce (client-side filter on loaded assignments — avoids excessive re-filtering on every keystroke)**, status filter chips, empty states (no courses, no assignments); **loading skeleton/shimmer while assignments fetch, matching existing instructor screen loading patterns**; BLoC-driven via `BlocBuilder<InstructorAssignmentsCubit, InstructorAssignmentsState>`; ≥85% visual match to existing instructor course screens; **role-based UI gating: hide Create/Edit/Delete actions for non-instructor roles, show read-only view**
- [X] T020 [US1] Create `CreateAssignmentScreen` in `lib/screens/instructor/create_assignment_screen.dart` — full-screen page with `AssignmentCreateForm`, AppBar with save/cancel actions, calls `InstructorAssignmentsCubit.createAssignment()` or `updateAssignment()` on save; passes `courseId` from route arguments; shows loading/success/error states via `BlocListener`; **if editing an assignment with existing graded submissions and maxScore is changed, show warning banner**
- [X] T021 [US1] Wire assignment card actions in `InstructorAssignmentsScreen` — Edit button navigates to `CreateAssignmentScreen` in edit mode (pre-populated form via `AssignmentFormData.fromJson()`), Delete button shows `AwesomeDialog` confirmation then calls `InstructorAssignmentsCubit.deleteAssignment()`, status dropdown calls `InstructorAssignmentsCubit.updateStatus()` with one-way transition validation
- [X] T022 [US1] Create barrel export in `lib/widgets/instructor/assignments/assignment_barrel.dart` — exports all assignment widgets

**Checkpoint**: User Story 1 should be fully functional — instructor can select course, view assignments, create/edit/delete, upload instruction files, and transition status. Independently testable.

---

## Phase 3: User Story 2 — View and Filter Submissions (Priority: P2)

**Goal**: Instructor can view all submissions for an assignment in a paginated, filterable, sortable full-screen list.

**Independent Test**: Can be fully tested by opening submissions list for an assignment with existing submissions, applying filters (all/graded/ungraded/late), searching by student name, and sorting by date/score — all via live API.

### Tests for User Story 2

- [X] T023 [P] [US2] Unit test for `InstructorAssignmentsCubit.loadSubmissions()` in `test/unit/bloc/instructor/instructor_assignments_cubit_test.dart` — mock `AssignmentService.getSubmissions()` returns list, verify state emits loaded with submissions
- [X] T024 [P] [US2] Unit test for submission filter logic in `InstructorAssignmentsCubit` filter methods — verify "ungraded" filter returns only `submitted` + `resubmit`, "graded" returns `graded`, "late" returns `isLate == 1`
- [X] T025 [US2] Widget test for `AssignmentSubmissionsScreen` in `test/widget/screens/assignment_submissions_screen_test.dart` — mock cubit emits loaded state with 5 submissions, verify list renders, filter chips work, search field filters

### Implementation for User Story 2

- [X] T026 [P] [US2] Create `SubmissionListItem` widget in `lib/widgets/instructor/assignments/submission_list_item.dart` — row showing student avatar (initials circle), student name, submission date (relative time), status badge (using `SubmissionStatus` from assignment_enums.dart), score (if graded), late indicator (if `isLate == 1`); tap opens grading screen; uses existing grading theme colors from `grading_theme_colors.dart`; **verify `grading_theme_colors.dart` has color mappings for `submitted`, `returned`, `resubmit` statuses — add if missing to match existing design language**
- [X] T027 [P] [US2] Create `SubmissionContentViewer` widget in `lib/widgets/instructor/assignments/submission_content_viewer.dart` — displays submission content: text (markdown rendered via `flutter_markdown`), link (clickable URL with `url_launcher`), file (Google Drive iframe via `webview_flutter` or download button); **if webview_flutter fails to load file preview (>50MB or auth error), show download-only fallback with file name and size**; used in grading screen
- [X] T028 [US2] Create `AssignmentSubmissionsScreen` in `lib/screens/instructor/assignments/assignment_submissions_screen.dart` — full-screen page with: AppBar showing assignment title, filter chips (All/Graded/Ungraded/Late), **search field with 300ms debounce (client-side filtering of loaded submissions — no server-side search endpoint exists for submissions)**, **sort dropdown (student name, submission date, score, status) with ascending/descending toggle**, paginated `SliverList` of `SubmissionListItem`s (20 per page), "Load More" button at bottom for pagination, grading statistics header (total/pending/graded/late chips from `stat_chip_widget.dart`), empty state for no submissions; BLoC-driven; receives `assignmentId` from route arguments
- [X] T029 [US2] Add **`loadSubmissions(assignmentId, {page, limit})` method** to `InstructorAssignmentsCubit` — **separate from `loadAssignments()`**; tracks `submissionsPage`, `hasMoreSubmissions`, appends new items to existing submissions list on "Load More", retry on page load failure without clearing previously loaded submissions
- [X] T030 [US2] Wire navigation from `AssignmentCard` in `InstructorAssignmentsScreen` — "View Submissions" button pushes `AssignmentSubmissionsScreen` with `assignmentId` parameter via `go_router`

**Checkpoint**: User Stories 1 AND 2 should both work independently — instructor can create assignments AND view/filter/paginate submissions.

---

## Phase 4: User Story 3 — Grade Individual Submissions (Priority: P3)

**Goal**: Instructor can open a submission, review content, enter score (0-maxScore, step 0.5), add feedback, see late penalty calculation, and save grade.

**Independent Test**: Can be fully tested by opening a submission, entering score + feedback, saving, verifying grade persists and reflects in submissions list — works for assignments created outside the mobile app.

### Tests for User Story 3

- [X] T031 [P] [US3] Unit test for `InstructorAssignmentsCubit.gradeSubmission()` in `test/unit/bloc/instructor/instructor_assignments_cubit_test.dart` — mock `AssignmentService.gradeSubmission()` returns success, verify state updates submission to "graded" with score
- [X] T032 [P] [US3] Unit test for late penalty display calculation in grading panel — verify penalty percentage and final score display correctly for on-time, 1-day late (10% penalty), 3-day late (30% penalty) scenarios
- [X] T033 [US3] Widget test for `SubmissionGradingScreen` in `test/widget/screens/submission_grading_screen_test.dart` — mock cubit, verify score input (0-maxScore, step 0.5), feedback textarea, save button calls gradeSubmission, late penalty display for late submission, error message on failure with score/feedback retained

### Implementation for User Story 3

- [X] T034 [P] [US3] Create `GradingPanel` widget in `lib/widgets/instructor/assignments/grading_panel.dart` — score input (`TextFormField` with validator 0-maxScore, increment/decrement buttons step 0.5), feedback `TextFormField` (3 rows), late penalty display box (Original Score, Late Penalty %, Final Score — hidden if on time), save button with loading state, error banner with retry; uses existing `grading_theme_colors.dart`; **use existing grading theme colors for penalty display box**
- [X] T035 [US3] Create `SubmissionGradingScreen` in `lib/screens/instructor/assignments/submission_grading_screen.dart` — full-screen page with: AppBar showing student name, `SubmissionContentViewer` (text/link/file preview), `GradingPanel` below, scrollable layout; receives `submissionId` and `assignmentId` from route arguments; **calls `InstructorAssignmentsCubit.gradeSubmission()` via BLoC (not direct `AssignmentService` call)**; shows success/error via `BlocListener`; **on success pops back to submissions list with grade reflected immediately**; **if assignment is archived, disable grade save and show read-only message; after grade save, re-fetch submission to get latest server state (handles concurrent edits)**
- [X] T036 [US3] Wire navigation from `SubmissionListItem` in `AssignmentSubmissionsScreen` — tap submission pushes `SubmissionGradingScreen` with `submissionId` + `assignmentId`; after grade save, refresh submissions list via cubit
- [X] T037 [US3] Refactor `GradeDialog` in `lib/widgets/instructor/grading/grade_dialog.dart` — adapt to use `AssignmentSubmissionModel` instead of `Submission`, update score input to use `double` (step 0.5), add late penalty display using `LatePenaltyCalculator`, **update `onSubmit` callback to call `InstructorAssignmentsCubit.gradeSubmission()` via BLoC (not direct `AssignmentService` call — follows Constitution Principle I)**; preserve existing UI structure and colors (≥85% rule); **Do NOT reorganize widget tree (Rows, Columns, Stacks order must be preserved — only update model types and API calls)**
- [X] T038 [US3] Refactor `SubmissionCard` in `lib/widgets/instructor/grading/submission_card.dart` — update props to accept `AssignmentSubmissionModel` instead of `Submission`, update status badge to use backend `SubmissionStatus` enum, add late indicator based on `isLate` field; preserve existing visual design; **Do NOT reorganize widget tree (Rows, Columns, Stacks order must be preserved — only update model types)**

**Checkpoint**: All user stories (US1, US2, US3) should now be independently functional.

---

## Phase 5: User Story 4 — Delete Assignments (Priority: P4)

**Goal**: Instructor can delete assignments with explicit confirmation dialog.

**Independent Test**: Can be fully tested by deleting an assignment and confirming it no longer appears in the list.

### Implementation for User Story 4

- [X] T039 [US4] Implement delete confirmation flow in `InstructorAssignmentsScreen` — `AwesomeDialog` with assignment title, warning message "This action cannot be undone", confirm/cancel buttons; on confirm calls `InstructorAssignmentsCubit.deleteAssignment(id)`, shows loading state, removes assignment from list on success, shows error toast on failure
- [X] T040 [US4] Add delete validation in `InstructorAssignmentsCubit` — handle `AssignmentService.delete()` errors (404 not found, 403 forbidden), emit error state, log failure

**Checkpoint**: All 4 user stories complete and independently testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Integration tests, mock data audit, orphan file cleanup, documentation.

- [X] T041 [P] Create integration test `test/integration/features/assignments/instructor_assignments_flow_integration_test.dart` — full flow: select course → view assignments → create assignment → view submissions → grade submission → verify grade persists; assert timing thresholds (assignment list <2s, submissions page <2s, grade save <1s)
- [X] T042 [P] Create widget test `test/widget/instructor/assignment_card_test.dart` — test assignment card rendering with all status types, action button visibility
- [X] T043 [P] Create widget test `test/widget/instructor/assignment_create_form_test.dart` — test form validation (empty title rejected, invalid due date rejected, valid form submits)
- [X] T044 [P] Create widget test `test/widget/instructor/submission_list_item_test.dart` — test submission row rendering with `submitted`/`graded`/`resubmit` statuses + `isLate` indicator
- [X] T045 Run full mock data audit — grep for **`_generateDemo`, `_generateSample`, `_simulateReply`, `_mockMessages`, `_mockLabs`, `_mockAssignments`, `_mockCourses`, `_mockGrades`, `_mockSubmissions`, `Duration(hours:`, `Duration(minutes:`, `isMe: true/false`, `setState(() =>`, `TODO: Replace with API`** in `lib/bloc/instructor/grading_center_cubit.dart`, `lib/bloc/instructor/grading_center_state.dart`, and all modified files; verify zero matches
- [X] T046 Identify and delete orphan files related to Phase 6 scope: search for files importing `lib/models/instructor/assignment_model.dart` (deleted in T009), `questions_section.dart`, `lab_details_section.dart`, `project_details_section.dart` from `lib/widgets/instructor/create_assignment/` — if no remaining imports, delete them; update `create_assignment.dart` barrel to remove deleted section exports
- [X] T047 Run `flutter analyze` — verify zero new issues introduced (pre-existing ~957 acceptable)
- [X] T048 Run `flutter test` — verify 181+ passed (new tests added, none broken)
- [X] T049 Update `QWEN.md` with Phase 6 completion notes: new screens, new cubits, modified files, deleted legacy models
- [ ] T050 Visual parity check — compare before/after screenshots of modified screens (assignments list, grading center) to verify ≥85% visual similarity. Use `specs/020-phase-6-instructor/visual-parity-checklist.md`.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — can start immediately. **BLOCKS all user stories.**
- **User Stories (Phase 2-5)**: All depend on Foundational phase completion.
  - User stories can proceed sequentially in priority order (P1 → P2 → P3 → P4)
  - Or in parallel if team capacity allows (all depend only on Phase 1)
- **Polish (Phase 6)**: Depends on all desired user stories being complete

### User Story Dependencies

```
Phase 1 (Foundational: T001-T010)
    ↓ BLOCKS ALL
Phase 2: US1 - Create & Manage Assignments (T011-T022) ← MVP
    ↓ (US2 needs assignment to exist for submissions)
Phase 3: US2 - View & Filter Submissions (T023-T030)
    ↓ (US3 needs submissions to exist for grading)
Phase 4: US3 - Grade Individual Submissions (T031-T038)
Phase 5: US4 - Delete Assignments (T039-T040) — independent, can parallel with US2/US3
Phase 6: Polish & Audit (T041-T050)
```

### Within Each User Story

- Tests MUST be written before implementation (T011-T014 before T015-T022, etc.)
- Models/utilities before widgets
- Widgets before screens
- Screen wiring last
- Story complete before moving to next priority

### Parallel Opportunities

```bash
# Phase 1: All [P] tasks can run in parallel
T001 (AssignmentFormData model)
T002 (grading_model.dart update)
T003 (submission_model.dart update)
T004 (LatePenaltyCalculator)
T005 (InstructorAssignmentsState)
T008 (GradingCenterState refactor)

# Phase 2: All [P] tasks can run in parallel
T011 (AssignmentFormData tests)
T012 (Cubit create tests)
T013 (Cubit status tests)
T015 (AssignmentCard widget)
T016 (AssignmentStatusBadge widget)
T017 (InstructionFileUploader widget)

# Phase 3: All [P] tasks can run in parallel
T023 (Cubit submissions tests)
T024 (Filter logic tests)
T026 (SubmissionListItem widget)
T027 (SubmissionContentViewer widget)

# Phase 4: All [P] tasks can run in parallel
T031 (Cubit grade tests)
T032 (Late penalty display tests)
T034 (GradingPanel widget)

# Phase 6: All [P] tasks can run in parallel
T041 (Integration test)
T042 (AssignmentCard widget test)
T043 (CreateForm widget test)
T044 (SubmissionListItem widget test)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Foundational (T001-T010) — CRITICAL, blocks all
2. Complete Phase 2: User Story 1 (T011-T022)
3. **STOP and VALIDATE**: Test assignment creation/editing/status transitions independently
4. Run `flutter analyze` and `flutter test`
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Foundational → Foundation ready
2. Add US1 (Create & Manage) → Test independently → Deploy/Demo (MVP!)
3. Add US2 (View & Filter Submissions) → Test independently → Deploy/Demo
4. Add US3 (Grade Submissions) → Test independently → Deploy/Demo
5. Add US4 (Delete Assignments) → Test independently → Deploy/Demo
6. Each story adds value without breaking previous stories
7. Phase 6: Polish, integration tests, mock audit, orphan cleanup

### Parallel Team Strategy

With multiple developers:

1. Team completes Foundational (Phase 1) together
2. Once Foundational is done:
   - Developer A: US1 (Phase 2)
   - Developer B: US2 (Phase 3) — after US1 creates at least one assignment
   - Developer C: US3 (Phase 4) — after US2 has submissions to grade
3. US4 (Phase 5) can be done by any developer in parallel
4. Phase 6: Polish and audit as a team

---

## Orphan File Cleanup (T046 Details)

Files to check for deletion after T009 (legacy model removal):

| File | Condition for Deletion |
|------|----------------------|
| `lib/widgets/instructor/create_assignment/questions_section.dart` | No remaining imports (quiz feature, not assignment) |
| `lib/widgets/instructor/create_assignment/lab_details_section.dart` | No remaining imports (lab feature, not assignment) |
| `lib/widgets/instructor/create_assignment/project_details_section.dart` | No remaining imports (project feature, not assignment) |
| `lib/models/instructor/assignment_model.dart` | Already deleted in T009 — verify no remaining imports |
| `lib/widgets/instructor/create_assignment/create_assignment.dart` | Update barrel to remove deleted section exports |

Grep pattern to find orphans:
```powershell
Select-String -Path "lib\**\*.dart" -Pattern "questions_section|lab_details_section|project_details_section|AssignmentDraft|import.*instructor/assignment_model" | Select-Object Path, LineNumber
```

Any file with zero results after the above grep is safe to delete.

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Constitution Principle VII (Static Data Elimination): T045 mock audit is a gate — phase fails if any mock patterns remain
- Constitution Principle XII (UI Consistency): T050 visual parity check verifies ≥85% similarity
- All decimal fields use `double.tryParse(value.toString())` — never assume numeric type from API
- `lateSubmissionAllowed` and `isLate` are `int` (0/1), NOT `bool` — parse as `(value as num) == 1`
- `allowedFileTypes` is JSON string — parse with `jsonDecode()`
- FormData uploads: use `Dio.FormData` with `MultipartFile.fromFile()`, do NOT set `Content-Type` header
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
