# Data Model: Phase 1 — Foundation (API Services & Domain Models)

**Feature**: 015-phase-1-foundation
**Date**: 2026-04-10

---

## Entities

### 1. CourseModel

**Source**: `GET /api/courses/:id`, nested in enrollment/assignment/lab responses
**File**: `lib/models/core/course_model.dart` (UPDATE)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Primary key (bigint) |
| `departmentId` | `int` | No | `departmentId` | FK to departments |
| `code` | `String` | No | `code` | 2-10 chars, uppercase alphanumeric |
| `name` | `String` | No | `name` | Course name |
| `description` | `String?` | Yes | `description` | Nullable |
| `credits` | `int` | No | `credits` | 1-6 |
| `level` | `CourseLevel` | No | `level` | Enum: FRESHMAN/SOPHOMORE/JUNIOR/SENIOR/GRADUATE |
| `syllabusUrl` | `String?` | Yes | `syllabusUrl` | Valid URL or null |
| `instructorId` | `int?` | Yes | `instructorId` | FK to users |
| `taIds` | `List<int>` | Yes | `taIds` | Array of user IDs |
| `status` | `CourseStatus` | No | `status` | Enum: ACTIVE/INACTIVE/ARCHIVED |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |
| `updatedAt` | `DateTime` | No | `updatedAt` | ISO 8601 |
| `department` | `DepartmentInfo?` | Yes | `department` | Nested object (id, name, code) |
| `prerequisites` | `List<CoursePrerequisite>` | Yes | `prerequisites` | Nested array (loaded relation) |
| `sections` | `List<SectionModel>` | Yes | `sections` | Nested array (loaded relation) |

**Relationships**:
- Has many `SectionModel` (via `sections`)
- Has many `CoursePrerequisite` (via `prerequisites`)
- Belongs to `DepartmentInfo` (via `department`)
- Referenced by `EnrollmentModel`, `AssignmentModel`, `LabModel`

---

### 2. DepartmentInfo (Nested in CourseModel)

| Field | Type | Nullable | Backend Key |
|---|---|---|---|
| `id` | `int` | No | `id` |
| `name` | `String` | No | `name` |
| `code` | `String` | No | `code` |

---

### 3. CoursePrerequisite (Nested in CourseModel)

| Field | Type | Nullable | Backend Key |
|---|---|---|---|
| `id` | `int` | No | `id` |
| `courseId` | `int` | No | `courseId` |
| `prerequisiteCourseId` | `int` | No | `prerequisiteCourseId` |
| `isMandatory` | `bool` | No | `isMandatory` |
| `prerequisiteCourse` | `CourseInfo?` | Yes | `prerequisiteCourse` |
| `createdAt` | `DateTime` | No | `createdAt` |

---

### 4. CourseEnrollmentModel

**Source**: `GET /api/enrollments/my-courses`, `GET /api/enrollments/available`, `GET /api/enrollments/teaching`
**File**: `lib/models/core/enrollment_model.dart` (UPDATE)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `String` | No | `id` | Enrollment ID (stringified) |
| `userId` | `int` | No | `userId` | FK to users |
| `sectionId` | `int` | No | `sectionId` | FK to sections |
| `status` | `EnrollmentStatus` | No | `status` | Enum: enrolled/waitlisted/dropped/completed/failed |
| `grade` | `String?` | Yes | `grade` | Letter grade or null |
| `finalScore` | `double?` | Yes | `finalScore` | Parse with `double.tryParse()` |
| `enrollmentDate` | `DateTime` | No | `enrollmentDate` | ISO 8601 |
| `canDrop` | `bool` | No | `canDrop` | Whether student can drop |
| `dropDeadline` | `DateTime?` | Yes | `dropDeadline` | Drop deadline or null |
| `role` | `String` | No | `role` | 'student'/'instructor'/'ta' |
| `course` | `CourseModel?` | Yes | `course` | Nested course object |
| `section` | `SectionModel?` | Yes | `section` | Nested section object |
| `semester` | `SemesterModel?` | Yes | `semester` | Nested semester object |

