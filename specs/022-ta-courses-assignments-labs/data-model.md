# Data Model: TA — Courses, Assignments & Labs Integration

**Date**: 2026-04-14

## Overview

This phase primarily **reuses existing domain models** from Phase 1 (foundation), Phase 6 (Instructor assignments), and Phase 7 (Instructor labs). No new entity types are introduced. The key data modeling work is:

1. Adding one new entity: **Section** (for section-scoped TA access)
2. Replacing 12 local mock model classes in TA screens with canonical models
3. Confirming existing model compatibility with TA use cases

## Existing Models (Reused, No Changes Required)

### LabModel
**File**: `lib/models/labs/lab_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Primary key |
| `labId` | `int?` | Backend compat |
| `courseId` | `int` | FK to courses |
| `title` | `String` | Required |
| `description` | `String?` | Optional |
| `labNumber` | `int?` | Sequential number |
| `dueDate` | `DateTime?` | Due date |
| `availableFrom` | `DateTime?` | Available from date |
| `maxScore` | `double` | Max possible score |
| `weight` | `double` | Weight in final grade |
| `status` | `LabStatus` | draft/published/closed/archived |
| `createdBy` | `int?` | Creator user ID |
| `course` | `CourseInfo?` | Joined course info |
| `instructions` | `List<LabInstructionModel>` | Lab instructions |
| `instructionFiles` | `List<DriveFileModel>` | Attached Google Drive files |

**TA Compatibility**: ✅ Fully compatible. Per constitution v6.0.0, TA can create/edit labs for their assigned sections using this model with the same form fields as Instructor. When a TA deletes a lab, the frontend must first check whether submissions exist (via `LabModel.submissionsCount` or from the loaded `LabSubmissionModel[]` list) and show an enhanced data-loss warning dialog if submissions are present.

---

### LabSubmissionModel
**File**: `lib/models/labs/lab_submission_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `labId` | `int` | FK to labs |
| `userId` | `int` | Student user ID |
| `user` | `UserInfo?` | Joined student info |
| `submissionText` | `String?` | Text submission content |
| `fileId` | `int?` | FK to files |
| `driveFile` | `DriveFileModel?` | Google Drive file |
| `submissionStatus` | `SubmissionStatus` | submitted/graded/returned/resubmit |
| `isLate` | `bool` | **Boolean** (differs from AssignmentSubmissionModel) |
| `submittedAt` | `DateTime` | Submission timestamp |
| `score` | `double?` | Graded score |
| `feedback` | `String?` | Grader feedback |
| `gradedBy` | `int?` | Grader user ID |
| `gradedAt` | `DateTime?` | Grading timestamp |
| `latePenaltyPercent` | `double?` | Late penalty percentage |

**TA Compatibility**: ✅ Fully compatible. TA grades using the same model as Instructor. `isLate` is `bool` (correct per lab backend).

---

### AssignmentModel
**File**: `lib/models/assignments/assignment_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Primary key |
| `assignmentId` | `int?` | Backend compat |
| `courseId` | `int` | FK to courses |
| `title` | `String` | Required |
| `description` | `String?` | Optional |
| `instructions` | `String?` | Markdown instructions |
| `dueDate` | `DateTime?` | Due date |
| `availableFrom` | `DateTime?` | Available from |
| `maxScore` | `double` | Max score |
| `weight` | `double` | Weight % |
| `submissionType` | `SubmissionType` | text/file/link/any |
| `maxFileSizeMb` | `double?` | Max file size |
| `allowedFileTypes` | `List<String>?` | Parsed from JSON string |
| `latePenaltyPercent` | `double?` | Late penalty % |
| `status` | `AssignmentStatus` | draft/published/closed/archived |
| `course` | `CourseInfo?` | Joined course info |
| `instructionFiles` | `List<DriveFileModel>` | Attached instruction files |

**TA Compatibility**: ✅ Fully compatible. Note: this file also has UI-specific enums (`AssignmentStatus.pending/submitted/graded/late/overdue`) that differ from the backend `AssignmentStatus` enum. The backend enum (draft/published/closed/archived) is in `lib/models/core/enums/assignment_enums.dart`. Ensure TA creation form uses the backend enum.

---

### AssignmentSubmissionModel
**File**: `lib/models/assignments/assignment_submission_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `assignmentId` | `int` | FK to assignments |
| `userId` | `int` | Student user ID |
| `user` | `UserInfo?` | Joined student info |
| `submissionText` | `String?` | Text content |
| `submissionLink` | `String?` | Link submission |
| `fileId` | `int?` | FK to files |
| `driveFile` | `DriveFileModel?` | Google Drive file |
| `submissionStatus` | `SubmissionStatus` | submitted/graded/returned/resubmit |
| `isLate` | `bool` | **Parsed from int 0/1** via `_parseBoolFromIntLike()` |
| `attemptNumber` | `int` | Attempt count |
| `submittedAt` | `DateTime` | Submission timestamp |
| `score` | `double?` | Graded score |
| `feedback` | `String?` | Grader feedback |
| `gradedBy` | `int?` | Grader user ID |
| `gradedAt` | `DateTime?` | Grading timestamp |

