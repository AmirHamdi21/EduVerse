# Tasks: TA Ã¢â‚¬â€ Courses, Assignments & Labs Integration

**Feature**: Phase 8 Ã¢â‚¬â€ TA Courses, Assignments & Labs Integration
**Branch**: `022-ta-courses-assignments-labs`
**Generated**: 2026-04-14
**Spec**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Research**: [research.md](./research.md) | **Data Model**: [data-model.md](./data-model.md) | **Contracts**: [contracts/api-contracts.md](./contracts/api-contracts.md)

## Dependencies & Story Order

```
Phase 2 (Foundational: TA Cubits) 
    Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 3 (US1: TA Courses & Details) [P1]
    Ã¢â€â€š       Ã¢â€Å“Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 4 (US2: TA Assignment CRUD) [P1]
    Ã¢â€â€š       Ã¢â€â€š       Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 5 (US3: TA Assignment Grading) [P1]
    Ã¢â€â€š       Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 6 (US4: TA Lab CRUD) [P2]
    Ã¢â€â€š               Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 7 (US5: TA Lab Grading) [P2]
    Ã¢â€â€š                       Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 8 (US6: TA Lab Attendance) [P2]
    Ã¢â€â€š                               Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 9 (US7: TA Lab Materials Upload) [P3]
    Ã¢â€â€Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€ â€™ Phase 10 (Polish & Cleanup)
```

**Independent Test Criteria per Story**:
- **US1**: TA logs in, sees courses from backend, taps course, views 9 sub-tabs with live/empty data
- **US2**: TA creates an assignment, edits it, deletes it Ã¢â‚¬â€ all via live API
- **US3**: TA views assignment submissions, filters, grades one Ã¢â‚¬â€ status updates to "graded"
- **US4**: TA creates a lab, edits it, views detail with submissions Ã¢â‚¬â€ all via live API
- **US5**: TA grades a lab submission with score + feedback + status Ã¢â‚¬â€ persists to backend
- **US6**: TA marks attendance for all students in a lab Ã¢â‚¬â€ records persist
- **US7**: TA uploads instruction file and TA material file Ã¢â‚¬â€ visible to correct audiences

**Suggested MVP Scope**: US1 + US2 + US3 (P1 stories) Ã¢â‚¬â€ TA can view courses, manage assignments, and grade submissions.

**Parallel Opportunities**:
- US2 and US3 can proceed in parallel after US1 (assignment CRUD and grading are independent workflows)
- US4, US5, US6 can proceed in parallel after US1 (lab CRUD, grading, attendance share lab detail screen)
- All sub-tab widgets (Phase 3) can be developed in parallel once BLoC is ready

---

## Phase 1: Setup

_Phase 1 setup is handled within T005 (Phase 2): BLoC registration in `lib/main.dart` is the only new startup wiring required. Verify during T005 that `pubspec.yaml` requires no new additions (no new dependencies are needed for this phase)._

---

## Phase 2: Foundational Ã¢â‚¬â€ TA Cubits & States

**Goal**: Create BLoC/Cubit classes for TA course list and TA labs list. These block all user story phases.

