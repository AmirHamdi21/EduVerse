# Data Model: Student Courses Phase 1

## Overview
Phase 1 focuses on shell-level redesign and backend-accurate filtering, not new domain creation. Existing enrollment/course entities remain authoritative, with additional UI query/state models introduced for clean BLoC-driven behavior.

## Entities

### 1. CourseEnrollmentModel (existing, contract-aligned)
Represents one enrollment row returned by `GET /api/enrollments/my-courses`.

Fields (in active use for Phase 1):
- `id: String`
- `userId: int`
- `sectionId: int`
- `enrollmentStatus: EnrollmentStatus`
- `grade: String?`
- `finalScore: double?`
- `enrollmentDate: DateTime`
- `canDrop: bool`
- `dropDeadline: DateTime?`
- `role: String`
- `course: CourseModel?`
- `section: SectionModel?`
- `semester: SemesterModel?`

Validation rules:
- `id` must be non-empty after parsing.
- `userId` and `sectionId` must parse to non-negative integers.
- `enrollmentStatus` must map to known enum values; unknown values map safely to fallback enum case.
- `semester` may be null; UI must tolerate missing semester metadata.

### 2. CoursesShellQuery (new logical model)
Represents user-selected controls that shape list rendering and server fetch.

Fields:
- `searchTerm: String`
- `selectedStatus: CoursesStatusFilter` (backend-supported options only)
- `selectedSort: CoursesSortOption`
- `selectedSemesterId: int?`

Validation rules:
- `searchTerm` is trimmed.
- `selectedSemesterId` is null or positive integer (`>= 1`).
- `selectedStatus` values must be from backend-supported set.

### 3. CoursesShellViewState (BLoC state projection)
Represents render-level states for `CoursesScreen` shell.

State variants:
- `initial`
- `loading(cachedEnrollments?)`
- `loaded(enrollments)`
- `authSessionRequired(message, statusCode)`
- `error(message)`

Validation rules:
- `authSessionRequired.statusCode` must be `401` or `403`.
- `loaded.enrollments` can be empty; empty UI message must render instead of error UI.

### 4. SemesterFilterOption (UI helper)
Derived option model for semester selector control.

Fields:
- `semesterId: int`
- `label: String`
- `isSelected: bool`

Validation rules:
- Distinct `semesterId` values only.
- `label` must be non-empty.

## Relationships
- One `CoursesShellQuery` drives one `StudentCoursesFetched` event payload.
- `StudentCoursesFetched(semester)` triggers one service call to `EnrollmentService.getMyEnrollments(semester)`.
- Service response maps to many `CourseEnrollmentModel` instances.
- `CourseEnrollmentModel.semester` contributes to visible `SemesterFilterOption` list (if provided by backend payload).
- `CoursesShellViewState` is derived from BLoC transitions and consumed by `CoursesScreen` widgets.

## Derived/Computed Fields
- `CoursesLoaded.courses` remains derived from `enrollments.map((e) => e.course)`.
- Status chips/counters are computed from currently loaded enrollments.
- Visible list is computed as: server-filtered list (semester) -> client status filter (if applicable) -> search term -> sort option.

## State Transitions
1. `CoursesInitial` -> `CoursesLoading(cachedData?)` on initial open or refresh.
2. `CoursesLoading` -> `CoursesLoaded` when fetch succeeds.
3. `CoursesLoading` -> `CoursesAuthSessionRequired` when status code is `401/403`.
4. `CoursesLoading` -> `CoursesError` on non-auth failures.
5. Semester change triggers `StudentCoursesFetched(semester: X)` and re-enters loading flow.

## Contract Notes for Parsing
- Primary endpoint payload is array-first contract for `my-courses`.
- Model parsing should prefer contract field names from DTOs.
- Temporary compatibility branches should be removed once endpoint parity is verified in tests.
