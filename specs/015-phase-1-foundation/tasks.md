# Tasks: Phase 1 — Foundation (API Services & Domain Models)

**Input**: Design documents from `specs/015-phase-1-foundation/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/services.md

**Tests**: NOT included in this phase. Phase 1 is purely service/model layer work. Tests will be added in later phases when BLoCs and UI are built.

**Organization**: Tasks are grouped by user story (from spec.md) so each story can be implemented, tested, and delivered independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to ([US1], [US2], [US3])
- Include exact file paths in descriptions

## Path Conventions

- Models: `lib/models/core/`, `lib/models/assignments/`, `lib/models/labs/`
- Services: `lib/services/api/`
- Shared: `lib/common/`
- Enums: `lib/models/core/enums/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create shared error types and update the HTTP client for retry support

- [x] T001 [P] Create `ServiceResult<T>` class in `lib/common/service_error.dart` with fields: `isSuccess` (bool), `data` (T?, present when isSuccess), `error` (ServiceError?, present when !isSuccess). Also create `ServiceError` class with fields: `type` (enum ServiceErrorType: network, auth, server, parsing), `statusCode` (int?), `message` (String), `originalError` (dynamic?). Add factory constructors `ServiceResult.success(T data)` and `ServiceResult.failure(ServiceError error)`. Follow the contract in `contracts/services.md`.
- [x] T002 Add retry helper utility in `lib/common/retry_helper.dart` implementing: (a) exponential backoff (1s → 2s → 4s, max 3 attempts) for transient errors (5xx, `DioExceptionType.connectionTimeout`, `DioExceptionType.receiveTimeout`, `SocketException`), returning `ServiceError` on exhaustion; (b) error classification mapper that maps HTTP status codes to `ServiceErrorType`: 401→auth, 403→auth, 404→server, 409→server, 500-599→server (after retries exhausted), timeout→network, no internet→network, JSON parse failure→parsing. Non-transient errors (401, 403, 404, 409) must NOT be retried.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Shared Models & Enums

- [x] T003 [P] Create enum file `lib/models/core/enums/course_enums.dart` with `CourseLevel` (FRESHMAN, SOPHOMORE, JUNIOR, SENIOR, GRADUATE, unknown), `CourseStatus` (ACTIVE, INACTIVE, ARCHIVED, unknown), `SectionStatus` (OPEN, CLOSED, FULL, CANCELLED, unknown). Each enum gets `fromString(String)` factory, `toJson()` method, and `.unknown` fallback.
- [x] T004 [P] Create enum file `lib/models/core/enums/schedule_enums.dart` with `ScheduleType` (LECTURE, LAB, TUTORIAL, EXAM, unknown) and `DayOfWeek` (MONDAY–SUNDAY, unknown). Same `fromString`/`toJson` pattern.
- [x] T005 [P] Create enum file `lib/models/core/enums/assignment_enums.dart` with `AssignmentStatus` (draft, published, closed, archived, unknown), `SubmissionType` (file, text, link, multiple, unknown), `SubmissionStatus` (submitted, graded, returned, resubmit, unknown).
- [x] T006 [P] Create enum file `lib/models/core/enums/lab_enums.dart` with `LabStatus` (draft, published, closed, archived, unknown) and `LabAttendanceStatus` (present, absent, excused, late, unknown).
- [x] T007 [P] Create enum file `lib/models/core/enums/enrollment_enums.dart` with `EnrollmentStatus` (enrolled, waitlisted, dropped, completed, failed, unknown) and `DropReason` (personal, academic, schedule_conflict, other, unknown).
- [x] T008 [P] Create `DriveFileModel` in `lib/models/core/drive_file_model.dart` with fields: `driveFileId` (int), `driveId` (String), `fileName` (String), `webViewLink` (String), `downloadUrl` (String, mapped from backend `webContentLink`), `iframeUrl` (String, computed as `https://drive.google.com/file/d/{driveId}/preview`). Use `Equatable`. `fromJson` must handle all field types safely.
- [x] T009 [P] Create `PaginatedResponse<T>` generic wrapper in `lib/models/core/paginated_response.dart` with fields: `data` (List<T>), `total` (int), `page` (int), `limit` (int), `totalPages` (int), `hasNextPage` (bool, computed), `hasPreviousPage` (bool, computed). Factory constructor parses `{data: [...], meta: {total, page, limit, totalPages}}`.
- [x] T010 [P] Create helper class `CourseInfo` (nested model: id, name, code) and `UserInfo` (nested model: userId, firstName, lastName, email) in `lib/models/core/shared_models.dart`. These are used across multiple entities.
- [x] T011 Update `CoreApiClient` in `lib/services/api/core_api_client.dart` to expose a `test` constructor that accepts a pre-built Dio instance (verify it already exists — it does per current code). Add no-op if already present.

