# Tasks: TA — Courses, Assignments & Labs Integration

**Feature**: Phase 8 — TA Courses, Assignments & Labs Integration
**Branch**: `022-ta-courses-assignments-labs`
**Generated**: 2026-04-14
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Research**: [research.md](./research.md) | **Data Model**: [data-model.md](./data-model.md) | **Contracts**: [contracts/api-contracts.md](./contracts/api-contracts.md)

## Dependencies & Story Order

```
Phase 2 (Foundational: TA Cubits) 
    ├──→ Phase 3 (US1: TA Courses & Details) [P1]
    │       ├──→ Phase 4 (US2: TA Assignment CRUD) [P1]
    │       │       └──→ Phase 5 (US3: TA Assignment Grading) [P1]
    │       └──→ Phase 6 (US4: TA Lab CRUD) [P2]
    │               └──→ Phase 7 (US5: TA Lab Grading) [P2]
    │                       └──→ Phase 8 (US6: TA Lab Attendance) [P2]
    │                               └──→ Phase 9 (US7: TA Lab Materials Upload) [P3]
    └──→ Phase 10 (Polish & Cleanup)
```

**Independent Test Criteria per Story**:
- **US1**: TA logs in, sees courses from backend, taps course, views 9 sub-tabs with live/empty data
- **US2**: TA creates an assignment, edits it, deletes it — all via live API
- **US3**: TA views assignment submissions, filters, grades one — status updates to "graded"
- **US4**: TA creates a lab, edits it, views detail with submissions — all via live API
- **US5**: TA grades a lab submission with score + feedback + status — persists to backend
- **US6**: TA marks attendance for all students in a lab — records persist
- **US7**: TA uploads instruction file and TA material file — visible to correct audiences

**Suggested MVP Scope**: US1 + US2 + US3 (P1 stories) — TA can view courses, manage assignments, and grade submissions.

**Parallel Opportunities**:
- US2 and US3 can proceed in parallel after US1 (assignment CRUD and grading are independent workflows)
- US4, US5, US6 can proceed in parallel after US1 (lab CRUD, grading, attendance share lab detail screen)
- All sub-tab widgets (Phase 3) can be developed in parallel once BLoC is ready

---

## Phase 1: Setup

_No tasks needed — project structure and dependencies already exist from previous phases._

---

## Phase 2: Foundational — TA Cubits & States

**Goal**: Create BLoC/Cubit classes for TA course list and TA labs list. These block all user story phases.

- [ ] T001 Create TACoursesCubit in `lib/bloc/ta/ta_courses_cubit.dart` with methods: `fetchTACourses()` (calls `EnrollmentService.getTeachingCourses()`), `fetchCourseDetail(courseId)` (aggregates course info, section, semester), emit states: `TACoursesInitial`, `TACoursesLoading`, `TACoursesLoaded(List<TeachingCourseModel>)`, `TACoursesError(String)`
- [ ] T002 Create TACoursesState in `lib/bloc/ta/ta_courses_state.dart` with classes: `TACoursesInitial`, `TACoursesLoading`, `TACoursesLoaded`, `TACoursesError`, `TACourseDetailLoading`, `TACourseDetailLoaded`, `TACourseDetailError` — all extend `Equatable` with proper `props`
- [ ] T003 Create TALabsCubit in `lib/bloc/ta/ta_labs_cubit.dart` with methods: `fetchTALabs(courseId)` (calls `LabService.getAll({courseId})`), `fetchLabDetail(labId)` (calls `LabService.getById(labId)` + `LabService.getSubmissions(labId)` + `LabService.getAttendance(labId)`), emit states: `TALabsInitial`, `TALabsLoading`, `TALabsLoaded(List<LabModel>)`, `TALabsError(String)`, `TALabDetailLoading`, `TALabDetailLoaded(LabModel, List<LabSubmissionModel>)`, `TALabDetailError(String)`
- [ ] T004 Create TALabsState in `lib/bloc/ta/ta_labs_state.dart` with classes: `TALabsInitial`, `TALabsLoading`, `TALabsLoaded`, `TALabsError`, `TALabDetailLoading`, `TALabDetailLoaded`, `TALabDetailError`, `TALabAttendanceLoading`, `TALabAttendanceLoaded(List<LabAttendanceModel>)`, `TALabAttendanceError`
- [ ] T005 Register TACoursesCubit and TALabsCubit in app's dependency injection (same location where other BLoCs are registered — check `main.dart` or service locator)

