# Quickstart: Course Detail Drill-down & Material Viewer

This feature implements the backend `/api/courses/{courseId}/structure` endpoint into the EduVerse Flutter application, supporting Students, Instructors, and TAs.

### Setup Instructions
1. Guarantee that the `EduVerse_Backend` node instance is currently running locally.
2. Launch the Flutter App:
   ```bash
   cd d:\Graduation\EduVerse\edu_verse
   flutter run
   ```

### Implementation Checklist
- Read from `CourseStructureModel` and `CourseMaterialModel`.
- Inject the `StructureService` to fetch standard materials grouped natively by week using the predefined `Map<int, List<CourseStructureModel>>` structure.
- Construct the TA "Overview" tab and wire it tightly alongside other Phase 4 refactored TA tabs.
- Ensure the `url_launcher` plugin properly activates when interacting with `externalUrl` elements over external apps.