**Checkpoint**: Foundation ready — all enums, shared models, error types, and retry helper complete. User story implementation can now begin.

---

## Phase 3: User Story 1 — Course & Enrollment Data Access (Priority: P1) 🎯 MVP

**Goal**: Enable all authenticated users (Student, Instructor, TA, Admin) to see real course data from the backend — enrollments, available courses, sections, schedules, and semesters.

**Independent Test**: Call `EnrollmentService.getMyCourses()`, `EnrollmentService.getAvailableCourses()`, `SectionService.getByCourse()`, and `ScheduleService.getBySection()` with a valid JWT token. Verify all returned Dart models correctly deserialize nested fields (course, section, semester, instructor, schedules, prerequisites) from sample backend JSON — including null fields, zero counts, and empty arrays.

### Implementation for User Story 1

#### Models

- [x] T012 [P] [US1] Update `CourseModel` in `lib/models/core/course_model.dart` to match backend `GET /api/courses/:id` response shape: fields `id` (int), `departmentId` (int), `code` (String), `name` (String), `description` (String?), `credits` (int), `level` (CourseLevel enum), `syllabusUrl` (String?), `instructorId` (int?), `taIds` (List<int>?), `status` (CourseStatus enum), `createdAt`, `updatedAt`, `department` (DepartmentInfo nested object), `prerequisites` (List<CoursePrerequisite>?), `sections` (List<SectionModel>?). Preserve backward-compatible `courseId` getter if widgets depend on it.
- [x] T013 [P] [US1] Update `SemesterModel` in `lib/models/core/semester_model.dart` (existing model — ADD fields): `registrationStart` (DateTime?), `registrationEnd` (DateTime?), `status` (String). Update `fromJson` to map backend keys: `semesterName`→`name`, `semesterStart`→`startDate`, `semesterEnd`→`endDate`. Safe date parsing with `DateTime.tryParse()`.
- [x] T014 [P] [US1] Update `SectionModel` in `lib/models/core/section_model.dart` with fields: `id` (int), `courseId` (int), `semesterId` (int), `sectionNumber` (String), `maxCapacity` (int), `currentEnrollment` (int), `location` (String?), `status` (SectionStatus enum), `createdAt`, `updatedAt`, `course` (CourseInfo?), `semester` (SemesterModel?), `schedules` (List<ScheduleModel>?).
- [x] T015 [P] [US1] Create `ScheduleModel` in `lib/models/core/schedule_model.dart` with fields: `id` (int), `sectionId` (int), `dayOfWeek` (DayOfWeek enum), `startTime` (String, HH:mm), `endTime` (String, HH:mm), `room` (String?), `building` (String?), `scheduleType` (ScheduleType enum), `createdAt`.
- [x] T016 [US1] Update `CourseEnrollmentModel` in `lib/models/core/enrollment_model.dart` — verify existing fields match backend shape. Ensure `status` uses `EnrollmentStatus` enum. Verify `course`, `section`, `semester` nested parsing works with updated models from T012–T015. Preserve backward-compatible `courseId` getter.

#### Services