- [x] T001 Create `TACoursesCubit` in `lib/bloc/ta/ta_courses_cubit.dart` Ã¢â‚¬â€ constructor takes **6 injected services** (all required): `EnrollmentService`, `SectionService`, `LabService`, `CourseService`, `MaterialService`, `AssignmentService`; declare the following named methods: `fetchTACourses()` (calls `EnrollmentService.getTeachingCourses()`), `fetchCourseOverview(courseId)` (aggregates course info + section stats, replaces old `fetchCourseDetail`), `fetchCourseSectionsAndLabs(courseId)` (calls `SectionService.getByCourse(courseId)` + `LabService.getAll({courseId})`), `fetchCourseStructure(courseId)` (calls `CourseService.getStructure(courseId)`), `fetchCourseMaterials(courseId)` (calls `MaterialService.getMaterials(courseId)`), `fetchCourseAssignments(courseId)` (calls `AssignmentService.getAll({courseId})`), `fetchPendingGrading(courseId)` (calls `AssignmentService.getAll({courseId})` + filters for ungraded submissions), `fetchAttendanceSummary(courseId)` (calls `LabService.getAll({courseId})` then `LabService.getAttendance(labId)` for each lab Ã¢â‚¬â€ N sequential calls aggregated client-side), `fetchSectionStudents(sectionId)` (calls `EnrollmentService.getSectionStudents(sectionId)`), `deleteAssignment(courseId, assignmentId)` (calls `AssignmentService.delete(assignmentId)`, on success internally calls `fetchCourseAssignments(courseId)` to refresh the assignments list Ã¢â‚¬â€ emits updated `assignmentsData` via compound state `copyWith`); each method emits updates to the **compound `TACoursesState`** (see T002) Ã¢â‚¬â€ never resets sibling tabs' data
- [x] T002 Create `TACoursesState` in `lib/bloc/ta/ta_courses_state.dart` using a **compound state** pattern: a single immutable class `TACoursesState extends Equatable` with a `copyWith()` method for per-tab updates, containing these fields: `coursesStatus` (`TASubTabState<List<TeachingCourseModel>>` Ã¢â‚¬â€ for the courses list), `overviewData` (`TASubTabState<TACourseOverview>` Ã¢â‚¬â€ sub-tab 1), `sectionsLabsData` (`TASubTabState<TACourseSectionsLabs>` Ã¢â‚¬â€ sub-tab 2), `structureData` (`TASubTabState<CourseStructureModel>` Ã¢â‚¬â€ sub-tab 3), `materialsData` (`TASubTabState<List<CourseMaterialModel>>` Ã¢â‚¬â€ sub-tab 4), `assignmentsData` (`TASubTabState<List<AssignmentModel>>` Ã¢â‚¬â€ sub-tab 5), `pendingGradingData` (`TASubTabState<List<AssignmentSubmissionModel>>` Ã¢â‚¬â€ sub-tab 6), `attendanceSummaryData` (`TASubTabState<List<TALabAttendanceSummary>>` Ã¢â‚¬â€ sub-tab 7), `studentsData` (`TASubTabState<List<UserInfo>>` Ã¢â‚¬â€ sub-tab 8); define `TASubTabState<T>` as a sealed class with: `TASubTabInitial`, `TASubTabLoading`, `TASubTabLoaded(T data)`, `TASubTabError(String message)` Ã¢â‚¬â€ emitting a loading state for tab 4 (`materialsData`) does **NOT** reset tab 2's (`sectionsLabsData`) loaded data; also extend `Equatable` on all sub-state variants with correct `props`
- [x] T003 Create `TALabsCubit` in `lib/bloc/ta/ta_labs_cubit.dart` with methods: `fetchTALabs({String? courseId})` (calls `LabService.getAll({courseId})` Ã¢â‚¬â€ when `courseId` is `null`, fetches ALL TA labs across all assigned courses for the main labs list screen; when provided, filters to one course for course-specific views like the Sections & Labs sub-tab), `fetchLabDetail(labId)` (calls `LabService.getById(labId)` + `LabService.getSubmissions(labId)` + `LabService.getAttendance(labId)` Ã¢â‚¬â€ loads all detail data in one shot; the resulting `TALabDetailLoaded.submissions` and `TALabDetailLoaded.attendance` are reused by T036 and T041 without re-fetching), `refreshLabSubmissions(labId)` (calls `LabService.getSubmissions(labId)` and emits an updated `TALabDetailLoaded` via `copyWith(submissions: refreshedList)` Ã¢â‚¬â€ called by T037 after grade save to refresh only the submissions list without re-fetching lab info or attendance), `refreshLabAttendance(labId)` (calls `LabService.getAttendance(labId)`, emits `TALabAttendanceRefreshing` then `copyWith(attendance: refreshedList)` on `TALabDetailLoaded` Ã¢â‚¬â€ called by T042 after batch attendance save), `deleteLab(labId)` (calls `LabService.delete(labId)`, on success internally calls `fetchTALabs()` to refresh the labs list Ã¢â‚¬â€ emits `TALabsLoading` then updated `TALabsLoaded`; called by T033 on delete confirmation), `gradeLabSubmission(labId, submissionId, score, feedback, status)` (calls `PATCH /labs/{labId}/submissions/{subId}/grade` with `{score, feedback, status}` via `LabService.gradeSubmission()`; **emission order**: current state Ã¢â€ â€™ `TALabGrading` Ã¢â€ â€™ (PATCH success) Ã¢â€ â€™ emit `TALabGradeSuccess` Ã¢â€ â€™ then call `refreshLabSubmissions(labId)` to update the submissions list; on PATCH failure Ã¢â€ â€™ emit `TALabGradeError(message)` Ã¢â‚¬â€ called by T037 on grade save); emit states: `TALabsInitial`, `TALabsLoading`, `TALabsLoaded(List<LabModel>)`, `TALabsError(String)`, `TALabDetailLoading`, `TALabDetailLoaded(LabModel lab, List<LabSubmissionModel> submissions, List<LabAttendanceModel> attendance)`, `TALabDetailError(String)`
- [x] T004 Create TALabsState in `lib/bloc/ta/ta_labs_state.dart` with classes: `TALabsInitial`, `TALabsLoading`, `TALabsLoaded`, `TALabsError`, `TALabDetailLoading`, `TALabDetailLoaded`, `TALabDetailError`, `TALabAttendanceRefreshing` (emitted by `refreshLabAttendance(labId)` before the partial reload Ã¢â‚¬â€ keeps existing attendance data visible in the UI while new data is loading so the tab does not flash to an empty state), `TALabGrading` (emitted by `gradeLabSubmission()` while the PATCH is in flight), `TALabGradeSuccess` (emitted after successful PATCH in `gradeLabSubmission()` and before `refreshLabSubmissions` is called Ã¢â‚¬â€ T037's `BlocListener` responds to show a success toast), `TALabGradeError(String message)` (emitted on PATCH failure in `gradeLabSubmission()` Ã¢â‚¬â€ T037's `BlocListener` responds with an error snackbar)
- [x] T005 Register `TACoursesCubit` and `TALabsCubit` in `lib/main.dart`: declare `late TACoursesCubit _taCoursesCubit` and `late TALabsCubit _taLabsCubit` fields on the app state class; initialize them in `initState()` Ã¢â‚¬â€ **`TACoursesCubit` requires all 6 services**: `TACoursesCubit(enrollmentService: _enrollmentService, sectionService: _sectionService, labService: _labService, courseService: _courseService, materialService: _materialService, assignmentService: _assignmentService)` (verify each `_service` field already exists in app state or declare alongside the cubit fields); `TALabsCubit` requires: `TALabsCubit(labService: _labService)`; add `BlocProvider.value(value: _taCoursesCubit)` and `BlocProvider.value(value: _taLabsCubit)` to the `MultiBlocProvider` list (around line 225, following `_instructorCoursesBloc`); dispose both in `dispose()` via `_taCoursesCubit.close()` and `_taLabsCubit.close()` in `lib/bloc/ta/ta_courses_cubit.dart` Ã¢â‚¬â€ constructor takes **6 injected services** (all required): `EnrollmentService`, `SectionService`, `LabService`, `CourseService`, `MaterialService`, `AssignmentService`; declare the following named methods: `fetchTACourses()` (calls `EnrollmentService.getTeachingCourses()`), `fetchCourseOverview(courseId)` (aggregates course info + section stats, replaces old `fetchCourseDetail`), `fetchCourseSectionsAndLabs(courseId)` (calls `SectionService.getByCourse(courseId)` + `LabService.getAll({courseId})`), `fetchCourseStructure(courseId)` (calls `CourseService.getStructure(courseId)`), `fetchCourseMaterials(courseId)` (calls `MaterialService.getMaterials(courseId)`), `fetchCourseAssignments(courseId)` (calls `AssignmentService.getAll({courseId})`), `fetchPendingGrading(courseId)` (calls `AssignmentService.getAll({courseId})` + filters for ungraded submissions), `fetchAttendanceSummary(courseId)` (calls `LabService.getAll({courseId})` then `LabService.getAttendance(labId)` for each lab Ã¢â‚¬â€ N sequential calls aggregated client-side), `fetchSectionStudents(sectionId)` (calls `EnrollmentService.getSectionStudents(sectionId)`), `deleteAssignment(courseId, assignmentId)` (calls `AssignmentService.delete(assignmentId)`, on success internally calls `fetchCourseAssignments(courseId)` to refresh the assignments list Ã¢â‚¬â€ emits updated `assignmentsData` via compound state `copyWith`); each method emits updates to the **compound `TACoursesState`** (see T002) Ã¢â‚¬â€ never resets sibling tabsÃ¢â‚¬â„¢ data

