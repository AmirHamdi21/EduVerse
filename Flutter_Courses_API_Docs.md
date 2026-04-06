# EduVerse API - Courses & Enrollments Documentation for Flutter

This document provides comprehensive details on the `Courses` and `Enrollments` endpoints. It is formatted to aid your Flutter application integration, containing the expected request shapes, query parameters, response structures, and sample Dart definitions for your state management and models.

---

## 1. General Info & Headers

**Base URL**
- **Local Dev**: `http://localhost:8081` (or `http://10.0.2.2:8081` for Android Emulators)
- **Production**: `<PRODUCTION_URL>`

**Headers**
Many of these endpoints require an active session. Pass the JWT `accessToken` in the header:
```text
Authorization: Bearer <accessToken>
```

---

## 2. General Course Browsing (Public / Discovery)

These endpoints do NOT require an authentication token. They are used for the course catalog.

### 2.1 List All Courses
**Endpoint:** `GET /api/courses`
**Access:** Public
**Description:** Retrieves a paginated list of all courses in the catalog.

**Query Parameters:**
- `departmentId` (int, optional): Filter by department.
- `level` (string, optional): Filter by course level (e.g. "100", "300").
- `status` (string, optional): Filter by status (`active`, `inactive`).
- `search` (string, optional): Search by name or code.
- `page` (int, optional): Default: 1.
- `limit` (int, optional): Default: 20.

**Success Response (HTTP 200)**
```json
{
  "data": [
    {
      "id": 1,
      "code": "CS101",
      "name": "Introduction to Computer Science",
      "credits": 3,
      "level": "100",
      "departmentId": 1,
      "status": "active"
    }
  ],
  "total": 50,
  "page": 1,
  "limit": 20,
  "totalPages": 3
}
```

### 2.2 Get Course Details
**Endpoint:** `GET /api/courses/:id`
**Access:** Public
**Description:** Detailed info for a specific course, including section counts and prerequisites.

**Success Response (HTTP 200)**
```json
{
  "id": 1,
  "code": "CS101",
  "name": "Intro to CS",
  "description": "Basics of OOP...",
  "credits": 3,
  "prerequisitesCount": 0,
  "sectionsCount": 2,
  "status": "active"
}
```

---

## 3. Student Enrollment Flow

These endpoints are specifically designated for students to manage their schedules.

### 3.1 Get Available Courses
**Endpoint:** `GET /api/enrollments/available`
**Access:** Protected (`Bearer Token`, Role: STUDENT)
**Description:** Lists courses that the current student is eligible to enroll in (prerequisites met, sections available).

**Query Parameters:**
- `departmentId` (int)
- `semesterId` (int)
- `search` (string)
- `level` (string)
- `page` (int, default 1)
- `limit` (int, default 20)

**Success Response (HTTP 200)**
*Note: This specific shape is critical for your "Add Course" screen.*
```json
[
  {
    "id": 10,
    "name": "Data Structures",
    "code": "CS201",
    "description": "...",
    "credits": 4,
    "level": "200",
    "departmentId": 1,
    "departmentName": "Computer Science",
    "sections": [
      {
        "id": 5,
        "sectionNumber": "01",
        "maxCapacity": 50,
        "currentEnrollment": 45,
        "availableSeats": 5,
        "location": "Room 204",
        "semesterId": 1,
        "semesterName": "Fall 2026"
      }
    ],
    "prerequisites": [],
    "canEnroll": true,
    "enrollmentStatus": null
  }
]
```

### 3.2 Enroll in a Section
**Endpoint:** `POST /api/enrollments/register`
**Access:** Protected (`Bearer Token`, Role: STUDENT)
**Description:** Enrolls the student in a specific course section.

**Request Body (`EnrollCourseDto`)**
```json
{
  "sectionId": 5 // Required: The ID of the specific section to enroll in
}
```

**Success Response (HTTP 201 Created)**
Returns the full Enrollment Response.
```json
{
  "id": 150,
  "userId": 42,
  "sectionId": 5,
  "status": "enrolled",
  "enrollmentDate": "2026-08-15T10:00:00.000Z"
}
```

**Error Responses:**
- **400 Bad Request**: Prerequisites not met, or a schedule conflict exists.
- **409 Conflict**: Already enrolled in this course.

### 3.3 Get My Enrolled Courses
**Endpoint:** `GET /api/enrollments/my-courses`
**Access:** Protected (`Bearer Token`, Role: STUDENT)
**Description:** Retrieves all active and past enrollments for the student.

**Query Parameters:**
- `semester` (int, optional): Filter by semester ID.