- [x] T017 [P] [US1] Create `SemesterService` in `lib/services/api/semester_service.dart` with method `getAll()` → `GET /api/enrollments/periods`. Returns `Future<ServiceResult<List<SemesterModel>>>`. Uses `CoreApiClient`. Wraps call in try/catch, maps errors to `ServiceResult.failure(ServiceError)`.
- [x] T018 [P] [US1] Create `ScheduleService` in `lib/services/api/schedule_service.dart` with methods: `getBySection(sectionId)` → `GET /api/schedules/section/:sectionId`, `getById(id)` → `GET /api/schedules/:id`, `create(sectionId, data)` → `POST /api/schedules/section/:sectionId`, `delete(id)` → `DELETE /api/schedules/:id`. All return `ServiceResult<T>`. Parse responses into `ScheduleModel` / `List<ScheduleModel>`.
- [x] T019 [P] [US1] Create `SectionService` in `lib/services/api/section_service.dart` with methods: `getByCourse(courseId, {semesterId})` → `GET /api/sections/course/:courseId`, `getById(id)` → `GET /api/sections/:id`, `create(data)` → `POST /api/sections`, `update(id, data)` → `PATCH /api/sections/:id`, `updateEnrollment(id, count)` → `PATCH /api/sections/:id/enrollment`. All return `ServiceResult<T>`. Parse into `SectionModel` / `List<SectionModel>`.
- [x] T020 [US1] Update `EnrollmentService` in `lib/services/api/enrollment_service.dart` — keep existing methods (`getMyCourses`, `getAvailableCourses`, `getTeachingCourses`, `getSectionStudents`, `getSectionTAs`) and add new methods: `getSectionInstructors(sectionId)` → `GET /api/enrollments/sections/:id/instructors`, `assignInstructor(sectionId, userId)` → `POST /api/enrollments/sections/:id/instructors`, `removeInstructor(sectionId, enrollmentId)` → `DELETE /api/enrollments/sections/:id/instructors/:enrollmentId`, `assignTA(sectionId, userId)` → `POST /api/enrollments/sections/:id/tas`, `removeTA(sectionId, enrollmentId)` → `DELETE /api/enrollments/sections/:id/tas/:enrollmentId`, `register(sectionId, data)` → `POST /api/enrollments/register`, `dropEnrollment(id)` → `DELETE /api/enrollments/:id`. **ALL methods** (existing + new) must return `ServiceResult<T>` and apply retry helper from T002 for transient errors.

**Checkpoint**: At this point, User Story 1 should be fully functional — courses, enrollments, sections, schedules, and semesters all load from the backend with correct model parsing.

---

## Phase 4: User Story 2 — Assignment Lifecycle Data Access (Priority: P2)

**Goal**: Enable full assignment CRUD, submission, grading, and file upload workflows. The assignment service layer handles the core academic workflow for all roles.

**Independent Test**: Call all 12 `AssignmentService` methods with mocked Dio responses. Verify `AssignmentModel` correctly parses backend JSON including `isLate` as integer (0/1), `allowedFileTypes` as JSON string, `instructionFiles` as `DriveFileModel[]`, and pagination meta. Verify `AssignmentSubmissionModel` parses `isLate` as int.

### Implementation for User Story 2

#### Models

- [x] T021 [P] [US2] Full rewrite of `AssignmentModel` in `lib/models/assignments/assignment_model.dart` to match backend `GET /api/assignments` shape: `id` (int), `courseId` (int), `title` (String), `description` (String?), `instructions` (String?), `maxScore` (double, via `double.tryParse()`), `weight` (double, via `double.tryParse()`), `dueDate` (DateTime?), `availableFrom` (DateTime?), `lateSubmissionAllowed` (bool, parse as `(value as num) == 1`), `latePenaltyPercent` (double, via `double.tryParse()`), `submissionType` (SubmissionType enum), `maxFileSizeMb` (int), `allowedFileTypes` (List<String>?, parse via `jsonDecode()`), `status` (AssignmentStatus enum), `createdBy` (int), `createdAt`, `updatedAt`, `course` (CourseInfo?), `instructionFiles` (List<DriveFileModel>?). Remove any old fields not in backend shape.
- [x] T022 [P] [US2] Create `AssignmentSubmissionModel` in `lib/models/assignments/assignment_submission_model.dart` (SEPARATE file from existing `AssignmentModel` — the existing file contains `SubmissionModel` which is a different class). Fields: `id` (int), `assignmentId` (int), `userId` (int), `submissionText` (String?), `submissionLink` (String?), `fileId` (int?), `submissionStatus` (SubmissionStatus enum), `isLate` (bool, parse as `(value as num) == 1`), `attemptNumber` (int), `submittedAt` (DateTime), `score` (double?, via `double.tryParse()`), `feedback` (String?), `gradedBy` (int?), `gradedAt` (DateTime?), `user` (UserInfo?), `driveFile` (DriveFileModel?).

#### Services

