# Implementation Tasks: Admin — Course Management

## Phase 1: Setup

- [X] T001 Verify `ApiClient` configuration in `lib/services/api/api_client.dart` for correct endpoint structure and error interception logic.
- [X] T002 Import `CourseModel`, `SectionModel`, `ScheduleModel`, and `InstructorAssignmentModel` via `lib/models/courses/` into the admin features.

## Phase 2: Foundational

- [X] T003 Implement `CourseWizardBloc` (`CourseWizardEvent`, `CourseWizardState`) in `lib/bloc/admin_course_management/course_wizard_bloc.dart` with support for saving draft IDs and handling `INACTIVE` state on partial failures.
- [X] T004 Implement `CourseListBloc` (`LoadCourses`, `FilterCourses`) in `lib/bloc/admin_course_management/course_list_bloc.dart` to manage the fetching and caching of the live course catalog.
- [X] T005 Implement `AdminEnrollmentBloc` in `lib/bloc/admin_course_management/admin_enrollment_bloc.dart`, parsing HTTP 409 responses from the API to emit `AdminEnrollmentConflictWarning` states, and handling forced enroll/drop commands (including overriding drop deadlines).
- [X] T006 [P] Update `lib/services/api/course_service.dart`, `section_service.dart`, `schedule_service.dart`, and `enrollment_service.dart` with the necessary Admin `POST` and `PUT` API methods (including update endpoints for nested entities like assigned instructors) according to `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`.

## Phase 3: User Story 1 - View and Filter Courses

- [X] T007 [US1] Remove static mock models and dummy array instances from `lib/screens/admin/courses/admin_course_management_screen.dart` strictly to leave empty variable spaces mapped to the BLoC states (preserving the UI layout structure).
- [X] T008 [US1] Wrap the primary course list view inside `lib/screens/admin/courses/admin_course_management_screen.dart` with a `BlocBuilder<CourseListBloc, CourseListState>`, explicitly implementing visually-matching "empty" and "error" states that preserve the layout dimensions instead of shrinking the view when no data exists.
- [X] T008.A [US1] Implement explicit data fetching and UI mapping for the `Staff` tab within the `lib/screens/admin/courses/admin_course_management_screen.dart` TabBarView to display live instructor/TA assignments using `CourseListBloc` or a dedicated assignments BLoC.
- [X] T008.B [US1] Implement explicit data fetching and UI mapping for the `Schedule` tab within the `lib/screens/admin/courses/admin_course_management_screen.dart` TabBarView to display live section and timing data.
- [X] T008.C [US1] Implement explicit data fetching and UI mapping for the `Exams` tab within the `lib/screens/admin/courses/admin_course_management_screen.dart` TabBarView based on the course catalog context.
- [X] T009 [US1] Update `lib/widgets/admin/courses/course_card.dart` to accept and render live `CourseModel` data directly, ensuring standard widget UI (colors/size/structure) maintains 85%+ visual match to the mockup, and explicitly rendering a Draft/Inactive visual badge when `status == CourseStatus.INACTIVE`.
- [X] T010 [US1] Modify `lib/widgets/admin/courses/course_filters.dart` to dispatch `FilterCourses` search events to `CourseListBloc`, making sure an `INACTIVE` filter explicitly exists so admins can find their failed/draft creations.

## Phase 4: User Story 2 - Create Course Wizard

