# Data Model: Phase 6 — Instructor Assignments CRUD & Grading

**Date**: 2026-04-12
**Branch**: `020-phase-6-instructor`

---

## Entity: Assignment

**Source**: `lib/models/assignments/assignment_model.dart` (exists from Phase 1)
**Backend endpoints**: `GET/POST/PATCH /assignments`, `GET /assignments/{id}`

### Fields

| Field | Type | Required | Default | Notes |
|---|---|---|---|---|
| `id` | `int` | ✅ (auto) | — | BigInt from backend |
| `courseId` | `int` | ✅ | — | FK to courses |
| `title` | `String` | ✅ | — | Non-empty validation |
| `description` | `String?` | ❌ | `null` | Optional description |
| `instructions` | `String?` | ❌ | `null` | Markdown-supported |
| `maxScore` | `double` | ✅ | `100.0` | Parse with `double.tryParse(value.toString())` |
| `weight` | `double?` | ❌ | `10.0` | Grade weight percentage |
| `dueDate` | `String?` | ✅ | — | ISO 8601 datetime |
| `availableFrom` | `String?` | ❌ | `null` | ISO 8601 datetime |
| `lateSubmissionAllowed` | `int` | ❌ | `0` | **TINYINT(1)** — parse as `(value as num) == 1`, NOT bool |
| `latePenaltyPercent` | `double?` | ❌ | `0.0` | 0-100, parse with `double.tryParse()` |
| `submissionType` | `SubmissionType` | ✅ | `file` | Enum: `file`, `text`, `link`, `multiple` |
| `maxFileSizeMb` | `int?` | ❌ | `10` | Max file size in MB |
| `allowedFileTypes` | `String?` | ❌ | `null` | **JSON string** — parse with `jsonDecode()`, e.g. `'["pdf","zip"]'` |
| `status` | `AssignmentStatus` | ✅ | `draft` | Enum: `draft`, `published`, `closed`, `archived` |
| `createdBy` | `int` | ✅ (auto) | — | Creator user ID |
| `createdAt` | `String?` | ✅ (auto) | — | ISO 8601 |
| `updatedAt` | `String?` | ✅ (auto) | — | ISO 8601 |
| `course` | `CourseModel?` | ❌ | `null` | Joined course relation |
| `instructionFiles` | `List<DriveFileModel>` | ❌ | `[]` | Uploaded instruction files |

### Relationships
- **Belongs to**: Course (via `courseId`)
- **Has many**: AssignmentSubmissions (via assignment `id`)
- **Has many**: DriveFileModel (instruction files, via relation)

### Status Transitions
```
draft → published → closed → archived (one-way, no reversals)
```

### Validation Rules
- `title`: non-empty string
- `dueDate`: must be a valid ISO 8601 datetime, must be in the future for new assignments
- `maxScore`: must be > 0
- `submissionType`: must be one of the enum values
- `latePenaltyPercent`: must be 0-100 if provided
- `maxFileSizeMb`: must be > 0 if provided

---

## Entity: AssignmentSubmission

**Source**: `lib/models/assignments/assignment_submission_model.dart` (exists from Phase 1)
**Backend endpoints**: `GET /assignments/{id}/submissions`

### Fields

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | `int` | ✅ | BigInt from backend |
| `assignmentId` | `int` | ✅ | FK to assignments |
| `userId` | `int` | ✅ | FK to users (student) |
| `user` | `UserRelation?` | ❌ | Joined user info (firstName, lastName, email) |
| `submissionText` | `String?` | ❌ | Text submission content |
| `submissionLink` | `String?` | ❌ | URL submission |
| `driveFile` | `DriveFileModel?` | ❌ | Google Drive file (for file submissions) |
| `submissionStatus` | `SubmissionStatus` | ✅ | Enum: `submitted`, `graded`, `returned`, `resubmit` |
| `score` | `double?` | ❌ | Parse with `double.tryParse()` |
| `feedback` | `String?` | ❌ | Instructor feedback text |
| `gradedBy` | `int?` | ❌ | Grader user ID |
| `gradedAt` | `String?` | ❌ | ISO 8601 grading timestamp |
| `isLate` | `int` | ❌ | **TINYINT(1)** — parse as `(value as num) == 1`, NOT bool |
| `submittedAt` | `String` | ✅ | ISO 8601 submission timestamp |

### Relationships
- **Belongs to**: Assignment (via `assignmentId`)
- **Belongs to**: User/Student (via `userId`)
- **Has one**: DriveFileModel (optional, for file submissions)
- **Graded by**: User/Instructor (via `gradedBy`)

### Submission Status Flow
```
submitted → graded → returned (optional) → resubmit (optional) → submitted (cycle)
```

