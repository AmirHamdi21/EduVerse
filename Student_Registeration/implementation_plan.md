# EduVerse Flutter Student Registration Implementation Plan

## Scope

This document is investigation-only. No feature implementation is executed here.

Target outcome:

- Add a new Student `Registration` screen to the Flutter app.
- Match the React web `Registration` tab flow for Student role.
- Use real backend APIs only.
- Keep the existing Flutter student course list and course details screens intact.
- Add entry points from:
  - student drawer
  - student courses list floating `Join Course` button

Investigated codebases:

- Backend: `D:\Graduation\backend\last_backend\EduVerse_Backend`
- Web frontend reference: `D:\Graduation\frontend_tarek\Eduverse-Frontend`
- Flutter target: `D:\Graduation\EduVerse\edu_verse`

Primary files investigated:

- Backend
  - `src/modules/enrollments/controllers/enrollments.controller.ts`
  - `src/modules/enrollments/services/enrollments.service.ts`
  - `src/modules/enrollments/dto/*.ts`
  - `src/modules/enrollments/entities/course-enrollment.entity.ts`
  - `src/modules/courses/controllers/course-sections.controller.ts`
  - `src/modules/courses/services/course-sections.service.ts`
  - `src/modules/campus/controllers/semester.controller.ts`
  - `src/modules/campus/services/semester.service.ts`
- Web
  - `src/services/api/enrollmentService.ts`
  - `src/pages/student-dashboard/components/CourseRegistration.tsx`
  - `src/pages/student-dashboard/StudentDashboard.tsx`
  - `src/pages/student-dashboard/components/Sidebar.tsx`
  - `src/pages/student-dashboard/components/ClassTab.tsx`
  - `src/pages/student-dashboard/components/LabInstructions.tsx`
  - `src/pages/student-dashboard/components/CourseCommunity.tsx`
  - `src/pages/student-dashboard/pages/CourseView.tsx`
- Flutter
  - `lib/services/api/enrollment_service.dart`
  - `lib/services/api/core_api_client.dart`
  - `lib/common/retry_helper.dart`
  - `lib/common/service_error.dart`
  - `lib/models/core/enrollment_model.dart`
  - `lib/models/core/course_model.dart`
  - `lib/models/core/section_model.dart`
  - `lib/models/core/semester_model.dart`
  - `lib/bloc/courses/courses_bloc.dart`
  - `lib/bloc/courses/courses_event.dart`
  - `lib/bloc/courses/courses_state.dart`
  - `lib/screens/student/courses_screen.dart`
  - `lib/screens/student/course_details_screen.dart`
  - `lib/widgets/student/dashboard/student_drawer.dart`
  - `lib/widgets/student/courses/join_course_button.dart`
  - `lib/config/app_router.dart`
  - `lib/common/utils/student_courses_theme.dart`
  - `lib/common/utils/student_course_filters.dart`
  - `lib/bloc/labs/labs_cubit.dart`
  - `lib/bloc/lab_detail/lab_detail_cubit.dart`
  - `lib/features/courses/bloc/course_list/course_list_bloc.dart`

---

## 1. Endpoint Audit Table

### 1.1 Student registration flow endpoints

