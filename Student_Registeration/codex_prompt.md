# Codex Implementation Prompt: Flutter Student Registration Feature

Implement a new Student `Registration` feature in the Flutter app at `D:\Graduation\EduVerse\edu_verse`.

Important:

- Do not change backend or web code unless you hit a confirmed blocker and must report it.
- This task is for the Flutter app only.
- Preserve the current Flutter student courses list and course detail flows.
- Add a **new** student registration screen.
- Use real backend APIs only.
- Do not use mock data, hardcoded lists, or SharedPreferences-backed fake registration state.
- Follow existing project patterns:
  - `CoreApiClient`
  - `RetryHelper.execute<T>()`
  - `ServiceResult<T>`
  - `Equatable`
  - `Cubit` / `Bloc`
- Match the React web `Registration` tab flow for Student role, but do **not** copy the web page's known status-count bugs.

---

## 1. Task Overview

Build a new student `Registration` screen with a modern colorful UI that feels aligned with the existing Flutter student `Courses` and `Course Details` screens.

Required behavior:

1. Add a new student drawer item: `Registration`
2. Add a new route for the registration screen
3. Change the student `Join Course` floating button in `/courses` so it opens the new registration screen
4. Fetch real student data using backend endpoints:
   - enrolled courses
   - available courses for enrollment
   - enrollment periods
5. Allow the student to:
   - browse available courses
   - filter/search like the web page
   - choose a section
   - enroll
   - drop an existing enrolled course when allowed
6. Refresh the enrolled-course list and available-course list after each mutation
7. Refresh other Flutter features that depend on enrollments:
   - `CoursesBloc`
   - `LabsCubit`

Do not:

- replace `/courses`
- turn the registration screen into a mock catalog
- parse `/enrollments/available` with `CourseEnrollmentModel`
- invent waitlist behavior that the backend does not actually support

---

## 2. Project Architecture

### Flutter app

- Path: `D:\Graduation\EduVerse\edu_verse`
- Tech: Flutter + Dart
- Networking: Dio through `CoreApiClient`
- State management: Bloc/Cubit
- Models: Equatable models
- Error wrapping: `ServiceResult<T>` and `ServiceError`

### API base/auth

- Base URL comes from `ApiService.baseUrl` used by `CoreApiClient`
- Auth is Bearer token injection in `CoreApiClient._onRequest`
- 401 refresh-token retry already exists in `CoreApiClient._onError`

### Existing reusable patterns

- `lib/services/api/core_api_client.dart`
- `lib/common/retry_helper.dart`
- `lib/common/service_error.dart`
- `lib/common/utils/student_courses_theme.dart`
- `lib/bloc/courses/courses_bloc.dart`

---

## 3. Files You Must Read First

### Backend reference

- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\enrollments\dto\drop-course.dto.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\campus\controllers\semester.controller.ts`
- `D:\Graduation\backend\last_backend\EduVerse_Backend\src\modules\courses\controllers\course-sections.controller.ts`

### Web reference

- `D:\Graduation\frontend_tarek\Eduverse-Frontend\src\services\api\enrollmentService.ts`
- `D:\Graduation\frontend_tarek\Eduverse-Frontend\src\pages\student-dashboard\components\CourseRegistration.tsx`
- `D:\Graduation\frontend_tarek\Eduverse-Frontend\src\pages\student-dashboard\StudentDashboard.tsx`
- `D:\Graduation\frontend_tarek\Eduverse-Frontend\src\pages\student-dashboard\components\Sidebar.tsx`

### Flutter target

- `D:\Graduation\EduVerse\edu_verse\lib\services\api\enrollment_service.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\services\api\core_api_client.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\common\retry_helper.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\common\service_error.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\models\core\enrollment_model.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\models\core\course_model.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\models\core\section_model.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\models\core\semester_model.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\common\utils\student_courses_theme.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\bloc\courses\courses_bloc.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\screens\student\courses_screen.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\widgets\student\courses\join_course_button.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\widgets\student\dashboard\student_drawer.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\config\app_router.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\main.dart`
- `D:\Graduation\EduVerse\edu_verse\lib\bloc\labs\labs_cubit.dart`

### Existing tests to extend

- `D:\Graduation\EduVerse\edu_verse\test\services\api\enrollment_service_test.dart`
- `D:\Graduation\EduVerse\edu_verse\test\widgets\student\courses\courses_screen_phase1_test.dart`

---

## 4. Verified Backend API Specification

All paths below are full backend paths including `/api`.

## 4.1 Get student enrolled courses

- Path: `/api/enrollments/my-courses`
- Method: `GET`
- Role: `STUDENT`
- Query params:
  - `semester?: number`

Response shape:

```json
[
  {
    "id": 150,
    "userId": 42,
    "sectionId": 5,
    "status": "enrolled",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2026-08-15T10:00:00.000Z",
    "droppedAt": null,
    "completedAt": null,
    "canDrop": true,
    "dropDeadline": "2026-09-01T23:59:59.000Z",
    "course": {
      "id": 12,
      "name": "Discrete Mathematics",
      "code": "MATH201",
      "description": "Introductory discrete math",
      "credits": 3,
      "level": "freshman"
    },
    "section": {
      "id": 5,
      "sectionNumber": "A",
      "maxCapacity": 30,
      "currentEnrollment": 26,
      "location": "C-305"
    },
    "semester": {
      "id": 2,
      "name": "Fall 2026",
      "startDate": "2026-08-15T00:00:00.000Z",
      "endDate": "2026-12-20T00:00:00.000Z"
    },
    "prerequisites": [
      {
        "id": 10,
        "courseId": 12,
        "prerequisiteCourseId": 3,
        "courseCode": "MATH101",
        "courseName": "Calculus I",
        "isMandatory": true,
        "studentCompleted": true,
        "studentGrade": "B+"
      }
    ]
  }
]
```

## 4.2 Get available courses for registration

- Path: `/api/enrollments/available`
- Method: `GET`
- Role: `STUDENT`
- Query params:
  - `departmentId?: number`
  - `semesterId?: number`
  - `search?: string`
  - `level?: string`
  - `page?: number`
  - `limit?: number`

Response shape:

```json
[
  {
    "id": 77,
    "name": "Data Structures",
    "code": "CS201",
    "description": "Core data structures and analysis",
    "credits": 3,
    "level": "sophomore",
    "departmentId": 1,
    "departmentName": "Computer Science",
    "canEnroll": true,
    "enrollmentStatus": null,
    "prerequisites": [
      {
        "id": 4,
        "courseId": 77,
        "prerequisiteCourseId": 12,
        "courseCode": "CS101",
        "courseName": "Programming Fundamentals",
        "isMandatory": true
      }
    ],
    "sections": [
      {
        "id": 31,
        "sectionNumber": "A",
        "maxCapacity": 40,
        "currentEnrollment": 32,
        "availableSeats": 8,
        "location": "B-201",
        "semesterId": 2,
        "semesterName": "Fall 2026"
      },
      {
        "id": 32,
        "sectionNumber": "B",
        "maxCapacity": 40,
        "currentEnrollment": 40,
        "availableSeats": 0,
        "location": "B-203",
        "semesterId": 2,
        "semesterName": "Fall 2026"
      }
    ]
  }
]
```

## 4.3 Register in a section

- Path: `/api/enrollments/register`
- Method: `POST`
- Role: `STUDENT`
- Body:

```json
{
  "sectionId": 31
}
```

Response shape: same as one item from `/api/enrollments/my-courses`

Representative backend failure messages:

- `Student is already enrolled in this section`
- `Prerequisite course XXX not completed`
- `Prerequisite course grade must be B- or higher`
- `Schedule conflict with existing enrollment`
- `Retaking courses for grade improvement requires admin approval`

## 4.4 Drop enrollment

- Path: `/api/enrollments/:id`
- Method: `DELETE`
- Role: Student own enrollment or Admin
- Optional body:

```json
{
  "reason": "student_request",
  "notes": "Optional explanation"
}
```

Response shape: full updated enrollment object, not `{ "message": "..." }`

Representative backend failure messages:

- `Drop deadline has passed. Contact admin to drop this course`
- `Cannot drop an enrollment that is no longer active`
- `You do not have permission to access this enrollment`

## 4.5 Enrollment periods

- Path: `/api/enrollments/periods`
- Method: `GET`
- Role: Student allowed

Response shape:

```json
[
  {
    "id": 2,
    "semesterName": "Fall 2026",
    "semesterCode": "FALL2026",
    "registrationStart": "2026-07-20",
    "registrationEnd": "2026-08-10",
    "semesterStart": "2026-08-15",
    "semesterEnd": "2026-12-20",
    "status": "upcoming"
  }
]
```

## 4.6 Optional enrichment endpoints

Use only if you need extra details in the registration UI:

- `/api/sections/:id`
  - `GET`
  - public
  - returns full section with course, semester, schedules
- `/api/enrollments/section/:sectionId/instructor`
  - `GET`
  - student allowed
- `/api/enrollments/section/:sectionId/tas`
  - `GET`
  - student allowed

Do not add these calls unless the design truly needs them, because they introduce N+1 fetch cost.

---

## 5. Critical Audit Notes You Must Respect

1. **Do not reuse `CourseEnrollmentModel` for `/enrollments/available`.**
   - That endpoint returns catalog rows, not enrollment rows.

2. **Do not copy the web page's broken status checks.**
   - Web counts `registered` and `waitlist`
   - Backend actually returns `enrolled`, `completed`, `dropped`, `withdrawn`

3. **Backend waitlist is not implemented.**
   - The service currently keeps `enrollmentStatus = ENROLLED` even when a section is full.
   - Keep the UI tolerant, but do not invent fake waitlist behavior.

4. **The backend may return `departmentName = "Unknown"` for available courses.**
   - The service uses `course.department?.name` without clearly joining the relation.
   - Your Flutter UI must degrade gracefully if department names are missing.

5. **Use `/api/enrollments/periods` for the student registration header.**
   - Do not reuse the admin semesters path for this screen unless you are explicitly told to.

6. **Preserve current course list and course detail flows.**
   - `/courses` stays the enrolled-course screen.
   - The new registration route is separate.

7. **After register/drop, refresh dependent Flutter state.**
   - `CoursesBloc`
   - `LabsCubit`

8. **Do not touch `main.dart` unless absolutely necessary.**
   - `EnrollmentService` is already available through `RepositoryProvider`.
   - Prefer route-level `BlocProvider` in `app_router.dart`.

9. **Do not remove existing enrolled-course cache logic from `CoursesBloc` as part of this task.**
   - Just do not rely on that cache for the new registration screen.

---

## 6. Required Implementation Plan

## Phase 1: Data contracts

Create these files:

- `lib/models/registration/registration_available_course_model.dart`
- `lib/models/registration/registration_available_section_model.dart`
- `lib/models/registration/registration_available_prerequisite_model.dart`
- `lib/common/utils/student_registration_filters.dart`

Modify:

- `lib/services/api/enrollment_service.dart`

Required methods in `EnrollmentService`:

- `Future<ServiceResult<List<RegistrationAvailableCourseModel>>> getAvailableCourses({ int? departmentId, int? semesterId, String? search, String? level, int page = 1, int limit = 20 })`
- `Future<ServiceResult<List<EnrollmentPeriodModel>>> getEnrollmentPeriods()`
- `Future<ServiceResult<CourseEnrollmentModel>> registerForSection({ required int sectionId })`
- keep `dropEnrollment(dynamic id)` and existing enrolled-course methods working

Implementation rules:

- Use `RetryHelper.execute<T>()`
- Parse lists using the same defensive patterns already used in the service layer
- Keep current public methods if other code depends on them, but add the correct student-registration ones

## Phase 2: Cubit/state

Create:

- `lib/bloc/student_registration/student_registration_state.dart`
- `lib/bloc/student_registration/student_registration_cubit.dart`

State must include:

- available courses
- enrolled courses
- enrollment periods
- loading flags
- enroll/drop mutation flags
- filter/search selection
- success/error messages

Cubit methods:

- `load()`
- `refresh()`
- `setSearchQuery(...)`
- `setDepartment(...)`
- `setLevel(...)`
- `selectCourse(...)`
- `selectSection(...)`
- `enrollSelectedSection()`
- `dropEnrollment(...)`
- `clearMessages()`

Load flow:

- fetch enrolled courses
- fetch available courses
- fetch periods
- compute real stats

Mutation flow:

- enroll/drop
- then refetch enrolled + available lists

## Phase 3: New UI

Create:

- `lib/screens/student/student_registration_screen.dart`
- `lib/widgets/student/registration/registration_header.dart`
- `lib/widgets/student/registration/registration_stats_row.dart`
- `lib\widgets\student\registration\registration_filter_bar.dart`
- `lib\widgets\student\registration\available_course_card.dart`
- `lib\widgets\student\registration\registered_course_card.dart`
- `lib\widgets\student\registration\section_selection_sheet.dart`
- `lib\widgets\student\registration\registration_empty_state.dart`
- `lib\widgets\student\registration\registration_loading_view.dart`

Design rules:

- match the colorful, modern feel of:
  - current student `/courses`
  - current student course details screen
- use `StudentCoursesTheme` where possible
- gradient header required
- real stats required
- modern cards required
- do not make it basic

Layout recommendation:

- top gradient header with period badge
- stats row
- search and filter controls
- available-course list
- compact enrolled-course section
- bottom-sheet section picker for enroll action

Card behavior:

- if course is already enrolled, show enrolled chip and no enroll button
- if `canEnroll == false`, show disabled state such as `Prerequisites Required`
- if multiple sections exist, show section sheet before final enroll
- if one section exists, preselect it and confirm

## Phase 4: Navigation wiring

Modify:

- `lib/config/app_router.dart`
- `lib/widgets/student/dashboard/student_drawer.dart`
- `lib/widgets/student/courses/join_course_button.dart`

Required route:

- recommended path: `'/registration'`

Drawer:

- add a new `Registration` item after `Courses`

Join button:

- change route from `'/courses'` to `'/registration'`

## Phase 5: Refresh dependent features

From the registration screen, after successful enroll/drop:

- trigger `context.read<CoursesBloc>().add(const CoursesRefreshed())`
  - or `StudentCoursesFetched(...)` if you need semester-aware refresh
- trigger `context.read<LabsCubit>().loadEnrolledCourses()`

Do not restructure those other features.

## Phase 6: Localization

Modify:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_ar.arb`