**Derived**: `courseId` getter → `course?.courseId.toString() ?? ''`

---

### 5. SectionModel

**Source**: `GET /api/sections/course/:courseId`, `GET /api/sections/:id`
**File**: `lib/models/core/section_model.dart` (UPDATE)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Section ID (bigint) |
| `courseId` | `int` | No | `courseId` | FK to courses |
| `semesterId` | `int` | No | `semesterId` | FK to semesters |
| `sectionNumber` | `String` | No | `sectionNumber` | Section number |
| `maxCapacity` | `int` | No | `maxCapacity` | Max students |
| `currentEnrollment` | `int` | No | `currentEnrollment` | Current count |
| `location` | `String?` | Yes | `location` | Room/location |
| `status` | `SectionStatus` | No | `status` | Enum: OPEN/CLOSED/FULL/CANCELLED |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |
| `updatedAt` | `DateTime` | No | `updatedAt` | ISO 8601 |
| `course` | `CourseInfo?` | Yes | `course` | Nested (id, name, code) |
| `semester` | `SemesterModel?` | Yes | `semester` | Nested semester |
| `schedules` | `List<ScheduleModel>` | Yes | `schedules` | Nested schedule array |

---

### 6. ScheduleModel

**Source**: `GET /api/schedules/section/:sectionId`, `GET /api/schedules/:id`
**File**: New or existing (check if exists)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Schedule ID |
| `sectionId` | `int` | No | `sectionId` | FK to sections |
| `dayOfWeek` | `DayOfWeek` | No | `dayOfWeek` | Enum: MONDAY-SUNDAY |
| `startTime` | `String` | No | `startTime` | HH:mm (24-hour) |
| `endTime` | `String` | No | `endTime` | HH:mm (24-hour) |
| `room` | `String?` | Yes | `room` | Room number |
| `building` | `String?` | Yes | `building` | Building name |
| `scheduleType` | `ScheduleType` | No | `scheduleType` | Enum: LECTURE/LAB/TUTORIAL/EXAM |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |

---

### 7. SemesterModel

**Source**: `GET /api/enrollments/periods`
**File**: `lib/models/core/semester_model.dart` (UPDATE — existing model, add fields)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Semester ID |
| `name` | `String` | No | `semesterName` | e.g. "Fall 2025" |
| `startDate` | `DateTime` | No | `semesterStart` | ISO 8601 |
| `endDate` | `DateTime` | No | `semesterEnd` | ISO 8601 |
| `registrationStart` | `DateTime?` | Yes | `registrationStart` | ISO 8601 |
| `registrationEnd` | `DateTime?` | Yes | `registrationEnd` | ISO 8601 |
| `status` | `String` | No | `status` | "active"/"inactive"/"archived" |

---

### 8. AssignmentModel

**Source**: `GET /api/assignments`, `GET /api/assignments/:id`
**File**: `lib/models/assignments/assignment_model.dart` (FULL REWRITE)