| # | Backend Controller Decorator | Web Frontend Method | Correct Full Path | HTTP Method | Roles |
|---|---|---|---|---|---|
| 1 | `@Controller('api/enrollments')` + `@Get('my-courses')` | `enrollmentService.getMyCourses()` / `EnrollmentService.getMyCourses()` | `/api/enrollments/my-courses` | `GET` | `STUDENT` |
| 2 | `@Controller('api/enrollments')` + `@Get('available')` | `enrollmentService.getAvailableCourses()` / `EnrollmentService.getAvailableCourses()` | `/api/enrollments/available` | `GET` | `STUDENT` |
| 3 | `@Controller('api/enrollments')` + `@Post('register')` | `enrollmentService.enrollInSection()` / `EnrollmentService.register()` | `/api/enrollments/register` | `POST` | `STUDENT` |
| 4 | `@Controller('api/enrollments')` + `@Delete(':id')` | `enrollmentService.dropCourse()` / `EnrollmentService.drop()` | `/api/enrollments/:id` | `DELETE` | Authenticated user; intended Student own enrollment or Admin override |
| 5 | `@Controller('api/enrollments')` + `@Get('periods')` | No student web registration call today; useful for Flutter registration header/stats | `/api/enrollments/periods` | `GET` | `IT_ADMIN`, `ADMIN`, `INSTRUCTOR`, `TA`, `STUDENT` |
| 6 | `@Controller('api/semesters')` + `@Get('current')` | No direct web registration call | `/api/semesters/current` | `GET` | `IT_ADMIN`, `ADMIN`, `INSTRUCTOR`, `TA`, `STUDENT` |
| 7 | `@Controller('api/semesters')` + `@Get()` | Used indirectly in Flutter admin periods service, not in web registration tab | `/api/semesters` | `GET` | `IT_ADMIN`, `ADMIN`, `INSTRUCTOR`, `TA`, `STUDENT` |
| 8 | `@Controller('api/sections')` + `@Get(':id')` | Not used by current web registration tab; optional enrichment endpoint | `/api/sections/:id` | `GET` | Public |

### 1.2 Supporting section-staff endpoints discovered during audit

These are not part of the current web student `Registration` tab, but they are already used elsewhere in the Flutter student course detail flow and are relevant if the new registration UI wants richer section staff details:

| # | Backend Controller Decorator | Web Frontend Method | Correct Full Path | HTTP Method | Roles |
|---|---|---|---|---|---|
| 9 | `@Controller('api/enrollments')` + `@Get('section/:sectionId/instructor')` | `enrollmentService.getSectionInstructor()` | `/api/enrollments/section/:sectionId/instructor` | `GET` | `ADMIN`, `INSTRUCTOR`, `TA`, `STUDENT` |
| 10 | `@Controller('api/enrollments')` + `@Get('section/:sectionId/tas')` | `enrollmentService.getSectionTAs()` | `/api/enrollments/section/:sectionId/tas` | `GET` | `ADMIN`, `INSTRUCTOR`, `TA`, `STUDENT` |

### 1.3 Verified request/response contracts

#### `GET /api/enrollments/my-courses`

Controller:

- `@Query('semester') semester?: number`

Required query params:

- none

Optional query params:

- `semester: number`

Response source:

- `EnrollmentsService.getMyEnrollments()`
- Returns `EnrollmentResponseDto[]`

Returned fields per item:

- `id: number`
- `userId: number`
- `sectionId: number`
- `status: 'enrolled' | 'completed' | 'dropped' | 'withdrawn'`
- `grade: string | null`
- `finalScore: number | null`
- `enrollmentDate: Date`
- `droppedAt: Date | null`
- `completedAt: Date | null`
- `canDrop: boolean`
- `dropDeadline: Date | null`
- `course`
  - `id`
  - `name`
  - `code`
  - `description`
  - `credits`
  - `level`
- `section`
  - `id`
  - `sectionNumber`
  - `maxCapacity`
  - `currentEnrollment`
  - `location`
- `semester`
  - `id`
  - `name`
  - `startDate`
  - `endDate`
- `instructor`
  - currently always omitted because backend service hardcodes `const instructor: any = null`
- `prerequisites[]`
  - `id`
  - `courseId`
  - `prerequisiteCourseId`
  - `courseCode`
  - `courseName`
  - `isMandatory`
  - `studentCompleted`
  - `studentGrade`

#### `GET /api/enrollments/available`

Controller:

- `@Query() filters: AvailableCoursesFilterDto`

Optional query params from DTO:

- `departmentId?: number`
- `semesterId?: number`
- `search?: string`
- `level?: string`
- `page?: number = 1`
- `limit?: number = 20`

Response source:

- `EnrollmentsService.getAvailableCourses()`
- Returns `AvailableCoursesDto[]`

Returned fields per item:

- `id: number`
- `name: string`
- `code: string`
- `description: string`
- `credits: number`
- `level: string`
- `departmentId: number`
- `departmentName: string`
- `sections[]`
  - `id`
  - `sectionNumber`
  - `maxCapacity`
  - `currentEnrollment`
  - `availableSeats`
  - `location`
  - `semesterId`
  - `semesterName`
