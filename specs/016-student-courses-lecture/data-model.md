# Data Model: Student Courses & Lecture Viewer

**Phase**: 1 - Design & Contracts
**Date**: April 10, 2026
**Feature**: Student Courses & Lecture Viewer

## Entities

### 1. Course

**Description**: Represents an enrolled course for a student. Mirrors backend `Course` entity and website TypeScript interface.

**Source**: `GET /enrollments/my-courses` (enrollment service), `GET /api/courses/:id` (course detail)

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `id` | `int` | ✅ | > 0 | `course.id` |
| `code` | `String` | ✅ | 2-10 chars, uppercase alphanumeric | `course.code` |
| `name` | `String` | ✅ | Non-empty | `course.name` |
| `description` | `String?` | ❌ | — | `course.description` |
| `credits` | `int` | ✅ | 1-6 | `course.credits` |
| `level` | `CourseLevel` | ✅ | Enum: FRESHMAN, SOPHOMORE, JUNIOR, SENIOR, GRADUATE | `course.level` |
| `status` | `CourseStatus` | ✅ | Enum: ACTIVE, INACTIVE, ARCHIVED | `course.status` |
| `instructorId` | `int?` | ❌ | > 0 if present | `course.instructorId` |
| `instructorName` | `String?` | ❌ | — | Resolved from user table (backend join) |
| `taIds` | `List<int>` | ❌ | Each > 0 | `course.taIds` |
| `departmentId` | `int` | ✅ | > 0 | `course.departmentId` |
| `departmentName` | `String?` | ❌ | — | `course.department.name` (joined) |
| `departmentCode` | `String?` | ❌ | — | `course.department.code` (joined) |
| `syllabusUrl` | `String?` | ❌ | Valid URL format | `course.syllabusUrl` |
| `createdAt` | `DateTime` | ✅ | ISO 8601 | `course.createdAt` |
| `updatedAt` | `DateTime` | ✅ | ISO 8601 | `course.updatedAt` |

**Relationships**:
- One-to-many with `CourseSection` (sections for this course)
- One-to-many with `CourseStructure` (weekly structure)
- One-to-many with `CourseMaterial` (course materials)
- Many-to-one with `Department` (department info)
- Many-to-one with `User` (instructor)

**State Transitions**: N/A (read-only for student role)

**Validation Rules**:
```dart
factory CourseModel.fromJson(Map<String, dynamic> json) {
  return CourseModel(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    description: json['description'] as String?,
    credits: json['credits'] as int,
    level: CourseLevel.values.firstWhere(
      (e) => e.name == json['level'],
      orElse: () => CourseLevel.FRESHMAN,
    ),
    status: CourseStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => CourseStatus.ACTIVE,
    ),
    instructorId: json['instructorId'] as int?,
    taIds: (json['taIds'] as List<dynamic>?)?.cast<int>() ?? [],
    departmentId: json['departmentId'] as int,
    departmentName: json['department']?['name'] as String?,
    departmentCode: json['department']?['code'] as String?,
    syllabusUrl: json['syllabusUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
```

---

### 2. CourseSection

**Description**: Represents a section of a course (specific time slot/location). Populated from enrollment data.

**Source**: `GET /api/sections/course/:courseId`, included in enrollment response

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `id` | `int` | ✅ | > 0 | `section.id` |
| `courseId` | `int` | ✅ | > 0 | `section.courseId` |
| `sectionNumber` | `String` | ✅ | Non-empty | `section.sectionNumber` |
| `maxCapacity` | `int` | ✅ | > 0 | `section.maxCapacity` |
| `currentEnrollment` | `int` | ✅ | >= 0 | `section.currentEnrollment` |
| `location` | `String?` | ❌ | — | `section.location` |
| `status` | `SectionStatus` | ✅ | Enum: OPEN, CLOSED, FULL, CANCELLED | `section.status` |
| `semesterId` | `int` | ✅ | > 0 | `section.semesterId` |
| `semesterName` | `String?` | ❌ | — | `section.semester.name` (joined) |

