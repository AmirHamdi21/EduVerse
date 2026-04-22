# Feature Tasks: Instructor Screens & Widgets Integration

## Dependencies
- Phase 2 Foundational Tasks must be fully executed before moving to Phase 3.
- User Story 1 (Phase 3) is prioritized highest and establishes the UI integration pattern.
- User Story 2 (Phase 4) depends on the UI state refactoring from Phase 3.

## Parallel Execution Examples
- P1: Once `TeachingCourseModel` (T003) is generated, `EnrollmentService` updates (T005) and `CoursesBloc` refactors (T006) can execute in parallel.
- P2: After `CoursesBloc` emits states, screen refactoring (T007) and removing static instances from list widgets (T008) can happen concurrently by viewing `lib/widgets/instructor/courses/`.

## Phase 1: Setup

Goal: Remove obsolete legacy components mimicking static backend behaviors.

- [x] T001 ~~Delete `instructor_course_model.dart`~~ — SKIPPED: Still imported by 14+ other files (dashboard, course_management, grading, router). Will be handled when those screens are migrated.
- [x] T002 ~~Delete `extended_course_model.dart`~~ — SKIPPED: Still used as UI view wrapper by course card widgets. Replaced data source from mock to live backend.

## Phase 2: Foundational

Goal: Create the requisite API bindings and domain models required by all User Stories.

- [x] T003 Create `TeachingCourseModel` using Equatable at `lib/models/instructor/teaching_course_model.dart` mapping exactly to the JSON payload.
- [x] T004 ~~Run `build_runner`~~ — SKIPPED: Project uses hand-written models with Equatable (not freezed), so no code generation is needed.
- [x] T005 [P] Update `EnrollmentService` to implement `getTeachingCourses()` fetching from `GET /api/enrollments/teaching` at `lib/services/api/enrollment_service.dart`.
- [x] T006 [P] Refactor `CoursesBloc` (and corresponding state/event classes) to integrate `TeachingCourseModel`, implementing offline caching via SharedPreferences at `lib/bloc/courses/courses_bloc.dart`.

## Phase 3: User Story 1 - View Assigned Teaching Courses

**Story Goal:** As an instructor, I want to see a live list of courses and sections assigned to me, so that I can manage my teaching schedule and course materials.
**Independent Test:** Can be isolated by observing the `instructor_courses_screen.dart` loading state rendering a list from the BLoC directly rather than local memory lists.

- [x] T007 [P] [US1] Refactor `instructor_courses_screen.dart` modifying its `build` method to wrap the dashboard in a `BlocConsumer` responding to `CoursesBloc` states at `lib/screens/instructor/courses/instructor_courses_screen.dart`.
- [x] T008 [P] [US1] Remove static mock arrays (`_getDemoCourses()`) and implement mapping of `TeachingCourseModel` arrays into UI lists via `_mapToExtendedCourses()` within `lib/screens/instructor/courses/instructor_courses_screen.dart`.
- [x] T009 [US1] Implement a retry mechanism widget (`_buildErrorState`) shown during a BLoC error state in `lib/screens/instructor/courses/instructor_courses_screen.dart`.
- [x] T010 [US1] Empty State graphic already provided by existing `_buildEmptyState()` method, now triggered when BLoC returns an empty `[]` of teaching courses.

## Phase 4: User Story 2 - View Real-Time Course Stats

**Story Goal:** As an instructor, I want to see dynamic statistics for my courses (e.g., total enrolled students), so that I can quickly assess the status of my classes.
**Independent Test:** Verifying the numeric "total students" header correlates exactly with the sum of `currentEnrollment` from fetched assignment models.

- [x] T011 [US2] Implement dynamic `totalStudents` reduction logic via `InstructorCoursesLoaded.totalStudents` getter feeding the Stats Board widget at `lib/screens/instructor/courses/instructor_courses_screen.dart` (Top Stats Board).
- [x] T012 [US2] Remove the hardcoded `avgEngagement` metric from the active UI rendering as specified by Clarification resolutions at `lib/screens/instructor/courses/instructor_courses_screen.dart`.

## Final Phase: Polish & Cross-Cutting Concerns

- [x] T013 Validate SharedPreferences caching parity for Instructors — offline cache implemented in `CoursesBloc._cacheTeachingCourses()` / `_loadCachedTeachingCourses()`.
- [x] T014 Execute `dart format` on all modified files. `flutter analyze` reports 0 errors — only pre-existing `info`-level `withOpacity` deprecation notices.
- [x] T015 Final sweeping audit completed — `_getDemoCourses()` and `_loadCourses()` confirmed fully removed. No orphaned instructor mock data files found.
