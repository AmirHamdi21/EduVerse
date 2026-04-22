# Data Model

## TeachingCourseModel
**Mapping**: Represents a streamlined enrollment object for instructors/teaching assistants, directly mapping to the `GET /api/enrollments/teaching` response payload.

**Fields**:
- `sectionId`: `int` (Required)
- `courseId`: `int` (Required)
- `course`: `CourseSummaryModel` (Required)
- `section`: `SectionSummaryModel` (Required)
- `semester`: `SemesterSummaryModel` (Required)

**Validation / State**:
- Instances of `TeachingCourseModel` are instantiated purely via JSON payload parsed automatically using `freezed`.
- No student-specific fields (e.g., `grade`, `status`, `dropDeadline`) exist.
- Used extensively in parsing state for BLoC (loading/loaded states) and populating UI components.