---

## Phase 3: US1 Ã¢â‚¬â€ TA Views Assigned Courses & Course Details [P1]

**Goal**: TA course list shows live API data. Course detail has 9 sub-tabs with live API fetches and empty-state fallbacks. Modern, colorful UI matching existing TA patterns.

**Independent Test**: TA logs in Ã¢â€ â€™ sees courses from backend Ã¢â€ â€™ taps course Ã¢â€ â€™ sees 9 sub-tabs, each attempting API fetch Ã¢â€ â€™ shows data, empty state, or error appropriately.

- [x] T006 [US1] Rewrite `lib/screens/ta/courses/ta_courses_list_screen.dart` to use `TACoursesCubit` via `BlocBuilder` Ã¢â‚¬â€ remove any remaining hardcoded values, dispatch `fetchTACourses()` in `initState`, show loading/error/loaded states, preserve existing `TAColors` and `TADrawer` patterns, keep filter chips UI structure (Ã¢â€°Â¥85% visual similarity)
- [x] T007 [US1] Rewrite `lib/screens/ta/courses/ta_course_detail_screen.dart` to expand from 4 to 9 sub-tabs Ã¢â‚¬â€ **each sub-tab fires a named `TACoursesCubit` method on first activation** (never direct service calls from the widget layer per Constitution Principle I)
- [x] T008 [P][US1] Update `lib/widgets/ta/courses/ta_course_overview_tab.dart` Ã¢â‚¬â€ implemented inline in T007 with live TACourseOverview data
- [x] T009 [P][US1] Sections & Labs sub-tab Ã¢â‚¬â€ implemented inline in T007 with expandable sections and lab navigation
- [x] T010 [P][US1] Lectures sub-tab Ã¢â‚¬â€ implemented inline in T007 with CourseStructureModel rendering
- [x] T011 [P][US1] Materials sub-tab Ã¢â‚¬â€ implemented inline in T007 with CourseMaterialModel list
- [x] T012 [P][US1] Assignments sub-tab Ã¢â‚¬â€ implemented inline in T007 with AssignmentModel list and TAColors
- [x] T013 [P][US1] Grading sub-tab Ã¢â‚¬â€ implemented inline in T007 with pending grading tasks and navigation
- [x] T014 [P][US1] Attendance sub-tab Ã¢â‚¬â€ implemented inline in T007 with per-lab TALabAttendanceSummary cards
- [x] T015 [P][US1] Students sub-tab Ã¢â‚¬â€ implemented inline in T007 with section-scoped student roster
- [x] T016 [P][US1] Announcements sub-tab Ã¢â‚¬â€ implemented inline in T007 with static empty state

---

## Phase 4: US2 Ã¢â‚¬â€ TA Creates, Edits, and Deletes Assignments [P1]

**Goal**: TA can create, edit, and delete assignments using shared Instructor components. All actions call live backend API.

**Independent Test**: TA creates assignment Ã¢â€ â€™ appears in list Ã¢â€ â€™ edits field Ã¢â€ â€™ saves Ã¢â€ â€™ deletes with confirmation Ã¢â€ â€™ removed from list.

