---
description: "Task list for Phase 5: Course Detail Drill-down & Material Viewer feature implementation"
---

# Tasks: Course Detail Drill-down & Material Viewer

**Input**: Design documents from `/specs/005-course-details-viewer/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Exact file paths are included in the descriptions.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Ensure required dependency `url_launcher` is present in `pubspec.yaml`
- [x] T002 [P] Create dummy structure target files to satisfy import structures during foundational modeling.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Create `CourseMaterialModel` mapped to `eduverse_db.sql` schema in `lib/models/materials/course_material_model.dart`
- [x] T004 Create `CourseStructureModel` in `lib/models/core/course_structure_model.dart`
- [x] T005 Implement `CourseService.getCourseStructure()` utilizing `Dio` for `/api/courses/{courseId}/structure` in `lib/services/api/course_service.dart`
- [x] T005a Implement `SharedPreferences` key-value caching inside `CoursesBloc` for structure payloads to persist offline (satisfies SC-003 load latency).

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - View Week-by-Week Course Structure (Priority: P1) 🎯 MVP

**Goal**: As a Student, Instructor, or TA, I want to drill down into a specific course to view its comprehensive week-by-week structure and organization.

**Independent Test**: Can be fully tested by opening a course dashboard and seeing the structural syllabus loads fully from the backend.

### Implementation for User Story 1

- [x] T006 [P] [US1] Define loading and loaded states for structures in `lib/bloc/courses/courses_state.dart`
- [x] T007 [US1] Connect `StructureService` fetch logic to event handlers inside `lib/bloc/courses/courses_bloc.dart`, ensuring cached arrays are emitted immediately to hit the <2s target before refreshing network bounds.
- [x] T008 [US1] Refactor `lib/screens/student/course_details_screen.dart` to consume real BLoC state array groupings instead of mock ones.
- [x] T009 [US1] Update `lib/widgets/instructor/course_management/overview_tab.dart` to populate with active layout arrays.
- [x] T010 [US1] Wire the TA structure layout directly into the `Overview` tab inside `lib/widgets/ta/courses/ta_course_overview_tab.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional; syllabus outlines should be correctly retrieving and mapping empty lists or actual layouts.

---

## Phase 4: User Story 2 - Interact with Course Materials (Priority: P1)

**Goal**: Visually distinguish between different material types (Videos, Documents, Quizzes) and be able to open or download them natively.

**Independent Test**: Tap any loaded material within the UI and verify that the correct action triggers securely based on its externalURL or internal routing logic.

### Implementation for User Story 2

- [x] T011 [P] [US2] Build `MaterialTypeIcon` utility widget mapping `DOCUMENT`/`VIDEO`/`QUIZ` string enums to Flutter visual icons.
- [x] T012 [P] [US2] Implement interaction tap callback using `url_launcher` on individual rows handling the structured external web resources safely.
- [x] T013 [US2] Add graceful `DioException` error handling specific to 403 Forbidden interceptors to hide edit buttons softly on backend rejections for TAs inside the BLoC parser.

**Checkpoint**: User Stories 1 AND 2 should both work interchangeably, achieving the core drill-down viewer goals natively.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup obsolete dependencies related to past static TA structures and standardize the deployment.

- [x] T014 Audit and delete unused legacy static mockup TA course files from before backend integration across `lib/models/ta/` or `lib/widgets/ta` mock definitions. (Result: No orphaned files found — all are actively used)
- [x] T015 Run flutter analyzer to ensure type safety remains optimal across `lib/services/api/` and the presentation layer scopes. (Result: 0 errors, 7 pre-existing info-level deprecation warnings)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately.
- **Foundational (Phase 2)**: Depends on Setup, BLOCKS all user stories.
- **User Stories (Phase 3 & 4)**: US2 components can be visually drafted in parallel with US1 state building, but interaction tests require US1 completion.
- **Polish (Phase 5)**: Execute exclusively after US2 interaction validations.

### Parallel Opportunities

- Entities mapping (`T003` and `T004`) can be generated simultaneously.
- UI views can be independently drafted per role screen simultaneously (`T008`, `T009`, `T010`).
