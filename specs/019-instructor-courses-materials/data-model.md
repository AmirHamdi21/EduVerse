# Data Model: Phase 5 — Instructor Courses & Materials Management

**Feature**: 019-instructor-courses-materials
**Date**: April 12, 2026

---

## Entity 1: TeachingCourseModel

**Purpose**: Represents a course section the instructor is assigned to teach. Returned by `GET /enrollments/teaching`.

**Source**: Backend `GET /enrollments/teaching` response + website TypeScript `TeachingCourse` interface.

### Fields

| Field | Dart Type | Backend Type | Required | Validation | Notes |
|-------|-----------|-------------|----------|------------|-------|
| `sectionId` | `int` | `bigint` | ✅ | > 0 | Section enrollment record ID |
| `userId` | `int` | `bigint` | ✅ | > 0 | Instructor user ID |
| `courseId` | `int` | `bigint` | ✅ | > 0 | FK to courses |
| `role` | `String` | `enum('instructor')` | ✅ | `'instructor'` | Always 'instructor' for this endpoint |
| `course` | `CourseModel` | object | ✅ | — | Nested course object (code, name, departmentId, credits, level, status) |
| `section` | `SectionModel` | object | ✅ | — | Nested section object (sectionNumber, maxCapacity, currentEnrollment, location, status) |
| `semester` | `SemesterModel` | object | ✅ | — | Nested semester object (name, startDate, endDate) |
| `enrolledCount` | `int` | computed | ✅ | >= 0 | From `section.currentEnrollment` |
| `capacity` | `int` | computed | ✅ | > 0 | From `section.maxCapacity` |
| `averageGrade` | `double?` | `decimal` computed | ❌ | 0.0–100.0 | Parse with `double.tryParse(value.toString())` |
| `attendanceRate` | `double?` | computed | ❌ | 0.0–100.0 | Percentage of students present |

### Relationships
- `course` → `CourseModel` (one-to-one via nested object)
- `section` → `SectionModel` (one-to-one via nested object)
- `semester` → `SemesterModel` (one-to-one via nested object)

### Factory Method
```dart
factory TeachingCourseModel.fromJson(Map<String, dynamic> json) {
  final course = json['course'] != null ? CourseModel.fromJson(json['course']) : null;
  final section = json['section'] != null ? SectionModel.fromJson(json['section']) : null;
  final semester = json['semester'] != null ? SemesterModel.fromJson(json['semester']) : null;
  return TeachingCourseModel(
    sectionId: int.tryParse(json['sectionId']?.toString() ?? '0') ?? 0,
    userId: int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
    courseId: int.tryParse(json['courseId']?.toString() ?? '0') ?? 0,
    role: json['role']?.toString() ?? 'instructor',
    course: course,
    section: section,
    semester: semester,
    enrolledCount: section?.currentEnrollment ?? 0,
    capacity: section?.maxCapacity ?? 0,
    averageGrade: double.tryParse(json['averageGrade']?.toString() ?? ''),
    attendanceRate: double.tryParse(json['attendanceRate']?.toString() ?? ''),
  );
}
```

---

## Entity 2: CourseMaterialModel

**Purpose**: Represents a single learning resource attached to a course.

**Source**: Backend `GET /courses/{id}/materials` response + website `CourseMaterial` interface.

### Fields

| Field | Dart Type | Backend Type | Required | Validation | Notes |
|-------|-----------|-------------|----------|------------|-------|
| `id` | `int` | `bigint` | ✅ | > 0 | Material ID |
| `courseId` | `int` | `bigint` | ✅ | > 0 | FK to courses |
| `title` | `String` | `varchar(255)` | ✅ | Non-empty | Material title |
| `type` | `MaterialType` | `enum` | ✅ | Valid enum value | `lecture`, `slide`, `video`, `reading`, `link`, `document`, `other` |
| `weekNumber` | `int?` | `integer` | ❌ | >= 0 | Week this material belongs to |
| `url` | `String?` | `varchar(500)` | ❌ | Valid URL if present | For link/video types |
| `externalUrl` | `String?` | `varchar(500)` | ❌ | Valid URL | YouTube embed URL for videos |
| `driveFileId` | `String?` | `varchar(100)` | ❌ | — | Google Drive file ID for document types |
| `isPublished` | `bool` | `TINYINT(1)` | ✅ | 0 or 1 | Parse as `(value as num) == 1` |
| `viewCount` | `int` | `integer` | ✅ | >= 0 | Number of student views |
| `downloadCount` | `int` | `integer` | ✅ | >= 0 | Number of downloads |
| `createdAt` | `DateTime` | `timestamp` | ✅ | — | ISO 8601 |
| `updatedAt` | `DateTime` | `timestamp` | ✅ | — | ISO 8601 |
| `structureItem` | `CourseStructureItemModel?` | object | ❌ | — | Associated structure item (week) |

### Parsing Rules
- `isPublished`: Parse as `(json['isPublished'] as num) == 1` (may arrive as 0/1)
- `type`: `MaterialType.values.firstWhere((e) => e.name == json['type'], orElse: () => MaterialType.other)`
- `url`/`externalUrl`: Validate with regex or Uri.parse try-catch

---

## Entity 3: MaterialBundleModel

**Purpose**: Logical grouping of materials sharing a common base title and week number.

**Source**: Ported from website `groupMaterialsIntoBundles()` function.

### Fields

| Field | Dart Type | Required | Notes |
|-------|-----------|----------|-------|
| `baseTitle` | `String` | ✅ | Stripped title (e.g., "Introduction to AI") |
| `weekNumber` | `int?` | ✅ | Week this bundle belongs to |
| `videoMaterial` | `CourseMaterialModel?` | ❌ | Primary video material (type == 'video') |
| `companionMaterials` | `List<CourseMaterialModel>` | ✅ | Companion documents, slides, readings |
| `allMaterials` | `List<CourseMaterialModel>` | computed | video + companions |