- [x] T017 [US2] Wire TA course detail Assignments sub-tab (from T012) to show "Create Assignment" button that opens the shared Instructor assignment creation form (`lib/widgets/instructor/assignments/assignment_create_form.dart`) Ã¢â‚¬â€ pass `courseId` from current course context, on success call `context.read<TACoursesCubit>().fetchCourseAssignments(courseId)` to refetch via cubit (Constitution Principle I Ã¢â‚¬â€ no direct service calls from widget layer)
- [x] T018 [US2] Wire each assignment card in TA Assignments sub-tab to show "Edit" button Ã¢â‚¬â€ open shared Instructor `assignment_create_form.dart` in edit mode (pre-populated with existing `AssignmentModel` data); the form internally calls `AssignmentService.update(id, data)` on save; the TA tab's `onSuccess` callback calls `context.read<TACoursesCubit>().fetchCourseAssignments(courseId)` to refetch via cubit (Principle I Ã¢â‚¬â€ the TA widget does NOT make the update call directly; the shared form handles the mutation API interaction)
- [x] T019 [US2] Wire each assignment card in TA Assignments sub-tab to show "Delete" button Ã¢â‚¬â€ show confirmation dialog using `showDialog(context, builder: (ctx) => AlertDialog(title: const Text('Delete Assignment'), content: const Text('This action cannot be undone. Delete this assignment?'), actions: [TextButton('Cancel'), TextButton('Delete')]))` (project uses inline `AlertDialog` Ã¢â‚¬â€ no shared `ConfirmDialog` widget exists); on confirm call `context.read<TACoursesCubit>().deleteAssignment(courseId, assignmentId)` (defined in T001 Ã¢â‚¬â€ internally calls `AssignmentService.delete(assignmentId)` then `fetchCourseAssignments(courseId)` to refresh the list via compound state update; Principle I compliant Ã¢â‚¬â€ no direct service call from widget layer)
- [x] T020 [US2] Ensure assignment status transitions (`draft Ã¢â€ â€™ published Ã¢â€ â€™ closed Ã¢â€ â€™ archived`) are available in TA assignment edit flow Ã¢â‚¬â€ reuse Instructor status transition UI from `assignment_create_form.dart` or status badge widget
- [x] T021 [US2] Add assignment instruction file upload to TA assignment edit flow Ã¢â‚¬â€ reuse `lib/widgets/instructor/assignments/instruction_file_uploader.dart` (confirmed exists from Phase 6 QWEN.md); calls `POST /assignments/{id}/instructions/upload` with FormData `file` field; show progress bar via `onSendProgress`
- [x] T022 [US2] Handle 403 Forbidden responses gracefully Ã¢â‚¬â€ the shared `assignment_create_form.dart` MUST expose an `onError(String message)` callback; the TA tab passes `onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)))` to the form; if the backend rejects TA assignment create/edit with 403, the form calls `onError` with message "You don't have permission to manage assignments for this course" and the TA tab surfaces it as a snackbar; for delete, `TACoursesCubit.deleteAssignment()` handles its own 403 error by emitting an error state that the UI listens to via `BlocListener`

---

## Phase 5: US3 Ã¢â‚¬â€ TA Grades Assignment Submissions [P1]

**Goal**: TA can view all submissions for an assignment, filter by status/lateness, and grade pending submissions. Reuses Instructor grading panel.

**Independent Test**: TA opens assignment Ã¢â€ â€™ sees submissions list Ã¢â€ â€™ filters to ungraded Ã¢â€ â€™ selects one Ã¢â€ â€™ enters score + feedback Ã¢â€ â€™ saves Ã¢â€ â€™ status updates to "graded".