- `prerequisites[]`
  - `id`
  - `courseId`
  - `prerequisiteCourseId`
  - `courseCode`
  - `courseName`
  - `isMandatory`
- `canEnroll: boolean`
- `enrollmentStatus?: string`

Implementation detail discovered in backend:

- `departmentName` is populated from `course.department?.name`, but the service query never explicitly joins `course.department`. If the relation is not eager at runtime, the backend will emit `"Unknown"` for every available course.

#### `POST /api/enrollments/register`

Controller body DTO:

- `EnrollCourseDto`
  - `sectionId: number` required

Response:

- `EnrollmentResponseDto`

Validation/business logic discovered in service:

- rejects if user or section or course or semester not found
- rejects duplicate non-dropped enrollment
- checks retake policy
- checks prerequisites
- checks schedule conflicts
- attempts capacity handling, but current implementation does **not** truly waitlist

Important backend behavior:

- if section is already full, current code still sets `enrollmentStatus = ENROLLED`
- the backend exception `SectionFullException` exists but is not used in this path
- the current backend therefore does not deliver true waitlist behavior to match the web UI copy

#### `DELETE /api/enrollments/:id`

Controller:

- `@Body() dropCourseDto?: DropCourseDto`

Optional body DTO:

- `reason?: DropReason`
  - `'student_request' | 'failing_grade' | 'admin_removal' | 'schedule_conflict' | 'other'`
- `notes?: string`

Service behavior:

- checks enrollment exists
- checks permission unless admin
- only active enrolled courses may be dropped
- student drops are blocked after the calculated drop deadline
- decrements section current enrollment
- returns full updated `EnrollmentResponseDto`

#### `GET /api/enrollments/periods`

Response source:

- `EnrollmentsService.getEnrollmentPeriods()`

Returned fields:

- `id`
- `semesterName`
- `semesterCode`
- `registrationStart`
- `registrationEnd`
- `semesterStart`
- `semesterEnd`
- `status`

---

## 2. Endpoint Correctness Audit Findings

### 2.1 Backend vs web mismatches

1. Web service `dropCourse()` expects `{ message?: string }`, but backend `DELETE /api/enrollments/:id` returns a full `EnrollmentResponseDto`.
2. Web `CourseRegistration.tsx` counts `registeredCourses.filter((c) => c.status === 'registered')`, but backend statuses are `enrolled`, `completed`, `dropped`, `withdrawn`.
3. Web `CourseRegistration.tsx` counts waitlist with `c.status === 'waitlist'`, but backend waitlist is not implemented and the service currently never returns `waitlist` or `waitlisted`.
4. Web interface `AvailableCourse.enrollmentStatus` is typed as `'enrolled' | 'not_enrolled' | 'waitlisted'`, but backend only returns existing enrollment statuses when present and often omits the field entirely for not-enrolled courses.
5. Web keeps `prerequisites: []` in UI mapping even though backend returns structured prerequisite data.
6. Web `assignInstructor()` and `assignTA()` inside `src/services/api/enrollmentService.ts` call `/enrollments/assign-instructor` and `/enrollments/assign-ta`, but those endpoints do not exist in backend. Correct paths are:
   - `/api/enrollments/sections/:sectionId/instructors`
   - `/api/enrollments/sections/:sectionId/tas`
   These are outside Student registration scope but are real service mismatches.

### 2.2 Backend vs Flutter mismatches

1. Flutter `EnrollmentService.getAvailableCourses()` currently parses `/enrollments/available` into `CourseEnrollmentModel`, but backend returns `AvailableCoursesDto[]`, not enrollment rows.
2. Flutter `EnrollmentStatus` enum includes `waitlisted` and `failed`, but backend enrollment status enum currently exposes only:
   - `enrolled`
   - `dropped`
   - `completed`
   - `withdrawn`
3. Flutter `EnrollmentService.getCourseStudents()` calls `/enrollments/course/$courseId/enrolled-students`, which does not exist in the backend controller investigated. This is outside the Student registration screen scope but is a verified service-path mismatch.
4. Flutter `StudentDrawer` points its dashboard item to `/student-dashboard`, but `app_router.dart` exposes `/dashboard`. This is an adjacent routing bug discovered while auditing navigation.
5. Flutter `JoinCourseButton` routes to `/courses`; user requirement is to route it to the new registration screen instead.

