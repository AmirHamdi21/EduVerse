# Quickstart: Admin Course Management

This feature implements the full course management flow for the Admin persona, replacing mocked interfaces with functional APIs and real state management.

## Setup Instructions

1.  **Ensure Services:** Ensure that `CourseService`, `SectionService`, `ScheduleService`, and `EnrollmentService` in `lib/services/api/` are correctly configured and injected.
2.  **Add Bloc Providers:** In the main app or the admin layout, provide `CourseListBloc`, `CourseWizardBloc`, and `AdminEnrollmentBloc` where appropriate.
3.  **Run Application:** Serve the app to an emulator or physical device.

## Core Workflows

1.  **Viewing Courses:** Navigate to the Admin Dashboard and select Course Management. `CourseListBloc` triggers `LoadCourses` to fetch data from the server.
2.  **Creating a Course (Wizard):**
    *   Click "Add Course".
    *   **Step 1:** Fill in `CourseModel` details. On 'Next', `CourseWizardBloc` issues a `POST /courses` request. If successful, stores `draftCourseId`.
    *   **Step 2:** Fill in `SectionModel` and `ScheduleModel` details. On 'Next', it creates the section and schedule via API, storing `draftSectionId`.
    *   **Step 3:** Assign instructors/TAs. On finish, it links staff to the section via API, then completes. If this fails, the created Course stays `INACTIVE`.
3.  **Manual Enrollment Operations:** Admins can view enrolled students via a course section's "Staff/Students" tab and execute `ForceEnroll` or `ForceDrop` events on the `AdminEnrollmentBloc`, handling the "warn but allow" logic on conflict.
