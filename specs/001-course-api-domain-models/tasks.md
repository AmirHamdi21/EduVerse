---
description: "Task list for Phase 1: API Client, Domain Models & Global Config"
---

# Tasks: Phase 1: API Client, Domain Models & Global Config

**Input**: Design documents from `/specs/001-course-api-domain-models/`
**Prerequisites**: plan.md, spec.md, data-model.md, contracts/api-contracts.md, research.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Verify and update `dio`, `flutter_bloc`, and `shared_preferences` dependencies in `pubspec.yaml`
- [x] T002 [P] Create initial directory paths for `lib/models`, `lib/services/api`, and `lib/bloc/courses`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Implement authentication auto-refresh logic and central BaseUrl handling inside `lib/services/api/core_api_client.dart` utilizing Dio Interceptors.

**Checkpoint**: Foundation ready - Core Network Handler handles tokens smoothly.

---

## Phase 3: User Story 1 - Unified Course Data Representation (Priority: P1) 🎯 MVP

**Goal**: Accurately parse and represent course structures based on web dashboard specifications matching exactly the provided Typescript implementations.

**Independent Test**: Provide JSON payloads statically to each factory `.fromJson` and ensure entities construct perfectly without TypeExceptions.

### Tests for User Story 1
- [x] T004 [P] [US1] Write JSON parsing unit tests for `CourseModel` and `CourseEnrollmentModel` in `test/models/core_models_test.dart`
- [x] T005 [P] [US1] Write JSON parsing unit tests for materials and assignments in `test/models/material_models_test.dart`

### Implementation for User Story 1

- [x] T006 [P] [US1] Create `CourseModel` in `lib/models/core/course_model.dart`
- [x] T007 [P] [US1] Create `CourseEnrollmentModel` in `lib/models/core/enrollment_model.dart`
- [x] T008 [P] [US1] Create `CourseStructureModel` in `lib/models/core/course_structure_model.dart`
- [x] T009 [P] [US1] Create `CourseMaterialModel` in `lib/models/materials/course_material_model.dart`
- [x] T010 [P] [US1] Create `AssignmentModel` in `lib/models/materials/assignment_model.dart`
- [x] T011 [P] [US1] Create `AnnouncementModel` in `lib/models/materials/announcement_model.dart`
- [x] T012 [P] [US1] Create `DiscussionThreadModel` in `lib/models/materials/discussion_thread_model.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional in parsing data gracefully forming the domain layer.

---

## Phase 4: User Story 2 - Real-time Course Data Retrieval (Priority: P2)

**Goal**: Connect Dart API service classes to the previously defined `core_api_client.dart` network layer for CRUD operations securely aligned to `api-contracts.md`.

**Independent Test**: Instantiate these remote services independently and print out responses from backend endpoints simulating Student/Instructor states.

### Tests for User Story 2
- [x] T013 [P] [US2] Write mocked network tests for `CourseService` validating correct parameter serialization in `test/services/api/course_service_test.dart`

### Implementation for User Story 2

- [x] T014 [P] [US2] Implement `CourseService` in `lib/services/api/course_service.dart` 
- [x] T015 [P] [US2] Implement `EnrollmentService` in `lib/services/api/enrollment_service.dart`
- [x] T016 [P] [US2] Implement `MaterialService` in `lib/services/api/material_service.dart`
- [x] T017 [P] [US2] Implement `CommunicationService` in `lib/services/api/communication_service.dart` encompassing Assignments and Announcements.

**Checkpoint**: At this point, User Stories 1 AND 2 interface cleanly reading live requests cleanly serialized to Domain object mapping.

---

## Phase 5: User Story 3 - Global Course State Broadcasting (Priority: P3)

**Goal**: Bind all services into a highly cohesive abstraction emitting reliable state signals to UI blocks asynchronously resolving edge cases around timeouts or offline loss.

**Independent Test**: Use BLoC test routines to verify transition phases: Loading -> Data or fallback scenarios. 

### Tests for User Story 3
- [x] T018 [P] [US3] Write BLoC transition unit tests validating `Loading` to `Data/Error` states in `test/bloc/courses_bloc_test.dart` using `bloc_test` package.

### Implementation for User Story 3

- [x] T019 [P] [US3] Create baseline State and Event definitions in `lib/bloc/courses/courses_event.dart` and `lib/bloc/courses/courses_state.dart`
- [x] T020 [US3] Build `CoursesBloc` in `lib/bloc/courses/courses_bloc.dart` routing events to service fetch mechanisms and capturing responses.
- [x] T021 [US3] Bind `SharedPreferences` safely inside BLoC intercept handling blocks enforcing offline-cache persistence.

**Checkpoint**: All user stories functional, yielding robust decoupled application structures.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T022 Integrate BLoC provision natively upstream at layout root `lib/main.dart` or routing hierarchy.
- [x] T023 Handle all explicit JSON parsing catches globally across models avoiding hard crashes on undefined backend structure fields natively.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Stories (Phase 3+)**: Can occur consecutively or concurrently after Phase 2 completeness. 
- **Polish (Final Phase)**: Resolves architecture injection at the app root level.

### User Story Dependencies

- **User Story 1 (P1)**: The bedrock formatting parsing models needed fundamentally everywhere.
- **User Story 2 (P2)**: Must utilize models defined in US1.
- **User Story 3 (P3)**: Dictates bridging logic requiring the completion of US2 APIs.

### Parallel Opportunities

- All entity models inside Phase 3 (`T006-T012`) can be written strictly in parallel.
- All Service classes inside Phase 4 (`T014-T017`) can be configured entirely independently.
