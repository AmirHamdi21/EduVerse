# Feature Specification: Phase 1 — Foundation (API Services & Domain Models)

**Feature Branch**: `015-phase-1-foundation`
**Created**: 2026-04-10
**Status**: Draft
**Input**: User description: "Phase 1: Foundation — API Services & Domain Models for Courses/Assignments/Labs integration"

## Clarifications

### Session 2026-04-10

- Q: What retry strategy should services use for transient errors? → A: Auto-retry with exponential backoff (up to 3 attempts) for 5xx and network timeouts.
- Q: How should service errors be logged and classified? → A: Structured error logging with error type classification (network, auth, server, parsing).
- Q: Which services use PaginatedResponse<T>? → A: Only AssignmentService.getAll(); all other list methods return List<T>.
- Q: Should upload methods be real HTTP calls or stubs? → A: Real multipart form-data HTTP requests.
- Q: Which enrollment endpoints are in scope? → A: All endpoints including section students, assign/remove instructor, assign/remove TA.
- Q: How to handle DriveFileModel field name mismatches from backend? → A: Map webContentLink→downloadUrl, compute iframeUrl from driveId.

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Course & Enrollment Data Access (Priority: P1)

Any authenticated user (Student, Instructor, TA, Admin) opens the app and sees their courses populated from the live backend — not mock data. Students see enrolled courses with real enrollment status, grades, and section info. Instructors see teaching courses with real section counts. TAs see assigned courses. Admins see all department courses. The course catalog lets students browse available courses and check enrollment eligibility.

**Why this priority**: Every subsequent phase (student dashboards, instructor management, TA grading, admin course creation) depends on courses loading from the backend. Without this foundation, no other feature can display real data.

**Independent Test**: Can be fully tested by calling `EnrollmentService.getMyCourses()`, `EnrollmentService.getAvailableCourses()`, `SectionService.getByCourse()`, and `ScheduleService.getBySection()` with a valid JWT token, and verifying the returned Dart models correctly deserialize all nested fields (course, section, semester, instructor, schedules, prerequisites) from sample backend JSON responses — including edge cases like null fields, zero counts, and empty arrays.

**Acceptance Scenarios**:

1. **Given** a student has a valid JWT token, **When** the app calls `EnrollmentService.getMyCourses()`, **Then** the response parses into a list of `EnrollmentModel` objects with nested `course`, `section`, `semester`, `instructor`, and `prerequisites` objects, and `canDrop`/`dropDeadline` flags correctly mapped.
2. **Given** an instructor has a valid JWT token, **When** the app calls `EnrollmentService.getTeachingCourses()`, **Then** the response parses into teaching course objects with section counts and student enrollment data.
3. **Given** a student browses available courses, **When** the app calls `EnrollmentService.getAvailableCourses()`, **Then** the response parses into `CourseEnrollmentModel` objects with `canEnroll`, `prerequisitesMet`, `seatsAvailable`, and `hasScheduleConflict` flags.
4. **Given** a course ID is known, **When** the app calls `SectionService.getByCourse(courseId)`, **Then** the response parses into `SectionModel` objects with nested `course`, `semester`, and `schedules` relations.
5. **Given** a section ID is known, **When** the app calls `ScheduleService.getBySection(sectionId)`, **Then** the response parses into `ScheduleModel` objects with correct `DayOfWeek` enum, time strings (`HH:mm`), and `ScheduleType` enum values.

---

### User Story 2 — Assignment Lifecycle Data Access (Priority: P2)

A student views their pending assignments, submits work (text, link, or file), and sees their grade. An instructor creates an assignment with full field support (markdown instructions, due dates, submission type, late penalty, allowed file types), views submissions, and grades them. A TA views assignment submissions and grades them. All assignment data — including instruction files stored on Google Drive — flows through the service layer.

**Why this priority**: Assignment submission is the core academic workflow. The assignment service layer with correct model parsing (especially edge cases like `isLate` as int vs bool, `allowedFileTypes` as JSON string) is a prerequisite for Phases 3, 6, and 8.