- [X] T011 [US2] Update the app routing or admin layout wrapper to utilize `BlocProvider<CourseWizardBloc>` (elevating its scope above `admin_add_course_screen.dart` to preserve draft `INACTIVE` courses and state across app navigation), and sync the visual Stepper/PageView to the BLoC's current step state. When entering "edit" mode (`course.status == ACTIVE`), the Stepper MUST be unlocked and non-sequential, allowing direct jumps to Step 2 or 3 without re-saving prior steps.
- [X] T012 [US2] Refactor step 1 (Course Details) logic inside `lib/widgets/admin/courses/course_details_form.dart` to execute strict synchronous client-side frontend validation (`FormState.validate()`) before dispatching a `SubmitStep1` event to `CourseWizardBloc`. Furthermore, handle listening for backend 409/400 uniqueness constraint violations via the BLoC state, explicitly displaying those validation errors back to the native UI fields.
- [X] T013 [US2] Refactor step 2 (Section/Schedule Info) logic inside `lib/widgets/admin/courses/course_settings.dart` executing frontend validation (e.g., capacity > 0) prior to dispatching a `SubmitStep2` event.
- [X] T014 [US2] Expand `lib/widgets/admin/courses/course_staff_assign.dart` into a multi-instructor dynamic `ListView.builder` UI component that dispatches `SubmitStep3`. The `ListView.builder` items MUST render using identical visual padding, box-decorations, and style footprint as the previous single static dropdown to preserve layout geometry and aesthetic structure.
- [X] T015 [US2] Bind the existing explicit navigation actions (Next/Back) in `lib/widgets/admin/courses/add_course_bottom_bar.dart` and `lib/widgets/admin/courses/add_course_progress.dart` to `CourseWizardBloc` events, explicitly ensuring buttons are disabled or show a loading indicator during `status == Loading` to prevent duplicate submissions.

## Phase 5: User Story 3 - Edit and Delete Courses

- [X] T016 [US3] Add a "pre-fill" event inside `CourseWizardBloc` so existing live `CourseModel` data populates the forms immediately when opening `lib/screens/admin/courses/admin_add_course_screen.dart` for edits, ensuring step submissions use `PUT` requests to properly update nested section, schedule, and staff entities.
- [X] T016.A [US3] Update `lib/config/app_router.dart` (or the equivalent routing configuration) to safely accept and pass the explicit `courseId` or `CourseModel` parameter to the `admin_add_course_screen.dart` route to trigger `CourseWizardBloc` pre-fills.
- [X] T017 [US3] Bind soft delete actions to the UI trigger inside `lib/widgets/admin/courses/course_settings.dart` or the context menu in the main layout, ensuring an explicit UI confirmation prompt is displayed and accepted prior to dispatching a delete event to `CourseListBloc`. The BLoC MUST optimistically remove the item from its list state or seamlessly trigger a background re-fetch to maintain UX without a full-page flicker.

## Phase 6: User Story 4 - Manage Student Enrollments

- [X] T018 [US4] Bind `AdminEnrollmentBloc` events explicitly to a dedicated drill-down Section View or corresponding modal dialog, as the main `admin_course_management_screen.dart` serves the general catalog, not section-specific student enrollments.
- [X] T019 [US4] Display a styled UI confirmation dialog upon receiving an `AdminEnrollmentConflictWarning` state from `AdminEnrollmentBloc`, handling forced enrollment commands that bypass scheduling conflicts, and explicitly verifying forced dropping past standard deadlines via API flag.

## Phase 7: Polish & Cross-Cutting Concerns

- [X] T020 Execute a complete functional traversal of the multi-step wizard, artificially failing Step 2, ensuring it correctly updates the new course to the `INACTIVE` status gracefully.
- [X] T021 Audit `lib/screens/admin/courses/` and `lib/widgets/admin/courses/` to actively search for and DELETE any orphaned mockup dummy-data variables, dummy constants files, or unrelated static `.dart` classes from past UI mock stages before backend integration to keep the file tree fully clean.
- [X] T022 Final consistency validation: Check all Admin Phase 9 (Course Management) modified Flutter screens, asserting the final dynamic UI remains ≥ 85% visually identical to the original pre-integration state without breaking existing structural dimensions or layout paradigms.
- [X] T023 Audit and centralize all newly introduced UI labels across the admin course management screens (e.g., "Draft/Inactive", "Confirm Delete?", "Force Enroll") strictly utilizing the project's existing `.arb` / `l10n` localization framework, preventing hardcoded English string litter.