- [x] T023 [US3] Create assignment submissions view accessible from TA Assignments sub-tab Ã¢â‚¬â€ when TA taps an assignment card, show submissions list via a **dedicated locally-scoped `TAAssignmentSubmissionsCubit`** (create in `lib/bloc/ta/ta_assignment_submissions_cubit.dart`; NOT globally registered in `lib/main.dart`); methods: `fetchSubmissions(assignmentId)` (calls `AssignmentService.getSubmissions(assignmentId)`), `gradeSubmission(assignmentId, submissionId, score, feedback)` (calls `PATCH /assignments/{aId}/submissions/{sId}/grade`, **emission order MUST be**: `TASubsGrading` Ã¢â€ â€™ (PATCH success) Ã¢â€ â€™ emit `TASubsGradeSuccess` Ã¢â€ â€™ then call `fetchSubmissions(assignmentId)` Ã¢â€ â€™ `TASubsLoading` Ã¢â€ â€™ `TASubsLoaded`; the `TASubsGradeSuccess` MUST be emitted **before** `fetchSubmissions` so T025's `BlocListener` can respond with the success toast before the list reloads); states: `TASubsLoading`, `TASubsLoaded(List<AssignmentSubmissionModel>)`, `TASubsError(String)`, `TASubsGrading`, `TASubsGradeSuccess`, `TASubsGradeError(String)`; the submissions screen provides this cubit locally via `BlocProvider(create: (ctx) => TAAssignmentSubmissionsCubit(assignmentService: ctx.read())..fetchSubmissions(assignmentId))` (Principle I compliant); display student name/email, submission date, attempt number, late indicator, score (if graded), status badge Ã¢â‚¬â€ reuse `widgets/instructor/assignments/submission_list_item.dart`
- [x] T024 [US3] Add filtering to submissions list Ã¢â‚¬â€ filter by status (All/Graded/Ungraded) and lateness (All/Late/On Time), implement as local filter on loaded data (no additional API calls needed)
- [x] T025 [US3] Wire "Grade" action on each ungraded submission to open shared Instructor `widgets/instructor/assignments/grading_panel.dart` Ã¢â‚¬â€ pass `AssignmentSubmissionModel`, `maxScore` from parent assignment, on save call `TAAssignmentSubmissionsCubit.gradeSubmission(assignmentId, submissionId, score, feedback)` (declared in T023 Ã¢â‚¬â€ internally calls `PATCH /assignments/{aId}/submissions/{sId}/grade` and auto-refreshes via `fetchSubmissions()`); use `BlocListener` on `TASubsGradeSuccess` to show success toast and on `TASubsGradeError` to show error snackbar (Principle I compliant Ã¢â‚¬â€ no direct API call from the widget layer)
- [x] T026 [US3] Handle re-grading scenario Ã¢â‚¬â€ if submission already has `gradedBy` and `gradedAt`, show previous grader info and previous score/feedback in grading panel for reference
- [x] T027 [US3] Add unit test asserting `AssignmentSubmissionModel._parseBoolFromIntLike()` correctly maps `0` Ã¢â€ â€™ `false` and `1` Ã¢â€ â€™ `true`; create `test/unit/models/assignments/assignment_submission_model_test.dart` if it does not exist; this test is also validated during the T049 Phase 10 mock audit grep
- [x] T028 [US3] Handle empty submissions list Ã¢â‚¬â€ show structured empty state: "No submissions found for this assignment" with appropriate icon

---

## Phase 6: US4 Ã¢â‚¬â€ TA Creates, Edits, and Views Labs [P2]

**Goal**: Replace all mock data in TA labs screens with live API. TA can create, edit, and view labs using shared Instructor components.

**Independent Test**: TA sees labs from backend Ã¢â€ â€™ creates lab Ã¢â€ â€™ edits lab Ã¢â€ â€™ views detail with submissions.

- [x] T029 [US4] Full rewrite of `lib/screens/ta/labs/ta_labs_list_screen.dart` Ã¢â‚¬â€ remove ALL mock data (6 hardcoded labs, 3 fake courses, `Future.delayed`, local `TALabListItem`/`TACourseWithLabs` classes), replace with `BlocBuilder<TALabsCubit>` dispatching `fetchTALabs()` (no `courseId` argument Ã¢â‚¬â€ fetches all assigned TA labs across all courses for the main list screen); **also in `initState`**: call `context.read<TACoursesCubit>().fetchTACourses()` if `TACoursesCubit.state.coursesStatus` is `TASubTabInitial` Ã¢â‚¬â€ ensures the course list is loaded before the TA might tap Create Lab (T031 needs courses for its form dropdown), organize labs by course section, use `LabModel` canonical model, preserve filter chips UI structure (Ã¢â€°Â¥85% visual similarity), use `TAColors` and `TADrawer`
- [x] T030 [US4] Full rewrite of `lib/screens/ta/labs/ta_lab_detail_screen.dart` Ã¢â‚¬â€ remove ALL mock data (5 `_getMock*()` methods, fake student names, scores, sessions); replace with `BlocBuilder<TALabsCubit>` dispatching `fetchLabDetail(labId)`; display real lab info from `LabModel`; **add a read-only Submissions tab** that displays `LabSubmissionModel[]` from the cubit state (student name, submission date, status badge, score if graded) Ã¢â‚¬â€ this satisfies US4 AC3 ("TA taps View Submissions Ã¢â€ â€™ sees all submissions") and makes US4 independently testable after Phase 6 completes without waiting for Phase 7 grading; use `TAColors` (Ã¢â€°Â¥85% visual similarity)
- [x] T031 [US4] Wire "Create Lab" button in TA Labs list to open shared Instructor `lib/widgets/instructor/labs/lab_create_form.dart` Ã¢â‚¬â€ the form's course selection dropdown shows all TA-assigned teaching courses (sourced from `TACoursesCubit` loaded state via `BlocSelector` Ã¢â‚¬â€ NOT course-scoped; the TA picks any course they teach); show a loading indicator in the course dropdown while `coursesStatus` is `TASubTabLoading` (courses may still be loading if the TA navigated directly to Labs Ã¢â‚¬â€ see T029 guard); on success call `POST /labs`; refetch via `TALabsCubit.fetchTALabs()` (no `courseId` Ã¢â‚¬â€ refreshes the all-courses labs list, matching the screen's initial load); handle `403 Forbidden` responses with a snackbar: "You don't have permission to create labs for this course"
- [x] T032 [US4] Wire "Edit Lab" action in TA Labs list/detail to open shared Instructor `lib/widgets/instructor/labs/lab_create_form.dart` in edit mode (pre-populated with existing `LabModel` data); the form internally calls `PATCH /labs/{id}` on save; the TA screen's `onSuccess` callback calls `context.read<TALabsCubit>().fetchLabDetail(labId)` to refresh the detail screen (if editing from detail) or `context.read<TALabsCubit>().fetchTALabs()` to refresh the list (if editing from list) Ã¢â‚¬â€ both via cubit (Principle I); handle `403 Forbidden` responses via form `onError` callback with snackbar: "You don't have permission to edit this lab"
- [x] T033 [US4] Wire "Delete Lab" action in TA Labs list/detail Ã¢â‚¬â€ check whether submissions exist (from `TALabDetailLoaded.submissions.length` or `LabModel.submissionsCount`): (a) **if submissions exist**, show enhanced data-loss warning: `showDialog(context, builder: (ctx) => AlertDialog(title: Text('Delete Lab'), content: Text('This lab has existing student submissions. Deleting it will permanently remove all submission data. Continue?'), actions: [TextButton('Cancel'), TextButton('Delete Anyway')]))`; (b) **if no submissions**, show standard confirmation: `showDialog(context, builder: (ctx) => AlertDialog(title: Text('Delete Lab'), content: Text('Are you sure you want to delete this lab?'), actions: [TextButton('Cancel'), TextButton('Delete')]))` (project uses inline `AlertDialog` Ã¢â‚¬â€ no shared `ConfirmDialog` widget); on confirm call `context.read<TALabsCubit>().deleteLab(labId)` (defined in T003 Ã¢â‚¬â€ internally calls `LabService.delete(labId)` then `fetchTALabs()` to refresh the list; Principle I compliant Ã¢â‚¬â€ no direct service/API call from widget layer); handle `403 Forbidden` via cubit error state with snackbar: "You don't have permission to delete this lab"
- [x] T034 [US4] Replace local mock model classes in TA labs files with canonical models: remove `TALabListItem`, `TACourseWithLabs`, `TALabDetail`, `TALabTaskItem`, `TALabQuestion`, `TALabActivityItem` Ã¢â‚¬â€ all replaced by `LabModel`, `LabSubmissionModel`, `TeachingCourseModel` from canonical model files
- [x] T035 [US4] Handle empty labs list Ã¢â‚¬â€ show structured empty state: "No labs found for your assigned courses" with beaker icon (matching existing empty state patterns)