---

## Phase 3: US1 — TA Views Assigned Courses & Course Details [P1]

**Goal**: TA course list shows live API data. Course detail has 9 sub-tabs with live API fetches and empty-state fallbacks. Modern, colorful UI matching existing TA patterns.

**Independent Test**: TA logs in → sees courses from backend → taps course → sees 9 sub-tabs, each attempting API fetch → shows data, empty state, or error appropriately.

- [ ] T006 [US1] Rewrite `lib/screens/ta/courses/ta_courses_list_screen.dart` to use `TACoursesCubit` via `BlocBuilder` — remove any remaining hardcoded values, dispatch `fetchTACourses()` in `initState`, show loading/error/loaded states, preserve existing `TAColors` and `TADrawer` patterns, keep filter chips UI structure (≥85% visual similarity)
- [ ] T007 [US1] Rewrite `lib/screens/ta/courses/ta_course_detail_screen.dart` to expand from 4 to 9 sub-tabs — each sub-tab lazily fetches data on activation via service calls (Overview: `EnrollmentService.getTeachingCourses()` + stats aggregation, Sections & Labs: `SectionService.getByCourse()` + `LabService.getAll()`, Lectures: `CourseService.getStructure()`, Materials: `MaterialService.getMaterials()`, Assignments: `AssignmentService.getAll()`, Grading: `AssignmentService.getAll()` + submission counts, Attendance: `LabService.getAttendance()` per lab, Students: `EnrollmentService.getSectionStudents()`, Announcements: attempt fetch or show empty state), show structured empty states when no data, preserve `TAColors` and existing tab bar structure (≥85% visual similarity)
- [ ] T008 [US1] Update `lib/widgets/ta/courses/ta_course_overview_tab.dart` to accept live data from parent (remove hardcoded `TAUpcomingTask`/`TARecentActivity` single-item lists passed from parent), keep widget structure and `TAColors` unchanged, add empty state widget for when no data is available
- [ ] T009 [US1] Create Sections & Labs sub-tab widget in `lib/widgets/ta/courses/ta_course_sections_labs_tab.dart` — read-only section list with schedule info + lab list for the course, use `TAColors`, show empty state when no sections/labs exist
- [ ] T010 [US1] Create Lectures sub-tab widget in `lib/widgets/ta/courses/ta_course_lectures_tab.dart` — display week-based course structure from `CourseStructureModel`, use `TAColors`, show empty state when no structure exists
- [ ] T011 [US1] Create Materials sub-tab widget in `lib/widgets/ta/courses/ta_course_materials_tab.dart` — display published course materials list, use `TAColors`, show empty state when no materials exist
- [ ] T012 [US1] Create Assignments sub-tab widget in `lib/widgets/ta/courses/ta_course_assignments_tab.dart` — display assignment list with submission counts per assignment, reuse `widgets/instructor/assignments/assignment_card.dart` if compatible, use `TAColors`, show empty state when no assignments exist
- [ ] T013 [US1] Create Grading sub-tab widget in `lib/widgets/ta/courses/ta_course_grading_tab.dart` — replace existing empty `gradingTasks: const []` with live pending grading tasks aggregated from all course assignments' submissions, reuse `widgets/instructor/assignments/submission_list_item.dart` patterns, use `TAColors`, show empty state when no pending grading
- [ ] T014 [US1] Create Attendance sub-tab widget in `lib/widgets/ta/courses/ta_course_attendance_tab.dart` — display aggregated attendance stats across all course labs, use `TAColors`, show empty state when no attendance data
- [ ] T015 [US1] Create Students sub-tab widget in `lib/widgets/ta/courses/ta_course_students_tab.dart` — display section-scoped student roster from `EnrollmentService.getSectionStudents()`, use `TAColors`, show empty state when no students
- [ ] T016 [US1] Create Announcements sub-tab widget in `lib/widgets/ta/courses/ta_course_announcements_tab.dart` — attempt to fetch announcements (check backend for endpoint), if no endpoint exists show structured empty state: "Announcements are not available for this course" with appropriate icon, use `TAColors`

---

## Phase 4: US2 — TA Creates, Edits, and Deletes Assignments [P1]

**Goal**: TA can create, edit, and delete assignments using shared Instructor components. All actions call live backend API.

**Independent Test**: TA creates assignment → appears in list → edits field → saves → deletes with confirmation → removed from list.

