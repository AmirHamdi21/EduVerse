# Research & Decisions: Admin — Course Management

## 1. 3-Step Wizard Implementation
- **Decision**: Use a single `CourseWizardBloc` to manage the state across all 3 steps. Use a `Stepper` widget or a custom `PageView` with step indicators to maintain the 85% UI similarity to the existing `admin_add_course_screen.dart` mockup.
- **Rationale**: A single BLoC can hold the draft `CourseModel`, `SectionModel`, `ScheduleModel`, and staff assignments in its state. As the admin proceeds, the BLoC performs the sequential API calls (`POST /courses`, `POST /sections`, `POST /schedules/section/{id}`, `POST /enrollments/sections/{id}/instructors`, etc.) and handles partial failures (e.g., saving as INACTIVE if steps 2 or 3 fail).
- **Alternatives**: Separate BLoCs for each step. Rejected because the steps are highly coupled (Step 2 needs the Course ID from Step 1, Step 3 needs the Section ID from Step 2).

## 2. Multi-Instructor UI Expansion
- **Decision**: Update the existing single-instructor dropdown in the mock UI to a dynamic list where the admin can add multiple instructors, selecting a role (`primary`, `co_instructor`, `guest`) for each. 
- **Rationale**: The backend explicitly supports this via `InstructorRole` enum and relations. The spec requires expanding the UI to match this backend parity (Clarification Q3).
- **Alternatives**: Keep the UI as single-instructor but send it as `primary` array of 1. Rejected because it violates the clarified spec requirement.

## 3. Manual Enrollment conflict warnings
- **Decision**: When an admin attempts to enroll a student, the `AdminEnrollmentBloc` will catch any HTTP 409/Conflict response indicating a schedule conflict. The BLoC will emit a `AdminEnrollmentConflictWarning` state. The UI will show a confirmation dialog. If confirmed, a force flag or separate endpoint mechanism will be used to bypass the conflict, as supported by the backend logic.
- **Rationale**: Complies with the clarified requirement to "Warn but allow".

## 4. Static Data Elimination
- **Decision**: Delete all mock data classes and static lists in the existing `admin_course_management_screen.dart` and its sub-widgets. Map them to `CourseListBloc` which fetches from `GET /courses` with query parameters.
- **Rationale**: Constitution Principle VII mandates eliminating all static data.
