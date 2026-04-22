# API Contracts: Student Courses Shell (Phase 1)

## Scope
This contract covers endpoints audited for the Phase 1 Courses shell redesign.

Primary behavior change in Phase 1:
- Semester-filtered retrieval through `GET /api/enrollments/my-courses?semester=<id>`.

Secondary audited endpoints (no behavior change in Phase 1):
- `GET /api/enrollments/available`
- `POST /api/enrollments/register`

Audit sources:
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\controllers\enrollments.controller.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\services\enrollments.service.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enrollment-response.dto.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\available-courses.dto.ts`
- `C:\Users\Friends\Desktop\Graduation\Backend\EduVerse_Backend\src\modules\enrollments\dto\enroll-course.dto.ts`

## 1) GET /api/enrollments/my-courses

### Request
- Method: `GET`
- Path: `/api/enrollments/my-courses`
- Auth: Bearer token required
- Query parameters:
  - `semester` (optional, integer, positive)

### Response
- Status `200`: array of enrollment objects
- DTO + mapper shape (`EnrollmentResponseDto` + `buildEnrollmentResponse`):

```json
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
    "id": 3,
    "name": "Fall 2026",
    "startDate": "2026-08-15T00:00:00.000Z",
    "endDate": "2026-12-20T00:00:00.000Z"
  },
  "instructor": null,
  "prerequisites": [
    {
      "id": 1,
      "courseId": 12,
      "prerequisiteCourseId": 8,
      "courseCode": "MATH101",
      "courseName": "Calculus I",
      "isMandatory": true,
      "studentCompleted": true,
      "studentGrade": "B+"
    }
  ]
}
```

Behavioral notes from service implementation:
- `getMyEnrollments()` returns statuses restricted to `ENROLLED` and `COMPLETED` only.
- Optional `semester` query is applied by section-semester filtering in service logic.
- `instructor` is currently built as `undefined` in mapper because instructor lookup is intentionally disabled (`const instructor: any = null`). Frontend must treat it as optional.
- `prerequisites` array is always mapper-computed and can be empty.

### Error responses
- `401`: unauthenticated/expired session
- `403`: authenticated but forbidden for role or policy
- `5xx`: server-side failure

### Flutter mapping notes
- Request path should be emitted by `EnrollmentService` as `/enrollments/my-courses` (base path handled by API client).
- `CoursesBloc` must map `401/403` to dedicated auth/session state.
- UI must show a dedicated recovery state for auth/session issues.

## 2) GET /api/enrollments/available (audited for Join Course context)

### Request
- Method: `GET`
- Path: `/api/enrollments/available`
- Auth: Bearer token required
- Query parameters (audited):
  - `departmentId` (optional, integer >= 1)
  - `semesterId` (optional, integer >= 1)
  - `search` (optional, string)
  - `level` (optional, string)
  - `page` (optional, integer >= 1, default `1`)
  - `limit` (optional, integer >= 1, default `20`)

### Response
- Status `200`: list of `AvailableCoursesDto` objects
- `AvailableCoursesDto` includes:
  - course metadata: `id`, `name`, `code`, `description`, `credits`, `level`, `departmentId`, `departmentName`
  - nested `sections[]`: `id`, `sectionNumber`, `maxCapacity`, `currentEnrollment`, `availableSeats`, `location`, `semesterId`, `semesterName`
  - nested `prerequisites[]`: `id`, `courseId`, `prerequisiteCourseId`, `courseCode`, `courseName`, `isMandatory`
  - enrollment flags: `canEnroll`, `enrollmentStatus` (optional)

### Phase 1 usage
- No logic changes planned in this phase; endpoint is audited to ensure Join Course shell context remains contract-aware.

## 3) POST /api/enrollments/register (audited for Join Course context)

### Request
- Method: `POST`
- Path: `/api/enrollments/register`
- Auth: Bearer token required
- Body (`EnrollCourseDto`):

```json
{
  "sectionId": 5
}
```

Validation notes:
- `sectionId` is required, numeric, and `>= 1`.

### Response
- Status `201`/`200`: `EnrollmentResponseDto` payload (same shape family used by `/my-courses` mapper)
- Failure patterns include validation and conflict errors depending on enrollment rules

### Phase 1 usage
- No logic change in Phase 1; existing Join Course behavior is preserved.

## Contract Alignment Checklist
- [x] Endpoint paths and HTTP verbs confirmed.
- [x] Optional semester query for `my-courses` confirmed.
- [x] Auth failure codes (`401/403`) incorporated into frontend state plan.
- [x] Related Join Course endpoints audited for shell-adjacent consistency.
- [x] Service/model parsing plan references DTO field names, not UI assumptions.

## Mapper-to-Model Evidence (Consumed Phase 1 Fields)

| Backend field path | Mapper source | Flutter target |
|---|---|---|
| `id` | `buildEnrollmentResponse.id` | `CourseEnrollmentModel.id` |
| `userId` | `buildEnrollmentResponse.userId` | `CourseEnrollmentModel.userId` |
| `sectionId` | `buildEnrollmentResponse.sectionId` | `CourseEnrollmentModel.sectionId` |
| `status` | `buildEnrollmentResponse.status` | `CourseEnrollmentModel.enrollmentStatus` |
| `enrollmentDate` | `buildEnrollmentResponse.enrollmentDate` | `CourseEnrollmentModel.enrollmentDate` |
| `canDrop` | `buildEnrollmentResponse.canDrop` | `CourseEnrollmentModel.canDrop` |
| `dropDeadline` | `buildEnrollmentResponse.dropDeadline` | `CourseEnrollmentModel.dropDeadline` |
| `course.id` | `buildEnrollmentResponse.course.id` | `CourseEnrollmentModel.course.id` |
| `course.code` | `buildEnrollmentResponse.course.code` | `CourseEnrollmentModel.course.code` |
| `course.name` | `buildEnrollmentResponse.course.name` | `CourseEnrollmentModel.course.name` |
| `course.credits` | `buildEnrollmentResponse.course.credits` | `CourseEnrollmentModel.course.credits` |
| `section.sectionNumber` | `buildEnrollmentResponse.section.sectionNumber` | `CourseEnrollmentModel.section.sectionNumber` |
| `semester.id` | `buildEnrollmentResponse.semester.id` | `CourseEnrollmentModel.semester.id` |
| `semester.name` | `buildEnrollmentResponse.semester.name` | `CourseEnrollmentModel.semester.name` |
| `instructor.firstName/lastName/email` | `buildEnrollmentResponse.instructor` (optional) | `CourseEnrollmentModel.instructor` |
| `prerequisites[]` fields | `buildEnrollmentResponse.prerequisites` | `CourseEnrollmentModel.prerequisites` |
