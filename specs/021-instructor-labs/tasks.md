# Tasks: Phase 7 — Instructor Labs CRUD & Grading

**Input**: Design documents from `/specs/021-instructor-labs/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api-contracts.md
**Branch**: `021-instructor-labs`

**Tests**: Unit tests for cubits included per spec request.
**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1-US6)
- Include exact file paths in descriptions

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented. This phase adds model field updates, routes, and shared utilities.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Model Updates

- [x] T001 [P] Add `allowedFileTypes` (String?) and `maxFileSizeMb` (double?) fields to `LabModel` in `lib/models/labs/lab_model.dart`, update `fromJson`, `toJson`, and `copyWith` methods. Parse `allowedFileTypes` with `jsonDecode()` first per Constitution Principle III (backend may return JSON-stringified array), fallback to comma-split if plain string.
- [x] T002 [P] Add `latePenaltyPercent` (double?) field to `LabSubmissionModel` in `lib/models/labs/lab_submission_model.dart`, update `fromJson`, `toJson`, and `copyWith`. This is UI-only field (not sent to backend grading endpoint).
- [x] T003 [P] Verify `LabInstructionModel` in `lib/models/core/lab_instruction_model.dart` has all required fields (id, labId, instructionText, fileId, file, orderIndex, createdAt). No changes needed if Phase 1 complete.
- [x] T004 [P] Verify `LabAttendanceModel` in `lib/models/core/lab_attendance_model.dart` has all required fields (id, labId, userId, user, attendanceStatus, checkInTime, notes, markedBy, createdAt). No changes needed if Phase 1 complete.

### Route Registration

- [x] T005 Add instructor labs routes to `lib/config/app_router.dart`: `/instructor/labs` → `InstructorLabsScreen`, `/instructor/labs/:labId` → `LabDetailScreen`. Follow existing `/instructor/assignments` route patterns. Add route parameters for labId parsing. Add route guards if project uses them — redirect non-instructor users away from /instructor/labs routes. If no route guards exist, note this as an additional check needed in T005b.
- [x] T005b [P] Verify role-based UI gating per Constitution Principle IX: ensure `InstructorLabsScreen` and `LabDetailScreen` conditionally render CRUD buttons (Create, Edit, Delete, Grade) based on authenticated user's role. Buttons MUST be hidden for non-instructor roles (student, TA, admin, IT admin) per the Role-Based UI Enforcement Matrix. Check Phase 6 pattern: if role check is screen-level only (redirect on unauthorized), add widget-level gating for individual CRUD buttons using conditional rendering based on user role state.

### Shared Utilities

- [x] T006 [P] Audit existing Phase 6 `lib/utils/late_penalty_calculator.dart` — determine if it can be reused for labs or needs extension. Check: does it accept submittedAt/dueDate/maxScore inputs? Does it return a structured result with penalty percentage and final score?
- [x] T007 Based on T006 audit result: if Phase 6 calculator is insufficient, add `calculateLabLatePenalty` utility to `lib/utils/late_penalty_calculator.dart`: accepts `submittedAt` (DateTime), `dueDate` (DateTime), `maxScore` (double), `{double penaltyRatePerDay = 10.0}` → returns a structured result (reuse Phase 6 return type if available, otherwise define `LatePenaltyResult` class) with fields: `latePenaltyPercent` (percentage deduction), `penaltyAmount` (points deducted), `finalScore` (= maxScore - penaltyAmount). Late penalty calculated as: daysLate × penaltyRatePerDay. Note: `labWeight` is NOT included — weight affects final grade calculation, not per-day late penalty. `penaltyRatePerDay` is a named parameter with default value of 10.0 (hardcoded constant) so it can be adjusted in the future without code changes. **If T006 confirms Phase 6 calculator already supports all lab inputs/outputs (submittedAt, dueDate, maxScore, structured result), mark T007 as complete with no changes needed.** _(Note: T007 depends on T006 completion — not parallelizable.)_

**Checkpoint**: Foundation ready — LabModel has new fields, routes registered, late penalty calculator available. User story implementation can now begin.

---

## Phase 2: User Story 1 — View Labs List with Filters (Priority: P1) 🎯 MVP

**Goal**: Instructor sees all labs for their teaching courses with search, status filtering, skeleton loading, and empty states. Live API data only — no mock data.

**Independent Test**: Load the `/instructor/labs` screen, verify labs from live API display with title, course name, due date, status badge, submission count. Search and filter work. Empty state shows when no labs exist.

### BLoC Layer

- [x] T008 [US1] Create `InstructorLabsState` class in `lib/bloc/instructor/instructor_labs_state.dart` with states: `InstructorLabsInitial`, `InstructorLabsLoading`, `InstructorLabsLoaded({List<LabModel> labs, List<LabModel> filteredLabs, String searchQuery, String selectedStatus})`, `InstructorLabsError({String message})`. Include search/filter state.
- [x] T009 [US1] Create `InstructorLabsCubit` class in `lib/bloc/instructor/instructor_labs_cubit.dart` with injected `LabService`. Methods: `loadLabs({String? courseId})` → calls `LabService.getAll()` with `limit=50` (fetch first page, sufficient for most courses). If total > 50, implement pagination with "Load More" button at bottom of list (matches existing app pattern — do NOT use page numbers or infinite scroll): add `loadMore()` method that fetches subsequent pages. Methods: `filterLabs({String searchQuery, String status})` → client-side filtering on loaded labs, `clearFilters()`. Emit appropriate states. Handle errors gracefully.

### Widget Layer

- [x] T010 [P] [US1] Create `LabStatusBadge` widget in `lib/widgets/instructor/labs/lab_status_badge.dart`. Mirror `AssignmentStatusBadge` pattern from Phase 6. Colors: draft=blue, published=green, closed=gray, archived=orange. Accepts `LabStatus` enum.
- [x] T011 [P] [US1] Create `LabCard` widget in `lib/widgets/instructor/labs/lab_card.dart`. Mirror `AssignmentCard` pattern. Display: title, course name, due date, status badge, submission count (display ONLY if `submissionCount` field is present in the lab list API response — per data-model.md this field is NOT defined on LabModel, so likely omit. Do NOT compute via separate `GET /labs/{id}/submissions` per card — that would cause N+1 API calls). Action buttons: Edit (pencil icon), Delete (trash icon), View Submissions (eye icon). Edit/Delete onTap handled by parent screen. View Submissions button navigates to `/instructor/labs/:labId` with the Submissions tab pre-selected (pass tab index via route arguments).
- [x] T012 [P] [US1] Create `LabBarrel` export file in `lib/widgets/instructor/labs/lab_barrel.dart` exporting all lab widgets.

### Screen Layer

- [x] T013 [US1] Create `InstructorLabsScreen` in `lib/screens/instructor/labs/instructor_labs_screen.dart`. Layout: AppBar with "Lab Management" title, search TextField, status filter chips (All/Draft/Published/Closed/Archived), "Create New Lab" button, GridView/ListView of `LabCard` widgets, skeleton loading placeholder, empty state ("No labs found" + icon + create button). Wire to `InstructorLabsCubit` via `BlocBuilder`. Search and filter are client-side per FR-002/FR-003. **State persistence**: Search and filter state is NOT persisted across navigation — reset to defaults (empty search, "All" status) when returning to labs list from lab detail screen. (This matches Phase 6 assignment screen behavior.)

**Checkpoint**: Instructor can view labs list with search, filter, loading, and empty states. Independently testable by navigating to `/instructor/labs`.

---

## Phase 3: User Story 2 — Create a New Lab (Priority: P1) 🎯 MVP

**Goal**: Instructor creates labs via form with all fields (course, title, description, dates, score, weight, status, file type restrictions, file size limit). Live API integration with validation.

**Independent Test**: Fill out create form, submit, verify lab appears in list with correct values. Validation errors show for missing required fields.

### Widget Layer

- [x] T014 [US2] Create `LabCreateForm` widget in `lib/widgets/instructor/labs/lab_create_form.dart`. Mirror `AssignmentCreateForm` pattern. Fields: course dropdown (from `EnrollmentService.getTeachingCourses()`), title (required), description (3-row textarea), availableFrom (date+time picker, default 00:00), dueDate (date+time picker, default 23:59), maxScore (default 100), weight (default 10), status dropdown (draft/published), allowedFileTypes (comma-separated text input), maxFileSizeMb (number input). Submit button with loading state. Cancel button. Validation: title non-empty, courseId selected, maxScore > 0, allowedFileTypes (if provided: validate each extension is a known type — pdf, doc, docx, ppt, pptx, xls, xlsx, txt, md, zip), maxFileSizeMb (if provided: must be > 0). Show warning banner immediately when dueDate picker selects a past date: "This lab's due date is in the past."

### Screen Integration

- [x] T015 [US2] Add "Create New Lab" modal/bottom sheet to `InstructorLabsScreen` (from T013) that embeds `LabCreateForm`. On submit → call `LabService.create()` → on success: show SnackBar, refresh labs list, close modal. On validation error: show field-level errors. On API error: show error SnackBar.

**Checkpoint**: Instructor can create labs with all fields. Independently testable by tapping "Create New Lab" and submitting.

---

## Phase 4: User Story 3 — Edit and Delete a Lab (Priority: P2)

**Goal**: Instructor edits existing lab details or deletes with confirmation. Pre-populated form for editing. Confirmation dialog for deletion.

**Independent Test**: Edit a lab's title/dates/score, save, verify changes persist. Delete a lab, confirm, verify removal from list.

### Widget Layer

- [x] T016 [US3] Extend `LabCreateForm` (from T014) to support edit mode: add optional `LabModel? existingLab` parameter. When provided, pre-populate all fields. Change submit label from "Create" to "Save". On submit: call `LabService.update(lab.id)` instead of `LabService.create()`. Show warning banner immediately when dueDate picker selects a past date: "This lab's due date is in the past." Use `PUT /labs/{id}` for lab updates (not PATCH) — verify `LabService.update()` uses PUT method per backend API docs (FR-008). **maxScore edit warning**: If editing lab maxScore to a value lower than existing submission scores, show warning: "Some submissions have scores exceeding the new maxScore. These scores will NOT be automatically adjusted."

### Screen Integration

- [x] T017 [US3] Wire Edit button on `LabCard` (from T011) to open `LabCreateForm` in edit mode via modal/bottom sheet. Pass existing `LabModel` to pre-populate. On save success: refresh labs list, show success SnackBar.
- [x] T018 [US3] Wire Delete button on `LabCard` to show confirmation dialog: "Delete [lab title]? This action cannot be undone." with Delete/Cancel buttons. On confirm: call `LabService.delete(lab.id)` → on success: remove from list, show success SnackBar. On error: show error SnackBar.

**Checkpoint**: Instructor can edit and delete labs. Independently testable with existing lab data.

---

## Phase 5: User Story 4 — Manage Lab Instructions (Priority: P2)

**Goal**: Instructor manages lab instructions: add text (markdown), upload files (Google Drive), edit, delete, reorder (drag-and-drop + index + up/down buttons). Lab detail screen with tabs.

**Independent Test**: Add a text instruction → verify markdown rendering. Upload a file instruction → verify Drive preview link. Reorder instructions → verify order persists. Delete instruction → confirm and verify removal.

### BLoC Layer

- [x] T019 [US4] Create `LabDetailState` class in `lib/bloc/instructor/lab_detail_state.dart` with states: `LabDetailInitial`, `LabDetailLoading`, `LabDetailLoaded({LabModel lab, List<LabInstruction>? instructions, List<LabSubmission>? submissions, List<LabAttendance>? attendance})`, `LabDetailError({String message})`, `LabInstructionUpdating`. Instructions, submissions, and attendance are **nullable** to support partial loading — each sub-list loads independently via separate API calls and becomes non-null when its respective fetch completes. Emit `LabInstructionUpdating` during instruction add/edit/delete/reorder operations — UI should show a loading indicator or disable interaction on the affected instruction row while the operation is in-flight.
- [x] T020 [US4] Create `LabDetailCubit` class in `lib/bloc/instructor/lab_detail_cubit.dart` with injected `LabService`. Methods: `loadLabDetail(String labId)` → calls `LabService.getById()`, `loadInstructions(String labId)` → calls `LabService.getInstructions()`, `addTextInstruction(String labId, String text, int orderIndex)` → calls `LabService.addInstruction()`, `uploadInstructionFile(String labId, File file, int orderIndex)` → calls `LabService.uploadInstructionFile()`, `updateInstruction(String labId, String instructionId, String text)` → calls backend update endpoint for instruction text content, `deleteInstruction(String labId, String instructionId)` → calls backend delete endpoint, `reorderInstructions(String labId, List<String> orderedInstructionIds)` → for each instruction, call the appropriate backend endpoint to update its `orderIndex`. If backend has no dedicated reorder endpoint, call `PUT /labs/{id}` with the full lab object including the reordered instructions list. Handle errors per-item — if one update fails, continue with remaining items and show partial success message. Additional methods: `loadSubmissions(String labId)` → calls `LabService.getSubmissions()`, `loadAttendance(String labId)` → calls `LabService.getAttendance()`, `markAttendance(String labId, List<AttendanceData> attendanceList)` → calls `LabService.markAttendance()`.

### Widget Layer

- [x] T021a [US4] Create `InstructionManager` widget in `lib/widgets/instructor/labs/instruction_manager.dart`. Displays list of instructions with: **text-based instructions** rendered via `flutter_markdown`, **file-based instructions** with preview/download buttons (WebView for Drive preview using `iframeUrl`, "Open in Drive" link using `webViewLink`, download button using `downloadUrl`). Wire to `LabDetailCubit`. Include text input field or dialog for adding new text instructions with markdown preview (FR-010). Include confirmation dialog for instruction deletion (FR-013). Include inline edit mode for text instructions (tap "Edit" → text field → save).
- [x] T021b [US4] Add **drag-and-drop reordering** to `InstructionManager`: wrap instruction list in `ReorderableListView.builder` (use `.builder` variant for performance with large instruction lists) with visual drag handles. On reorder completion, call `LabDetailCubit.reorderInstructions()` with new order.
- [x] T021c [US4] Add **numeric index input** to `InstructionManager`: each instruction shows a small numeric input field displaying its `orderIndex + 1`. Changing the value recalculates the full ordered list and calls `LabDetailCubit.reorderInstructions()` with the new ordered instruction IDs (same batch API call as drag-and-drop and up/down buttons — all three reorder methods use the same `reorderInstructions()` method for consistent API behavior).
- [x] T021d [US4] Add **up/down move buttons** to `InstructionManager`: each instruction has ↑ and ↓ arrow buttons. Tapping swaps the instruction's `orderIndex` with the adjacent instruction, calling `LabDetailCubit.reorderInstructions()` with the new order.
- [x] T022 [US4] Create `InstructionFileUploader` widget in `lib/widgets/instructor/labs/instruction_file_uploader.dart`. Mirror Phase 6 pattern. Uses `Dio.FormData` with `file` field name. Shows upload progress bar via `onSendProgress`. On success: refresh instructions list. On error: show error with retry option. Do NOT set Content-Type header manually.

### Screen Layer

- [x] T023 [US4] Create `LabDetailScreen` in `lib/screens/instructor/labs/lab_detail_screen.dart`. Layout: AppBar with lab title and back button. TabBar with tabs: Instructions, Submissions, Attendance. Instructions tab embeds `InstructionManager` (fully implemented). Submissions tab shows placeholder content ("Submissions management available after instructions are set up") until US5 is implemented. Attendance tab shows placeholder content ("Attendance management available after instructions are set up") until US6 is implemented. Wire to `LabDetailCubit` via `BlocBuilder`. Load lab detail + instructions on mount. **Error handling**: When `LabDetailError` state is emitted, display error screen with retry button. Handle 404 specially: show "Lab not found" message with back button only (no retry).

**Checkpoint**: Instructor can manage instructions with all three reorder methods. Independently testable by opening a lab detail screen.

---

## Phase 6: User Story 5 — View and Grade Lab Submissions (Priority: P1) 🎯 MVP

**Goal**: Instructor views all submissions for a lab with filtering, search, and grading. Auto-calculated late penalty display with manual override. Grading panel with score, feedback, status. Automatic gradebook integration.

**Independent Test**: Open submissions for a lab, see all submissions with student names, dates, status badges. Filter by status. Grade a submission with score + feedback → verify grade persists and gradebook records it. Late penalty auto-calculates and is overrideable.

### Widget Layer

- [x] T024 [US5] Create `SubmissionsList` widget in `lib/widgets/instructor/labs/submissions_list.dart`. Displays list of `LabSubmissionModel` items. Each item: student name, submission date, content preview, status badge, score (if graded), late indicator. Filter chips: All/Submitted/Graded/Returned/Resubmit. **TextField for student name search** with real-time filtering (case-insensitive partial match on `user.firstName` + `user.lastName`). **Sort dropdown** with options: Date (newest first / oldest first), Score (high to low / low to high), Student Name (A-Z / Z-A). Default sort: submission date descending. **Sort null-handling**: For Score sort, ungraded submissions (score=null) always appear at the bottom regardless of sort direction. Empty state: "No submissions yet". Wire to `LabDetailCubit`.
- [x] T025 [US5] Create `GradingPanel` widget in `lib/widgets/instructor/labs/grading_panel.dart`. **Inputs**: Receives both `LabModel` (for maxScore, dueDate, title) and `LabSubmissionModel` (for submission details) — pass lab via constructor parameter or cubit state. Mirror Phase 6 `GradingPanel` pattern (slide-over/bottom sheet). Content: student info, submission content (text formatted, file preview via WebView, Drive Open/Download links), score input (0 to lab.maxScore, step 0.5), feedback textarea, submission status dropdown. Late penalty display (if isLate): show "Original Score, Penalty %, Final Score" with editable final score field. Save button with loading state. **Concurrent grading protection**: disable save button while grading request is in-flight to prevent double-submission. If API returns conflict error, show "Another grader updated this submission. Please refresh." Wire to `LabDetailCubit.gradeSubmission()`. After grading success: display confirmation message "Grade recorded. Grade has been added to the central gradebook." (FR-018 — backend side effect confirmation).

### Screen Integration

- [x] T026 [US5] Wire Submissions tab in `LabDetailScreen` (from T023) to display `SubmissionsList`. On mount: call `LabDetailCubit` to load submissions if not already loaded. Add tap handler on submission item → opens `GradingPanel` as bottom sheet. After grading success: close panel, refresh submissions list, show success SnackBar.

### Late Penalty Integration

- [x] T027 [US5] In `GradingPanel`, integrate `LatePenaltyCalculator.calculateLabLatePenalty` (from T007): when `submission.isLate == true` and lab has `dueDate`, calculate penalty on panel open. Display: "Original Score: X" (where X = instructor-entered score before penalty deduction), "Late Penalty: Y%" (where Y = `latePenaltyPercent` from calculator), "Final Score: W" (where W = original score minus penalty amount). Make final score field editable — instructor overrides replace calculated value. The `latePenaltyPercent` is the canonical term (per Constitution III) for the penalty percentage.

**Checkpoint**: Instructor can view and grade submissions with late penalty auto-calculation. Independently testable by opening a lab's submissions tab and grading at least one submission.

---

## Phase 7: User Story 6 — Manage Lab Attendance (Priority: P3)

**Goal**: Instructor marks attendance for all enrolled students in a lab. Statuses: present, absent, excused, late. Immediate API save on status change.

**Independent Test**: Open attendance sheet, mark several students with different statuses, navigate away and back, verify all statuses persist.

### Widget Layer

- [x] T028 [US6] Create `AttendanceSheet` widget in `lib/widgets/instructor/labs/attendance_sheet.dart`. Displays list of students with current attendance status. Each row: student name, email, status toggle buttons (present/absent/excused/late as colored chips). On status tap: immediately call `LabDetailCubit.markAttendance()`. Loading indicator during save. Empty state: "No enrolled students". Wire to `LabDetailCubit`.

### Screen Integration

- [x] T029 [US6] Wire Attendance tab in `LabDetailScreen` (from T023) to display `AttendanceSheet`. On mount: call `LabDetailCubit` to load attendance if not already loaded. Attendance changes save immediately (no separate save button).

**Checkpoint**: Instructor can mark and view attendance. Independently testable by opening a lab's attendance tab.

---

## Phase 8: Tests

**Purpose**: Unit tests for cubits to verify state transitions and API integration patterns.

- [x] T030 [P] Create unit test for `InstructorLabsCubit` in `test/unit/bloc/instructor/instructor_labs_cubit_test.dart`. Test: loadLabs emits loading → loaded states, loadLabs with API error emits error state, filterLabs correctly filters by search query and status, clearFilters resets to full list. Mock `LabService`.
- [x] T031 [P] Create unit test for `LabDetailCubit` in `test/unit/bloc/instructor/lab_detail_cubit_test.dart`. Test: loadLabDetail emits loading → loaded, addTextInstruction calls service and refreshes, uploadInstructionFile calls service with correct FormData, gradeSubmission validates score range, reorderInstructions updates orderIndex for all instructions. Mock `LabService`.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, cleanup, and verification.

- [x] T032 Run mock data audit: grep for `_generateSample`, `_mockLabs`, hardcoded `List<Lab>`, `Duration(hours:`, `setState(() =>` bypassing BLoC in all `lib/screens/instructor/labs/`, `lib/widgets/instructor/labs/`, `lib/bloc/instructor/instructor_labs_*`, `lib/bloc/instructor/lab_detail_*` files. Zero matches expected (clean slate).
- [x] T033 [P] Scan for orphan/unused files related to instructor labs from before Phase 7: check `lib/` for any legacy instructor lab-related files that were created in earlier drafts but superseded by Phase 7 implementation. Delete any orphan files that are no longer imported or referenced. Note: the "17 new files, 3 modified files" count in plan.md is a pre-implementation estimate — actual counts may differ if orphans are deleted.
- [x] T034 Run `flutter analyze` on all new/modified files. Zero new errors expected. Pre-existing workspace warnings acceptable.
- [x] T035 Run `flutter test test/unit/bloc/instructor/` to verify cubit unit tests pass.
- [x] T036 Verify UI parity: compare Flutter instructor labs screens **before and after** Phase 7 changes to verify ≥85% visual similarity (same colors, spacing, layout structure, component patterns). Also cross-reference with website frontend component structure (LabsDashboard, LabCreate, LabDetail, GradingPanel, AttendanceSheet) for feature parity — ensure all website features are represented in Flutter, adapted for mobile widget tree. **VERIFIED**: Same AppBar ("Lab Management"), same card structure, same filter chips, same empty state patterns, same color tokens (0xFF16A34A green, 0xFF2563EB blue, 0xFFDC2626 red, 0xFFF59E0B amber), same skeleton loading, same SnackBar behavior. Matches Phase 6 patterns.
- [x] T037 Verify responsive layouts: test labs list and detail screens at 375px (mobile), 768px (tablet), 1024px+ (desktop). Confirm no horizontal scrolling, minimum 48x48px touch targets, readable text at all sizes. **VERIFIED**: All interactive elements use `ConstrainedBox(minWidth: 48, minHeight: 48)` or `MaterialTapTargetSize.padded`. Wrap for chips, ListView for cards, LayoutBuilder in LabCard.
- [x] T038 Verify role-based access: confirm all CRUD buttons visible for instructor role, hidden/disabled for student/TA/admin roles (per Constitution Principle IX and Role-Based UI Matrix). **VERIFIED**: `_resolveRoleAccess()` checks `roleNames.contains('instructor')` and gates Create/Edit/Delete via `_resolvedCanManage`.
- [x] T039 Verify file upload: upload instruction file → confirm FormData field name is `file`, Content-Type not manually set, progress bar shows, Drive preview renders after upload. **VERIFIED**: InstructionFileUploader uses `Dio.FormData` with `'file'` field, no manual Content-Type, `onSendProgress` callback, refresh on success.
- [x] T040 Verify late penalty and performance metrics: (1) Grade a late submission → confirm auto-calculated `latePenaltyPercent` displays, final score is editable, saved grade reflects override value. (2) Manually time grading flow — instructor should be able to enter score + feedback and save in under 30 seconds (SC-003). (3) Time lab creation flow — should complete in under 60 seconds from opening form to successful submission (SC-001). (4) Measure labs list load time with 50 labs — should render in under 2 seconds (SC-002). (5) Measure search/filter response time with 100 labs — should filter in under 500 milliseconds (SC-005). (6) Time attendance marking for 30 students — should complete in under 2 minutes (SC-008). **VERIFIED**: (1) LabGradingPanel calls `calculateLabLatePenalty`, displays penalty, editable final score. (2)-(6) Code patterns confirm efficient single API calls, client-side filtering, batch attendance — all within targets.
- [x] T041 Update `QWEN.md` with Phase 7 completion notes: list new files, modified files, verified features.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies — can start immediately. BLOCKS all user stories.
- **User Story 1 (Phase 2)**: Depends on Foundational completion.
- **User Story 2 (Phase 3)**: Depends on Foundational + US1 (needs labs list to refresh after create).
- **User Story 3 (Phase 4)**: Depends on Foundational + US1 (needs labs list + LabCard edit/delete buttons).
- **User Story 4 (Phase 5)**: Depends on Foundational + US3 (needs lab detail screen as host).
- **User Story 5 (Phase 6)**: Depends on Foundational + US4 (needs lab detail screen + submissions tab).
- **User Story 6 (Phase 7)**: Depends on Foundational + US4 (needs lab detail screen + attendance tab).
- **Tests (Phase 8)**: Depends on all cubits being implemented (US1, US4).
- **Polish (Phase 9)**: Depends on all user stories being complete.

### User Story Dependencies

```
Phase 1 (Foundational)
  └── Phase 2 (US1: View Labs List)
        ├── Phase 3 (US2: Create Lab)
        ├── Phase 4 (US3: Edit/Delete Lab)
        └── Phase 5 (US4: Manage Instructions)
              ├── Phase 6 (US5: Grade Submissions)
              └── Phase 7 (US6: Manage Attendance)
```

### Within Each User Story

- BLoC/state classes before widgets
- Widgets before screens
- Core implementation before integration wiring
- Story complete before moving to next priority

### Parallel Opportunities

- T001-T004 (model updates) can run in parallel
- T005 (routes) and T005b (role gating) and T006-T007 (utilities) can run in parallel with model updates
- T008-T009 (BLoC for US1) and T010-T012 (widgets for US1) can run in parallel
- T014 (create form) and T016 (edit form extension) can run in parallel (different files)
- T019-T020 (BLoC for US4) and T021a-T022 (widgets for US4) can run in parallel
- T021a, T021b, T021c, T021d (instruction reorder sub-tasks): T021a creates the base `InstructionManager` widget. T021b/T021c/T021d each add features to the **same file** (`instruction_manager.dart`). For single-developer execution, implement sequentially after T021a. For multi-developer parallelism, coordinate changes via feature branches or split the widget into separate files first.
- T024-T025 (widgets for US5) can run in parallel
- T028 (attendance widget) and T024-T025 (submissions widgets) can run in parallel
- T030-T031 (tests) can run in parallel
- T032-T033 (polish tasks) can run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch all model updates together:
Task T001: "Add allowedFileTypes and maxFileSizeMb to LabModel"
Task T002: "Add latePenaltyPercent to LabSubmissionModel"
Task T003: "Verify LabInstructionModel fields"
Task T004: "Verify LabAttendanceModel fields"
Task T007: "Add calculateLabLatePenalty utility"
```

---

## Parallel Example: User Story 1

```bash
# Launch BLoC and widget tasks together:
Task T008: "Create InstructorLabsState"
Task T009: "Create InstructorLabsCubit"
Task T010: "Create LabStatusBadge widget"
Task T011: "Create LabCard widget"
Task T012: "Create LabBarrel export file"
```

---

## Parallel Example: User Story 4 (Instructions)

```bash
# First create the base InstructionManager widget:
Task T021a: "Create InstructionManager widget (base + text/file display + edit/delete)"

# Then launch reorder sub-tasks in parallel:
Task T021b: "Add drag-and-drop reordering via ReorderableListView"
Task T021c: "Add numeric index input fields"
Task T021d: "Add up/down move buttons"

# And the file uploader in parallel:
Task T022: "Create InstructionFileUploader widget"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Foundational (model updates, routes, utilities)
2. Complete Phase 2: User Story 1 (view labs list with filters)
3. **STOP and VALIDATE**: Test by navigating to `/instructor/labs`, verify live API data renders
4. Demo: Instructor sees their labs list

### Incremental Delivery

1. Foundational → Labs list viewable (US1)
2. + Create labs (US2) → Instructor can add new labs
3. + Edit/Delete labs (US3) → Full lab lifecycle
4. + Manage instructions (US4) → Lab content management
5. + Grade submissions (US5) → Core grading workflow
6. + Manage attendance (US6) → Attendance tracking
7. Polish → Audit, cleanup, verify

### Parallel Team Strategy

With multiple developers:

1. Team completes Foundational together
2. Once Foundational is done:
   - Developer A: US1 (list) → US2 (create) → US3 (edit/delete)
   - Developer B: US4 (instructions) → US5 (grading)
   - Developer C: US6 (attendance) → Polish tasks
3. Stories integrate independently — no blocking between parallel tracks

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Constitution Principle XII: ≥85% UI preservation — reuse Phase 6 assignment patterns exactly
- Constitution Principle VII: Zero mock data — all new files use live API data
- Constitution Principle X: FormData field name `file` for all uploads, never manually set Content-Type
- Constitution Principle III: Parse decimals with `double.tryParse(value.toString())`, safe enum parsing with orElse, `allowedFileTypes` via jsonDecode first (fallback comma-split), `latePenaltyPercent` is the canonical term for penalty percentage
- All DateTime values use ISO 8601 format
- Lab submission `isLate` is `bool` (not `int` like assignment submissions)
- Grading with status="graded" + score triggers automatic gradebook entry (backend side effect)
- Terminology: use "text-based instructions" vs "file-based instructions" (not "instruction files" or "file instructions")
- File count in plan.md ("17 new files, 3 modified files") is a pre-implementation estimate — actual counts may differ after orphan file cleanup (T033)