### 2.3 Recommended behavior decisions

1. Use backend truth for status normalization, not the buggy web literal checks.
2. Preserve the web page structure and operation flow, but do not intentionally copy its incorrect status comparisons.
3. Keep a waitlist stat card only as a passive future-proof metric. It will likely be `0` until backend waitlist support exists.

---

## 3. Cross-Feature Investigation Results

| Feature / Screen | File(s) | Current dependency on enrollment data | Needs change? | Why |
|---|---|---|---|---|
| Student course list | `lib/screens/student/courses_screen.dart`, `lib/bloc/courses/courses_bloc.dart`, `lib/widgets/student/courses/*` | Uses `GET /enrollments/my-courses` via `CoursesBloc` | Indirect only | After successful register/drop from new screen, this view should be refreshed, but its structure does not need to change |
| Student course details | `lib/screens/student/course_details_screen.dart`, `features/courses/bloc/course_detail/*` | Consumes `CourseEnrollmentModel`; loads section staff via enrollment endpoints | No direct model change | Registration screen should keep using a separate available-course model so course detail flow remains stable |
| Student labs list | `lib/bloc/labs/labs_cubit.dart` | Calls `EnrollmentService.getMyCourses()` to derive enrolled course options | Indirect only | Labs list should be refreshed after register/drop so newly enrolled courses appear |
| Student lab detail submission gate | `lib/bloc/lab_detail/lab_detail_cubit.dart` | Calls `EnrollmentService.getMyCourses()` for enrollment gate before submission | No code change required | It already refetches from API when needed; registration changes only improve data freshness |
| Alternate course list bloc | `lib/features/courses/bloc/course_list/course_list_bloc.dart` | Calls `EnrollmentService.getMyCourses()` | No immediate change | Separate legacy/feature bloc; not part of new registration route |
| Student dashboard drawer | `lib/widgets/student/dashboard/student_drawer.dart` | Menu routing only | Yes | Must add new `Registration` item to navigate to the new screen |
| Student course list join button | `lib/widgets/student/courses/join_course_button.dart` | Routes to `/courses` | Yes | Must navigate to new registration route |
| Student dashboard quick access | `lib/widgets/student/dashboard/student_quick_access_grid.dart` | Routes to `/courses` | No | User explicitly asked only drawer item and join button; keep unchanged unless requested later |
| Web student dashboard registration tab | `src/pages/student-dashboard/components/CourseRegistration.tsx` | Reference implementation for flow and layout | Reference only | No code change in Flutter plan, but this file is the UI/behavior source of truth |
| Web class/community/labs pages | `ClassTab.tsx`, `CourseCommunity.tsx`, `LabInstructions.tsx`, `CourseView.tsx` | All depend on `getMyCourses()` | Reference only | Confirms registration mutations must refresh enrolled courses everywhere, but no Flutter structural change is required beyond refresh hooks |

---

## 4. Existing Service / Model Reuse

### 4.1 Safe to reuse as-is

| File | Reuse decision | Why |
|---|---|---|
| `lib/services/api/core_api_client.dart` | Reuse | Already provides base URL, auth token injection, refresh-token retry |
| `lib/common/retry_helper.dart` | Reuse | Standard `ServiceResult<T>` wrapping and transient retry behavior |
| `lib/common/service_error.dart` | Reuse | Matches existing service error surface |
| `lib/models/core/enrollment_model.dart` | Reuse for enrolled-course data only | Correct for `GET /enrollments/my-courses` and `POST /enrollments/register` responses |
| `lib/models/core/course_model.dart` | Reuse | Still valid for nested `course` inside enrollment responses |
| `lib/models/core/semester_model.dart` | Reuse | Already parses `registrationStart` / `registrationEnd` if present |
| `lib/common/utils/student_courses_theme.dart` | Reuse | Good visual token base for a registration screen that should feel like existing student course UI |
| `lib/bloc/courses/courses_bloc.dart` | Reuse for post-mutation refresh only | Existing enrolled-course list management should stay separate from registration screen state |