- [ ] T017 [US2] Wire TA course detail Assignments sub-tab (from T012) to show "Create Assignment" button that opens the shared Instructor assignment creation form (`lib/widgets/instructor/assignments/assignment_create_form.dart`) — pass `courseId` from current course context, on success refetch assignment list via `AssignmentService.getAll(courseId)`
- [ ] T018 [US2] Wire each assignment card in TA Assignments sub-tab to show "Edit" button — open shared Instructor `assignment_create_form.dart` in edit mode (pre-populated with existing `AssignmentModel` data), on save call `AssignmentService.update(id, data)`, refetch list
- [ ] T019 [US2] Wire each assignment card in TA Assignments sub-tab to show "Delete" button — show confirmation dialog (reuse existing `ConfirmDialog` pattern from project), on confirm call `AssignmentService.delete(id)`, refetch list
- [ ] T020 [US2] Ensure assignment status transitions (`draft → published → closed → archived`) are available in TA assignment edit flow — reuse Instructor status transition UI from `assignment_create_form.dart` or status badge widget
- [ ] T021 [US2] Add assignment instruction file upload to TA assignment edit flow — reuse `widgets/instructor/assignments/instruction_file_uploader.dart` (if exists) or create upload widget that calls `POST /assignments/{id}/instructions/upload` with FormData `file` field, show progress bar via `onSendProgress`
- [ ] T022 [US2] Handle 403 Forbidden responses gracefully — if backend rejects TA assignment CRUD with 403, show error snackbar "You don't have permission to manage assignments for this course"

---

## Phase 5: US3 — TA Grades Assignment Submissions [P1]

**Goal**: TA can view all submissions for an assignment, filter by status/lateness, and grade pending submissions. Reuses Instructor grading panel.

**Independent Test**: TA opens assignment → sees submissions list → filters to ungraded → selects one → enters score + feedback → saves → status updates to "graded".

- [ ] T023 [US3] Create assignment submissions view accessible from TA Assignments sub-tab — when TA taps an assignment card, show submissions list using `AssignmentService.getSubmissions(assignmentId)`, display student name/email, submission date, attempt number, late indicator, score (if graded), status badge — reuse `widgets/instructor/assignments/submission_list_item.dart`
- [ ] T024 [US3] Add filtering to submissions list — filter by status (All/Graded/Ungraded) and lateness (All/Late/On Time), implement as local filter on loaded data (no additional API calls needed)
- [ ] T025 [US3] Wire "Grade" action on each ungraded submission to open shared Instructor `widgets/instructor/assignments/grading_panel.dart` — pass `AssignmentSubmissionModel`, `maxScore` from parent assignment, on save call `PATCH /assignments/{aId}/submissions/{sId}/grade` with `{score, feedback}`, show success toast, refetch submissions
- [ ] T026 [US3] Handle re-grading scenario — if submission already has `gradedBy` and `gradedAt`, show previous grader info and previous score/feedback in grading panel for reference
- [ ] T027 [US3] Ensure `isLate` field is correctly parsed from backend response (int 0/1 → bool) via `AssignmentSubmissionModel._parseBoolFromIntLike()` — verify existing model handles this (it does per data-model.md)
- [ ] T028 [US3] Handle empty submissions list — show structured empty state: "No submissions found for this assignment" with appropriate icon

---

## Phase 6: US4 — TA Creates, Edits, and Views Labs [P2]

**Goal**: Replace all mock data in TA labs screens with live API. TA can create, edit, and view labs using shared Instructor components.

**Independent Test**: TA sees labs from backend → creates lab → edits lab → views detail with submissions.