---

## Phase 7: US5 Ã¢â‚¬â€ TA Grades Lab Submissions [P2]

**Goal**: TA can view and grade lab submissions. Reuses Instructor lab grading panel.

**Independent Test**: TA opens lab Ã¢â€ â€™ sees submissions Ã¢â€ â€™ selects pending Ã¢â€ â€™ grades with score + feedback + status Ã¢â€ â€™ persists.

- [x] T036 [US5] Wire "View Submissions" action in TA lab detail to display the **already-loaded** submissions from `TALabsCubit`Ã¢â‚¬â„¢s `TALabDetailLoaded.submissions` field (populated during `fetchLabDetail(labId)` called in T030 Ã¢â‚¬â€ **do NOT trigger a new `LabService.getSubmissions()` call here**, as the data is already in the cubit state); display list with student name, date, status, score (if graded); reuse `lib/widgets/instructor/labs/grading_panel.dart` patterns; trigger a submissions refresh only after a grade is saved in T037
- [x] T037 [US5] Wire "Grade" action on pending lab submission to open grading interface Ã¢â‚¬â€ pass `LabSubmissionModel`, `maxScore` from parent lab, allow score input (0-maxScore, step 0.5), feedback textarea, status dropdown (submitted/graded/returned/resubmit), on save call `context.read<TALabsCubit>().gradeLabSubmission(labId, submissionId, score, feedback, status)` (defined in T003 Ã¢â‚¬â€ internally calls `PATCH /labs/{labId}/submissions/{subId}/grade` with `{score, feedback, status}`, emits `TALabGradeSuccess` on success, then auto-calls `refreshLabSubmissions(labId)` to update the submissions list without re-fetching lab info or attendance; Principle I compliant Ã¢â‚¬â€ no direct `LabService`/API calls from widget layer); use `BlocListener` on `TALabGradeSuccess` to show success toast and on `TALabGradeError` to show error snackbar
- [x] T038 [US5] Add unit test asserting `LabSubmissionModel.isLate` correctly deserializes from backend boolean JSON (`true`/`false`) to Dart `bool`; create `test/unit/models/labs/lab_submission_model_test.dart` if it does not exist; this is also verified during the T049 Phase 10 mock audit grep
- [x] T039 [US5] Handle re-grading scenario Ã¢â‚¬â€ if submission already graded, show previous grader info and score for reference, allow score update
- [x] T040 [US5] Handle empty submissions list Ã¢â‚¬â€ show structured empty state: "No submissions found for this lab"

---

## Phase 8: US6 Ã¢â‚¬â€ TA Marks Lab Attendance [P2]

**Goal**: TA can mark attendance for students in a lab session. Reuses Instructor attendance sheet.

**Independent Test**: TA opens attendance for a lab Ã¢â€ â€™ sees student list Ã¢â€ â€™ marks statuses Ã¢â€ â€™ saves Ã¢â€ â€™ records persist on reopen.

- [x] T041 [US6] Wire attendance tab in TA lab detail to read attendance records **from the cubit state** (`TALabDetailLoaded.attendance`, already populated by `fetchLabDetail(labId)` in T030/T003 Ã¢â‚¬â€ do NOT trigger a new `LabService.getAttendance()` call); display student list with current attendance status badges; reuse `lib/widgets/instructor/labs/attendance_sheet.dart` (confirmed exists from Phase 7 QWEN.md Ã¢â‚¬â€ no "if compatible" qualifier)
- [x] T042 [US6] Implement attendance marking UI using a **batch save approach** (SC-007 compliance: all saves < 5s) Ã¢â‚¬â€ for each student, provide a status selector (present/absent/excused/late) using `LabAttendanceStatus` enum; status changes are staged in local widget state without triggering per-toggle API calls; show a "Save Attendance" button that on tap: (1) fires `POST /labs/{id}/attendance` with `{userId, attendanceStatus, notes}` for each changed student **in parallel** via `Future.wait([...])` (avoids N sequential requests for 20+ students), (2) on all futures complete, calls `context.read<TALabsCubit>().refreshLabAttendance(labId)` to refresh attendance via cubit (Principle I); cubit emits `TALabAttendanceRefreshing` during refresh then updated `TALabDetailLoaded.attendance`; show a dismissible loading overlay during the parallel save operation
- [x] T043 [US6] Replace local mock model classes in attendance tab: remove `TALabSession`, `TALabStudent`, `TAAttendanceStatus` enum Ã¢â‚¬â€ replace with `LabAttendanceModel`, `UserInfo`, `LabAttendanceStatus` from canonical model files (`lib/models/core/lab_attendance_model.dart`)
- [x] T044 [US6] Handle empty attendance list Ã¢â‚¬â€ show structured empty state: "No attendance records for this lab"