**Independent Test**: Can be fully tested by calling `AssignmentService.getAll()`, `AssignmentService.getById()`, `AssignmentService.create()`, `AssignmentService.update()`, `AssignmentService.delete()`, `AssignmentService.updateStatus()`, `AssignmentService.getSubmissions()`, `AssignmentService.submit()`, `AssignmentService.gradeSubmission()`, `AssignmentService.uploadInstructionFile()`, and `AssignmentService.getMySubmission()` with mocked Dio responses, verifying all models correctly parse the backend JSON shapes — including the `isLate` field arriving as `0`/`1` (number) and `allowedFileTypes` arriving as a JSON-encoded string.

**Acceptance Scenarios**:

1. **Given** a course ID, **When** the app calls `AssignmentService.getAll(courseId: courseId)`, **Then** the response parses into a `PaginatedResponse<AssignmentModel>` with correct `data` array and `meta` pagination object, and each `AssignmentModel` has all fields mapped including `instructionFiles` as `DriveFileModel` array.
2. **Given** an assignment exists, **When** the app calls `AssignmentService.getById(assignmentId)`, **Then** the returned `AssignmentModel` includes the nested `course` relation and `instructionFiles` array with correct `DriveFileModel` fields (`driveId`, `fileName`, `webViewLink`, `iframeUrl`, `downloadUrl`).
3. **Given** a student submits an assignment, **When** the app calls `AssignmentService.getMySubmission(assignmentId)`, **Then** the returned `AssignmentSubmissionModel` correctly parses `isLate` as an integer (`0`/`1`), maps `submissionStatus` enum, and includes nested `user` object with `firstName`, `lastName`, `email`.
4. **Given** an instructor views submissions, **When** the app calls `AssignmentService.getSubmissions(assignmentId)`, **Then** the response parses into a list of `AssignmentSubmissionModel` with `score` as nullable double, `feedback` as nullable string, and `driveFile` as nullable `DriveFileModel`.
5. **Given** an assignment has `allowedFileTypes` set, **When** the model parses the response, **Then** `allowedFileTypes` is decoded from a JSON string (e.g., `"[\"pdf\",\"zip\"]"`) into a `List<String>`.

---

### User Story 3 — Lab Lifecycle Data Access (Priority: P3)

A student views their labs, reads lab instructions (with markdown rendering and attached Google Drive files), submits lab work, and sees their grade. An instructor creates a lab, manages instructions (add/edit/delete), uploads instruction files, views submissions, grades them, and marks attendance. A TA views lab submissions, grades them, and marks attendance. All lab data flows through the `LabService`.

**Why this priority**: Labs are parallel to assignments but have additional complexity (instruction management, attendance tracking, TA material uploads). The lab service layer is prerequisite for Phases 4, 7, and 8.

**Independent Test**: Can be fully tested by calling `LabService.getAll()`, `LabService.getById()`, `LabService.create()`, `LabService.update()`, `LabService.delete()`, `LabService.updateStatus()`, `LabService.getInstructions()`, `LabService.addInstruction()`, `LabService.uploadInstructionFile()`, `LabService.getSubmissions()`, `LabService.submit()`, `LabService.gradeSubmission()`, `LabService.getAttendance()`, `LabService.markAttendance()`, `LabService.getMySubmission()`, and `LabService.uploadTaMaterial()` with mocked Dio responses, verifying all models correctly parse backend JSON — especially `isLate` arriving as `boolean` (true/false) unlike assignments where it arrives as `int` (0/1).

**Acceptance Scenarios**:

1. **Given** a course ID, **When** the app calls `LabService.getAll(courseId: courseId)`, **Then** the response parses into a list of `LabModel` objects with `instructionFiles` as `DriveFileModel` array and `course` relation included.
2. **Given** a lab ID, **When** the app calls `LabService.getInstructions(labId)`, **Then** the response parses into a list of `LabInstructionModel` objects with `instructionText` (markdown content), `file` as optional `DriveFileModel`, and `orderIndex` for sorting.
3. **Given** a student submits lab work, **When** the app calls `LabService.getMySubmission(labId)`, **Then** the returned `LabSubmissionModel` correctly parses `isLate` as a `boolean` (true/false), maps `status` enum, and includes nested `user` object.
4. **Given** an instructor marks attendance, **When** the app calls `LabService.markAttendance(labId, data)`, **Then** the response parses into `LabAttendanceModel` with `attendanceStatus` enum (`present`, `absent`, `excused`, `late`), `checkInTime`, `notes`, and `markedBy` user ID.
5. **Given** a lab has TA materials uploaded, **When** the app calls `LabService.uploadTaMaterial(labId, file)`, **Then** the upload succeeds with FormData field name `file` and returns the material metadata.