### 4.2 Reuse with modification

| File | Reuse decision | Why |
|---|---|---|
| `lib/services/api/enrollment_service.dart` | Modify | Current available-courses parsing is wrong and registration-period method is missing |
| `lib/widgets/student/courses/join_course_button.dart` | Modify | Navigation target must change from `/courses` to the new registration route |
| `lib/widgets/student/dashboard/student_drawer.dart` | Modify | Must add `Registration` menu item |
| `lib/config/app_router.dart` | Modify | Must register the new route and provide screen-level Bloc/Cubit injection |
| `test/services/api/enrollment_service_test.dart` | Modify | Needs coverage for available-course parsing and registration-period fetch |
| `test/widgets/student/courses/courses_screen_phase1_test.dart` | Modify | Join button route expectation will change |

### 4.3 Do not reuse for the new screen

| File / class | Reuse decision | Why |
|---|---|---|
| `CourseEnrollmentModel` for available-courses endpoint | Do not reuse | Available course payload is catalog-centric, not enrollment-centric |
| `SectionModel` as the exact available-section contract | Prefer a dedicated model | Available section payload omits some `SectionModel` fields and adds UI-relevant `availableSeats` / `semesterName` |
| `CoursesBloc` as the main registration state owner | Do not reuse | Registration screen needs separate filters, selection, enroll/drop mutations, and header stats |

---

## 5. User Review Required

These decisions have non-obvious product or data consequences and should be acknowledged before implementation:

1. **Waitlist truth vs web copy**
   - Recommendation: keep a waitlist metric and passive UI affordance for parity, but derive it from actual statuses. It will likely remain `0` because backend waitlist logic is not implemented.

2. **Registration-period source**
   - Recommendation: use `/api/enrollments/periods` for the new student registration header instead of reusing admin `/api/semesters`, because `/api/enrollments/periods` is feature-scoped and already verified for Student role.

3. **Department filter reliability**
   - Recommendation: implement department filtering in Flutter exactly as the web does, but guard for the backend returning `departmentName = "Unknown"` for all rows. If that happens in real data, this is a backend data-quality issue, not a Flutter bug.

4. **Status normalization**
   - Recommendation: do not copy the web page's `registered` / `waitlist` string comparisons. Normalize to backend status strings while keeping equivalent visuals.

5. **Route naming**
   - Recommendation: use a dedicated route such as `/registration` for the new student registration screen. This avoids collision with auth `/register` while staying simple and consistent with the current router style.

---

## 6. Proposed Changes By Phase

## Phase 1: Add correct registration data contracts and service methods