- [x] T023 [US2] Create `AssignmentService` in `lib/services/api/assignment_service.dart` with 12 methods:
  - `getAll({courseId, sectionId, status, search, page, limit, sortBy, sortOrder})` → `GET /api/assignments` — returns `ServiceResult<PaginatedResponse<AssignmentModel>>` (ONLY service method returning PaginatedResponse). Apply retry helper.
  - `getById(id)` → `GET /api/assignments/:id` — returns `ServiceResult<AssignmentModel>`.
  - `create(data)` → `POST /api/assignments` — returns `ServiceResult<AssignmentModel>`.
  - `update(id, data)` → `PATCH /api/assignments/:id` — returns `ServiceResult<AssignmentModel>`.
  - `delete(id)` → `DELETE /api/assignments/:id` — returns `ServiceResult<void>`.
  - `updateStatus(id, status)` → `PATCH /api/assignments/:id/status` — returns `ServiceResult<AssignmentModel>`.
  - `getSubmissions(assignmentId)` → `GET /api/assignments/:id/submissions` — returns `ServiceResult<List<AssignmentSubmissionModel>>`.
  - `submit(assignmentId, {submissionText, submissionLink})` → `POST /api/assignments/:id/submit` — JSON body. Returns `ServiceResult<AssignmentSubmissionModel>`.
  - `submitFile(assignmentId, File file, {submissionText, submissionLink})` → `POST /api/assignments/:id/submissions/upload` — **Multipart FormData** with field name `file`. Do NOT manually set `Content-Type`. Returns `ServiceResult<AssignmentSubmissionModel>`.
  - `getMySubmission(assignmentId)` → `GET /api/assignments/:id/submissions/my` — returns `ServiceResult<AssignmentSubmissionModel>`.
  - `gradeSubmission(assignmentId, submissionId, score, {feedback})` → `PATCH /api/assignments/:id/submissions/:subId/grade` — returns `ServiceResult<Map>`.
  - `uploadInstructionFile(assignmentId, File file, {title, orderIndex})` → `POST /api/assignments/:id/instructions/upload` — **Multipart FormData** with field name `file`. Returns `ServiceResult<DriveFileModel>`.

**Checkpoint**: User Stories 1 AND 2 should both work independently. Assignments can be listed, created, submitted, and graded with correct model parsing.

---

## Phase 5: User Story 3 — Lab Lifecycle Data Access (Priority: P3)

**Goal**: Enable full lab CRUD, instruction management, submission, grading, attendance tracking, and TA material uploads. Labs parallel assignments but have additional complexity (multiple instructions, attendance).

**Independent Test**: Call all 16 `LabService` methods with mocked Dio responses. Verify `LabModel`, `LabSubmissionModel`, `LabInstructionModel`, `LabAttendanceModel` correctly parse backend JSON — especially `isLate` as boolean (true/false, NOT int like assignments).

### Implementation for User Story 3

#### Models

- [x] T024 [P] [US3] Full rewrite of `LabModel` in `lib/models/labs/lab_model.dart` to match backend `GET /api/labs` shape: `id` (int), `courseId` (int), `title` (String), `description` (String?), `labNumber` (int?), `dueDate` (DateTime?), `availableFrom` (DateTime?), `maxScore` (double, via `double.tryParse()`), `weight` (double, via `double.tryParse()`), `status` (LabStatus enum), `createdBy` (int), `createdAt`, `updatedAt`, `course` (CourseInfo?), `instructionFiles` (List<DriveFileModel>?).
- [x] T025 [P] [US3] Create `LabSubmissionModel` in `lib/models/labs/lab_submission_model.dart` with fields: `id` (int), `labId` (int), `userId` (int), `submissionText` (String?), `fileId` (int?), `submissionStatus` (SubmissionStatus enum), `isLate` (bool, parse as **direct boolean** — `value == true`, NOT int like assignments), `submittedAt` (DateTime), `score` (double?, via `double.tryParse()`), `feedback` (String?), `gradedBy` (int?), `gradedAt` (DateTime?), `user` (UserInfo?), `driveFile` (DriveFileModel?).
- [x] T026 [P] [US3] Create `LabInstructionModel` in `lib/models/core/lab_instruction_model.dart` with fields: `id` (int), `labId` (int), `instructionText` (String?), `fileId` (int?), `file` (DriveFileModel?), `orderIndex` (int), `createdAt`.
- [x] T027 [P] [US3] Create `LabAttendanceModel` in `lib/models/core/lab_attendance_model.dart` with fields: `id` (int), `labId` (int), `userId` (int), `attendanceStatus` (LabAttendanceStatus enum), `checkInTime` (DateTime?), `notes` (String?), `markedBy` (int?), `createdAt`.

