# Data Model: Phase 3 — Student Assignments

**Date**: 2026-04-11

---

## Entity: AssignmentModel

**Source file**: `lib/models/assignments/assignment_model.dart` (EXISTS — no changes needed)

The model already contains all backend fields needed for this phase:

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `String` | Backend `id` | Legacy UI-facing ID |
| `assignmentId` | `int` | Backend `id` | Backend contract ID |
| `title` | `String` | Backend `title` | Assignment title |
| `description` | `String?` | Backend `description` | Optional description |
| `courseId` | `int` | Backend `courseId` | FK to course |
| `courseName` | `String` | Backend `course.name` | Display name |
| `courseCode` | `String` | Backend `course.code` | Display code |
| `instructionsText` | `String?` | Backend `instructions` | Markdown-formatted instructions |
| `instructionFiles` | `List<DriveFileModel>?` | Backend `instructionFiles` | Attached Google Drive files |
| `dueDate` | `DateTime` | Backend `dueDate` | Deadline |
| `maxGrade` | `double` | Backend `maxScore` | Maximum possible score |
| `submissionType` | `SubmissionType` | Backend `submissionType` | text/file/link/any |
| `lateSubmissionAllowed` | `bool` | Backend `lateSubmissionAllowed` | Parsed from TINYINT(1) |
| `latePenaltyPercent` | `double` | Backend `latePenaltyPercent` | Penalty percentage |
| `apiStatus` | `AssignmentStatus` | Backend `status` | draft/published/closed/archived |
| `allowedFileTypes` | `List<String>?` | Backend `allowedFileTypes` | Parsed from JSON string |
| `maxFileSizeMb` | `int` | Backend `maxFileSizeMb` | Max upload size |
| `weight` | `double` | Backend `weight` | Grade weight percentage |
| `availableFrom` | `DateTime?` | Backend `availableFrom` | When assignment becomes available |
| `isOverdue` | `bool` | Computed | `dueDate.isBefore(now)` AND not submitted/graded |

### Computed Properties (EXISTING)

| Property | Type | Logic |
|---|---|---|
| `isOverdue` | `bool` | Past due date AND status not submitted/graded/late |
| `daysUntilDue` | `int` | Difference in days from now to due date |
| `isDueToday` | `bool` | Due date matches today's date |
| `grade` | `double?` | Delegates to `submission.grade` |
| `feedback` | `String?` | Delegates to `submission.feedback` |

### Computed Properties (NEEDED FOR THIS PHASE)

| Property | Type | Logic | Purpose |
|---|---|---|---|
| `submissionFilterStatus` | `String` | `"submitted"` if has submission, `"overdue"` if no submission + past due, `"pending"` otherwise | Drives the All/Submitted/Pending/Overdue filter |

**Validation rules**:
- `allowedFileTypes` parsed via `jsonDecode()` from JSON string (already implemented)
- `lateSubmissionAllowed` parsed as `(value as num) == 1` (already implemented)
- `maxGrade` parsed via `double.tryParse(value.toString())` (already implemented)

---

## Entity: AssignmentSubmissionModel

**Source file**: `lib/models/assignments/assignment_submission_model.dart` (EXISTS — no changes needed)

| Field | Type | Source | Notes |
|---|---|---|---|
| `id` | `int` | Backend `id` | Submission ID |
| `assignmentId` | `int` | Backend `assignmentId` | FK to assignment |
| `userId` | `int` | Backend `userId` | FK to student |
| `submissionText` | `String?` | Backend `submissionText` | Text submission content |
| `submissionLink` | `String?` | Backend `submissionLink` | URL submission |
| `driveFile` | `DriveFileModel?` | Backend `driveFile` | Google Drive file |
| `submissionStatus` | `SubmissionStatus` | Backend `submissionStatus` | submitted/graded/returned/resubmit |
| `isLate` | `bool` | Backend `isLate` | Parsed from TINYINT(1) |
| `attemptNumber` | `int` | Backend `attemptNumber` | Resubmission counter |
| `submittedAt` | `DateTime` | Backend `submittedAt` | Submission timestamp |
| `score` | `double?` | Backend `score` | Grade received |
| `feedback` | `String?` | Backend `feedback` | Instructor feedback text |
| `gradedBy` | `int?` | Backend `gradedBy` | Grader user ID |
| `gradedAt` | `DateTime?` | Backend `gradedAt` | Grading timestamp |
| `user` | `UserInfo?` | Backend `user` | Student info |

### Display Computed Values

| Display | Logic |
|---|---|
| Score display | `score != null ? "$score / ${assignment.maxGrade}" : "Not yet graded"` |
| Late indicator | `isLate == true` → show "Late" badge |
| Resubmission allowed | `submissionStatus == SubmissionStatus.graded` → show resubmit button |

---

## Entity: DriveFileModel

**Source file**: `lib/models/core/drive_file_model.dart` (EXISTS — no changes needed)

Used for instruction file attachments and Drive file submissions.

| Field | Type | Source |
|---|---|---|
| `driveFileId` | `String` | Backend `driveFileId` |
| `fileName` | `String` | Backend `fileName` |
| `webViewLink` | `String` | Backend `webViewLink` |
| `downloadUrl` | `String` | Backend `downloadUrl` |
| `fileSize` | `int?` | Backend `fileSize` |
| `mimeType` | `String?` | Backend `mimeType` |

**Preview URL construction**: `https://drive.google.com/file/d/{driveFileId}/preview`

---

## State Transitions

### Assignment Status (Backend → Display)

| Backend `apiStatus` | Student Visibility | Submission Allowed |
|---|---|---|
| `draft` | Hidden | No |
| `published` | Visible | Yes (if not past due, or late allowed) |
| `closed` | Visible | No |
| `archived` | Hidden | No |

### Submission Status Flow

```
(no submission) → submitted → graded → (resubmit allowed?) → submitted (new attempt)
                                        → (resubmit not allowed?) → [final]
```

### Filter Status Derivation

```
For each assignment:
  IF student has submission record → "Submitted"
  ELSE IF dueDate < now → "Overdue"
  ELSE → "Pending"
```

---

## Validation Rules (Client-Side Before Upload)

| Rule | Check | Error Message |
|---|---|---|
| File size | `file.size <= assignment.maxFileSizeMb * 1024 * 1024` | "File exceeds maximum size of {maxFileSizeMb}MB" |
| File type | `file.extension in assignment.allowedFileTypes` (if specified) | "File type not allowed. Allowed: {types}" |
| Past due + no late | `now > dueDate && !lateSubmissionAllowed` | "Submission deadline has passed. Late submissions are not accepted." |
| Past due + late allowed | `now > dueDate && lateSubmissionAllowed` | Show warning: "Late submission accepted. {latePenaltyPercent}% penalty will apply." |
| URL format | `Uri.tryParse(url)?.hasScheme == true` | "Please enter a valid URL" |