---

## Phase 9: US7 Ã¢â‚¬â€ TA Uploads Lab Instructions and TA Materials [P3]

**Goal**: TA can add text instructions, upload instruction files, and upload TA-only materials to labs.

**Independent Test**: TA adds text instruction Ã¢â€ â€™ appears in lab Ã¢â€ â€™ uploads file Ã¢â€ â€™ visible to students Ã¢â€ â€™ uploads TA material Ã¢â€ â€™ visible only to instructors/TAs.

- [x] T045 [US7] Wire instruction management in TA lab detail Ã¢â‚¬â€ reuse `widgets/instructor/labs/instruction_manager.dart` for adding text instructions (calls `POST /labs/{id}/instructions`), display ordered by `orderIndex`; **on success, call `context.read<TALabsCubit>().fetchLabDetail(labId)` to refresh the lab detail including updated instructions list (Principle I)**
- [x] T046 [US7] Wire instruction file upload in TA lab detail Ã¢â‚¬â€ reuse `widgets/instructor/labs/instruction_file_uploader.dart` for uploading files to Google Drive (calls `POST /labs/{id}/instructions/upload` with FormData `file` field), show progress bar via `onSendProgress`, client-side validation (50MB docs, 10MB images); **on upload success, call `context.read<TALabsCubit>().fetchLabDetail(labId)` to refresh the lab detail including updated instruction files list (Principle I)**
- [x] T047 [US7] Wire TA materials upload Ã¢â‚¬â€ **the `POST /labs/{id}/ta-materials/upload` endpoint is NOT documented in `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`** (confirmed absent by API docs audit); before implementing, inspect backend source at `<BACKEND_PATH>` for this endpoint; **if found**: create an upload widget calling the confirmed endpoint with FormData `file` field + `onSendProgress`, display uploaded TA materials list with file name and download link; **if NOT found after backend inspection**: render a structured "TA Materials upload is not yet supported by the backend" empty state with an info icon Ã¢â‚¬â€ do NOT block the rest of Phase 9 (T045, T046 use confirmed endpoints and must proceed)
- [x] T048 [US7] Handle file upload errors Ã¢â‚¬â€ show retry option for failed uploads, display appropriate error messages for size/type validation failures

---

## Phase 10: Polish, Cross-Cutting & Cleanup

**Goal**: Final audit, mock data elimination verification, orphan file cleanup, unused file deletion.