#### Services

- [x] T028 [US3] Create `LabService` in `lib/services/api/lab_service.dart` with 16 methods:
  - `getAll({courseId})` → `GET /api/labs` — returns `ServiceResult<List<LabModel>>` (NOT paginated).
  - `getById(id)` → `GET /api/labs/:id` — returns `ServiceResult<LabModel>`.
  - `create(data)` → `POST /api/labs` — returns `ServiceResult<LabModel>`.
  - `update(id, data)` → `PATCH /api/labs/:id` — returns `ServiceResult<LabModel>`.
  - `delete(id)` → `DELETE /api/labs/:id` — returns `ServiceResult<void>`.
  - `getInstructions(labId)` → `GET /api/labs/:id/instructions` — returns `ServiceResult<List<LabInstructionModel>>`.
  - `addInstruction(labId, data)` → `POST /api/labs/:id/instructions` — returns `ServiceResult<LabInstructionModel>`.
  - `uploadInstructionFile(labId, File file, {title, orderIndex})` → `POST /api/labs/:id/instructions/upload` — **Multipart FormData** with field name `file`. Returns `ServiceResult<DriveFileModel>`.
  - `getSubmissions(labId)` → `GET /api/labs/:id/submissions` — returns `ServiceResult<List<LabSubmissionModel>>`.
  - `submit(labId, {submissionText, submissionLink})` → `POST /api/labs/:id/submit` — JSON body. Returns `ServiceResult<LabSubmissionModel>`.
  - `submitFile(labId, File file, {submissionText})` → `POST /api/labs/:id/submissions/upload` — **Multipart FormData** with field name `file`. Returns `ServiceResult<LabSubmissionModel>`.
  - `getMySubmission(labId)` → `GET /api/labs/:id/my-submission` — returns `ServiceResult<LabSubmissionModel>`.
  - `gradeSubmission(labId, submissionId, score, {feedback})` → `PATCH /api/labs/:labId/submissions/:subId/grade` — returns `ServiceResult<Map>`.
  - `getAttendance(labId)` → `GET /api/labs/:id/attendance` — returns `ServiceResult<List<LabAttendanceModel>>`.
  - `markAttendance(labId, data)` → `POST /api/labs/:id/attendance` — returns `ServiceResult<LabAttendanceModel>`.
  - `uploadTaMaterial(labId, File file)` → `POST /api/labs/:id/ta-materials/upload` — **Multipart FormData** with field name `file`. Returns `ServiceResult<DriveFileModel>`.

**Checkpoint**: All user stories (US1, US2, US3) should now be independently functional. 6 services, 14 models, 13 enums complete.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup, validation, and unused file removal

### Error Handling Validation
<!-- Maps to spec Edge Cases: "Token expiration", "Network failure", "Transient server errors", "Role-based access denial" -->

- [x] T029 Verify all 6 services wrap every HTTP call in try/catch and return `ServiceResult<T>` — no raw `DioException` or unhandled exceptions should propagate to callers. Test with mocked 401, 403, 404, 409, 500 responses.
- [x] T030 Verify retry logic: mock 500 response → service retries up to 3 times with exponential backoff (1s → 2s → 4s). After 3 failures, returns `ServiceResult.failure(ServiceError(type: server))`. Verify 401/403/404/409 do NOT trigger retries.

### Model Parsing Validation
<!-- Maps to spec Edge Cases: "isLate type divergence", "allowedFileTypes JSON string", "Decimal fields as strings", "Empty pagination", "Null optional fields" -->

