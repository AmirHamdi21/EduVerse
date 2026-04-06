# Interface Contracts (API Mappings)

### HTTP API Endpoints (via `EduVerse_Backend`)

These endpoints dictate the payloads that the new Domain Models and `Dio` clients will parse.

**Base URL**: Inherited from global config (e.g., `ApiService`). We configure it differently based on your running device:

```dart
// Change this to your backend URL
static const String baseUrl = 'http://192.168.1.4:8081/api'; // Android emulator
// For iOS simulator use: 'http://localhost:8081/api'
// For real device use your computer's IP: 'http://192.168.x.x:8081/api'
```

#### Course Endpoints (`lib/services/api/course_service.dart`)
- **GET `/api/courses`** - Fetch all courses.
- **GET `/api/courses/{courseId}`** - Fetch specifics for a course.
- **GET `/api/courses/department/{deptId}`** - Fetch courses in a department.
- **GET `/api/courses/{courseId}/prerequisites`** - Fetch course prerequisites.
- **POST `/api/courses`** - Create a new course (Instructor/Admin).

#### Course Structure Endpoints (`lib/services/api/course_service.dart`)
- **GET `/api/courses/{courseId}/structure`** - Fetch struct items natively.
- **GET `/api/courses/{courseId}/structure/{id}`** - Fetch a specific item.
- **POST `/api/courses/{courseId}/structure`** - Append new structure item.
- **PUT `/api/courses/{courseId}/structure/{id}`** - Update module info.
- **PATCH `/api/courses/{courseId}/structure/reorder`** - Change timeline sequence.
- **DELETE `/api/courses/{courseId}/structure/{id}`** - Remove timeline item.

#### Enrollment Endpoints (`lib/services/api/enrollment_service.dart`)
- **GET `/api/enrollments/my-courses`** - Student's enrolled courses.
- **GET `/api/enrollments/available`** - Catalog of courses to join.
- **GET `/api/enrollments/{enrollmentId}`** - Detail specific enrollment status.
- **GET `/api/enrollments/course/{courseId}/list`** - Instructor view of all enrollments in a course.
- **GET `/api/enrollments/section/{sectionId}/students`** - Students per section.
- **GET `/api/enrollments/section/{sectionId}/waitlist`** - Instructor view of section waitlist.

#### Materials Endpoints (`lib/services/api/material_service.dart`)
- **GET `/api/courses/{courseId}/materials`** - (Query Filters: `?materialType=&weekNumber=&search=`) Search/retrieve standard materials.
- **POST `/api/courses/{courseId}/materials`** - Instructors attach materials.
- **POST `/api/courses/{courseId}/materials/bulk`** - Bulk create items.
- **GET `/api/courses/{courseId}/materials/{mId}`** - Specific item context.
- **PUT `/api/courses/{courseId}/materials/{mId}`** - Edit material texts.
- **PATCH `/api/courses/{courseId}/materials/{mId}/visibility`** - Toggle `isPublished`.
- **POST `/api/courses/{courseId}/materials/{mId}/view`** - Student reads material (Analytics).
- **GET `/api/courses/{courseId}/materials/{mId}/embed`** - Returns `{ "embedUrl": "..." }` for YouTube/media.
- **GET `/api/courses/{courseId}/materials/{mId}/download`** - Native file downloading.
- **DELETE `/api/courses/{courseId}/materials/{mId}`** - Archival.

#### Announcements (`lib/services/api/communication_service.dart`)
- **GET `/api/announcements`** - Fetch board timeline.
- **POST `/api/announcements`** - Instructor broadcasts.
- **GET `/api/announcements/{id}`** - Details for a broadcast.
- **PUT `/api/announcements/{id}`** - Edit broadcast context.
- **PATCH `/api/announcements/{id}/publish`** - Transition state to public.
- **PATCH `/api/announcements/{id}/pin`** - Transition `isPinned`.
- **GET `/api/announcements/{id}/analytics`** - Read receipt stats for Instructors.

#### Assignments (`lib/services/api/communication_service.dart`)
- **GET `/api/assignments`** - Student task lists.
- **GET `/api/assignments/{id}`** - Detail metrics for tasks.
- **POST `/api/assignments`** - New grading block.
- **PATCH `/api/assignments/{id}`** - Amend descriptions.
- **GET `/api/assignments/{id}/submissions/my`** - Student's specific submission state.
- **GET `/api/assignments/{id}/submissions`** - All submissions for Instructor review.

#### Discussions (`lib/services/api/communication_service.dart`)
- **GET `/api/discussions`** - All forums access.
- **POST `/api/discussions`** - Start a thread natively.
- **GET `/api/discussions/{id}`** - Load thread & comments natively.
- **PUT `/api/discussions/{id}`** - Amend OP text.
- **POST `/api/discussions/{id}/reply`** - Participant replies.
- **PATCH `/api/discussions/{id}/pin`** - Stick thread to top.
- **PATCH `/api/discussions/{id}/lock`** - Prevent new replies.