---

### Edge Cases

- **`isLate` type divergence**: Assignment submissions return `isLate` as `0`/`1` (integer), while lab submissions return `isLate` as `true`/`false` (boolean). Models MUST handle both formats gracefully.
- **`allowedFileTypes` JSON string**: The backend returns `allowedFileTypes` as a JSON-encoded string (e.g., `"[\"pdf\",\"zip\"]"`) not a native array. Models MUST `jsonDecode()` before treating as list.
- **Decimal fields as strings**: `maxScore`, `weight`, `latePenaltyPercent`, `score` may arrive as strings from some database drivers. Models MUST use `double.tryParse(value.toString())`.
- **Empty pagination**: When no results match, `data` is an empty array and `meta.total` is `0`. Models MUST not crash on empty arrays.
- **Null optional fields**: `description`, `instructions`, `dueDate`, `availableFrom`, `syllabusUrl`, `feedback`, `score`, `gradedBy`, `gradedAt` can all be `null`. Models MUST use nullable types.
- **Token expiration**: If JWT is expired, `CoreApiClient` MUST return a clear `401 Unauthorized` error state, not throw an unhandled exception.
- **Network failure**: If the device is offline, service calls MUST return a network error state that the UI can display, not crash.
- **Transient server errors**: For 5xx responses and network timeouts, services MUST auto-retry with exponential backoff (up to 3 attempts). After 3 failed attempts, the error MUST be surfaced to the caller (BLoC) as a permanent failure.
- **Role-based access denial**: If a student calls an instructor-only endpoint (e.g., `POST /assignments`), the backend returns `403 Forbidden`. The service MUST surface this as a permission error, not a parsing error.
- **Large paginated datasets**: When `meta.totalPages` is large, the `PaginatedResponse` helper MUST correctly compute `hasNextPage` and `hasPreviousPage` without overflow.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an `EnrollmentService` that calls student enrollment endpoints (`GET /enrollments/my-courses`, `GET /enrollments/available`, `POST /enrollments/register`, `DELETE /enrollments/:id`, `GET /enrollments/teaching`) and section enrollment management endpoints (`GET /enrollments/sections/:id/students`, `GET /enrollments/sections/:id/instructors`, `GET /enrollments/sections/:id/tas`, `POST /enrollments/sections/:id/instructors`, `DELETE /enrollments/sections/:id/instructors/:enrollmentId`, `POST /enrollments/sections/:id/tas`, `DELETE /enrollments/sections/:id/tas/:enrollmentId`) with correct JWT auth headers and query parameter support.
- **FR-002**: System MUST provide an `AssignmentService` that calls all assignment endpoints: list, get by ID, create, update, delete, update status, get submissions, submit (JSON body: text/link), submitFile (multipart FormData), get my submission, grade submission, uploadInstructionFile (multipart FormData).
- **FR-003**: System MUST provide a `LabService` that calls all lab endpoints: list, get by ID, create, update, delete, update status, get instructions, add instruction, uploadInstructionFile (multipart FormData), get submissions, submit (JSON body), submitFile (multipart FormData), get my submission, grade submission, get attendance, mark attendance, uploadTaMaterial (multipart FormData).
- **FR-004**: System MUST provide a `SectionService` that calls `GET /sections/course/:courseId`, `GET /sections/:id`, `POST /sections`, `PATCH /sections/:id`, and `PATCH /sections/:id/enrollment`.
- **FR-005**: System MUST provide a `ScheduleService` that calls `GET /schedules/section/:sectionId`, `GET /schedules/:id`, `POST /schedules/section/:sectionId`, and `DELETE /schedules/:id`.
- **FR-006**: System MUST provide a `SemesterService` that calls `GET /enrollments/periods` (backend endpoint name; returns semester/period data with registration dates). Response parses into `SemesterModel` with fields: `id`, `name` (from `semesterName`), `startDate` (from `semesterStart`), `endDate` (from `semesterEnd`), `registrationStart`, `registrationEnd`, `status`.
- **FR-007**: All service responses MUST be deserialized into strongly-typed Dart domain models that exactly match the backend API response shapes documented in `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md`.
- **FR-008**: System MUST provide a `PaginatedResponse<T>` generic wrapper that parses the `{data: [...], meta: {total, page, limit, totalPages}}` response shape and computes `hasNextPage` / `hasPreviousPage` boolean properties. Only `AssignmentService.getAll()` returns `PaginatedResponse<T>`; all other list methods across all services return `List<T>`.
- **FR-009**: All models MUST use factory constructors with safe JSON parsing — nullable fields MUST be nullable Dart types, and missing keys MUST default to `null` rather than throwing.
- **FR-010**: System MUST provide 13 enums: 11 new enums across 5 files (`CourseLevel`, `CourseStatus`, `SectionStatus` in course_enums.dart; `ScheduleType`, `DayOfWeek` in schedule_enums.dart; `AssignmentStatus`, `SubmissionType`, `SubmissionStatus` in assignment_enums.dart; `LabStatus`, `LabAttendanceStatus` in lab_enums.dart; `EnrollmentStatus`, `DropReason` in enrollment_enums.dart) plus 2 existing enums (`MaterialType`, `InstructorRole`) already present in the codebase. All enums MUST have `fromString()` and `toJson()` utilities with `.unknown` fallback for new enums.
- **FR-011**: System MUST correctly parse `isLate` in assignment submissions as an integer (`0` = false, `1` = true) and in lab submissions as a boolean (`false`/`true`).
- **FR-012**: System MUST correctly parse `allowedFileTypes` from a JSON-encoded string into a `List<String>`.
- **FR-013**: System MUST correctly parse decimal fields (`maxScore`, `weight`, `latePenaltyPercent`, `score`) using `double.tryParse(value.toString())` to handle both numeric and string inputs.
- **FR-014**: System MUST provide a `DriveFileModel` that parses Google Drive file metadata (`driveId`, `fileName`, `webViewLink`, `iframeUrl`, `downloadUrl`) from backend responses.
- **FR-015**: All services MUST use the app's existing authenticated HTTP client for communication, inheriting automatic JWT token attachment and token refresh behavior.
- **FR-016**: All services MUST automatically retry failed requests with exponential backoff (up to 3 attempts) for transient errors (HTTP 5xx responses, network timeouts). Non-transient errors (401, 403, 404, 409) MUST NOT be retried. After exhausting retries, the service MUST return a typed error state to the caller.
- **FR-017**: All services MUST return structured error objects that classify the failure type: `network` (connectivity loss, timeout), `auth` (401, 403), `server` (5xx after retries exhausted), or `parsing` (JSON deserialization failure). Error objects MUST include the HTTP status code (if applicable), a human-readable message, and the error type.
- **FR-018**: All new services MUST be registered in the app's service registry and be injectable for testing.
- **FR-019**: System MUST provide a `LabInstructionModel` for lab instructions with `instructionText` (markdown), optional `file` relation, and `orderIndex` for ordering.
- **FR-020**: System MUST provide a `LabAttendanceModel` with `attendanceStatus` enum, `checkInTime`, `notes`, and `markedBy` fields.