- [ ] T029 [US4] Full rewrite of `lib/screens/ta/labs/ta_labs_list_screen.dart` — remove ALL mock data (6 hardcoded labs, 3 fake courses, `Future.delayed`, local `TALabListItem`/`TACourseWithLabs` classes), replace with `BlocBuilder<TALabsCubit>` dispatching `fetchTALabs()`, organize labs by course section, use `LabModel` canonical model, preserve filter chips UI structure (≥85% visual similarity), use `TAColors` and `TADrawer`
- [ ] T030 [US4] Full rewrite of `lib/screens/ta/labs/ta_lab_detail_screen.dart` — remove ALL mock data (5 `_getMock*()` methods, fake student names, scores, sessions), replace with `BlocBuilder<TALabsCubit>` dispatching `fetchLabDetail(labId)`, display real lab info from `LabModel`, show submissions from `LabSubmissionModel[]`, use `TAColors` (≥85% visual similarity)
- [ ] T031 [US4] Wire "Create Lab" button in TA Labs list to open shared Instructor `widgets/instructor/labs/lab_create_form.dart` — pass TA's teaching courses for course selection dropdown, on success call `POST /labs`, refetch labs list via `TALabsCubit.fetchTALabs()`
- [ ] T032 [US4] Wire "Edit Lab" action in TA Labs list/detail to open shared Instructor `lab_create_form.dart` in edit mode (pre-populated with existing `LabModel` data), on save call `PATCH /labs/{id}`, refetch
- [ ] T033 [US4] Wire "Delete Lab" action in TA Labs list/detail — show confirmation dialog, on confirm call `DELETE /labs/{id}`, refetch labs list
- [ ] T034 [US4] Replace local mock model classes in TA labs files with canonical models: remove `TALabListItem`, `TACourseWithLabs`, `TALabDetail`, `TALabTaskItem`, `TALabQuestion`, `TALabActivityItem` — all replaced by `LabModel`, `LabSubmissionModel`, `TeachingCourseModel` from canonical model files
- [ ] T035 [US4] Handle empty labs list — show structured empty state: "No labs found for your assigned courses" with beaker icon (matching existing empty state patterns)

---

## Phase 7: US5 — TA Grades Lab Submissions [P2]

**Goal**: TA can view and grade lab submissions. Reuses Instructor lab grading panel.

**Independent Test**: TA opens lab → sees submissions → selects pending → grades with score + feedback + status → persists.

- [ ] T036 [US5] Wire "View Submissions" action in TA lab detail to load submissions via `LabService.getSubmissions(labId)` — display list with student name, date, status, score (if graded), reuse `widgets/instructor/labs/grading_panel.dart` patterns or existing submission list widgets
- [ ] T037 [US5] Wire "Grade" action on pending lab submission to open grading interface — pass `LabSubmissionModel`, `maxScore` from parent lab, allow score input (0-maxScore, step 0.5), feedback textarea, status dropdown (submitted/graded/returned/resubmit), on save call `PATCH /labs/{labId}/submissions/{subId}/grade` with `{score, feedback, status}`, show success toast, refetch submissions
- [ ] T038 [US5] Handle lab `isLate` as boolean (true/false) — verify `LabSubmissionModel.isLate` is correctly typed as `bool` and parsed from backend boolean (per data-model.md, it already is)
- [ ] T039 [US5] Handle re-grading scenario — if submission already graded, show previous grader info and score for reference, allow score update
- [ ] T040 [US5] Handle empty submissions list — show structured empty state: "No submissions found for this lab"

---

## Phase 8: US6 — TA Marks Lab Attendance [P2]

**Goal**: TA can mark attendance for students in a lab session. Reuses Instructor attendance sheet.

**Independent Test**: TA opens attendance for a lab → sees student list → marks statuses → saves → records persist on reopen.

- [ ] T041 [US6] Wire attendance tab in TA lab detail to load attendance records via `LabService.getAttendance(labId)` — display student list with current attendance status badges, reuse `widgets/instructor/labs/attendance_sheet.dart` if compatible
- [ ] T042 [US6] Implement attendance marking UI — for each student, provide status selector (present/absent/excused/late) using `LabAttendanceStatus` enum, on change call `POST /labs/{id}/attendance` with `{userId, attendanceStatus, notes}`, show success indicator, refetch attendance
- [ ] T043 [US6] Replace local mock model classes in attendance tab: remove `TALabSession`, `TALabStudent`, `TAAttendanceStatus` enum — replace with `LabAttendanceModel`, `UserInfo`, `LabAttendanceStatus` from canonical model files (`lib/models/core/lab_attendance_model.dart`)
- [ ] T044 [US6] Handle empty attendance list — show structured empty state: "No attendance records for this lab"

---

## Phase 9: US7 — TA Uploads Lab Instructions and TA Materials [P3]

**Goal**: TA can add text instructions, upload instruction files, and upload TA-only materials to labs.

**Independent Test**: TA adds text instruction → appears in lab → uploads file → visible to students → uploads TA material → visible only to instructors/TAs.