### Bundle Detection Algorithm
```dart
List<MaterialBundleModel> groupMaterialsIntoBundles(List<CourseMaterialModel> materials) {
  // 1. Group by weekNumber
  // 2. For each week, strip known suffixes from titles:
  //    - " - Video", " - Slides", " - Notes", " - {originalFilename}"
  // 3. Materials with identical remaining base titles form a bundle
  // 4. First material with type 'video' becomes the videoMaterial
  // 5. Remaining materials become companionMaterials
}
```

### Known Suffixes to Strip
- `" - Video"` (case-insensitive)
- `" - Slides"` (case-insensitive)
- `" - Notes"` (case-insensitive)
- `" - {filenameWithoutExtension}"` — the original filename minus extension from upload

---

## Entity 4: CourseStructureItemModel

**Purpose**: Represents a week or module within a course.

**Source**: Backend `GET /courses/{id}/structure` response.

### Fields

| Field | Dart Type | Backend Type | Required | Validation | Notes |
|-------|-----------|-------------|----------|------------|-------|
| `id` | `int` | `bigint` | ✅ | > 0 | Structure item ID |
| `courseId` | `int` | `bigint` | ✅ | > 0 | FK to courses |
| `title` | `String` | `varchar(255)` | ✅ | Non-empty | e.g., "Week 1: Introduction" |
| `weekNumber` | `int` | `integer` | ✅ | >= 0 | Week number for ordering |
| `sortOrder` | `int` | `integer` | ✅ | >= 0 | Explicit sort order |
| `description` | `String?` | `text` | ❌ | — | Optional description |
| `createdAt` | `DateTime` | `timestamp` | ✅ | — | ISO 8601 |

---

## Entity 5: UploadProgressState

**Purpose**: Tracks upload progress for video and bundle uploads.

**Source**: Phase 5 new model — UI state model for BLoC.

### Fields

| Field | Dart Type | Required | Notes |
|-------|-----------|----------|-------|
| `uploadId` | `String` | ✅ | Unique identifier for this upload |
| `fileName` | `String` | ✅ | Name of file being uploaded |
| `fileSize` | `int` | ✅ | File size in bytes |
| `bytesSent` | `int` | ✅ | Bytes sent so far |
| `totalBytes` | `int` | ✅ | Total file size |
| `status` | `UploadStatus` | ✅ | `queued`, `uploading`, `completed`, `failed` |
| `stepLabel` | `String` | ✅ | e.g., "Uploading video...", "Uploading document 2 of 5" |
| `errorMessage` | `String?` | ❌ | Error message if failed |
| `startedAt` | `DateTime` | ✅ | Upload start time |
| `completedAt` | `DateTime?` | ❌ | Upload completion time |

### Computed Properties
- `progressPercent`: `(bytesSent / totalBytes * 100).clamp(0, 100)`
- `isUploading`: `status == UploadStatus.uploading`
- `isComplete`: `status == UploadStatus.completed`

---

## Entity 6: DeadlineCardModel

**Purpose**: Represents an upcoming deadline (assignment or lab) shown in the course overview.

**Source**: Phase 5 new model — aggregated from assignments and labs APIs.

### Fields

| Field | Dart Type | Required | Notes |
|-------|-----------|----------|-------|
| `id` | `String` | ✅ | Assignment or lab ID |
| `title` | `String` | ✅ | Assignment or lab title |
| `type` | `DeadlineType` | ✅ | `assignment` or `lab` |
| `dueDate` | `DateTime?` | ❌ | Due date (may be null) |
| `status` | `DeadlineStatus` | ✅ | `upcoming`, `dueToday`, `overdue` |
| `courseId` | `int` | ✅ | FK to courses |

### Enums
```dart
enum DeadlineType { assignment, lab }
enum DeadlineStatus { upcoming, dueToday, overdue }
```

---

## Entity 7: EngagementMetricsModel

**Purpose**: Aggregated engagement metrics for course overview.

**Source**: Phase 5 new model — computed from materials + assignments data.

### Fields

| Field | Dart Type | Required | Notes |
|-------|-----------|----------|-------|
| `totalMaterialViews` | `int` | ✅ | Sum of viewCount across all materials |
| `totalMaterialDownloads` | `int` | ✅ | Sum of downloadCount across all materials |
| `assignmentSubmissionRate` | `double` | ✅ | (students who submitted / total enrolled) * 100 |
| `totalSubmissions` | `int` | ✅ | Number of students who submitted at least one assignment |
| `totalEnrolledStudents` | `int` | ✅ | From section.currentEnrollment |

---

## State Transitions

### UploadStatus
```
queued → uploading → completed
                  → failed  (→ retry → uploading → ...)
```

### Material Visibility
```
published ↔ unpublished (toggle at any time)
```

### Course Structure Item
```
Created → Edited → Reordered → Deleted (only if no materials associated, or with warning)
```

## Validation Rules

| Entity | Rule | Enforcement |
|--------|------|-------------|
| CourseMaterial.title | Non-empty, max 255 chars | Client-side + backend |
| CourseMaterial.type | Valid MaterialType enum | Client-side validation |
| CourseStructureItem.title | Non-empty, max 255 chars | Client-side + backend |
| CourseStructureItem.weekNumber | >= 0 | Client-side validation |
| Upload file (document) | Max 50MB, valid extension | Client-side before upload |
| Upload file (image) | Max 10MB, valid extension | Client-side before upload |
| TeachingCourse section | Must have sectionId > 0 | Backend validation |