### Filter Logic (from clarification session)
- **"Ungraded" filter** = `submitted` + `resubmit` only
- **"Graded" filter** = `graded` only
- **"All"** = all statuses
- **"Late" filter** = any status where `isLate == 1`

---

## Entity: TeachingCourse

**Source**: `lib/models/instructor/teaching_course_model.dart` (exists, no changes)
**Backend endpoints**: `GET /enrollments/teaching`

### Fields (summary)

| Field | Type | Notes |
|---|---|---|
| `sectionId` | `int` | Section identifier |
| `courseId` | `int` | Course identifier |
| `course` | `CourseModel` | Full course details |
| `section` | `SectionModel` | Section details |
| `semester` | `SemesterModel` | Semester details |
| `enrolledCount` | `int` | Current enrollment count |
| `capacity` | `int` | Section max capacity |
| `averageGrade` | `double?` | Average grade across assessments |
| `attendanceRate` | `double?` | Attendance percentage |

---

## Entity: DriveFileModel

**Source**: `lib/models/core/drive_file_model.dart` (exists, no changes)
**Backend endpoints**: `POST /assignments/{id}/instructions/upload`

### Fields (summary)

| Field | Type | Notes |
|---|---|---|
| `driveId` | `String` | Google Drive file ID |
| `fileName` | `String` | Original file name |
| `webViewLink` | `String` | Google Drive web view URL |
| `iframeUrl` | `String` | Embeddable iframe URL |
| `downloadUrl` | `String` | Direct download URL |
| `mimeType` | `String?` | MIME type |
| `fileSize` | `int?` | File size in bytes |

---

## Enums

### AssignmentStatus
**Source**: `lib/models/core/enums/assignment_enums.dart` (exists, correct)

| Value | Description |
|---|---|
| `draft` | Not visible to students |
| `published` | Visible and accepting submissions |
| `closed` | No longer accepting submissions |
| `archived` | Hidden from all views |

### SubmissionStatus
**Source**: `lib/models/core/enums/assignment_enums.dart` (exists, correct — needs verification that `submitted/graded/returned/resubmit` are defined)

| Value | Description |
|---|---|
| `submitted` | Student has submitted work |
| `graded` | Submission has been graded |
| `returned` | Returned to student for review |
| `resubmit` | Student must resubmit |

### SubmissionType
**Source**: `lib/models/core/enums/assignment_enums.dart` (exists, correct)

| Value | Description |
|---|---|
| `file` | File-based submission |
| `text` | Text-based submission |
| `link` | URL/Link submission |
| `multiple` | Any type allowed — student chooses **exactly one** per attempt (from clarification Q3) |

---

## Derived/Calculated Values

### Late Penalty Calculation
**Formula** (from spec SC-009):
```
Final Score = Original Score × (1 - (latePenaltyPercent × daysLate / 100))
```

Where:
- `daysLate` = number of full days between `dueDate` and `submittedAt` (0 if on time)
- `latePenaltyPercent` = from assignment's `latePenaltyPercent` field (0-100)
- `Original Score` = the score entered by the instructor

**Implementation**: Pure utility function in `lib/utils/late_penalty_calculator.dart`

### Grading Statistics
Computed from a list of submissions:
- `totalSubmissions`: count of all submissions
- `pendingSubmissions`: count where status == `submitted` or `resubmit`
- `gradedSubmissions`: count where status == `graded`
- `lateSubmissions`: count where `isLate == 1`
- `averageGrade`: mean of `score` where status == `graded`
- `completionRate`: `gradedSubmissions / totalSubmissions`

---

## Data Flow

```
InstructorAssignmentsCubit
  ├─ loadTeachingCourses() → EnrollmentService.getTeachingCourses()
  ├─ selectCourse(courseId)
  ├─ loadAssignments() → AssignmentService.getAll(courseId: courseId, page: 1, limit: 20)
  ├─ createAssignment(formData) → AssignmentService.create(formData.toJson())
  ├─ editAssignment(id, formData) → AssignmentService.update(id, formData.toJson())
  ├─ deleteAssignment(id) → AssignmentService.delete(id)
  ├─ updateStatus(id, status) → AssignmentService.updateStatus(id, status)
  └─ setFilter / setSearchQuery → client-side filter on loaded data

SubmissionGradingScreen
  ├─ loadSubmissions(assignmentId) → AssignmentService.getSubmissions(assignmentId)
  ├─ gradeSubmission(submissionId, score, feedback) → AssignmentService.gradeSubmission(...)
  └─ refreshSubmissions() → re-fetch from API

CreateAssignmentScreen
  ├─ submit(formData) → AssignmentService.create(formData.toJson())
  └─ uploadInstructionFile(file) → AssignmentService.uploadInstructionFile(id, file)
```