- [ ] T045 [US7] Wire instruction management in TA lab detail — reuse `widgets/instructor/labs/instruction_manager.dart` for adding text instructions (calls `POST /labs/{id}/instructions`), display ordered by `orderIndex`
- [ ] T046 [US7] Wire instruction file upload in TA lab detail — reuse `widgets/instructor/labs/instruction_file_uploader.dart` for uploading files to Google Drive (calls `POST /labs/{id}/instructions/upload` with FormData `file` field), show progress bar via `onSendProgress`, client-side validation (50MB docs, 10MB images)
- [ ] T047 [US7] Wire TA materials upload — create or reuse upload widget that calls `POST /labs/{id}/ta-materials/upload` with FormData `file` field, show progress, display uploaded TA materials list with file name and download link, materials visible only to instructors and TAs (enforced by backend)
- [ ] T048 [US7] Handle file upload errors — show retry option for failed uploads, display appropriate error messages for size/type validation failures

---

## Phase 10: Polish, Cross-Cutting & Cleanup

**Goal**: Final audit, mock data elimination verification, orphan file cleanup, unused file deletion.

- [ ] T049 Run mock data audit across all modified TA files — grep for `_generateSample`, `_mock`, `Future.delayed` (in data context), `setState(() =>` (bypassing BLoC for data), hardcoded `List<Lab>`, `List<Course>`, `List<Assignment>` literals — all must return zero results in modified files
- [ ] T050 Run visual parity check — compare before/after screenshots of modified TA screens (`ta_courses_list_screen.dart`, `ta_course_detail_screen.dart`, `ta_labs_list_screen.dart`, `ta_lab_detail_screen.dart`) to ensure ≥85% visual similarity (same colors, layout structure, component hierarchy)
- [ ] T051 [P] Scan for unused/orphan TA-related files — search `lib/` for files that were replaced or are no longer referenced after this phase: check for local mock model classes that were defined inside screen files and may now be orphaned (`TALabListItem`, `TACourseWithLabs`, `TALabDetail`, `TALabSubmission`, `TALabTaskItem`, `TALabQuestion`, `TALabActivityItem`, `TALabSession`, `TALabStudent`, `TAGradingTask`, `TALabItem`), if any exist as separate files (not inline in screens), delete them
- [ ] T052 [P] Scan for unused imports in all modified TA files — remove imports of deleted mock model classes, unused `TAColors` references to removed widgets, dead `TALabsListScreen` helper functions
- [ ] T053 [P] Run `flutter analyze` on all modified files — fix any analyzer errors, unused variables, dead code warnings
- [ ] T054 [P] Run `flutter test` — ensure all existing tests pass, no regressions introduced by mock data removal
- [ ] T055 Verify role-based access control — confirm all TA CRUD actions are gated by `teaching_assistant` role check (UI hides actions for non-TA users), confirm 403 responses display appropriate error messages
- [ ] T056 Verify section-scoped data access — confirm TA only sees data for their assigned sections (backend-enforced, but verify frontend doesn't accidentally show course-wide data)
- [ ] T057 Update `QWEN.md` with Phase 8 completion summary — add entry documenting TA courses, assignments, labs integration, list of files modified/created, mock patterns eliminated

---

## Implementation Strategy

### MVP (Minimum Viable Product)
Complete **Phases 2-5** (Foundational + US1 + US2 + US3):
- TA can view assigned courses from backend
- TA can view course detail with 9 sub-tabs (live API or empty states)
- TA can create, edit, delete assignments
- TA can grade assignment submissions

This gives TAs their core academic workflow immediately.

### Incremental Delivery
1. **After Phase 2**: BLoC layer ready — can test data fetching independently
2. **After Phase 3**: TA course browsing works — end-to-end testable
3. **After Phase 4**: TA can manage assignments — CRUD complete
4. **After Phase 5**: TA can grade assignments — full P1 scope delivered
5. **After Phase 6**: TA labs list/detail work with live API — P2 scope starts
6. **After Phase 7**: TA can grade lab submissions
7. **After Phase 8**: TA can mark lab attendance
8. **After Phase 9**: TA can upload lab instructions and materials — full feature complete
9. **After Phase 10**: All mock data eliminated, orphan files cleaned, tests passing

### Parallel Execution Opportunities
- **T008-T016** (9 sub-tab widgets) can be developed in parallel by different implementers — each widget is independent, shares `TAColors` and empty state patterns
- **T017-T022** (US2 assignment CRUD) can proceed in parallel with **T023-T028** (US3 assignment grading) — they touch different files
- **T029-T035** (US4 lab CRUD screen rewrites) can proceed in parallel with **T036-T040** (US5 lab grading) and **T041-T044** (US6 attendance) — all within lab detail but different tabs
- **T049-T057** (Phase 10 polish) — T051, T052, T053, T054 can run in parallel