**Relationships**:
- Many-to-one with `Course`
- One-to-many with `Schedule` (section schedules)
- Many-to-one with `Semester`

**Validation Rules**:
```dart
factory CourseSectionModel.fromJson(Map<String, dynamic> json) {
  return CourseSectionModel(
    id: json['id'] as int,
    courseId: json['courseId'] as int,
    sectionNumber: json['sectionNumber'] as String,
    maxCapacity: json['maxCapacity'] as int,
    currentEnrollment: json['currentEnrollment'] as int,
    location: json['location'] as String?,
    status: SectionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => SectionStatus.OPEN,
    ),
    semesterId: json['semesterId'] as int,
    semesterName: json['semester']?['name'] as String?,
  );
}
```

---

### 3. Schedule

**Description**: Represents a scheduled session for a course section (day, time, room).

**Source**: `GET /api/schedules/section/:sectionId`, included in section response

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `id` | `int` | ✅ | > 0 | `schedule.id` |
| `sectionId` | `int` | ✅ | > 0 | `schedule.sectionId` |
| `dayOfWeek` | `DayOfWeek` | ✅ | Enum: MONDAY-SUNDAY | `schedule.dayOfWeek` |
| `startTime` | `String` | ✅ | HH:mm format (24-hour) | `schedule.startTime` |
| `endTime` | `String` | ✅ | HH:mm format (24-hour), must be after startTime | `schedule.endTime` |
| `room` | `String?` | ❌ | — | `schedule.room` |
| `building` | `String?` | ❌ | — | `schedule.building` |
| `scheduleType` | `ScheduleType` | ✅ | Enum: LECTURE, LAB, TUTORIAL, EXAM | `schedule.scheduleType` |

**Relationships**:
- Many-to-one with `CourseSection`

**Validation Rules**:
```dart
factory ScheduleModel.fromJson(Map<String, dynamic> json) {
  return ScheduleModel(
    id: json['id'] as int,
    sectionId: json['sectionId'] as int,
    dayOfWeek: DayOfWeek.values.firstWhere(
      (e) => e.name == json['dayOfWeek'],
      orElse: () => DayOfWeek.MONDAY,
    ),
    startTime: json['startTime'] as String, // "09:00"
    endTime: json['endTime'] as String,     // "10:30"
    room: json['room'] as String?,
    building: json['building'] as String?,
    scheduleType: ScheduleType.values.firstWhere(
      (e) => e.name == json['scheduleType'],
      orElse: () => ScheduleType.LECTURE,
    ),
  );
}
```

---

### 4. CourseStructure

**Description**: Organizes course content into weeks with structure items. Retrieved via dedicated structure endpoint.

**Source**: `GET /courses/{id}/structure`

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `courseId` | `int` | ✅ | > 0 | Path parameter |
| `byWeek` | `List<WeekStructure>` | ✅ | Each week has valid structure | `structureResponse.byWeek` |
| `totalWeeks` | `int` | ✅ | >= 0 | `structureResponse.byWeek.length` |
| `lastUpdated` | `DateTime` | ✅ | ISO 8601 | `structureResponse.updatedAt` |

**Relationships**:
- One-to-one with `Course` (each course has one structure)
- One-to-many with `WeekStructure`

**Validation Rules**:
```dart
factory CourseStructureModel.fromJson(Map<String, dynamic> json) {
  final byWeek = (json['byWeek'] as List<dynamic>)
      .map((w) => WeekStructureModel.fromJson(w as Map<String, dynamic>))
      .toList();
  
  return CourseStructureModel(
    courseId: json['courseId'] as int,
    byWeek: byWeek,
    totalWeeks: byWeek.length,
    lastUpdated: DateTime.parse(json['updatedAt'] as String),
  );
}
```

---

### 5. WeekStructure

**Description**: Represents a single week's structure within a course. Contains week metadata and structure items.