### Files

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\services\api\enrollment_service.dart`
  - Change `getAvailableCourses()` return type from `ServiceResult<List<CourseEnrollmentModel>>` to `ServiceResult<List<RegistrationAvailableCourseModel>>`
  - Add optional query params:
    - `departmentId`
    - `semesterId`
    - `search`
    - `level`
    - `page`
    - `limit`
  - Add `getEnrollmentPeriods()` that calls `/enrollments/periods`
  - Add a clearer `registerForSection({required int sectionId})` wrapper or rename the existing `register()` call while preserving backward compatibility if needed
  - Keep `dropEnrollment()` but allow optional body fields if the implementation wants a future-proof drop reason
  - Keep existing enrolled-course endpoints unchanged

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\models\registration\registration_available_course_model.dart`
  - New exact Flutter model for the web/backend available-course payload
  - Recommended fields:
    - `int id`
    - `String name`
    - `String code`
    - `String description`
    - `int credits`
    - `String level`
    - `int departmentId`
    - `String departmentName`
    - `bool canEnroll`
    - `String? enrollmentStatus`
    - `List<RegistrationAvailableSectionModel> sections`
    - `List<RegistrationAvailablePrerequisiteModel> prerequisites`
  - Add `fromJson` with tolerant parsing for `int` or numeric strings
  - Add computed helpers:
    - `bool get isAlreadyEnrolled`
    - `String get normalizedEnrollmentStatus`
    - `RegistrationAvailableSectionModel? get primarySection`

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\models\registration\registration_available_section_model.dart`
  - Exact fields:
    - `int id`
    - `String sectionNumber`
    - `int maxCapacity`
    - `int currentEnrollment`
    - `int availableSeats`
    - `String? location`
    - `int semesterId`
    - `String semesterName`
  - Add computed `bool get isFull => availableSeats <= 0`

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\models\registration\registration_available_prerequisite_model.dart`
  - Exact fields:
    - `int id`
    - `int courseId`
    - `int prerequisiteCourseId`
    - `String courseCode`
    - `String courseName`
    - `bool isMandatory`

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\common\utils\student_registration_filters.dart`
  - Pure helpers for:
    - search matching by title, code, department
    - department option derivation
    - level option derivation
    - stats derivation from enrolled + available lists
    - normalization of backend status values into UI-safe values

### Why this phase exists

- The Flutter app already has live enrolled-course parsing.
- It does **not** have a correct model for `/enrollments/available`.
- Fixing the contract first prevents UI code from leaking backend-shape assumptions everywhere.

## Phase 2: Add student registration state management

### Files

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\bloc\student_registration\student_registration_state.dart`
  - Use `Equatable`
  - Recommended state fields:
    - `bool isInitialLoading`
    - `bool isRefreshing`
    - `bool isSubmittingEnrollment`
    - `String? activeEnrollSectionIdKey`
    - `String? activeDropEnrollmentId`
    - `String searchQuery`
    - `String selectedDepartment`
    - `String selectedLevel`
    - `int? selectedCourseId`
    - `int? selectedSectionId`
    - `List<RegistrationAvailableCourseModel> availableCourses`
    - `List<CourseEnrollmentModel> enrolledCourses`
    - `List<EnrollmentPeriodModel> enrollmentPeriods`
    - `String? errorMessage`
    - `String? successMessage`
  - Add derived getters or companion helpers for:
    - `filteredAvailableCourses`
    - `departmentOptions`
    - `levelOptions`
    - `totalCredits`
    - `registeredCoursesCount`
    - `waitlistCount`
    - `availableCoursesCount`
    - `currentPeriod`

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\bloc\student_registration\student_registration_cubit.dart`
  - Dependencies:
    - `EnrollmentService`
  - Recommended methods:
    - `Future<void> load()`
    - `Future<void> refresh()`
    - `void setSearchQuery(String value)`
    - `void setDepartment(String value)`
    - `void setLevel(String value)`
    - `void selectCourse(int? courseId)`
    - `void selectSection(int? sectionId)`
    - `Future<bool> enrollSelectedSection()`
    - `Future<bool> dropEnrollment(String enrollmentId)`
    - `void clearMessages()`
  - `load()` should use `Future.wait` for:
    - `getMyEnrollments()`
    - `getAvailableCourses()`
    - `getEnrollmentPeriods()`
  - `enrollSelectedSection()` and `dropEnrollment()` must refetch both current and available course lists on success

- `[NEW] D:\Graduation\EduVerse\edu_verse\test\bloc\student_registration\student_registration_cubit_test.dart`
  - Cover:
    - initial load success
    - available-course parse mismatch safety
    - enroll success triggers refresh
    - drop success triggers refresh
    - backend error messages surface cleanly
    - missing `enrollmentStatus` becomes `not_enrolled` in UI logic

### Why this phase exists

- The new screen needs separate loading/mutation/filter state.
- `CoursesBloc` should stay focused on enrolled-course lists and detail screens.

## Phase 3: Build the new student registration screen and widgets

### Files

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\screens\student\student_registration_screen.dart`
  - Use `BlocProvider<StudentRegistrationCubit>`
  - Use `Scaffold` + `CustomScrollView`
  - Visual direction:
    - colorful gradient header
    - modern stats cards using real API data
    - search and filter controls
    - modern stacked course cards for available courses
    - compact enrolled-course section with drop action
  - Mobile-adapted structure that preserves the web flow:
    - header
    - stats
    - filters
    - available course list
    - enrolled-course strip/list
    - section picker confirmation bottom sheet

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_header.dart`
  - Show:
    - title
    - subtitle
    - current period badge using real registration window data
    - maybe active semester label

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_stats_row.dart`
  - Real-data cards:
    - enrolled credits
    - registered courses count
    - waitlist count or zero
    - optional available-courses count if layout allows

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_filter_bar.dart`
  - Search field
  - Department filter
  - Level filter
  - Use same visual language as existing student course shell

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\available_course_card.dart`
  - Each card should render:
    - course code
    - title
    - department
    - credits
    - level
    - primary section number
    - section count
    - seat count
    - semester name
    - location
    - disabled state if prerequisites not met
    - enrolled badge if already enrolled
    - enroll button if eligible
  - Button behavior:
    - if multiple sections, open section sheet
    - if one section, preselect then confirm

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registered_course_card.dart`
  - Compact card for the student's current enrollments
  - Show:
    - code
    - title
    - credits
    - section + semester
    - status chip
    - drop button if `canDrop == true`

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\section_selection_sheet.dart`
  - Bottom sheet/modal
  - Show all sections for selected course
  - Each option shows:
    - section number
    - semester
    - location
    - available seats
  - Confirm button calls cubit enroll method
  - Disabled when section full

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_empty_state.dart`
  - Empty available list
  - Empty enrolled list
  - API error state

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_loading_view.dart`
  - Skeletons/shimmer blocks matching the student course visual style