Then regenerate:

- `lib/generated_l10n/app_localizations.dart`
- `lib/generated_l10n/app_localizations_en.dart`
- `lib/generated_l10n/app_localizations_ar.dart`

Reuse existing keys where possible:

- `allDepartments`
- `allLevels`
- `joinCourse`
- `cancel`
- `confirm`
- `drop`

## Phase 7: Tests

Modify or add:

- `test/services/api/enrollment_service_test.dart`
- `test/models/registration_available_course_model_test.dart`
- `test/bloc/student_registration/student_registration_cubit_test.dart`
- `test/widgets/student/registration/student_registration_screen_test.dart`
- `test/widgets/student/courses/courses_screen_phase1_test.dart`

Minimum coverage:

- service parses available courses correctly
- missing `enrollmentStatus` is handled safely
- periods load correctly
- enroll refreshes data
- drop refreshes data
- join button navigates to new route
- registration screen renders loading, success, empty, and error states

---

## 7. Implementation Notes

- If you keep the old `register(dynamic sectionId, Map<String, dynamic> data)` method for compatibility, internally route it through the new `registerForSection`.
- Keep parsing tolerant for `int` and numeric-string ids.
- For UI stats:
  - `enrolled credits`: sum credits of `status == enrolled`
  - `registered courses`: count `status == enrolled`
  - `waitlist count`: count statuses `waitlisted` or `waitlist`; expect zero unless backend changes
