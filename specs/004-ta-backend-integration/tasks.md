---

description: "Execution task list for TA Backend Integration"
---

# Tasks: TA Backend Integration

**Input**: Design documents from `/specs/004-ta-backend-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Preparing data models and primary BLoC changes

- [x] T001 Define `TAAssignmentModel` in `lib/models/ta/ta_assignment_model.dart`
- [x] T002 Update `EnrollmentService` in `lib/services/api/enrollment_service.dart` to include TA endpoints (teaching route logic)
- [x] T003 Update `CoursesBloc` in `lib/bloc/courses/courses_bloc.dart` to support role-based filtering for the TA state

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Ensure `TeachingCourseModel` import paths are standardized across TA screens

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - View Assigned Courses List (Priority: P1) 🎯 MVP

**Goal**: Show a list of assigned courses for the authenticated TA via BLoC state, skipping static mockups.

**Independent Test**: Login as TA and confirm the `ta_courses_list_screen.dart` renders real courses retrieved from the network.

### Implementation for User Story 1

- [x] T005 [US1] Remove static mock data initialization in `lib/screens/ta/courses/ta_courses_list_screen.dart`
- [x] T006 [US1] Wrap list builder with `BlocBuilder<CoursesBloc, CoursesState>` in `lib/screens/ta/courses/ta_courses_list_screen.dart`, ensuring loading skeleton widgets are rendered during the `loading` state per Constitution Principle IV
- [x] T007 [US1] Render `TeachingCourseModel` instances into list UI elements in `lib/screens/ta/courses/ta_courses_list_screen.dart`
- [x] T008 [US1] Add a "no courses assigned" empty state widget inside the list builder

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Access Live Course Sub-tabs (Priority: P1)

**Goal**: Display accurate data context inside the course detailed tabs without legacy placeholder text.

**Independent Test**: Navigate to a TA course and verify all tabs (Overview, Labs, Grading, Discussions) show real data.

### Implementation for User Story 2

- [x] T009 [P] [US2] Pass `TeachingCourseModel` seamlessly through `lib/screens/ta/courses/ta_course_detail_screen.dart` into all child tab widgets, ensuring loading skeleton views apply before data resolves
- [x] T010 [P] [US2] Populate dynamic stats and text in `lib/widgets/ta/courses/ta_course_overview_tab.dart` based on model
- [x] T011 [P] [US2] Populate dynamic grading metrics in `lib/widgets/ta/courses/ta_course_grading_tab.dart` based on model
- [x] T012 [P] [US2] Populate dynamic lab tasks in `lib/widgets/ta/courses/ta_course_labs_tab.dart` based on model
- [x] T013 [P] [US2] Populate discussion threads dynamically in `lib/widgets/ta/courses/ta_course_discussions_tab.dart` where available
- [x] T014 [US2] Ensure `lib/widgets/ta/courses/ta_course_insights_card.dart` and `ta_course_stats_cards.dart` render calculations dynamically instead of using hardcoded mock numbers
- [x] T015 [US2] **FR-006**: Ensure destructive UI components (e.g., dropping students) are proactively hidden or visibly constrained in the grading/labs tabs

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Interact with Course Materials (Priority: P2)

**Goal**: Distinguish between material types and download/launch them safely.

**Independent Test**: Course materials are identified correctly, and clicking them uses `url_launcher`.

### Implementation for User Story 3

- [x] T016 [US3] Parse materials correctly determining labels mapping to `organizationType` (Video, Document, Quiz)
- [x] T017 [US3] Integrate `url_launcher` on material tap gestures to open URLs safely with fallback paths, explicitly displaying a Snackbar or Dialog actionable error message if the URL fails to launch

**Checkpoint**: All core UI components function.

---

## Phase 6: User Story 4 - Trigger Action Handlers (Priority: P2)

**Goal**: Connect local quick action buttons to actual functional handlers.

**Independent Test**: Quick actions correctly initiate route push correctly using route arguments.

### Implementation for User Story 4

- [x] T018 [US4] Refactor `lib/widgets/ta/courses/ta_course_quick_actions.dart` to trigger dynamic route navigations to actual grading/lab pages
- [x] T019 [US4] Update exports matching new layouts in `lib/widgets/ta/courses/ta_courses_barrel.dart`

**Checkpoint**: All user stories should now be independently functional

---

## Phase X: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T020 Run application to manually verify API interactions for TA dashboards
- [x] T021 Check for any unused mock or static files related to the TA courses feature from before backend integration and explicitly delete them (e.g., `ta_course_model.dart` or static lists) to ensure a clean codebase
- [x] T022 Resolve any remaining lint or typing analysis errors in modified UI files

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational (Phase 2).
- **User Story 2 (P1)**: May integrate with US1 conceptually but focuses on Sub-Tabs rendering logic.
- **User Story 3 (P2)**: Extends sub-tab behaviors.
- **User Story 4 (P2)**: Fixes quick action links.

### Parallel Opportunities

- The widgets in US2 (`ta_course_overview_tab`, `ta_course_grading_tab`, etc.) are heavily parallelizable (`[P]`) as they operate independently on the injected model.

---

## Parallel Example: User Story 2

```bash
# Launch tab updates in parallel for UI conversion
Task: "Populate dynamic stats and text in lib/widgets/ta/courses/ta_course_overview_tab.dart based on model"
Task: "Populate dynamic grading metrics in lib/widgets/ta/courses/ta_course_grading_tab.dart based on model"
Task: "Populate dynamic lab tasks in lib/widgets/ta/courses/ta_course_labs_tab.dart based on model"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 (List API parsing)
4. **STOP and VALIDATE**: Ensure network binding to `ta_courses_list_screen.dart` is accurate.

### Incremental Delivery

1. Data layer binding MVP (View List)
2. Add deep-linking data to Sub-tabs (US2)
3. Connect Material launch actions (US3)
4. Link Quick Actions (US4)
5. Cleanup mock data.