**TA Compatibility**: ✅ Fully compatible. `isLate` is correctly parsed from backend int (0/1) to bool.

---

### LabAttendanceModel
**File**: `lib/models/core/lab_attendance_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `labId` | `int` | FK to labs |
| `userId` | `int` | Student user ID |
| `user` | `UserInfo?` | Joined student info |
| `attendanceStatus` | `LabAttendanceStatus` | present/absent/excused/late |
| `checkInTime` | `DateTime?` | Check-in timestamp |
| `notes` | `String?` | Attendance notes |
| `markedBy` | `int?` | User who marked attendance |
| `createdAt` | `DateTime?` | Record creation time |

**TA Compatibility**: ✅ Fully compatible. TA marks attendance using same model as Instructor.

---

### DriveFileModel
**File**: `lib/models/core/drive_file_model.dart`

| Field | Type | Notes |
|---|---|---|
| `driveFileId` | `int` | Internal drive record ID |
| `driveId` | `String` | Google Drive file ID |
| `fileName` | `String` | File name |
| `webViewLink` | `String` | Google Drive view URL |
| `webContentLink` | `String` | Download URL |
| `iframeUrl` | `String` | Embed/preview URL |
| `entityType` | `String?` | Type tag (assignment_instruction, lab_instruction, etc.) |

**TA Compatibility**: ✅ Fully compatible. Used for instruction files, TA materials, and student submissions.

---

### TeachingCourseModel
**File**: `lib/models/instructor/teaching_course_model.dart`

| Field | Type | Notes |
|---|---|---|
| `sectionId` | `int` | Section ID (primary identifier) |
| `courseId` | `int` | Course ID |
| `course` | `CourseModel` | Full course info |
| `section` | `SectionModel` | Section info with capacity, location |
| `semester` | `SemesterModel` | Semester info |
| `instructor` | `UserInfo?` | Instructor info |

**TA Compatibility**: ✅ Returned by `GET /enrollments/teaching`. TA uses this to see assigned courses. Section-scoped access is inherent — the backend returns only sections the TA is assigned to.

---

### CourseModel
**File**: `lib/models/core/course_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `code` | `String` | Course code (e.g., CS101) |
| `courseName` / `name` | `String` | Course name |
| `department` | `String` | Department name |
| `credits` | `int` | Credit hours |
| `level` | `CourseLevel` | FRESHMAN/SOPHOMORE/JUNIOR/SENIOR/GRADUATE |
| `status` | `CourseStatus` | ACTIVE/INACTIVE/ARCHIVED |
| `instructorId` | `int?` | Assigned instructor |
| `taIds` | `List<int>?` | Assigned TA user IDs |

**TA Compatibility**: ✅ Compatible. Course info displayed in TA course list/detail.

---