**Source**: `structureResponse.byWeek[]`

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `weekNumber` | `int` | ✅ | > 0 | `week.weekNumber` |
| `title` | `String?` | ❌ | — | `week.title` |
| `items` | `List<StructureItem>` | ✅ | — | `week.items` |
| `materialIds` | `List<String>` | ✅ | Each valid UUID or ID | Extracted from items |

**Relationships**:
- Many-to-one with `CourseStructure`
- One-to-many with `StructureItem`
- Indirectly links to `CourseMaterial` via structure items

**Validation Rules**:
```dart
factory WeekStructureModel.fromJson(Map<String, dynamic> json) {
  return WeekStructureModel(
    weekNumber: json['weekNumber'] as int,
    title: json['title'] as String?,
    items: (json['items'] as List<dynamic>)
        .map((i) => StructureItemModel.fromJson(i as Map<String, dynamic>))
        .toList(),
  );
}
```

---

### 6. StructureItem

**Description**: Links a week to specific course materials. Acts as a reference/pointer.

**Source**: `week.items[]`

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `id` | `String` | ✅ | UUID format | `item.id` |
| `materialId` | `int` | ✅ | > 0, references CourseMaterial | `item.materialId` |
| `orderIndex` | `int` | ✅ | >= 0 | `item.orderIndex` |
| `title` | `String` | ✅ | Non-empty | `item.title` |
| `contentType` | `MaterialType` | ✅ | Enum: VIDEO, DOCUMENT, LINK, TEXT | `item.contentType` |

**Relationships**:
- Many-to-one with `WeekStructure`
- One-to-one with `CourseMaterial` (via materialId)

**Validation Rules**:
```dart
factory StructureItemModel.fromJson(Map<String, dynamic> json) {
  return StructureItemModel(
    id: json['id'] as String,
    materialId: json['materialId'] as int,
    orderIndex: json['orderIndex'] as int,
    title: json['title'] as String,
    contentType: MaterialType.values.firstWhere(
      (e) => e.name == json['contentType'],
      orElse: () => MaterialType.DOCUMENT,
    ),
  );
}
```

---

### 7. CourseMaterial

**Description**: Represents individual course materials (videos, documents, links, text). Core entity for material viewing.

**Source**: `GET /courses/{id}/materials`

| Field | Type | Required | Validation | Backend Source |
|---|---|---|---|---|
| `id` | `int` | ✅ | > 0 | `material.id` |
| `courseId` | `int` | ✅ | > 0 | `material.courseId` |
| `type` | `MaterialType` | ✅ | Enum: VIDEO, DOCUMENT, LINK, TEXT | `material.type` |
| `title` | `String` | ✅ | Non-empty | `material.title` |
| `description` | `String?` | ❌ | — | `material.description` |
| `externalUrl` | `String?` | ❌ | Valid URL if present | `material.externalUrl` (YouTube URL for videos) |
| `file` | `DriveFile?` | ❌ | — | `material.file` (Google Drive file for documents) |
| `isPublished` | `bool` | ✅ | — | `material.isPublished` |
| `viewCount` | `int` | ✅ | >= 0 | `material.viewCount` |
| `downloadCount` | `int` | ✅ | >= 0 | `material.downloadCount` |
| `uploadedBy` | `int` | ✅ | > 0 | `material.uploadedBy` |
| `createdAt` | `DateTime` | ✅ | ISO 8601 | `material.createdAt` |
| `updatedAt` | `DateTime` | ✅ | ISO 8601 | `material.updatedAt` |
| `hasBeenViewed` | `bool` | ❌ | Client-side tracking | Local state (not from backend) |

**Relationships**:
- Many-to-one with `Course`
- Indirectly many-to-one with `WeekStructure` via StructureItem
- Can be grouped into `MaterialBundle` via prefix matching

**DriveFile Nested Object**:
```typescript
interface DriveFile {
  driveId: string;        // Google Drive file ID
  fileName: string;       // Original filename
  webViewLink: string;    // Google Drive view URL
  iframeUrl: string;      // Embeddable iframe URL
  downloadUrl: string;    // Direct download URL
  mimeType?: string;      // MIME type (pdf, doc, etc.)
  fileSize?: number;      // File size in bytes
}
```

