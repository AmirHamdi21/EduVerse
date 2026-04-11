# Data Model: Student Labs Integration

**Feature**: 018-student-labs
**Date**: 2026-04-11

---

## Entity: Lab

**File**: `lib/models/labs/lab_model.dart`
**Source**: Backend `GET /labs/{id}` response + website TypeScript `Lab` interface

### Fields

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `id` | `String` | ✅ | Non-empty UUID | Lab identifier |
| `labId` | `int?` | ❌ | — | Backend numeric ID (for compatibility) |
| `courseId` | `int` | ✅ | > 0 | Parent course identifier |
| `title` | `String` | ✅ | Non-empty | Lab title |
| `description` | `String?` | ❌ | — | Lab description |
| `labNumber` | `int?` | ❌ | >= 1 | Sequential lab number |
| `dueDate` | `String?` | ❌ | ISO 8601 | Submission deadline |
| `availableFrom` | `String?` | ❌ | ISO 8601 | When lab becomes available |
| `maxScore` | `double` | ✅ | > 0 | Parsed via `double.tryParse(value.toString())` |
| `weight` | `double` | ❌ | 0-100 | Grade weight percentage |
| `status` | `LabStatus` | ✅ | Enum: draft/published/closed/archived | From `lib/models/core/lab_enums.dart` |
| `createdBy` | `int?` | ❌ | — | Creator user ID |
| `createdAt` | `String?` | ❌ | ISO 8601 | Creation timestamp |
| `updatedAt` | `String?` | ❌ | ISO 8601 | Last update timestamp |
| `course` | `CourseInfo?` | ❌ | — | Nested course object |
| `instructions` | `List<LabInstructionModel>` | ❌ | Ordered by `orderIndex` | Lab instructions (loaded relation) |
| `instructionFiles` | `List<DriveFileModel>` | ❌ | — | Google Drive attachment files |

### Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `isPastDue` | `bool` | `dueDate != null && DateTime.parse(dueDate!).isBefore(DateTime.now())` |
| `isAcceptingSubmissions` | `bool` | `status == LabStatus.published && !isPastDue` (or `isPastDue` but still published = late allowed) |
| `formattedDueDate` | `String?` | Human-readable due date |
| `daysUntilDue` | `int?` | Days remaining until due date (null if past due or no due date) |

### State Transitions

```
draft → published → closed → archived
```
Student only sees labs with status `published`, `closed`, or `archived` (never `draft`).

### Validation Rules
- `maxScore` must be > 0
- `status` must be a valid `LabStatus` enum value (parse with `LabStatus.fromString(json['status'], orElse: LabStatus.unknown)`)
- `courseId` must match an enrolled course for the current student
- `id` must be a valid UUID string

---

## Entity: LabInstruction

**File**: `lib/models/core/lab_instruction_model.dart`
**Source**: Backend `GET /labs/{id}/instructions` response

### Fields

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `id` | `String` | ✅ | Non-empty | Instruction identifier |
| `labId` | `String` | ✅ | Non-empty | Parent lab ID |
| `instructionText` | `String?` | ❌ | — | Markdown-formatted instruction text |
| `fileId` | `int?` | ❌ | — | Legacy file reference (internal DB ID) |
| `file` | `DriveFileModel?` | ❌ | — | Google Drive file (if file-based instruction) |
| `orderIndex` | `int` | ✅ | >= 0 | Display order (ascending) |
| `createdAt` | `String?` | ❌ | ISO 8601 | Creation timestamp |

### Validation Rules
- `orderIndex` determines display order — instructions MUST be sorted ascending
- Either `instructionText` or `file` (or both) should be present
- If `file` is present, `file.iframeUrl` must be valid for WebView preview

---

## Entity: LabSubmission

**File**: `lib/models/labs/lab_submission_model.dart`
**Source**: Backend `GET /labs/{id}/submissions/my` and `POST /labs/{id}/submit` responses

### Fields

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `id` | `String` | ✅ | Non-empty UUID | Submission identifier |
| `labId` | `String` | ✅ | Non-empty | Parent lab ID |
| `userId` | `int?` | ❌ | — | Student user ID |
| `submissionText` | `String?` | ❌ | — | Text submission content |
| `fileId` | `int?` | ❌ | — | Legacy file reference |
| `file` | `Map<String, dynamic>?` | ❌ | — | Legacy file object |
| `driveFile` | `DriveFileModel?` | ❌ | — | Google Drive submitted file |
| `status` | `SubmissionStatus` | ✅ | Enum: submitted/graded/returned/resubmit | Parsed from `submissionStatus` or `status` field |
| `score` | `double?` | ❌ | >= 0 | Parsed via `double.tryParse(value.toString())` |
| `feedback` | `String?` | ❌ | — | Instructor/TA feedback text |
| `gradedBy` | `int?` | ❌ | — | Grader user ID |
| `gradedAt` | `String?` | ❌ | ISO 8601 | Grading timestamp |
| `isLate` | `bool` | ✅ | **Boolean** (NOT number for labs) | Parsed as `value == true` or `value == 1` |
| `submittedAt` | `String` | ✅ | ISO 8601 | Submission timestamp |
| `user` | `UserInfo?` | ❌ | — | Student user info (firstName, lastName, email) |

### Critical Parsing Note