- [x] T049 **[PHASE 10 UNIFIED AUDIT Ã¢â‚¬â€ Sub-step A: Mock Data & Model Parsing]** Run mock data audit across all modified TA files Ã¢â‚¬â€ grep for `_generateSample`, `_mock`, `Future.delayed` (in data context), `setState(() =>` (bypassing BLoC for data), hardcoded `List<Lab>`, `List<Course>`, `List<Assignment>` literals Ã¢â‚¬â€ all must return zero results in modified files; also validate that `AssignmentSubmissionModel._parseBoolFromIntLike()` unit tests (T027) and `LabSubmissionModel.isLate` unit tests (T038) pass, consolidating those verifications into this final audit step
- [x] T050 Run visual parity check Ã¢â‚¬â€ compare before/after screenshots of modified TA screens (`ta_courses_list_screen.dart`, `ta_course_detail_screen.dart`, `ta_labs_list_screen.dart`, `ta_lab_detail_screen.dart`) to ensure Ã¢â€°Â¥85% visual similarity (same colors, layout structure, component hierarchy)
- [x] T051 [P] **[PHASE 10 UNIFIED AUDIT Ã¢â‚¬â€ Sub-step B: Orphan Files]** Scan for unused/orphan TA-related files Ã¢â‚¬â€ search `lib/` for files that were replaced or are no longer referenced after this phase: check for local mock model classes that were defined inside screen files and may now be orphaned (`TALabListItem`, `TACourseWithLabs`, `TALabDetail`, `TALabSubmission`, `TALabTaskItem`, `TALabQuestion`, `TALabActivityItem`, `TALabSession`, `TALabStudent`, `TAGradingTask`, `TALabItem`), if any exist as separate files (not inline in screens), delete them
- [x] T052 [P] **[PHASE 10 UNIFIED AUDIT Ã¢â‚¬â€ Sub-step C: Import Cleanup]** Scan for unused imports in all modified TA files Ã¢â‚¬â€ remove imports of deleted mock model classes, unused `TAColors` references to removed widgets, dead `TALabsListScreen` helper functions
- [x] T053 [P] Run `flutter analyze` on all modified files Ã¢â‚¬â€ fix any analyzer errors, unused variables, dead code warnings
- [ ] T054 [P] Run `flutter test` Ã¢â‚¬â€ ensure all existing tests pass, no regressions introduced by mock data removal
- [ ] T055 Verify role-based access control Ã¢â‚¬â€ test both: (a) **screen-level**: non-TA users navigating to TA routes (`/ta/courses`, `/ta/labs`) are redirected away (route guard); (b) **button-level**: Create/Edit/Delete buttons are conditionally hidden when current user role Ã¢â€°Â  `teaching_assistant`; confirm 403 responses from backend display appropriate error snackbars via cubit error states and form `onError` callbacks
- [ ] T056 Verify section-scoped data access Ã¢â‚¬â€ confirm TA only sees data for their assigned sections (backend-enforced, but verify frontend doesn't accidentally show course-wide data)
- [ ] T057 Update `QWEN.md` (project root: `QWEN.md`) with Phase 8 completion summary Ã¢â‚¬â€ add a new "## Phase 8 Update: TA Courses, Assignments & Labs Integration" section documenting: completion date, new/updated files list, mock patterns eliminated, test results snapshot, and phase gate status

- [ ] T058 **[M2 Ã¢â‚¬â€ Mid-session Revocation]** Verify mid-session TA access revocation handling Ã¢â‚¬â€ confirm that when any sub-tab `TACoursesCubit` emits a 403 error state (course access revoked on server), the UI displays "Access revoked. You are no longer assigned to this course." and navigates back to the TA courses list; test by triggering a 403 error state in the Cubit and verifying the BlocListener response
- [ ] T059 [P] **[H1 Ã¢â‚¬â€ FR-023 Responsive Layout]** Responsive layout audit Ã¢â‚¬â€ verify all 4 modified TA screens (`ta_courses_list_screen`, `ta_course_detail_screen`, `ta_labs_list_screen`, `ta_lab_detail_screen`) render correctly at mobile (<600px width), tablet (600Ã¢â‚¬â€œ1024px), and desktop (>1024px) breakpoints; test using Flutter DevTools responsive testing mode or physical devices; fix any overflow or layout collapse issues using `LayoutBuilder` or `MediaQuery.of(context).size.width`
- [ ] T060 [P] **[H2 Ã¢â‚¬â€ FR-024 Touch Targets]** Touch target audit Ã¢â‚¬â€ verify all interactive elements (buttons, chips, list tiles, tab headers) in modified TA screens meet the minimum 48Ãƒâ€”48Ãƒâ€”px touch target size; use Flutter Inspector accessibility overlay to identify undersized targets; fix with `SizedBox`, `InkWell` with `minHeight`/`minWidth`, or `Padding` wrappers as appropriate
- [ ] T061 [P] **[H3 Ã¢â‚¬â€ SC-001 to SC-008 Performance Verification]** Manual performance audit Ã¢â‚¬â€ profile the following using Flutter DevTools Timeline and record actual timings in QWEN.md: (a) TA courses list first-load Ã¢â‚¬â€ target <2s [SC-001]; (b) assignment creation end-to-end (form submit Ã¢â€ â€™ API response Ã¢â€ â€™ list refresh) Ã¢â‚¬â€ target <3s [SC-002]; (c) assignment grade save + status update Ã¢â‚¬â€ target <2s [SC-003]; (d) lab grade save + status update Ã¢â‚¬â€ target <2s [SC-004]; (e) attendance batch save for 20+ students Ã¢â‚¬â€ target <5s [SC-007]; (f) perform 10 consecutive grading actions and verify Ã¢â€°Â¤1 API failure [SC-008 Ã¢â‚¬â€ 95% success rate]

## Implementation Strategy

### MVP (Minimum Viable Product)
Complete **Phases 2-5** (Foundational + US1 + US2 + US3):
- TA can view assigned courses from backend
- TA can view course detail with 9 sub-tabs (live API or empty states)
- TA can create, edit, delete assignments
- TA can grade assignment submissions

This gives TAs their core academic workflow immediately.

### Incremental Delivery
1. **After Phase 2**: BLoC layer ready Ã¢â‚¬â€ can test data fetching independently
2. **After Phase 3**: TA course browsing works Ã¢â‚¬â€ end-to-end testable
3. **After Phase 4**: TA can manage assignments Ã¢â‚¬â€ CRUD complete
4. **After Phase 5**: TA can grade assignments Ã¢â‚¬â€ full P1 scope delivered
5. **After Phase 6**: TA labs list/detail work with live API Ã¢â‚¬â€ P2 scope starts
6. **After Phase 7**: TA can grade lab submissions
7. **After Phase 8**: TA can mark lab attendance
8. **After Phase 9**: TA can upload lab instructions and materials Ã¢â‚¬â€ full feature complete
9. **After Phase 10**: All mock data eliminated, orphan files cleaned, tests passing

### Parallel Execution Opportunities
- **T008-T016** (9 sub-tab widgets) can be developed in parallel by different implementers Ã¢â‚¬â€ each widget is independent, shares `TAColors` and empty state patterns
- **T017-T022** (US2 assignment CRUD) can proceed in parallel with **T023-T028** (US3 assignment grading) Ã¢â‚¬â€ they touch different files
- **T029-T035** (US4 lab CRUD screen rewrites) can proceed in parallel with **T036-T040** (US5 lab grading) and **T041-T044** (US6 attendance) Ã¢â‚¬â€ all within lab detail but different tabs
- **T049Ã¢â‚¬â€œT061** (Phase 10 polish) Ã¢â‚¬â€ T051, T052, T053, T054, T059, T060, T061 can run in parallel