| Field | Type | Nullable | Backend Key | Special Parsing |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Assignment ID (bigint) |
| `courseId` | `int` | No | `courseId` | FK to courses |
| `title` | `String` | No | `title` | 3-200 chars |
| `description` | `String?` | Yes | `description` | Nullable |
| `instructions` | `String?` | Yes | `instructions` | Markdown text |
| `maxScore` | `double` | No | `maxScore` | `double.tryParse(value.toString())` |
| `weight` | `double` | No | `weight` | `double.tryParse(value.toString())` |
| `dueDate` | `DateTime?` | Yes | `dueDate` | ISO 8601 |
| `availableFrom` | `DateTime?` | Yes | `availableFrom` | ISO 8601 |
| `lateSubmissionAllowed` | `bool` | No | `lateSubmissionAllowed` | `(value as num) == 1` |
| `latePenaltyPercent` | `double` | No | `latePenaltyPercent` | `double.tryParse(value.toString())` |
| `submissionType` | `SubmissionType` | No | `submissionType` | Enum: file/text/link/multiple |
| `maxFileSizeMb` | `int` | No | `maxFileSizeMb` | Default 10 |
| `allowedFileTypes` | `List<String>?` | Yes | `allowedFileTypes` | **JSON string** → `jsonDecode()` |
| `status` | `AssignmentStatus` | No | `status` | Enum: draft/published/closed/archived |
| `createdBy` | `int` | No | `createdBy` | Creator user ID |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |
| `updatedAt` | `DateTime` | No | `updatedAt` | ISO 8601 |
| `course` | `CourseInfo?` | Yes | `course` | Nested course info |
| `instructionFiles` | `List<DriveFileModel>` | Yes | `instructionFiles` | Google Drive files array |

---

### 9. AssignmentSubmissionModel

**Source**: `GET /api/assignments/:id/submissions`, `GET /api/assignments/:id/submissions/my`
**File**: `lib/models/assignments/assignment_submission_model.dart` (NEW)

| Field | Type | Nullable | Backend Key | Special Parsing |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Submission ID |
| `assignmentId` | `int` | No | `assignmentId` | FK |
| `userId` | `int` | No | `userId` | Student user ID |
| `submissionText` | `String?` | Yes | `submissionText` | Nullable |
| `submissionLink` | `String?` | Yes | `submissionLink` | Nullable |
| `fileId` | `int?` | Yes | `fileId` | Nullable |
| `submissionStatus` | `SubmissionStatus` | No | `submissionStatus` | Enum: submitted/graded/returned/resubmit |
| `isLate` | `bool` | No | `isLate` | **INT**: `(value as num) == 1` |
| `attemptNumber` | `int` | No | `attemptNumber` | Auto-incremented |
| `submittedAt` | `DateTime` | No | `submittedAt` | ISO 8601 |
| `score` | `double?` | Yes | `score` | `double.tryParse(value.toString())` |
| `feedback` | `String?` | Yes | `feedback` | Nullable |
| `gradedBy` | `int?` | Yes | `gradedBy` | Grader user ID |
| `gradedAt` | `DateTime?` | Yes | `gradedAt` | ISO 8601 |
| `user` | `UserInfo?` | Yes | `user` | Nested user object |
| `driveFile` | `DriveFileModel?` | Yes | `driveFile` | Nested Drive file |

---

### 10. LabModel

**Source**: `GET /api/labs`, `GET /api/labs/:id`
**File**: `lib/models/labs/lab_model.dart` (FULL REWRITE)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Lab ID (bigint) |
| `courseId` | `int` | No | `courseId` | FK to courses |
| `title` | `String` | No | `title` | Lab title |
| `description` | `String?` | Yes | `description` | Nullable |
| `labNumber` | `int?` | Yes | `labNumber` | Sequential number |
| `dueDate` | `DateTime?` | Yes | `dueDate` | ISO 8601 |
| `availableFrom` | `DateTime?` | Yes | `availableFrom` | ISO 8601 |
| `maxScore` | `double` | No | `maxScore` | `double.tryParse()` |
| `weight` | `double` | No | `weight` | `double.tryParse()` |
| `status` | `LabStatus` | No | `status` | Enum: draft/published/closed/archived |
| `createdBy` | `int` | No | `createdBy` | Creator user ID |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |
| `updatedAt` | `DateTime` | No | `updatedAt` | ISO 8601 |
| `course` | `CourseInfo?` | Yes | `course` | Nested course |
| `instructionFiles` | `List<DriveFileModel>` | Yes | `instructionFiles` | Google Drive files |

---

### 11. LabSubmissionModel

**Source**: `GET /api/labs/:id/submissions`, `GET /api/labs/:id/my-submission`
**File**: `lib/models/labs/lab_submission_model.dart` (NEW)