- `[NEW] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\registration\registration_widgets_barrel.dart`
  - Optional barrel export for the above widgets

- `[NEW] D:\Graduation\EduVerse\edu_verse\test\widgets\student\registration\student_registration_screen_test.dart`
  - Cover:
    - initial loading state
    - empty state
    - successful card rendering
    - section sheet opening
    - disabled enroll button when `canEnroll == false`
    - route presence and joined-course button navigation

### UI behavior requirements from the web reference

Must match from `CourseRegistration.tsx`:

- Search by course title, code, department
- Filter by department and level
- Show available course catalog
- Show currently enrolled courses
- Open section-selection confirmation before enroll
- Refetch available + my courses after enroll
- Refetch available + my courses after drop

### Flutter-specific adaptation rules

- Keep the screen mobile-first, not a direct desktop column clone.
- Preserve the existing Flutter student course aesthetic:
  - same gradient family
  - same rounded radii
  - same colorful card treatment
- Do not replace the existing `/courses` screen.

## Phase 4: Wire the new screen into navigation

### Files

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\config\app_router.dart`
  - Import `StudentRegistrationScreen`
  - Add route:
    - recommended `'/registration'`
  - Wrap route builder with `BlocProvider` for `StudentRegistrationCubit`
  - Reuse the existing global `EnrollmentService` from context

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\dashboard\student_drawer.dart`
  - Add a new main-menu item:
    - title: `Registration`
    - icon: `Icons.app_registration_rounded` or `Icons.how_to_reg_outlined`
    - route: `'/registration'`
  - Place it after `Courses`

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\widgets\student\courses\join_course_button.dart`
  - Change default navigation target from `'/courses'` to `'/registration'`
  - Keep the external `onPressed` override behavior unchanged

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\test\widgets\student\courses\courses_screen_phase1_test.dart`
  - Update the join-button route expectation to the new registration route

### Post-mutation refresh hooks

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\screens\student\student_registration_screen.dart`
  - On successful enroll/drop, notify:
    - `CoursesBloc` via `StudentCoursesFetched()` or `CoursesRefreshed()`
    - `LabsCubit.loadEnrolledCourses()`
  - This keeps the course list and labs feature aligned with the new enrollment state

## Phase 5: Localization and generated files

### Files

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\l10n\app_en.arb`
- `[MODIFY] D:\Graduation\EduVerse\edu_verse\lib\l10n\app_ar.arb`
  - Add keys for:
    - `registration`
    - `courseRegistration`
    - `browseCourses`
    - `creditsEnrolled`
    - `coursesRegistered`
    - `onWaitlist`
    - `availableCourses`
    - `myRegisteredCourses`
    - `searchCoursePlaceholder`
    - `selectSection`
    - `confirmEnrollment`
    - `dropCourse`
    - `registrationWindow`
    - `registrationOpen`
    - `registrationClosed`
    - `registrationUpcoming`
    - `prerequisitesRequired`
    - `noAvailableCourses`
    - `noRegisteredCourses`
    - `enrollNow`
    - `droppingCourse`
    - `enrollingCourse`

