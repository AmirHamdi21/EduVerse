# Data Model: Phase 7 — Instructor Labs CRUD & Grading

**Date**: 2026-04-13  
**Feature**: Instructor Labs CRUD & Grading  
**Branch**: `021-instructor-labs`

## Entities

### Lab

Represents a lab assignment for a course. Managed by instructors (and TAs in Phase 8).

**Source**: Backend API `GET /labs/{id}`, Website TypeScript interface `Lab`  
**Existing file**: `lib/models/labs/lab_model.dart` (Phase 1) — needs field additions

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `id` | `String` (UUID) | ✅ | — | Unique lab identifier |
| `courseId` | `String` (UUID) | ✅ | — | FK to course |
| `title` | `String` | ✅ | — | Lab title |
| `description` | `String?` | ❌ | `null` | Lab description (markdown supported) |
| `labNumber` | `int?` | ❌ | `null` | Sequential lab number within course |
| `dueDate` | `String?` (ISO 8601) | ❌ | `null` | Submission due date |
| `availableFrom` | `String?` (ISO 8601) | ❌ | `null` | Date lab becomes visible to students |
| `maxScore` | `double` | ✅ | `100.0` | Maximum possible score (parse with `double.tryParse()`) |
| `weight` | `double` | ❌ | `10.0` | Weight % in final grade |
| `status` | `LabStatus` | ✅ | `draft` | Enum: `draft`, `published`, `closed`, `archived` |
| `createdBy` | `String` | ✅ | — | Creator user ID (auto-set by backend) |
| `allowedFileTypes` | `String?` | ❌ | `null` | **NEW**: Comma-separated allowed file types (e.g., `"pdf,docx,zip"`) |
| `maxFileSizeMb` | `double?` | ❌ | `null` | **NEW**: Maximum file size in MB for student submissions |
| `course` | `CourseSummary?` | ❌ | `null` | Joined course info (id, code, name) |
| `instructions` | `List<LabInstruction>` | ❌ | `[]` | Lab instructions (loaded via `GET /labs/{id}/instructions`) |
| `instructionFiles` | `List<DriveFile>` | ❌ | `[]` | Google Drive files attached as instructions |

**Computed properties**:
- `isPastDue`: `dueDate != null && DateTime.now().isAfter(DateTime.parse(dueDate!))`
- `isAcceptingSubmissions`: `status == LabStatus.published && !isPastDue`

**Validation rules**:
- `title` must be non-empty
- `courseId` must reference a valid course the instructor teaches
- `maxScore` must be > 0
- `weight` must be >= 0
- `allowedFileTypes` (if provided): comma-separated string, parsed to `List<String>` for client-side validation
- `maxFileSizeMb` (if provided): must be > 0

**State transitions**:
```
draft → published → closed → archived
```
(One-way only — cannot reverse)

---

### LabInstruction

Represents a single instruction within a lab. Can be text-based or file-based.

**Source**: Backend API `GET /labs/{id}/instructions`, `POST /labs/{id}/instructions`  
**Existing file**: `lib/models/core/lab_instruction_model.dart` (Phase 1)

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `id` | `String` (UUID) | ✅ | — | Unique instruction identifier |
| `labId` | `String` (UUID) | ✅ | — | FK to lab |
| `instructionText` | `String?` | ❌ | `null` | Markdown text for text-based instructions |
| `fileId` | `int?` | ❌ | `null` | FK to Drive file (if file-based) |
| `file` | `DriveFile?` | ❌ | `null` | Google Drive file reference |
| `orderIndex` | `int` | ✅ | `0` | Sort order (0-indexed, sequential) |
| `createdAt` | `String` (ISO 8601) | ✅ | — | Creation timestamp |

**Relationships**: Belongs to one `Lab`. Optionally references one `DriveFile`.

**Reordering**: `orderIndex` is updated via backend when instructions are reordered (drag-and-drop, index entry, or up/down buttons).

---

### LabSubmission

Represents a student's submission to a lab.

**Source**: Backend API `GET /labs/{id}/submissions`, `PATCH /labs/{labId}/submissions/{subId}/grade`  
**Existing file**: `lib/models/labs/lab_submission_model.dart` (Phase 1) — needs field addition

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `id` | `String` (UUID) | ✅ | — | Unique submission identifier |
| `labId` | `String` (UUID) | ✅ | — | FK to lab |
| `userId` | `int` | ✅ | — | FK to student user |
| `user` | `UserInfo?` | ❌ | `null` | Joined student info (userId, firstName, lastName, email) |
| `submissionText` | `String?` | ❌ | `null` | Text submission content |
| `fileId` | `int?` | ❌ | `null` | FK to uploaded file (legacy) |
| `file` | `FileInfo?` | ❌ | `null` | Legacy file reference |
| `driveFile` | `DriveFile?` | ❌ | `null` | Google Drive file (if Drive submission) |
| `submissionStatus` | `SubmissionStatus` | ✅ | — | Enum: `submitted`, `graded`, `returned`, `resubmit` |
| `score` | `double?` | ❌ | `null` | Score (parse with `double.tryParse()`) |
| `feedback` | `String?` | ❌ | `null` | Instructor feedback text |
| `gradedBy` | `int?` | ❌ | `null` | Grader user ID |
| `gradedAt` | `String?` (ISO 8601) | ❌ | `null` | Grading timestamp |
| `isLate` | `bool` | ✅ | `false` | **Note**: Labs use `bool` (assignments use `int 0/1`) |
| `submittedAt` | `String` (ISO 8601) | ✅ | — | Submission timestamp |
| `latePenaltyPercent` | `double?` | ❌ | `null` | **NEW**: Auto-calculated late penalty percentage (UI-only, not sent to backend) |