- [x] T031 Test `isLate` parsing divergence: feed `isLate: 0` and `isLate: 1` to `AssignmentSubmissionModel.fromJson` → must produce `false`/`true`. Feed `isLate: true` and `isLate: false` to `LabSubmissionModel.fromJson` → must produce `true`/`false`.
- [x] T032 Test `allowedFileTypes` parsing: feed `"[\"pdf\",\"zip\"]"` (JSON string) to `AssignmentModel.fromJson` → must produce `["pdf", "zip"]` (List<String>). Feed `"[]"` → must produce empty list. Feed `null` → must produce `null`.
- [x] T033 Test decimal field parsing: feed `maxScore: "100"` (string) and `maxScore: 100.0` (number) → both must produce `100.0` (double) via `double.tryParse(value.toString())`.
- [x] T034 Test `PaginatedResponse<T>` edge cases: page 1 of 1 (hasNextPage=false, hasPreviousPage=false), last page, empty results (total=0, data=[]), single-page results. Must not crash on empty arrays.
- [x] T035 Test all 13 enums: parse valid backend string values → correct enum. Parse unknown string → `.unknown` variant. Serialize back to exact string via `toJson()`.

### Static Data Audit & Cleanup

- [x] T036 Run audit grep across all modified files (models/, services/, common/) for residual mock patterns: `_generateSample`, `_generateDemo`, `_mock`, `Future.delayed` (in data context), hardcoded `List<>` literals. Zero matches must remain in Phase 1 files.
- [x] T037 [P] Identify and delete unused TA course feature files from before backend integration. **Verification steps BEFORE deletion**: (1) Run `grep -r 'ta_assignment_model' lib/ --include='*.dart'` — if only the model file itself matches, it's safe to delete. (2) Check `lib/screens/ta/courses/`, `lib/screens/ta/labs/`, `lib/screens/ta/ai_grading/`, `lib/screens/ta/analytics/` — for each file, run `grep -r '<filename_without_extension>' lib/ --include='*.dart'` to find imports. (3) Check route definitions in `lib/config/` or `lib/main.dart` for references. (4) Delete only files where: (a) no imports found, (b) no route references, (c) file contains hardcoded mock data as primary data source. Document deleted files in a comment at the top of this task.
  Execution note (2026-04-10): No TA files were deleted because router/import references still exist for all audited TA course/lab/analytics/grading screens.
- [x] T038 Verify no `TODO: Replace with API` comments remain in any Phase 1 files. All must be resolved.

### Final Compilation Check

- [x] T039 Run `flutter analyze` — must produce zero errors in all Phase 1 files.
- [x] T040 Run `flutter test` — must pass (if any tests exist for the modified services/models).

### Service Registration

- [x] T041 Register all 6 services (`EnrollmentService`, `AssignmentService`, `LabService`, `SectionService`, `ScheduleService`, `SemesterService`) in the app's dependency injection system so they are injectable for testing. Follow the same registration pattern as existing services (`CourseService`, `MaterialService`) — locate the service locator/registration file (likely in `lib/main.dart` or a dedicated `lib/services/service_locator.dart`) and add instantiation with `CoreApiClient` injection for each new service.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — **BLOCKS all user stories**
- **User Story 1 (Phase 3)**: Depends on Foundational — **MVP target**
- **User Story 2 (Phase 4)**: Depends on Foundational — may integrate with US1 models (CourseModel, DriveFileModel)
- **User Story 3 (Phase 5)**: Depends on Foundational — may integrate with US1/US2 models (CourseModel, DriveFileModel, SubmissionStatus)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

```
Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1: Courses/Enrollment) [MVP]
                                        → Phase 4 (US2: Assignments)
                                        → Phase 5 (US3: Labs)
                                  → Phase 6 (Polish & Cleanup)
```

- **US1 (P1)**: Can start after Foundational — depends on CourseModel, EnrollmentModel, SectionModel, ScheduleModel, SemesterModel
- **US2 (P2)**: Can start after Foundational — depends on AssignmentModel, AssignmentSubmissionModel, DriveFileModel, PaginatedResponse
- **US3 (P3)**: Can start after Foundational — depends on LabModel, LabSubmissionModel, LabInstructionModel, LabAttendanceModel, DriveFileModel

### Within Each User Story

- Models before services (services import models)
- Enums before models (models import enums)
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1**: T001 and T002 can run in parallel (different files)
- **Phase 2**: T003–T011 can ALL run in parallel (all different files, no inter-dependencies)
- **Phase 3 (US1)**: T012–T016 (models) can run in parallel. T017–T019 (services) can run in parallel. T020 depends on T016 (enrollment model updated).
- **Phase 4 (US2)**: T021–T022 (models) can run in parallel. T023 (service) depends on T021–T022.
- **Phase 5 (US3)**: T024–T027 (models) can ALL run in parallel. T028 (service) depends on T024–T027.
- **Phase 6**: T029–T035 can run in parallel (independent validations). T036–T040 are sequential (audit → compile → test).