**Success Response (HTTP 200)**
Returns an array of Enrollment objects.
```json
[
  {
    "id": 150,
    "userId": 42,
    "sectionId": 5,
    "status": "enrolled",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2026-08-15T10:00:00.000Z",
    "canDrop": true,
    "dropDeadline": "2026-09-01T23:59:59.000Z",
    "course": {
      "id": 10,
      "name": "Data Structures",
      "code": "CS201",
      "description": "...",
      "credits": 4,
      "level": "200"
    },
    "section": {
      "id": 5,
      "sectionNumber": "01",
      "maxCapacity": 50,
      "currentEnrollment": 46,
      "location": "Room 204"
    },
    "semester": {
      "id": 1,
      "name": "Fall 2026",
      "startDate": "2026-08-20T00:00:00.000Z",
      "endDate": "2026-12-15T00:00:00.000Z"
    }
  }
]
```

### 3.4 Drop Course
**Endpoint:** `DELETE /api/enrollments/:id`
**Access:** Protected (`Bearer Token`, Role: STUDENT or ADMIN)
**Description:** Withdraws from an enrolled course. Uses the `enrollmentId`, NOT the `courseId`.

**Request Shape**
*Note: Endpoint is DELETE, no request body typically needed for simple drops, but dropReason might be an optional body in the backend.*

**Success Response (HTTP 200 / HTTP 204)**
- **400 Bad Request**: The drop deadline for the semester has passed.

---

## 4. Instructor & TA Flow

### 4.1 Get Teaching Courses
**Endpoint:** `GET /api/enrollments/teaching`
**Access:** Protected (`Bearer Token`, Role: INSTRUCTOR, TA)
**Description:** Retrieves sections assigned to the current instructor or teaching assistant (TA).

**Payload Structure (Option C Answer):**
This endpoint returns a **completely different shape** (Option C) from the student's `my-courses`. It does not include student-specific fields like `status`, `grade`, or `dropDeadline`. Instead, it provides a streamlined model mapping the instructor/TA directly to the courses and sections they teach or assist.

**Success Response (HTTP 200)**
```json
[
  {
    "sectionId": 5,
    "courseId": 10,
    "course": {
      "id": 10,
      "name": "Data Structures",
      "code": "CS201",
      "description": "...",
      "credits": 4,
      "level": "200"
    },
    "section": {
      "id": 5,
      "sectionNumber": "01",
      "maxCapacity": 50,
      "currentEnrollment": 46,
      "location": "Room 204"
    },
    "semester": {
      "id": 1,
      "name": "Fall 2026",
      "startDate": "2026-08-20T00:00:00.000Z",
      "endDate": "2026-12-15T00:00:00.000Z"
    }
  }
]
```

### 4.2 Get Section TAs
**Endpoint:** `GET /api/enrollments/sections/:sectionId/tas`
**Access:** Protected (`Bearer Token`, Role: INSTRUCTOR, ADMIN)
**Description:** Returns a detailed list of all Teaching Assistants assigned to a course section. Useful for instructors managing their assigned courses. Note: The Instructor flow uses this to view who is helping teach the course.

**Success Response (HTTP 200)**
```json
[
  {
    "id": 1,
    "sectionId": 10,
    "userId": 7,
    "responsibilities": "Grading assignments",
    "assignedAt": "2026-08-15T10:00:00.000Z",
    "firstName": "Jane",
    "lastName": "Smith",
    "email": "jane.smith@example.com"
  }
]
```

### 4.3 TA Specific Notes for Flutter
- **Reusability**: You can heavily reuse the `TeachingCourseModel` for both Instructor and TA dashboards, as the `/api/enrollments/teaching` endpoint acts as the primary data source for both roles and yields identical structural responses.
- **Permissions Limitation**: TAs generally have view access to the sections they assist with, but unlike Administrators or Instructors, they do not automatically have elevated endpoints for managing enrollments (like dropping other students or viewing the waitlist from this API controller) unless additionally scoped. Keep the TA UI strictly focused on Course views and other authorized tools (e.g., grading, forums).

---

## Flutter & Dart Implementation Tips

### 1. Data Models (Using `freezed`)

Having a unified model for the complex enrollment response handles your main dashboard rendering efficiently:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'enrollment_model.freezed.dart';
part 'enrollment_model.g.dart';

@freezed
class EnrollmentModel with _$EnrollmentModel {
  const factory EnrollmentModel({
    required int id,
    required int userId,
    required int sectionId,
    required String status, // 'enrolled', 'waitlisted', 'dropped', 'completed', 'failed'
    String? grade,
    double? finalScore,
    required DateTime enrollmentDate,
    DateTime? droppedAt,
    DateTime? completedAt,
    @Default(false) bool canDrop,
    DateTime? dropDeadline,
    
    // Nested relationships mapping
    CourseSummaryModel? course,
    SectionSummaryModel? section,
    SemesterSummaryModel? semester,
  }) = _EnrollmentModel;

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) => _$EnrollmentModelFromJson(json);
}