| Field | Type | Nullable | Backend Key | Special Parsing |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Submission ID |
| `labId` | `int` | No | `labId` | FK |
| `userId` | `int` | No | `userId` | Student user ID |
| `submissionText` | `String?` | Yes | `submissionText` | Nullable |
| `fileId` | `int?` | Yes | `fileId` | Nullable |
| `submissionStatus` | `SubmissionStatus` | No | `submissionStatus` | Enum |
| `isLate` | `bool` | No | `isLate` | **BOOL**: direct `== true` (NOT int) |
| `submittedAt` | `DateTime` | No | `submittedAt` | ISO 8601 |
| `score` | `double?` | Yes | `score` | `double.tryParse()` |
| `feedback` | `String?` | Yes | `feedback` | Nullable |
| `gradedBy` | `int?` | Yes | `gradedBy` | Grader user ID |
| `gradedAt` | `DateTime?` | Yes | `gradedAt` | ISO 8601 |
| `user` | `UserInfo?` | Yes | `user` | Nested user |
| `driveFile` | `DriveFileModel?` | Yes | `driveFile` | Nested Drive file |

---

### 12. LabInstructionModel

**Source**: `GET /api/labs/:id/instructions`
**File**: `lib/models/core/lab_instruction_model.dart` (NEW)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Instruction ID |
| `labId` | `int` | No | `labId` | FK to labs |
| `instructionText` | `String?` | Yes | `instructionText` | Markdown text |
| `fileId` | `int?` | Yes | `fileId` | FK to Drive file |
| `file` | `DriveFileModel?` | Yes | `file` | Nested Drive file |
| `orderIndex` | `int` | No | `orderIndex` | Sort order |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |

---

### 13. LabAttendanceModel

**Source**: `GET /api/labs/:id/attendance`
**File**: `lib/models/core/lab_attendance_model.dart` (NEW)

| Field | Type | Nullable | Backend Key | Validation |
|---|---|---|---|---|
| `id` | `int` | No | `id` | Attendance record ID |
| `labId` | `int` | No | `labId` | FK to labs |
| `userId` | `int` | No | `userId` | Student user ID |
| `attendanceStatus` | `LabAttendanceStatus` | No | `attendanceStatus` | Enum: present/absent/excused/late |
| `checkInTime` | `DateTime?` | Yes | `checkInTime` | ISO 8601 |
| `notes` | `String?` | Yes | `notes` | Optional notes |
| `markedBy` | `int?` | Yes | `markedBy` | Who marked it |
| `createdAt` | `DateTime` | No | `createdAt` | ISO 8601 |

---

### 14. DriveFileModel

**Source**: Nested in assignment/lab `instructionFiles`, submission `driveFile`
**File**: `lib/models/core/drive_file_model.dart` (NEW)

| Field | Type | Nullable | Backend Key | Notes |
|---|---|---|---|---|
| `driveFileId` | `int` | No | `driveFileId` | Internal record ID |
| `driveId` | `String` | No | `driveId` | Google Drive file ID |
| `fileName` | `String` | No | `fileName` | File name |
| `webViewLink` | `String` | No | `webViewLink` | Google Drive view URL |
| `downloadUrl` | `String` | No | `webContentLink` | **Mapped** from backend |
| `iframeUrl` | `String` | No | (computed) | `https://drive.google.com/file/d/{driveId}/preview` |

---

### 15. PaginatedResponse<T>

**Source**: `GET /api/assignments` (only endpoint returning this shape)
**File**: `lib/models/core/paginated_response.dart` (NEW)

| Field | Type | Nullable | Backend Key | Notes |
|---|---|---|---|---|
| `data` | `List<T>` | No | `data` | Typed array |
| `total` | `int` | No | `meta.total` | Total records |
| `page` | `int` | No | `meta.page` | Current page |
| `limit` | `int` | No | `meta.limit` | Per-page limit |
| `totalPages` | `int` | No | `meta.totalPages` | Total pages |
| `hasNextPage` | `bool` | No | (computed) | `page < totalPages` |
| `hasPreviousPage` | `bool` | No | (computed) | `page > 1` |