> **[!IMPORTANT]** Unlike assignment submissions where `isLate` arrives as `0`/`1` (number), lab submission `isLate` arrives as `true`/`false` (boolean). The model's `fromJson` factory MUST handle both formats safely:
> ```dart
> isLate: json['isLate'] is bool
>     ? json['isLate'] as bool
>     : (json['isLate'] as num?) == 1,
> ```

### Computed Properties

| Property | Type | Description |
|----------|------|-------------|
| `isGraded` | `bool` | `status == SubmissionStatus.graded` |
| `scoreDisplay` | `String?` | `"${score.toStringAsFixed(1)} / ${maxScore}"` if graded |
| `formattedSubmittedAt` | `String` | Human-readable submission date |

---

## Entity: DriveFile

**File**: `lib/models/core/drive_file_model.dart`
**Source**: Backend file upload responses (Google Drive integration)

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `driveId` | `String` | ✅ | Google Drive file ID |
| `driveFileId` | `int?` | ❌ | Internal DB file ID |
| `fileName` | `String` | ✅ | Original filename |
| `webViewLink` | `String` | ✅ | Google Drive web viewer URL |
| `iframeUrl` | `String` | ✅ | Embeddable preview URL (`https://drive.google.com/file/d/{id}/preview`) |
| `downloadUrl` | `String` | ✅ | Direct download URL |
| `entityType` | `String?` | ❌ | Context: `lab_instruction` or `lab_submission` |

---

## Entity: CourseEnrollment (for validation)

**File**: `lib/models/core/enrollment_model.dart`
**Source**: Backend `GET /enrollments/my-courses` response

### Relevant Fields (for frontend enrollment validation)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `int` | ✅ | Enrollment record ID |
| `userId` | `int` | ✅ | Student user ID |
| `sectionId` | `int` | ✅ | Section ID |
| `status` | `EnrollmentStatus` | ✅ | Enum: enrolled/waitlisted/dropped/completed/failed |
| `course` | `CourseModel?` | ❌ | Nested course object |
| `section` | `SectionModel?` | ❌ | Nested section object |

### Validation Rule (FR-013)
Before allowing lab submission, the frontend MUST verify:
- Student has an enrollment record where `status == EnrollmentStatus.enrolled`
- The enrollment's `course.id` matches the lab's `courseId`

---

## Entity: CourseInfo (nested in Lab)

**File**: `lib/models/labs/lab_model.dart` (nested class)
**Source**: Backend `GET /labs` response with course relation

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `int` | ✅ | Course ID |
| `code` | `String` | ✅ | Course code (e.g., "CS101") |
| `name` | `String` | ✅ | Course name |
| `instructorId` | `int?` | ❌ | Instructor user ID |

---

## Entity: UserInfo (nested in LabSubmission)

**File**: `lib/models/labs/lab_submission_model.dart` (nested class)
**Source**: Backend `GET /labs/{id}/submissions/my` response with user relation

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | `int` | ✅ | User ID |
| `firstName` | `String` | ✅ | First name |
| `lastName` | `String` | ✅ | Last name |
| `email` | `String` | ✅ | Email address |

---

## Enums

### LabStatus (already in `lib/models/core/lab_enums.dart`)

| Value | Description | Student Visibility |
|-------|-------------|-------------------|
| `draft` | Not visible to students | ❌ Hidden |
| `published` | Visible, accepting submissions | ✅ Visible |
| `closed` | No longer accepting submissions | ✅ Visible (read-only) |
| `archived` | Hidden from all views | ⚠️ May appear in history |
| `unknown` | Fallback for unparseable values | ⚠️ Display with warning |

### LabAttendanceStatus (already in `lib/models/core/lab_enums.dart`)

| Value | Description |
|-------|-------------|
| `present` | Student was present |
| `absent` | Student was absent |
| `excused` | Excused absence |
| `late` | Student arrived late |
| `unknown` | Fallback |

### SubmissionStatus (already in `lib/models/labs/lab_submission_model.dart`)

| Value | Description |
|-------|-------------|
| `submitted` | Student has submitted, not yet graded |
| `graded` | Submission has been graded |
| `returned` | Returned to student for review |
| `resubmit` | Student must resubmit |
| `unknown` | Fallback |

### EnrollmentStatus (already in `lib/models/core/enrollment_model.dart`)

| Value | Description |
|-------|-------------|
| `enrolled` | Active enrollment |
| `waitlisted` | On waitlist |
| `dropped` | Course dropped |
| `completed` | Course completed |
| `failed` | Course failed |

---

## Relationships

```
CourseEnrollment (1) ───→ Course (1) ───→ Lab (N)
                                          ├──→ LabInstruction (N) [ordered by orderIndex]
                                          ├──→ DriveFile (N) [instruction files]
                                          └──→ LabSubmission (N) [student's attempts]
                                                ├──→ DriveFile (0..1) [submitted file]
                                                └──→ UserInfo (0..1) [student info]
```

---

## State Machines

### LabsCubit States (existing, modified)

```
Initial → LoadingEnrolledCourses → LoadingLabs → Loaded
                              ↓              ↓
                            Error ←────────┘
```

### LabDetailCubit States (new)

```
Initial → LoadingLab → LoadingInstructions → LoadingSubmissions → Loaded
                    ↓                    ↓                   ↓
                  Error ←──────────────┘                   Submitting → Submitted
                                                             ↓
                                                           Error
```

### LabSubmissionSheet States (new)

```
Idle → TextSubmitting → SubmitSuccess
     → FileSubmitting → SubmitSuccess
     → Error (retry allowed)
```