@freezed
class CourseSummaryModel with _$CourseSummaryModel {
  const factory CourseSummaryModel({
    required int id,
    required String name,
    required String code,
    required String description,
    required int credits,
    required String level,
  }) = _CourseSummaryModel;

  factory CourseSummaryModel.fromJson(Map<String, dynamic> json) => _$CourseSummaryModelFromJson(json);
}

@freezed
class SectionSummaryModel with _$SectionSummaryModel {
  const factory SectionSummaryModel({
    required int id,
    required String sectionNumber,
    required int maxCapacity,
    required int currentEnrollment,
    String? location,
  }) = _SectionSummaryModel;

  factory SectionSummaryModel.fromJson(Map<String, dynamic> json) => _$SectionSummaryModelFromJson(json);
}

@freezed
class SemesterSummaryModel with _$SemesterSummaryModel {
  const factory SemesterSummaryModel({
    required int id,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) = _SemesterSummaryModel;

  factory SemesterSummaryModel.fromJson(Map<String, dynamic> json) => _$SemesterSummaryModelFromJson(json);
}

@freezed
class TeachingCourseModel with _$TeachingCourseModel {
  const factory TeachingCourseModel({
    required int sectionId,
    required int courseId,
    required CourseSummaryModel course,
    required SectionSummaryModel section,
    required SemesterSummaryModel semester,
  }) = _TeachingCourseModel;

  factory TeachingCourseModel.fromJson(Map<String, dynamic> json) => _$TeachingCourseModelFromJson(json);
}

@freezed
class TAAssignmentModel with _$TAAssignmentModel {
  const factory TAAssignmentModel({
    required int id,
    required int sectionId,
    required int userId,
    String? responsibilities,
    required DateTime assignedAt,
    required String firstName,
    required String lastName,
    required String email,
  }) = _TAAssignmentModel;

  factory TAAssignmentModel.fromJson(Map<String, dynamic> json) => _$TAAssignmentModelFromJson(json);
}
```

### 2. Available Courses Data Flow (Search Screen)

When rendering the "Browse Courses" view, map to the `AvailableCoursesDto` structure:

```dart
@freezed
class AvailableCourseModel with _$AvailableCourseModel {
  const factory AvailableCourseModel({
    required int id,
    required String name,
    required String code,
    required String description,
    required int credits,
    required String level,
    required int departmentId,
    required String departmentName,
    @Default([]) List<AvailableSectionModel> sections,
    required bool canEnroll,
    String? enrollmentStatus,
  }) = _AvailableCourseModel;

  factory AvailableCourseModel.fromJson(Map<String, dynamic> json) => _$AvailableCourseModelFromJson(json);
}

@freezed
class AvailableSectionModel with _$AvailableSectionModel {
  const factory AvailableSectionModel({
    required int id,
    required String sectionNumber,
    required int maxCapacity,
    required int currentEnrollment,
    required int availableSeats,
    String? location,
    required int semesterId,
    required String semesterName,
  }) = _AvailableSectionModel;

  factory AvailableSectionModel.fromJson(Map<String, dynamic> json) => _$AvailableSectionModelFromJson(json);
}
```

### 3. API Service (using `Dio`)
Example API calls using Dio:
```dart
class EnrollmentApi {
  final Dio _dio;
  
  EnrollmentApi(this._dio);

  Future<List<EnrollmentModel>> getMyCourses({int? semesterId}) async {
    final response = await _dio.get('/api/enrollments/my-courses', queryParameters: {
      if (semesterId != null) 'semester': semesterId,
    });
    
    return (response.data as List).map((json) => EnrollmentModel.fromJson(json)).toList();
  }

  Future<EnrollmentModel> enrollInSection(int sectionId) async {
    final response = await _dio.post('/api/enrollments/register', data: {
      'sectionId': sectionId,
    });
    
    return EnrollmentModel.fromJson(response.data);
  }

  Future<List<TeachingCourseModel>> getTeachingCourses() async {
    final response = await _dio.get('/api/enrollments/teaching');
    return (response.data as List).map((json) => TeachingCourseModel.fromJson(json)).toList();
  }

  Future<List<TAAssignmentModel>> getSectionTAs(int sectionId) async {
    final response = await _dio.get('/api/enrollments/sections/$sectionId/tas');
    return (response.data as List).map((json) => TAAssignmentModel.fromJson(json)).toList();
  }
}
```