---

## Parallel Example: Foundational Phase

```bash
# Launch all enum files together:
Task: "Create course_enums.dart" (T003)
Task: "Create schedule_enums.dart" (T004)
Task: "Create assignment_enums.dart" (T005)
Task: "Create lab_enums.dart" (T006)
Task: "Create enrollment_enums.dart" (T007)

# Launch all shared models together:
Task: "Create DriveFileModel" (T008)
Task: "Create PaginatedResponse" (T009)
Task: "Create shared models" (T010)
```

---

## Parallel Example: User Story 1 (Courses/Enrollment)

```bash
# Launch all model updates together:
Task: "Update CourseModel" (T012)
Task: "Update SemesterModel" (T013)
Task: "Update SectionModel" (T014)
Task: "Create ScheduleModel" (T015)
Task: "Update EnrollmentModel" (T016)

# Launch all services together (after models done):
Task: "Create SemesterService" (T017)
Task: "Create ScheduleService" (T018)
Task: "Create SectionService" (T019)
```

---

## Parallel Example: User Story 2 (Assignments)

```bash
# Launch models together:
Task: "Rewrite AssignmentModel" (T021)
Task: "Create AssignmentSubmissionModel" (T022)

# Then service:
Task: "Create AssignmentService" (T023)
```

---

## Parallel Example: User Story 3 (Labs)

```bash
# Launch ALL models together:
Task: "Rewrite LabModel" (T024)
Task: "Create LabSubmissionModel" (T025)
Task: "Create LabInstructionModel" (T026)
Task: "Create LabAttendanceModel" (T027)

# Then service:
Task: "Create LabService" (T028)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002)
2. Complete Phase 2: Foundational (T003–T011)
3. Complete Phase 3: User Story 1 (T012–T020)
4. **STOP and VALIDATE**: Verify courses load from backend with real data
5. Commit and demo

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 (Courses/Enrollment) → Verify courses load → Demo (MVP!)
3. Add US2 (Assignments) → Verify assignment CRUD → Demo
4. Add US3 (Labs) → Verify lab CRUD + attendance → Demo
5. Polish + Cleanup → Final audit → Phase 1 complete

### Parallel Team Strategy

With multiple developers (e.g., gpt-5.3-codex instances):

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Courses/Enrollment)
   - Developer B: User Story 2 (Assignments)
   - Developer C: User Story 3 (Labs)
3. Stories complete and integrate independently
4. Team combines all PRs and runs final audit

---

## Important Parsing Rules (Constitution Principles)

All models MUST follow these rules:

1. **`isLate` in AssignmentSubmissionModel**: `(json['isLate'] as num) == 1` (backend sends 0/1 as integer)
2. **`isLate` in LabSubmissionModel**: `json['isLate'] == true` (backend sends true/false as boolean)
3. **`allowedFileTypes` in AssignmentModel**: `json['allowedFileTypes'] != null ? (jsonDecode(json['allowedFileTypes']) as List).map((e) => e.toString()).toList() : null`
4. **`lateSubmissionAllowed` in AssignmentModel**: `(json['lateSubmissionAllowed'] as num) == 1`
5. **Decimal fields** (maxScore, weight, latePenaltyPercent, score): `double.tryParse(value.toString())`
6. **Date fields**: `DateTime.tryParse(value.toString())`
7. **Enums**: `EnumType.fromString(json['field'] as String? ?? 'unknown')`
8. **DriveFileModel.downloadUrl**: mapped from backend `webContentLink`
9. **DriveFileModel.iframeUrl**: computed as `'https://drive.google.com/file/d/${json['driveId']}/preview'`
10. **PaginatedResponse**: only returned by `AssignmentService.getAll()`

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- **CRITICAL**: Do NOT modify any UI files (screens/, widgets/, bloc/) in this phase
- **CRITICAL**: Do NOT modify `CourseService` or `MaterialService` unless backend alignment requires it
- T037 (unused file cleanup) requires careful verification — do NOT delete files that are still imported or routed to
- Total tasks: **41**
- Tasks per user story: US1=9, US2=3, US3=5 (models+services only), Foundational=9, Setup=2, Polish=13
- Parallel opportunities: 24 tasks marked [P]