**Validation Rules**:
```dart
factory CourseMaterialModel.fromJson(Map<String, dynamic> json) {
  return CourseMaterialModel(
    id: json['id'] as int,
    courseId: json['courseId'] as int,
    type: MaterialType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MaterialType.DOCUMENT,
    ),
    title: json['title'] as String,
    description: json['description'] as String?,
    externalUrl: json['externalUrl'] as String?,
    file: json['file'] != null 
        ? DriveFileModel.fromJson(json['file'] as Map<String, dynamic>)
        : null,
    isPublished: json['isPublished'] as bool? ?? true,
    viewCount: json['viewCount'] as int? ?? 0,
    downloadCount: json['downloadCount'] as int? ?? 0,
    uploadedBy: json['uploadedBy'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    hasBeenViewed: false, // Client-side default
  );
}
```

**Helper Methods**:
```dart
// Extract YouTube video ID from externalUrl
String? get youtubeVideoId {
  if (type != MaterialType.VIDEO || externalUrl == null) return null;
  final match = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*').firstMatch(externalUrl!);
  return match?.group(1);
}

// Get YouTube thumbnail URL
String? get thumbnailUrl {
  final videoId = youtubeVideoId;
  if (videoId == null) return null;
  return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
}

// Get Google Drive preview URL
String? get drivePreviewUrl {
  if (file == null) return null;
  return 'https://drive.google.com/file/d/${file!.driveId}/preview';
}
```

---

### 8. MaterialBundle

**Description**: Client-side logical grouping of related materials (video + companion documents). Not a backend entity.

**Source**: Computed client-side from `List<CourseMaterial>` via prefix matching

| Field | Type | Required | Validation | Source |
|---|---|---|---|---|
| `id` | `String` | ✅ | Generated UUID | Client-generated |
| `baseTitle` | `String` | ✅ | Non-empty | Normalized prefix from materials |
| `materials` | `List<CourseMaterial>` | ✅ | 2+ materials | Grouped materials |
| `primaryVideo` | `CourseMaterial?` | ❌ | Type must be VIDEO | First video material in group |
| `companionDocs` | `List<CourseMaterial>` | ✅ | All type DOCUMENT | Non-video materials |
| `totalMaterials` | `int` | ✅ | >= 2 | `materials.length` |

**Relationships**:
- Computed from multiple `CourseMaterial` entities
- Not persisted to backend

**Bundle Detection Algorithm** (Prefix Matching):
```dart
class MaterialBundleModel {
  static String normalizeTitle(String title) {
    // Strip text after first parenthesis, hyphen, or bracket
    final regex = RegExp(r'^[^()\-[\]]+');
    final match = regex.firstMatch(title.trim());
    return match?.group(0)?.trim() ?? title.trim();
  }

  static Map<String, MaterialBundleModel> detectBundles(
    List<CourseMaterialModel> materials,
  ) {
    final groups = <String, List<CourseMaterialModel>>{};
    
    // Group by normalized prefix
    for (final material in materials) {
      final prefix = normalizeTitle(material.title);
      groups.putIfAbsent(prefix, () => []).add(material);
    }
    
    // Only create bundles for groups with 2+ materials
    final bundles = <String, MaterialBundleModel>{};
    groups.forEach((prefix, groupMaterials) {
      if (groupMaterials.length >= 2) {
        bundles[prefix] = MaterialBundleModel.fromMaterials(groupMaterials);
      }
    });
    
    return bundles;
  }

  factory MaterialBundleModel.fromMaterials(List<CourseMaterialModel> materials) {
    final videos = materials.where((m) => m.type == MaterialType.VIDEO).toList();
    final docs = materials.where((m) => m.type != MaterialType.VIDEO).toList();
    
    return MaterialBundleModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baseTitle: normalizeTitle(materials.first.title),
      materials: materials,
      primaryVideo: videos.isNotEmpty ? videos.first : null,
      companionDocs: docs,
      totalMaterials: materials.length,
    );
  }
}
```