---

### 16. UserInfo (Nested helper)

| Field | Type | Nullable | Backend Key |
|---|---|---|---|
| `userId` | `int` | No | `user_id` |
| `firstName` | `String` | No | `first_name` |
| `lastName` | `String` | No | `last_name` |
| `email` | `String` | No | `email` |

### 17. CourseInfo (Nested helper)

| Field | Type | Nullable | Backend Key |
|---|---|---|---|
| `id` | `int` | No | `id` |
| `name` | `String` | No | `name` |
| `code` | `String` | No | `code` |

---

## Enums (13 total)

### course_enums.dart
| Enum | Values |
|---|---|
| `CourseLevel` | FRESHMAN, SOPHOMORE, JUNIOR, SENIOR, GRADUATE, unknown |
| `CourseStatus` | ACTIVE, INACTIVE, ARCHIVED, unknown |
| `SectionStatus` | OPEN, CLOSED, FULL, CANCELLED, unknown |

### schedule_enums.dart
| Enum | Values |
|---|---|
| `ScheduleType` | LECTURE, LAB, TUTORIAL, EXAM, unknown |
| `DayOfWeek` | MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY, unknown |

### assignment_enums.dart
| Enum | Values |
|---|---|
| `AssignmentStatus` | draft, published, closed, archived, unknown |
| `SubmissionType` | file, text, link, multiple, unknown |
| `SubmissionStatus` | submitted, graded, returned, resubmit, unknown |

### lab_enums.dart
| Enum | Values |
|---|---|
| `LabStatus` | draft, published, closed, archived, unknown |
| `LabAttendanceStatus` | present, absent, excused, late, unknown |

### enrollment_enums.dart
| Enum | Values |
|---|---|
| `EnrollmentStatus` | enrolled, waitlisted, dropped, completed, failed, unknown |
| `DropReason` | personal, academic, schedule_conflict, other, unknown |

### Shared enums
| Enum | Values | File |
|---|---|---|
| `MaterialType` | (from existing app) | existing |
| `InstructorRole` | (from existing app) | existing |

---

## Validation Rules

1. **All models** use `factory Model.fromJson(Map<String, dynamic>)` with safe nullable parsing
2. **Decimal fields** always use `double.tryParse(value.toString())`
3. **`isLate` (assignments)**: `(value as num) == 1` → `bool`
4. **`isLate` (labs)**: direct `value == true` (bool)
5. **`allowedFileTypes`**: `jsonDecode(value as String) as List` → `.map((e) => e.toString()).toList()`
6. **`lateSubmissionAllowed`**: `(value as num) == 1` → `bool`
7. **Date fields**: `DateTime.tryParse(value.toString())` with null fallback
8. **Enums**: `EnumType.fromString(string)` with `.unknown` fallback

---

## Entity Relationship Diagram (Text)

```
CourseModel
├── has many → SectionModel
│   ├── has many → ScheduleModel
│   └── belongs to → SemesterModel
├── has many → CoursePrerequisite
├── has many → AssignmentModel
│   ├── has many → AssignmentSubmissionModel
│   │   ├── belongs to → UserInfo
│   │   └── has one → DriveFileModel
│   └── has many → DriveFileModel (instructionFiles)
├── has many → LabModel
│   ├── has many → LabInstructionModel
│   │   └── has one → DriveFileModel
│   ├── has many → LabSubmissionModel
│   │   ├── belongs to → UserInfo
│   │   └── has one → DriveFileModel
│   └── has many → LabAttendanceModel
│   └── has many → DriveFileModel (instructionFiles)
└── belongs to → DepartmentInfo

CourseEnrollmentModel
├── belongs to → CourseModel
├── belongs to → SectionModel
└── belongs to → SemesterModel
```