### Key Entities

- **Course**: Academic course with code, name, department, credits, level, status, assigned instructor, TA list, and syllabus. Related to Sections, Prerequisites, and Materials.
- **Enrollment**: A student's registration in a course section. Contains status, grade, final score, enrollment/drop/completion dates, and references to the course, section, semester, instructor, and prerequisites.
- **Section**: A specific offering of a course within a semester. Contains capacity, current enrollment, location, status, and references to the course, semester, and associated schedules.
- **Schedule**: A recurring session time for a section. Contains day of week, start/end times, room, building, and schedule type (lecture/lab/tutorial/exam). Belongs to a Section.
- **Assignment**: A graded task for a course. Contains title, description, instructions (markdown), due date, max score, weight, submission type, file constraints, late penalty, status, and Google Drive instruction files. Belongs to a Course.
- **AssignmentSubmission**: A student's work for an assignment. Contains submission text, link, or file references, submission status, score, feedback, late flag, attempt number, and graded-by metadata.
- **Lab**: A hands-on session for a course. Similar to Assignment but with separate instruction management (multiple instruction entries), attendance tracking, and TA material uploads. Belongs to a Course.
- **LabSubmission**: A student's work for a lab. Same structure as AssignmentSubmission but with `isLate` as boolean instead of integer.
- **LabInstruction**: An individual instruction entry within a lab. Contains markdown text, optional attached Drive file, and order index.
- **LabAttendance**: An attendance record for a student in a lab. Contains attendance status, check-in time, notes, and who marked it.
- **DriveFile**: Metadata for a file stored on Google Drive. Contains `driveFileId` (internal record ID, from backend `driveFileId`), `driveId` (Google Drive file ID), `fileName`, `webViewLink`, `downloadUrl` (mapped from backend `webContentLink`), and `iframeUrl` (computed from `driveId` as `https://drive.google.com/file/d/{driveId}/preview`). Referenced by assignments, labs, and materials.
- **PaginatedResponse**: A generic wrapper for paginated API responses. Contains a typed `data` array and `meta` object with `total`, `page`, `limit`, `totalPages`, plus computed `hasNextPage`/`hasPreviousPage`.
- **Semester**: An academic term/period. Contains name (from `semesterName`), start date (from `semesterStart`), end date (from `semesterEnd`), registration start/end dates, and status. Model already exists at `lib/models/core/semester_model.dart` — fields to be added. Referenced by Sections and Enrollments.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 6 services (`EnrollmentService`, `AssignmentService`, `LabService`, `SectionService`, `ScheduleService`, `SemesterService`) compile without errors and are registered in the app's dependency injection system.
- **SC-002**: All 14 domain models correctly deserialize 100% of fields from sample backend JSON responses, with zero unhandled `dynamic` types in model properties.
- **SC-003**: All 13 enums correctly parse from backend string values and serialize back to the exact string the backend expects, with no silent fallbacks.
- **SC-004**: `PaginatedResponse<T>` correctly computes `hasNextPage` and `hasPreviousPage` for edge cases: page 1 of 1, last page, empty results (total = 0), and single-page results.
- **SC-005**: `isLate` field correctly parses as `bool` from both integer (`0`/`1`) and boolean (`false`/`true`) inputs without throwing or producing incorrect values.
- **SC-006**: `allowedFileTypes` field correctly parses from JSON-encoded string into `List<String>` for all valid inputs: empty string, `[]`, `["pdf"]`, `["pdf","docx","zip"]`.
- **SC-007**: All service methods return typed error states (not throw unhandled exceptions) for HTTP 401, 403, 404, 409, and 500 responses.
- **SC-008**: Zero static/mock data exists in any of the 6 new/updated service files (`EnrollmentService`, `AssignmentService`, `LabService`, `SectionService`, `ScheduleService`, `SemesterService`) — all data is fetched from the backend API. Note: BLoC cubit demo data (`_generateDemoAssignments`, `_generateDemoLabs`, etc.) is NOT in scope for Phase 1 — those files are not modified in this phase and will be addressed when BLoCs are built in later phases.
- **SC-009**: Transient failures (HTTP 5xx, network timeouts) trigger automatic retry with exponential backoff (up to 3 attempts); after 3 failed attempts, a typed `server` error is returned to the caller with the original HTTP status code.
- **SC-010**: Structured error objects correctly classify all failure types (`network`, `auth`, `server`, `parsing`) and include HTTP status code (when applicable), human-readable message, and error type enum value.

## Assumptions

- The app's existing authenticated HTTP client with JWT token management is functional and available for injection into new services, and supports configurable retry policy for transient failures.
- The app's existing token storage service provides valid JWT tokens for authenticated requests.
- The backend API is running and reachable at the configured base URL during development and testing.
- All backend endpoints return the response shapes documented in `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` — no undocumented field changes.
- The Flutter app's service registry is already configured and accepting new service registrations.
- File upload service methods (`submitFile`, `uploadInstructionFile`, `uploadTaMaterial`) MUST perform real multipart form-data HTTP requests — they are not stubs or placeholders.
- No UI changes are expected from this phase — it is purely service/model layer work.
- The app's existing `CourseService` and `MaterialService` files exist and may be referenced but are NOT modified in this phase.
- WebSocket/chat functionality is out of scope for this phase (covered by separate chat integration work).
- Students can only enroll in courses where `canEnroll: true` (prerequisites met, no schedule conflicts). Retake and waitlist logic follows backend behavior.