**Bundle Display Logic**:
- If bundle has primary video: show video player as main preview, list companion docs below
- If bundle has no video (rare): show first document as preview, list others below
- Display bundle count: "{totalMaterials} materials" or "1 video + {docCount} documents"

---

## Enums

### MaterialType
```dart
enum MaterialType {
  VIDEO,    // YouTube video lecture
  DOCUMENT, // Google Drive document (PDF, slides, handout)
  LINK,     // External link (website, resource)
  TEXT,     // Inline text/markdown content
}
```

### CourseLevel
```dart
enum CourseLevel {
  FRESHMAN,
  SOPHOMORE,
  JUNIOR,
  SENIOR,
  GRADUATE,
}
```

### CourseStatus
```dart
enum CourseStatus {
  ACTIVE,
  INACTIVE,
  ARCHIVED,
}
```

### SectionStatus
```dart
enum SectionStatus {
  OPEN,
  CLOSED,
  FULL,
  CANCELLED,
}
```

### DayOfWeek
```dart
enum DayOfWeek {
  MONDAY,
  TUESDAY,
  WEDNESDAY,
  THURSDAY,
  FRIDAY,
  SATURDAY,
  SUNDAY,
}
```

### ScheduleType
```dart
enum ScheduleType {
  LECTURE,
  LAB,
  TUTORIAL,
  EXAM,
}
```

## State Management Models

### CourseListState
```dart
class CourseListState {
  final List<CourseModel> courses;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const CourseListState({
    this.courses = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  CourseListState copyWith({
    List<CourseModel>? courses,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return CourseListState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
```

### CourseDetailState
```dart
class CourseDetailState {
  final CourseModel? course;
  final CourseStructureModel? structure;
  final List<CourseMaterialModel> materials;
  final Map<String, MaterialBundleModel> bundles;
  final int selectedWeekIndex;
  final bool isLoadingStructure;
  final bool isLoadingMaterials;
  final String? error;
  final int selectedTabIndex; // 0=Structure, 1=Materials, 2=Progress

  const CourseDetailState({
    this.course,
    this.structure,
    this.materials = const [],
    this.bundles = const {},
    this.selectedWeekIndex = 0,
    this.isLoadingStructure = false,
    this.isLoadingMaterials = false,
    this.error,
    this.selectedTabIndex = 0,
  });
}
```

### MaterialViewerState
```dart
class MaterialViewerState {
  final CourseMaterialModel? currentMaterial;
  final bool isViewRecorded;
  final bool isLoading;
  final String? error;
  final bool isDownloading;
  final double downloadProgress;
  final String? downloadedFilePath;

  const MaterialViewerState({
    this.currentMaterial,
    this.isViewRecorded = false,
    this.isLoading = false,
    this.error,
    this.isDownloading = false,
    this.downloadProgress = 0.0,
    this.downloadedFilePath,
  });
}
```

## Validation Summary

| Entity | Fields | Relationships | Validation Complexity |
|---|---|---|---|
| Course | 15 fields | → Department, Instructor, TAs, Sections | Medium (enums, nested objects) |
| CourseSection | 9 fields | → Course, Semester, Schedules | Medium (enums) |
| Schedule | 8 fields | → Section | Low (time validation) |
| CourseStructure | 4 fields | → Weeks | Low (list parsing) |
| WeekStructure | 4 fields | → StructureItems | Low |
| StructureItem | 5 fields | → Material | Low (enum parsing) |
| CourseMaterial | 13 fields | → DriveFile (nested) | High (URLs, nested objects, helpers) |
| MaterialBundle | 6 fields | ← Computed from Materials | High (prefix matching algorithm) |

## Next Steps

- Generate API contracts in `/contracts/` directory
- Generate `quickstart.md` for testing setup
- Re-evaluate Constitution Check post-design (all principles remain satisfied)
