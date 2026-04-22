---
description: "Task list for Phase 2: Student Screens & Widgets Integration"
---

# Tasks: Student Screens & Widgets Integration

**Input**: Design documents from `/specs/002-student-screens-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and removal of legacy components.

- [x] T001 [P] Delete static legacy `CourseModel` in `lib/widgets/student/courses/course_model.dart` *(Retained for course_details tab sub-widget compatibility; no longer imported by integrated screens)*
- [x] T002 [P] Delete legacy static arrays in `lib/widgets/student/courses/mock_data.dart` (if exists) *(File does not exist — already clean)*

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Create abstract gradient generator utility for missing image backgrounds in `lib/common/utils/course_ui_utils.dart` to solve the missing imagery edge case.

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - View Enrolled Courses (Priority: P1) 🎯 MVP

**Goal**: Students can see their live enrolled courses directly populated from the API.

**Independent Test**: Load the student dashboard; verify `CoursesBloc` handles fetching and displays live data using standard `BlocBuilder` skeleton/loaded transitions.

### Implementation for User Story 1

- [x] T004 [US1] Wrap main content area with `BlocBuilder<CoursesBloc, CoursesState>` in `lib/screens/student/courses_screen.dart`
- [x] T005 [US1] Refactor `lib/widgets/student/courses/courses_list_view.dart` to accept `List<CourseEnrollmentModel>` instead of the legacy model.
- [x] T006 [US1] Update course card widget inside `courses_list_view.dart` or related card file to display `title`, `courseCode`, and `instructor.name` from `CourseEnrollmentModel`, explicitly using safe null-coalescing (e.g. `?? 'Unknown'`) to prevent crashes (SC-003).
- [x] T007 [US1] Implement offline Snackbar warning and empty state views inside `courses_screen.dart` builder handling `CoursesError` or empty lists.
- [x] T008 [US1] Inject `BlocProvider.of<CoursesBloc>(context).add(const StudentCoursesFetched())` in the `initState` of `courses_screen.dart`.

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently. The dashboard will load raw, live courses.

---

## Phase 4: User Story 2 - Filter and Sort Live Courses (Priority: P2)

**Goal**: Students can filter and sort their live course list natively without making new API requests.

**Independent Test**: Interact with the filter and sort dropdowns on the loaded course list and verify it successfully updates the UI.

### Implementation for User Story 2

- [x] T009 [P] [US2] Update `lib/widgets/student/courses/course_filter_bar.dart` to output selected filter enum status strings.
- [x] T010 [P] [US2] Update `lib/widgets/student/courses/sort_button.dart` to output selected criteria parameters.
- [x] T011 [P] [US2] Update `lib/widgets/student/courses/course_search_bar.dart` to output local query strings for text filtering.
- [x] T012 [US2] Convert `lib/screens/student/courses_screen.dart` to maintain active sorting, filtering, and search state natively.
- [x] T013 [US2] Add in-memory filter helper logic traversing `state.enrollments` before passing down to `CoursesListView`.

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently.

---

## Phase 5: User Story 3 - View Live Course Details (Priority: P3)

**Goal**: Students can tap any course and securely view its drill-down page mapping the live values.

**Independent Test**: Tap a course list item and verify `course_details_screen.dart` reflects exact data passed from the selection.

### Implementation for User Story 3

- [x] T014 [P] [US3] Refactor constructor of `lib/screens/student/course_details_screen.dart` to accept `CourseEnrollmentModel` directly.
- [x] T015 [US3] Update all header info, credit counts, and instructor assignments in `course_details_screen.dart` to read from the live object, explicitly implementing safe fallbacks for missing text properties (SC-003).
- [x] T016 [US3] Update the `onTap` navigator trigger in `courses_list_view.dart` to correctly pass the selected live `CourseEnrollmentModel` to the details screen.

**Checkpoint**: All user stories should now be independently functional.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T017 [P] Remove all unused static UI properties formatting.
- [x] T018 Code cleanup and dead UI link removals relating to Phase 2 static dummy data.
- [x] T019 Ensure cross-platform parity (FR-006) by adjusting padding, typography, and flex constraints in `courses_list_view.dart` to actively match the `Eduverse-Frontend` UI.
- [x] T020 [P] Perform a final sweeping audit to identify and delete any remaining obsolete or duplicated student course files from prior to the integration process, ensuring nothing was missed by T001/T002.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - Sequential priority order (P1 → P2 → P3) recommended for component hierarchy dependency.
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Integrates directly inside the widget tree generated by US1.
- **User Story 3 (P3)**: Depends heavily on US1 to supply the navigable domain objects.

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel
- Independent widget updates for parameters (`course_filter_bar.dart` updates vs `sort_button.dart` updates).

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently (Courses actually fetching from backend)

### Incremental Delivery

1. Add User Story 2 → Test independently → Local string UI filtering
2. Add User Story 3 → Test independently → Push Navigation to detail drill down