- For missing `enrollmentStatus` in available rows:
  - treat as `not_enrolled` in UI logic
- For department filter:
  - if every course has blank/Unknown department, still render the list and suppress useless filtering noise gracefully
- Do not add fake schedule strings if the available-course payload does not include schedules
- If you choose to enrich with `/api/sections/:id`, do it only on demand for a selected course or selected section, not for every list item on initial load

---

## 8. Verification Checklist

Run from `D:\Graduation\EduVerse\edu_verse`:

```powershell
dart format lib test
flutter analyze
flutter test test/services/api/enrollment_service_test.dart
flutter test test/models/registration_available_course_model_test.dart
flutter test test/bloc/student_registration/student_registration_cubit_test.dart
flutter test test/widgets/student/registration/student_registration_screen_test.dart
flutter test test/widgets/student/courses/courses_screen_phase1_test.dart
```

Manual checks:

1. Open drawer and confirm `Registration` is present.
2. Tap `Join Course` from `/courses` and confirm it opens the new registration screen.
3. Confirm header/stats are populated from live API data.
4. Confirm available courses load from `/api/enrollments/available`.
5. Confirm current enrolled courses load from `/api/enrollments/my-courses`.
6. Confirm search and filters work.
7. Confirm section selection works.
8. Confirm enroll success refreshes lists.
9. Confirm drop success refreshes lists.
10. Confirm `/courses` and labs reflect the new enrollment state after refresh.
11. Confirm backend validation messages are shown to the user instead of generic failures.

---

## 9. Stop Conditions

Stop and report instead of silently faking data if:

1. `/api/enrollments/available` does not return usable department names and the UI requirement absolutely depends on real departments.
2. The backend returns a shape different from the verified controller/service contract above.
3. Route/provider access from `app_router.dart` cannot access `EnrollmentService` from context.

If none of those blockers happen, complete the implementation end to end.
