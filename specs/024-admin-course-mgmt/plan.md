# Implementation Plan: Admin — Course Management

## Technical Context
- **Language/Framework**: Dart 3+ / Flutter 3.24+
- **Primary Dependencies**: flutter_bloc, equatable, dio, go_router
- **Storage/State**: BLoC / Cubit for state management, Dio for network (no offline caching)
- **Target Platform**: iOS, Android
- **Project Type**: Mobile Application
- **Performance Goals**: Smooth UI transitions in 3-step wizard, fast API filtering
- **Constraints**: 
  - Enforce BLoC and strict data layer separation.
  - Overall UI must match previous mocked UI by at least 85%.
  - Eliminate all mock/static data.
- **Scale/Scope**: Admin persona features targeting course catalog, assignments, and enrollment overrides.

## Constitution Check
- [x] Principle 1 (BLoC State Management): Addressed via `CourseWizardBloc`, `CourseListBloc`, and `AdminEnrollmentBloc`.
- [x] Principle 2 (Strict Data Layer): All data runs through `*Service` files mapping models.
- [x] Principle 3 (Visual Similarity): Keeping `Stepper` or `PageView` implementations structurally identical to old `admin_add_course_screen.dart`.
- [x] Principle 4 (Eliminate Static Data): Deleting previous dummy models in favor of real `CourseModel`.

## Implementation Phases

### Phase 1: API Integration & BLoC Data Layer
**Objective**: Build out the BLoCs capable of performing the operations spec'd out.

1.  **Refactor/Verify Services**: 
    - Verify `CourseService`, `SectionService`, `ScheduleService` and `EnrollmentService`. Ensure `ApiClient` endpoints exist for wizard actions.
2.  **CourseWizardBloc**:
    - Implement `CourseWizardBloc` (Events: `StartWizard`, `SubmitStep1`, `SubmitStep2`, `SubmitStep3`, `SaveAsInactiveOnFailure`).
    - State holds draft IDs.
3.  **CourseListBloc / AdminEnrollmentBloc**:
    - Implement `CourseListBloc` for filtering and searching.
    - Implement `AdminEnrollmentBloc` to handle manual overrides, specifically handling HTTP 409 and emitting `AdminEnrollmentConflictWarning`.

### Phase 2: UI Refactoring & 3-Step Wizard Construction
**Objective**: Integrate BLoCs directly into Admin UI while stripping static logic.

1.  **Strip Static Data**:
    - Purge mock classes in `lib/widgets/admin/courses/` and `lib/screens/admin/`.
2.  **Build 3-Step Wizard**:
    - Refactor `AddCourseBottomBar` or wizard wrapper to depend on `CourseWizardBloc`.
    - Apply existing styling to `WizardStep1Details` (Course Info), `WizardStep2Section` (Section/Schedule Info), `WizardStep3Staff` (Multi-Instructor list).
3.  **Implement Multi-Instructor UI**:
    - In `WizardStep3Staff`, expand the existing dropdown to a dynamic `ListView.builder` allowing Admin to add multiple `InstructorAssignmentModel` via `role`.
4.  **Wire Sub-Tabs**:
    - In `CourseManagementScreen`, bind the 4 tabs (Courses, Staff, Schedule, Exams) to live `CourseListBloc` data.

### Phase 3: Edge Cases, Integration & Stabilization 
**Objective**: Finalize overrides and failure fallbacks.

1.  **Incomplete Wizard Handling**:
    - Implement fallback in `CourseWizardBloc` ensuring `CourseService.updateStatus(id, INACTIVE)` is called if step 2/3 errors or is cancelled.
2.  **Enrollment Warning Dialogs**:
    - Add `BlocListener` on `AdminEnrollmentBloc` to trigger a `showDialog` with conflict info, offering "Force Enroll" functionality.
3.  **QA and Checks**:
    - Perform end-to-end traversal of course creation and data verification. Verify that 85% UI layout is sustained.

## Gates & Acceptance Criteria
- [ ] Wizard accurately creates course, section, schedule, and assigns staff via API.
- [ ] Quitting at Step 2 properly halts and sets course as INACTIVE.
- [ ] Warn-but-allow conflict prompt displays and functions.
- [ ] Zero static mockup model references remain in the admin view.
