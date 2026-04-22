# Tasks: Phase 3 — Student Assignments

**Input**: Design documents from `/specs/017-phase-3-student/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Unit tests for BLoC, service, models. Widget tests for screens.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify existing dependencies and project structure

- [X] T001 Verify `flutter_markdown`, `file_picker`, and `webview_flutter` packages are in `pubspec.yaml` (add if missing)
- [X] T002 [P] Verify `AssignmentService` exists and is functional at `lib/services/api/assignment_service.dart`
- [X] T003 [P] Verify `AssignmentModel` exists with all backend fields at `lib/models/assignments/assignment_model.dart`
- [X] T004 [P] Verify `AssignmentSubmissionModel` exists at `lib/models/assignments/assignment_submission_model.dart`
- [X] T005 [P] Verify `DriveFileModel` exists at `lib/models/core/drive_file_model.dart`
- [X] T006 [P] Verify `CoreApiClient` and `ServiceResult<T>` exist and are usable

**Checkpoint**: All Phase 1 dependencies confirmed — foundational work can begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Replace mock `AssignmentsCubit` with real `AssignmentBloc`, add `submissionFilterStatus` computed property, and update `AssignmentsState` for backend-driven data. **CRITICAL: No user story work can begin until this phase is complete.**

### Models Update

- [X] T007 [P] Add `submissionFilterStatus` computed property to `AssignmentModel` in `lib/models/assignments/assignment_model.dart` — returns `"submitted"` if `submission != null`, `"overdue"` if `dueDate.isBefore(DateTime.now()) && submission == null`, `"pending"` otherwise
- [X] T008 [P] Add `hasSubmission` computed property to `AssignmentModel` — returns `true` if submission field is not null

### BLoC Replacement (Mock → Real API)

- [X] T009 Create `AssignmentEvent` base class and events in `lib/bloc/assignments/assignment_event.dart`: `FetchAssignments`, `SelectAssignment`, `SubmitTextAssignment`, `SubmitFileAssignment`, `FetchMySubmission`, `RefreshAssignments`, `ClearError`
- [X] T010 Create `AssignmentState` in `lib/bloc/assignments/assignment_state.dart`: fields — `assignments` (List<AssignmentModel>), `selectedAssignment` (AssignmentModel?), `mySubmission` (AssignmentSubmissionModel?), `isSubmitting` (bool), `submitError` (String?), `isLoading` (bool), `error` (String?), `filterStatus` (enum: all/submitted/pending/overdue), `searchQuery` (String), `totalCount` (int), `submittedCount` (int), `pendingCount` (int), `overdueCount` (int). Note: individual stat counters replace the undefined `AssignmentStats` type.
- [X] T011 Create `AssignmentBloc` in `lib/bloc/assignments/assignment_bloc.dart`: extends `Bloc<AssignmentEvent, AssignmentState>`, injects `AssignmentService` via constructor, handles all events with proper loading/loaded/error state emissions
- [X] T012 Implement `FetchAssignments` handler in `AssignmentBloc`: calls `AssignmentService.getAll()` (Contract 1), filters out `draft`/`archived` assignments, batches `getMySubmission()` for each assignment to derive filter status, emits `AssignmentLoaded` with enriched assignments list
- [X] T013 Implement `SelectAssignment` handler in `AssignmentBloc`: sets `selectedAssignment` in state, fetches `mySubmission` via `AssignmentService.getMySubmission()` (Contract 5), emits updated state. Assignment detail fetch uses `GET /assignments/:id` (Contract 2).
- [X] T014 Implement `SubmitTextAssignment` handler in `AssignmentBloc`: calls `AssignmentService.submit()` with text/link, emits submitting/submitting-success/submitting-error states, refreshes submission after success
- [X] T015 Implement `SubmitFileAssignment` handler in `AssignmentBloc`: calls `AssignmentService.submitFile()` with file, emits submitting/submitting-success/submitting-error states with progress tracking via BLoC state, refreshes submission after success
- [X] T016 Implement `RefreshAssignments` handler in `AssignmentBloc`: re-fetches all assignments from backend, clears cache, emits fresh state
- [X] T017 Implement `ClearError` handler in `AssignmentBloc`: clears error field in state
- [X] T018 Delete old `lib/bloc/assignments/assignments_cubit.dart` (mock-based cubit replaced by T009–T017)
- [X] T019 Delete old `lib/bloc/assignments/assignments_state.dart` (legacy state replaced by T010)

### Widget Cleanup (Orphaned UI)

- [X] T020 [P] Review and update `lib/widgets/student/assignments/assignment_card.dart` — adapt to work with backend-driven `AssignmentModel` (remove legacy enum references, use `apiStatus`, `submissionType`, `submissionFilterStatus` for badges)
- [X] T021 [P] Review and update `lib/widgets/student/assignments/assignments_filter_sheet.dart` — replace legacy filter (status/type/priority) with simple All/Submitted/Pending/Overdue tabs matching spec FR-004. Filter logic MUST use the `assignment.submissionFilterStatus` computed property (from T007), NOT the legacy `AssignmentsFilter.status` enum.
- [X] T022 [P] Review and update `lib/widgets/student/assignments/assignment_details_sheet.dart` — adapt to show markdown instructions, instruction file previews, and submission trigger button

**Checkpoint**: Foundation ready — `AssignmentBloc` replaces mock cubit, models updated, widgets adapted. All user stories can now proceed.

---

## Phase 3: User Story 1 — Browse and Filter Assignments (Priority: P1) 🎯 MVP

**Goal**: Student sees real assignments from backend filtered by enrolled courses, with search, status filters (All/Submitted/Pending/Overdue), and summary stats.

**Independent Test**: Can be fully tested by loading the Assignments screen and verifying that real assignments appear from the backend, filters correctly narrow the list, and search finds matching assignments. Delivers immediate value by giving students visibility into their academic workload.

### Implementation for User Story 1

- [X] T023 [US1] Refactor `lib/screens/student/assignments_screen.dart` — replace `BlocProvider<AssignmentsCubit>` with `BlocProvider<AssignmentBloc>`, dispatch `FetchAssignments` on init, connect `BlocBuilder<AssignmentBloc, AssignmentState>` to render loading/loaded/error states
- [X] T024 [US1] Implement stats cards in `assignments_screen.dart` showing Total, Submitted, Pending, Overdue counts derived from BLoC state (FR-002)
- [X] T025 [US1] Implement status filter buttons (All/Submitted/Pending/Overdue) in `assignments_screen.dart` that dispatch filter events to `AssignmentBloc` (FR-004)
- [X] T026 [US1] Implement search bar in `assignments_screen.dart` with real-time filtering by title/description (FR-003)
- [X] T027 [US1] Implement empty state in `assignments_screen.dart` when no assignments exist, with message suggesting to enroll in courses (FR-021)
- [X] T028 [US1] Implement `RefreshIndicator` in `assignments_screen.dart` that dispatches `RefreshAssignments` event
- [X] T029 [US1] Ensure assignment list in `assignments_screen.dart` filters out `draft` and `archived` assignments (FR-001)
- [X] T030 [US1] Ensure all touch targets in `assignments_screen.dart` maintain minimum 48x48 logical pixels (FR-024). Note: final comprehensive responsive/accessibility audit in Phase 7 (T076-T079); this task is an implementation-time check during US1.
- [X] T031 [US1] Ensure `assignments_screen.dart` is responsive at 375px, 768px, and 1024px+ widths (FR-023). Note: final comprehensive responsive audit in Phase 7 (T076-T078); this task is an implementation-time check during US1.
- [X] T032 [US1] Verify UI in `assignments_screen.dart` maintains ≥85% visual similarity to pre-integration state — same colors, card structure, header layout (FR-022)
- [X] T033 [US1] Add unit tests for `AssignmentBloc` fetch/filter logic in `tests/unit/bloc/assignments/assignment_bloc_test.dart`
- [X] T034 [US1] Add widget test for `AssignmentsScreen` loading/loaded/empty states in `tests/widget/screens/assignments_screen_test.dart`

**Checkpoint**: User Story 1 complete — assignment list loads from backend with search, filter, and stats. Independently testable.

---

## Phase 4: User Story 2 — View Assignment Details and Instructions (Priority: P2)

**Goal**: Student taps an assignment to view full details: title, metadata, markdown instructions, instruction file previews (Google Drive), with "Open in Drive" and download links.

**Independent Test**: Can be fully tested by tapping an assignment from the list, viewing its details, reading instructions, and previewing any attached instruction files. Delivers value by providing complete assignment context even if submission is not yet available.

### Implementation for User Story 2

- [X] T035 [P] [US2] Create `AssignmentDetailScreen` in `lib/screens/student/assignment_detail_screen.dart` — full-screen route with `Scaffold`, `AppBar`, `AssignmentDetailBody` widget
- [X] T036 [P] [US2] Create `AssignmentDetailBody` widget in `lib/widgets/student/assignments/assignment_detail_body.dart` — renders title, due date, max score, submission type badge, status badge, course name
- [X] T037 [US2] Implement markdown instruction rendering in `assignment_detail_body.dart` using `flutter_markdown` with `MarkdownStyleSheet` matching app theme (FR-006)
- [X] T038 [US2] Implement instruction file preview cards in `assignment_detail_body.dart` — each file shows `WebView` with Drive preview URL, "Open in Drive" button, download button (FR-007)
- [X] T039 [US2] Implement fallback "Open in Drive" link in `assignment_detail_body.dart` when WebView fails to load preview
- [X] T040 [US2] Hide instruction file section gracefully in `assignment_detail_body.dart` when `assignment.instructionFiles` is empty/null (preserve UI space)
- [X] T041 [US2] Wire `AssignmentCard.onTap` in `assignments_screen.dart` to push `AssignmentDetailScreen` via `Navigator.push()` with assignment as argument
- [X] T042 [US2] Dispatch `SelectAssignment` event in `AssignmentDetailScreen.initState` to fetch `mySubmission` for the selected assignment
- [X] T043 [US2] Add "Submit Assignment" button in `assignment_detail_body.dart` that triggers modal bottom sheet (wired in US3)
- [X] T044 [US2] Add widget test for `AssignmentDetailScreen` in `tests/widget/screens/assignment_detail_screen_test.dart`

**Checkpoint**: User Story 2 complete — assignment detail view with markdown instructions and file previews. Independently testable.

---

## Phase 5: User Story 3 — Submit Assignment Work (Priority: P3)

**Goal**: Student submits assignment work via modal bottom sheet with appropriate input based on `submissionType` (text, link, file from device/Drive), with validation, late warning, and error handling.

**Independent Test**: Can be fully tested by selecting an assignment, filling in the appropriate submission form based on the assignment's submission type, and submitting successfully. Delivers value by enabling students to complete assignments on mobile.

### Implementation for User Story 3

- [X] T045 [P] [US3] Create `SubmissionFormSheet` widget in `lib/widgets/student/assignments/submission_form_sheet.dart` — modal bottom sheet with `isScrollControlled: true`
- [X] T046 [P] [US3] Create `TextSubmissionTab` widget in `lib/widgets/student/assignments/submission_form_sheet.dart` — textarea input for text-type submissions
- [X] T047 [P] [US3] Create `LinkSubmissionTab` widget in `lib/widgets/student/assignments/submission_form_sheet.dart` — URL input with `Uri.tryParse` validation
- [X] T048 [P] [US3] Create `FileSubmissionTab` widget in `lib/widgets/student/assignments/submission_form_sheet.dart` — file picker (local device) with size/type validation, tab for Google Drive file selection
- [X] T049 [US3] Implement conditional rendering in `SubmissionFormSheet` based on `assignment.submissionType`: text-only → show TextTab, link-only → show LinkTab, file-only → show FileTab, any/multiple → show TabBar with all three. If `submissionType` is unknown/unexpected, default to showing all three options (graceful degradation per spec edge case) (FR-009)
- [X] T050 [US3] Implement client-side file size validation in `FileSubmissionTab` — compare against `assignment.maxFileSizeMb`, show error if exceeded (FR-012)
- [X] T051 [US3] Implement client-side file type validation in `FileSubmissionTab` — check extension against `assignment.allowedFileTypes`, show error if not allowed (FR-013)
- [X] T052 [US3] Implement late submission check in `SubmissionFormSheet` — if `dueDate.isBefore(now)` and `!lateSubmissionAllowed`, disable submit button with error message (FR-014)
- [X] T053 [US3] Implement late submission warning in `SubmissionFormSheet` — if `dueDate.isBefore(now)` and `lateSubmissionAllowed`, show warning banner with penalty percentage (FR-015)
- [X] T054 [US3] Wire submit button in `SubmissionFormSheet` to dispatch `SubmitTextAssignment` or `SubmitFileAssignment` event to `AssignmentBloc`
- [X] T055 [US3] Implement loading/progress indicator in `SubmissionFormSheet` during submission (FR-020)
- [X] T056 [US3] Implement success/error handling in `SubmissionFormSheet` — show SnackBar on success. On error: do NOT dismiss the bottom sheet, retain all form field values in widget state so the student can retry without re-entering data (FR-020)
- [X] T057 [US3] Implement `DriveFilePickerTab` in `lib/widgets/student/assignments/drive_file_picker.dart` — WebView-based Google Drive file browser that lets the student browse their existing Google Drive files and select one for submission. Returns the selected file's Drive ID and file metadata. Note: this is for browsing existing Drive files, NOT uploading local files to Drive (upload-to-Drive is handled by `AssignmentService.submitFile()` backend flow).
- [X] T058 [US3] Add unit tests for submission validation logic in `tests/unit/widgets/submission_form_test.dart`

**Checkpoint**: User Story 3 complete — submission form with all types, validation, late handling. Independently testable.

---

## Phase 6: User Story 4 — View Existing Submission and Grade (Priority: P3)

**Goal**: Student views their existing submission for an assignment: content, score (out of max), instructor feedback, late indicator, grading date, and resubmission option when applicable.

**Independent Test**: Can be fully tested by viewing an assignment for which a submission already exists and verifying that submission content, score, feedback, and status are displayed correctly.

### Implementation for User Story 4

- [X] T059 [P] [US4] Create `MySubmissionView` widget in `lib/widgets/student/assignments/my_submission_view.dart` — displays existing submission details
- [X] T060 [P] [US4] Create `ScoreDisplay` widget in `lib/widgets/student/assignments/my_submission_view.dart` — shows "score / maxScore" with percentage, or "Not yet graded"
- [X] T061 [US4] Implement submission content display in `MySubmissionView` — text content, link (clickable), file (with Drive preview link)
- [X] T062 [US4] Implement late badge in `MySubmissionView` when `submission.isLate == true` (FR-017)
- [X] T063 [US4] Implement feedback display in `MySubmissionView` — instructor feedback text with graded date (FR-018)
- [X] T064 [US4] Implement resubmission button in `MySubmissionView` when `submission.submissionStatus == graded` — opens `SubmissionFormSheet` for new attempt (FR-019)
- [X] T065 [US4] Hide resubmission button when `submission.submissionStatus != graded` or resubmission not allowed (read-only view)
- [X] T066 [US4] Integrate `MySubmissionView` into `AssignmentDetailScreen` — shows below instructions/files when `mySubmission` exists in BLoC state
- [X] T067 [US4] Handle 404 from `getMySubmission` gracefully — if no submission exists, hide `MySubmissionView` and show submission form trigger instead
- [X] T068 [US4] Add widget test for `MySubmissionView` in `tests/widget/widgets/my_submission_view_test.dart`

**Checkpoint**: User Story 4 complete — grade/submission display with resubmission. All user stories now independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories, cleanup, and final verification

### Mock Data Audit (Constitution Principle VII — Static Data Elimination)

- [X] T069 [P] Grep for residual mock patterns in all modified files: `_generateSample`, `_generateDemo`, `_generateDemoAssignments`, `Duration(hours:`, `DateTime.now().subtract(`, `Duration(minutes:`, hardcoded `List<AssignmentModel>`, `TODO: Replace with API`. Verify zero matches in files modified by this phase.
- [X] T070 [P] Scan for and delete any orphan assignment-related files that are no longer referenced: check `lib/widgets/student/assignments/` for unused widgets, `lib/screens/student/` for orphan screens
- [X] T071 [P] Verify no `setState(() =>` patterns bypass BLoC in `assignments_screen.dart` or new widgets

### File Cleanup — Orphaned Pre-Integration Files

- [X] T072 Identify and delete unused files from before backend integration: grep for imports of deleted `assignments_cubit.dart` and `assignments_state.dart` across the codebase, remove any stale references
- [X] T073 [P] Check `lib/widgets/student/assignments/` — if any widget files from before this phase are no longer imported by any screen, delete them (orphan cleanup)
- [X] T074 [P] Run `flutter analyze` and fix any dead code warnings related to old assignment files

### Responsive & Accessibility Verification

- [X] T075 Verify all screens render correctly at 375px width (mobile portrait) — no overflow errors, text readable
- [X] T076 Verify all screens render correctly at 768px width (tablet portrait) — adaptive layouts work
- [X] T077 Verify all screens render correctly at 1024px+ width (desktop) — no horizontal scrolling
- [X] T078 Verify all interactive elements maintain minimum 48x48 logical pixel touch targets (FR-024)

### Performance Validation (SC-001, SC-005)

- [X] T079 Measure assignment list load time from navigation to first render — must be ≤3 seconds (SC-001). Use `Stopwatch` in test or manual timing with DevTools.
- [X] T080 Measure file upload time for a 10MB file from selection to success confirmation — must be ≤30 seconds on standard mobile data (SC-005).

### Final Integration Testing

- [X] T081 End-to-end test: Fetch assignments → filter by Submitted → tap assignment → view details → submit text → view grade
- [X] T082 End-to-end test: Fetch assignments → filter by Overdue → verify late submission blocked when not allowed
- [X] T083 End-to-end test: Fetch assignments → select file-type assignment → submit file from device → verify success
- [X] T084 End-to-end test: Fetch assignments → select assignment with existing graded submission → view grade → resubmit → verify new attempt created
- [X] T085 Run `flutter analyze` on entire project — zero errors, zero warnings for modified files
- [X] T086 Run all unit tests: `flutter test tests/unit/bloc/assignments/` — all pass
- [X] T087 Run all widget tests: `flutter test tests/widget/` — all pass
- [X] T088 Visual parity check: Compare screenshots of `assignments_screen.dart` before/after changes — confirm ≥85% visual similarity (FR-022)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: No dependencies — can start immediately
- **Phase 2 (Foundational)**: Depends on Phase 1 — **BLOCKS all user stories**
- **Phase 3+ (User Stories)**: All depend on Phase 2 completion
  - User stories can proceed sequentially in priority order (P1 → P2 → P3 → P3)
  - US3 and US4 have no dependency on each other (can be parallel)
- **Phase 7 (Polish)**: Depends on all user story phases being complete

### User Story Dependencies

```
Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1: Browse/Filter) → Phase 4 (US2: Detail View)
                                                                              ↓
                                                                    Phase 5 (US3: Submit)
                                                                    Phase 6 (US4: View Grade)
                                                                              ↓
                                                                    Phase 7 (Polish & Cleanup)
```

- **US1 (P1)**: No dependencies on other stories — entry point for all assignment interactions
- **US2 (P2)**: Depends on US1 only for navigation from list card → detail screen
- **US3 (P3)**: Depends on US2 for detail screen context (submission form triggered from detail)
- **US4 (P3)**: Depends on US2 for detail screen context (submission view shown in detail)
- **US3 and US4**: Can be developed in parallel (both depend on US2, not each other)

### Within Each User Story

- Models → BLoC events/handlers → Screen integration → Widget creation → Tests
- Each phase should be a complete, independently testable increment

### Parallel Opportunities

- Phase 1: T002–T006 all marked [P] can run in parallel
- Phase 2: T007–T008 (model updates) can run in parallel; T009–T017 (BLoC) must be sequential; T020–T022 (widget reviews) can run in parallel
- Phase 3: T023–T032 sequential (all modify assignments_screen.dart); T033–T034 (tests) can run in parallel with each other after implementation
- Phase 4: T035–T036 (screen + body) can run in parallel; T037–T040 sequential (all in detail body)
- Phase 5: T045–T048 (submission form widgets) can run in parallel; T049–T058 sequential
- Phase 6: T059–T060 (widgets) can run in parallel; T061–T068 sequential

---

## Parallel Example: Phase 2 Foundational

```bash
# Launch model updates in parallel:
Task T007: "Add submissionFilterStatus to AssignmentModel"
Task T008: "Add hasSubmission to AssignmentModel"

# After model updates complete, launch BLoC creation (sequential):
Task T009: "Create AssignmentEvent"
Task T010: "Create AssignmentState"
Task T011: "Create AssignmentBloc"

# After BLoC complete, launch widget reviews in parallel:
Task T020: "Review assignment_card.dart"
Task T021: "Review assignments_filter_sheet.dart"
Task T022: "Review assignment_details_sheet.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (verify dependencies)
2. Complete Phase 2: Foundational (BLoC replaces mock cubit)
3. Complete Phase 3: User Story 1 (browse/filter assignments from backend)
4. **STOP and VALIDATE**: Verify assignments load from backend with search/filter/stats
5. Deploy/demo if ready — MVP delivers real assignment visibility

### Incremental Delivery

1. Setup + Foundational → BLoC ready, mock data eliminated
2. US1: Browse/Filter → Students see real assignments with filters (MVP!)
3. US2: Detail View → Students can read full assignment details
4. US3: Submit → Students can submit assignments (core feature complete)
5. US4: View Grade → Students can see grades and feedback (full workflow)
6. Polish: Cleanup, responsive verification, visual parity check

### Parallel Team Strategy

With multiple developers:

1. Developer A: Phase 1 + Phase 2 (Foundational — BLoC, models, widget reviews)
2. Once Phase 2 completes:
   - Developer A: User Story 1 (Browse/Filter)
   - Developer B: User Story 2 (Detail View)
3. Once US1+US2 complete:
   - Developer A: User Story 3 (Submission)
   - Developer B: User Story 4 (View Grade)
4. Both: Phase 7 (Polish & cleanup together)

---

## Total Task Summary

| Phase | Task Count | Description |
|---|---|---|
| Phase 1: Setup | 6 | Verify existing dependencies |
| Phase 2: Foundational | 16 | BLoC replacement, model updates, widget cleanup |
| Phase 3: US1 (P1) | 12 | Browse and filter assignments |
| Phase 4: US2 (P2) | 10 | View assignment details and instructions |
| Phase 5: US3 (P3) | 14 | Submit assignment work |
| Phase 6: US4 (P3) | 10 | View existing submission and grade |
| Phase 7: Polish | 20 | Mock audit, file cleanup, responsive, performance, integration tests |
| **Total** | **88** | All tasks |

### Task Count Per User Story

| User Story | Priority | Task Count | Independent Test |
|---|---|---|---|
| US1: Browse and Filter | P1 | 12 | Load assignments screen, verify real data + filters |
| US2: View Details | P2 | 10 | Tap assignment, verify detail content + previews |
| US3: Submit Work | P3 | 14 | Fill submission form, verify API call + success |
| US4: View Grade | P3 | 10 | View graded submission, verify score/feedback/resubmit |

### Suggested MVP Scope

**User Story 1 only** (Phase 1 + Phase 2 + Phase 3): Students can see their real assignments from the backend with search, status filters, and summary statistics. No submission or detail view yet — but the core value of "seeing real assignments" is delivered.

### Format Validation

✅ All 88 tasks follow the checklist format:
- `- [ ]` checkbox prefix
- Sequential task IDs: T001–T088
- `[P]` marker for parallelizable tasks
- `[US1]`, `[US2]`, `[US3]`, `[US4]` story labels for user story phases
- Clear file paths in every task description
- No vague tasks without file paths