- `[MODIFY GENERATED] D:\Graduation\EduVerse\edu_verse\lib\generated_l10n\app_localizations.dart`
- `[MODIFY GENERATED] D:\Graduation\EduVerse\edu_verse\lib\generated_l10n\app_localizations_en.dart`
- `[MODIFY GENERATED] D:\Graduation\EduVerse\edu_verse\lib\generated_l10n\app_localizations_ar.dart`

### Notes

- Reuse existing keys like `allDepartments`, `allLevels`, `joinCourse`, `cancel`, `confirm`, `drop`, where possible.
- The ARB files already contain repeated `allDepartments`; implementation should avoid creating additional duplicated keys.

## Phase 6: Tests and regression coverage

### Files

- `[MODIFY] D:\Graduation\EduVerse\edu_verse\test\services\api\enrollment_service_test.dart`
  - Add available-course parsing test
  - Add `getEnrollmentPeriods()` test
  - Add drop response shape tolerance test

- `[NEW] D:\Graduation\EduVerse\edu_verse\test\models\registration_available_course_model_test.dart`
  - Ensure exact backend/web shape parsing

- `[NEW] D:\Graduation\EduVerse\edu_verse\test\bloc\student_registration\student_registration_cubit_test.dart`

- `[NEW] D:\Graduation\EduVerse\edu_verse\test\widgets\student\registration\student_registration_screen_test.dart`

---

## 7. File Change Summary

| Category | New | Modified | Delete |
|---|---:|---:|---:|
| Models | 3 | 0 | 0 |
| Services | 0 | 1 | 0 |
| Utils | 1 | 0 | 0 |
| Bloc/Cubit | 2 | 0 | 0 |
| Screens | 1 | 1 | 0 |
| Widgets | 7 | 2 | 0 |
| Routing / navigation | 0 | 2 | 0 |
| Localization | 0 | 5 | 0 |
| Tests | 3 | 2 | 0 |
| Total | 17 | 13 | 0 |

No file deletions are recommended.

---

## 8. Verification Plan

## 8.1 Static verification

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

## 8.2 Runtime verification

Backend:

```powershell
cd D:\Graduation\backend\last_backend\EduVerse_Backend
npm run start:dev
```

Flutter:

```powershell
cd D:\Graduation\EduVerse\edu_verse
flutter run
```

## 8.3 Manual QA checklist

1. Open student dashboard drawer and confirm a new `Registration` item exists and opens the new screen.
2. Open `/courses` and tap `Join Course`; confirm navigation goes to the new registration screen, not the course list screen.
3. Confirm the new screen header shows a real registration period badge or a graceful fallback when none is available.
4. Confirm stats use real data:
   - enrolled credits from current enrollments
   - registered course count from backend statuses
   - waitlist count stays zero unless backend starts returning it
5. Confirm available course cards render real API data:
   - code
   - title
   - department
   - credits
   - level
   - seat counts
   - semester
   - section/location
6. Confirm search filters by title, code, and department.
7. Confirm department and level filters behave like the web page.
8. Tap a course with multiple sections and confirm section-selection bottom sheet opens.
9. Enroll in a valid section:
   - success message appears
   - available list refreshes
   - enrolled list refreshes
   - `/courses` screen shows the new course after refresh
   - labs list updates after refresh
10. Attempt to enroll in a course with unmet prerequisites or a schedule conflict and confirm the backend error message is surfaced cleanly.
11. Drop an enrolled course with `canDrop == true` and confirm the lists refresh correctly.
12. Attempt to drop a course after the deadline and confirm the backend deadline message is surfaced.
13. Confirm no mock data appears anywhere in the registration screen.

---

## 9. Final Recommendation

Proceed with a dedicated Flutter student registration feature, not a retrofit of the existing `/courses` screen.

Reason:

- the data contracts are different
- the UI responsibilities are different
- the existing course list screen is already API-driven and should remain focused on enrolled courses
- the new screen can cleanly mirror the web registration flow without destabilizing current student course details and labs behavior