### SectionModel
**File**: `lib/models/core/section_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `courseId` | `int` | FK to courses |
| `semesterId` | `int` | FK to semesters |
| `sectionNumber` | `String` | Section number |
| `maxCapacity` | `int` | Maximum students |
| `currentEnrollment` | `int` | Currently enrolled count |
| `location` | `String?` | Room/location |
| `status` | `SectionStatus` | OPEN/CLOSED/FULL/CANCELLED |
| `course` | `CourseInfo?` | Joined course info |
| `semester` | `SemesterInfo?` | Joined semester info |
| `schedules` | `List<ScheduleModel>` | Section schedules |

**TA Compatibility**: ✅ NEW entity for Phase 8 (previously existed but not documented). Represents the section-level scope for TA access.

---

### ScheduleModel
**File**: `lib/models/core/schedule_model.dart`

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Primary key |
| `sectionId` | `int` | FK to sections |
| `dayOfWeek` | `DayOfWeek` | MONDAY-SUNDAY |
| `startTime` | `String` | HH:mm format |
| `endTime` | `String` | HH:mm format |
| `room` | `String?` | Room number |
| `building` | `String?` | Building name |
| `scheduleType` | `ScheduleType` | LECTURE/LAB/TUTORIAL/EXAM |

**TA Compatibility**: ✅ Used for displaying section schedules in TA course detail.

---

## Local Model Classes to Replace

These mock/local model classes exist in TA screen files and must be replaced with canonical models:

| Local Model | File | Replacement |
|---|---|---|
| `TALabListItem` | `ta_labs_list_screen.dart` | `LabModel` |
| `TACourseWithLabs` | `ta_labs_list_screen.dart` | Derived from `TeachingCourseModel` + `LabModel[]` |
| `TALabDetail` | `ta_lab_detail_screen.dart` | `LabModel` + `LabSubmissionModel[]` |
| `TALabSubmission` | `ta_lab_submissions_tab.dart` | `LabSubmissionModel` |
| `TASubmissionStatus` enum | `ta_lab_submissions_tab.dart` | `SubmissionStatus` enum |
| `TALabSession` | `ta_lab_attendance_tab.dart` | Derived from `LabAttendanceModel` |
| `TALabStudent` | `ta_lab_attendance_tab.dart` | `UserInfo` + attendance record |
| `TAAttendanceStatus` enum | `ta_lab_attendance_tab.dart` | `LabAttendanceStatus` enum |
| `TAGradingTask` | `ta_course_grading_tab.dart` | `AssignmentSubmissionModel` |
| `TALabTaskItem` | `ta_lab_overview_tab.dart` | Removed (replaced by real data) |
| `TALabQuestion` | `ta_lab_overview_tab.dart` | Removed (replaced by real data) |
| `TALabActivityItem` | `ta_lab_overview_tab.dart` | Removed (replaced by real data) |

## Validation Rules

| Entity | Field | Rule |
|---|---|---|
| `LabModel` | `maxScore` | > 0, parsed via `double.tryParse()` |
| `LabModel` | `weight` | >= 0, parsed via `double.tryParse()` |
| `AssignmentModel` | `maxScore` | > 0, parsed via `double.tryParse()` |
| `AssignmentModel` | `allowedFileTypes` | Parsed from JSON string via `jsonDecode()` |
| `LabSubmissionModel` | `score` | 0 to `maxScore`, step 0.5 |
| `AssignmentSubmissionModel` | `score` | 0 to `maxScore`, step 0.5 |
| `LabSubmissionModel` | `isLate` | `bool` (backend returns boolean for labs) |
| `AssignmentSubmissionModel` | `isLate` | Parsed from int (0/1) via `_parseBoolFromIntLike()` |
| `LabAttendanceModel` | `attendanceStatus` | One of: present, absent, excused, late |

## State Transitions

### Assignment Status (TA can transition)
```
draft → published → closed → archived
```
One-way transitions only. TA cannot skip statuses.

### Lab Status (TA can transition)
```
draft → published → closed → archived
```
One-way transitions only.

### Lab Submission Status (TA can set during grading)
```
submitted → graded → returned → resubmit → submitted
```
TA sets status when grading. `graded` creates central gradebook record.

### Lab Attendance Status (TA can set)
```
present, absent, excused, late
```
Independent statuses, no transitions between them.
