# Data Model: Course Detail Drill-down & Material Viewer

## Core Entities

### 1. CourseStructureModel (maps to `LectureSectionLab`)
Represents a structural wrapper dictating where a topic or material sits within a course week.

**Fields**:
- `organizationId` (int)
- `courseId` (int)
- `materialId` (int?): Links to the attached material, if any.
- `material` (CourseMaterialModel?): Nested payload for the actual material context.
- `organizationType` (String): e.g. "lecture", "lab", "section", "tutorial".
- `title` (String)
- `weekNumber` (int)
- `orderIndex` (int)
- `description` (String?)

### 2. CourseMaterialModel (maps to `CourseMaterial`)
Represents the exact item to view or download.

**Fields**:
- `materialId` (int)
- `courseId` (int)
- `fileId` (int?): ID to request file download url.
- `driveFileId` (int?)
- `materialType` (String): e.g. "DOCUMENT", "VIDEO".
- `title` (String)
- `description` (String?)
- `externalUrl` (String?)
- `youtubeVideoId` (String?)
- `isPublished` (bool)
- `viewCount` (int)
- `downloadCount` (int)

## State Transitions
- **Loading State**: Displays skeleton UI matching standard EduVerse styles.
- **Empty State**: Renders "No materials available yet".
- **Error State**: Non-disruptive `SnackBar` / Banner or full error state view mapping the backend's explicit 403 Forbidden constraint if a TA attempts to interact inappropriately.