**Computed properties**:
- `studentName`: `"${user?.firstName} ${user?.lastName}"`
- `isGraded`: `submissionStatus == SubmissionStatus.graded`
- `latePenaltyDisplay`: `isLate && latePenaltyPercent != null ? "Penalty: ${latePenaltyPercent}%" : null`

**Validation rules** (for grading):
- `score` must be provided when `submissionStatus == graded`
- `score` must be in range `0` to `lab.maxScore`
- `score` step: `0.5` increments

---

### LabAttendance

Represents a student's attendance record for a lab session.

**Source**: Backend API `GET /labs/{id}/attendance`, `POST /labs/{id}/attendance`  
**Existing file**: `lib/models/core/lab_attendance_model.dart` (Phase 1)

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `id` | `String` (UUID) | ✅ | — | Unique attendance record identifier |
| `labId` | `String` (UUID) | ✅ | — | FK to lab |
| `userId` | `int` | ✅ | — | FK to student user |
| `user` | `UserInfo?` | ❌ | `null` | Joined student info |
| `attendanceStatus` | `LabAttendanceStatus` | ✅ | — | Enum: `present`, `absent`, `excused`, `late` |
| `checkInTime` | `String?` (ISO 8601) | ❌ | `null` | Check-in timestamp |
| `notes` | `String?` | ❌ | `null` | Attendance notes |
| `markedBy` | `int?` | ❌ | `null` | User who marked attendance |
| `createdAt` | `String` (ISO 8601) | ✅ | — | Creation timestamp |

---

### DriveFile

Represents a Google Drive file associated with a lab instruction.

**Source**: Backend API upload responses  
**Existing file**: `lib/models/core/drive_file_model.dart` (Phase 1)

| Field | Type | Required | Description |
|---|---|---|---|
| `driveId` | `String` | ✅ | Drive file identifier |
| `driveFileId` | `String?` | ❌ | Alternate Drive file ID |
| `fileName` | `String` | ✅ | Original file name |
| `webViewLink` | `String` | ✅ | Link to open in Drive |
| `iframeUrl` | `String` | ✅ | URL for WebView preview (`/preview` variant) |
| `downloadUrl` | `String` | ✅ | Direct download URL |
| `entityType` | `String` | ✅ | Entity type: `"lab_instruction"`, `"ta_material"` |

---

### Enums

#### LabStatus

**File**: `lib/models/core/enums/lab_enums.dart` (Phase 1)

| Value | Description |
|---|---|
| `draft` | Not visible to students |
| `published` | Visible and accepting submissions |
| `closed` | No longer accepting submissions |
| `archived` | Hidden from all views |

#### SubmissionStatus (shared with assignments)

**File**: `lib/models/core/enums/assignment_enums.dart` (Phase 1)

| Value | Description |
|---|---|
| `submitted` | Student has submitted |
| `graded` | Submission has been graded |
| `returned` | Returned to student for review |
| `resubmit` | Student must resubmit |

#### LabAttendanceStatus

**File**: `lib/models/core/enums/lab_enums.dart` (Phase 1)

| Value | Description |
|---|---|
| `present` | Student was present |
| `absent` | Student was absent |
| `excused` | Excused absence |
| `late` | Student arrived late |

---

## Field Additions Summary (from Clarification Session)

| Entity | Field Added | Reason |
|---|---|---|
| `Lab` | `allowedFileTypes` (String?) | Clarification Q2: Configurable file type restrictions per lab |
| `Lab` | `maxFileSizeMb` (double?) | Clarification Q2: Configurable file size limit per lab |
| `LabSubmission` | `latePenaltyPercent` (double?) | Clarification Q1: Auto-calculated late penalty display (UI-only) |

---

## Relationships Diagram

```
Course (1) ────< Lab (1) ────< LabInstruction (N)
                              └── DriveFile (0..1)
                    │
                    └───< LabSubmission (N) ──── UserInfo (student)
                    │                           └── DriveFile (0..1)
                    │
                    └───< LabAttendance (N) ──── UserInfo (student)
```

---

## Parsing Rules (Constitution Principle III)

| Field | Parser Rule | Reason |
|---|---|---|
| `maxScore`, `weight`, `score` | `double.tryParse(value.toString())` | May arrive as string from DB drivers |
| `isLate` (labs) | Value as `bool` | Labs use boolean (assignments use int 0/1) |
| `allowedFileTypes` | If comma-separated string: `value.split(',')` | Parse to List<String> for validation |
| `allowedFileTypes` (backend JSON) | May arrive as JSON string — use `jsonDecode()` if stringified array | Backend format varies |
| `submissionStatus` | `SubmissionStatus.values.firstWhere((e) => e.name == value, orElse: () => SubmissionStatus.submitted)` | Safe enum parsing |
| `attendanceStatus` | `LabAttendanceStatus.values.firstWhere((e) => e.name == value, orElse: () => LabAttendanceStatus.absent)` | Safe enum parsing |
