# 📖 EduVerse API Documentation — Courses / Assignments / Labs

> **Purpose**: Complete Flutter frontend integration guide.
> **Base URL**: `http://<host>:3001` (default port `3001`)
> **Auth**: Most endpoints require `Authorization: Bearer <JWT>` header.
> **Content-Type**: `application/json` unless otherwise noted (file uploads use `multipart/form-data`).

---

## Table of Contents

1. [Global Information](#1-global-information)
2. [Enums Reference](#2-enums-reference)
3. [Courses Module](#3-courses-module)
4. [Course Sections Module](#4-course-sections-module)
5. [Course Schedules Module](#5-course-schedules-module)
6. [Assignments Module](#6-assignments-module)
7. [Labs Module](#7-labs-module)
8. [Role-Based Access Matrix](#8-role-based-access-matrix)
9. [Error Handling](#9-error-handling)
10. [Flutter Integration Tips](#10-flutter-integration-tips)

---

## 1. Global Information

### 1.1 Authentication

All **authenticated endpoints** require the header:

```
Authorization: Bearer <access_token>
```

The token is obtained from `POST /api/auth/login`.

### 1.2 Roles

| Role Enum Value | Display Name | Description |
|---|---|---|
| `student` | Student | Regular student users |
| `instructor` | Instructor | Faculty members |
| `teaching_assistant` | TA | Teaching assistants |
| `admin` | Admin | Administrative staff |
| `it_admin` | IT Admin | Full system access |
| `department_head` | Department Head | Department leadership |

### 1.3 Pagination Response Shape

All paginated endpoints return:

```json
{
  "data": [ /* array of items */ ],
  "meta": {
    "total": 150,       // integer — total matching records
    "page": 1,          // integer — current page number
    "limit": 20,        // integer — items per page
    "totalPages": 8     // integer — total number of pages
  }
}
```

### 1.4 Validation Rules

The API uses `class-validator` with:
- `whitelist: true` — unknown properties are **stripped**
- `forbidNonWhitelisted: true` — unknown properties cause **400 error**
- `transform: true` — query strings auto-converted to proper types

---

## 2. Enums Reference

### 2.1 Course Enums

#### CourseLevel
| Value | Description |
|---|---|
| `FRESHMAN` | Freshman-level course |
| `SOPHOMORE` | Sophomore-level course |
| `JUNIOR` | Junior-level course |
| `SENIOR` | Senior-level course |
| `GRADUATE` | Graduate-level course |

#### CourseStatus
| Value | Description |
|---|---|
| `ACTIVE` | Course is currently active |
| `INACTIVE` | Course is inactive |
| `ARCHIVED` | Course is archived |

#### SectionStatus
| Value | Description |
|---|---|
| `OPEN` | Section accepting enrollments |
| `CLOSED` | Section manually closed |
| `FULL` | Section at max capacity |
| `CANCELLED` | Section cancelled |

#### ScheduleType
| Value | Description |
|---|---|
| `LECTURE` | Lecture session |
| `LAB` | Laboratory session |
| `TUTORIAL` | Tutorial/recitation session |
| `EXAM` | Examination session |

#### DayOfWeek
| Value |
|---|
| `MONDAY` |
| `TUESDAY` |
| `WEDNESDAY` |
| `THURSDAY` |
| `FRIDAY` |
| `SATURDAY` |
| `SUNDAY` |

### 2.2 Assignment Enums

#### SubmissionType
| Value | Description |
|---|---|
| `file` | File-based submission |
| `text` | Text-based submission |
| `link` | Link/URL submission |
| `multiple` | Combination of types |

#### AssignmentStatus
| Value | Description |
|---|---|
| `draft` | Not visible to students |
| `published` | Visible and accepting submissions |
| `closed` | No longer accepting submissions |
| `archived` | Hidden from all views |

> **Status Transitions**: `draft` → `published` → `closed` → `archived` (one-way only)

#### SubmissionStatus
| Value | Description |
|---|---|
| `submitted` | Student has submitted |
| `graded` | Submission has been graded |
| `returned` | Returned to student for review |
| `resubmit` | Student must resubmit |

### 2.3 Lab Enums

#### LabStatus
| Value | Description |
|---|---|
| `draft` | Not visible to students |
| `published` | Visible and accepting submissions |
| `closed` | No longer accepting submissions |
| `archived` | Hidden from all views |

#### LabSubmissionStatus
| Value | Description |
|---|---|
| `submitted` | Student has submitted |
| `graded` | Submission has been graded |
| `returned` | Returned to student |
| `resubmit` | Student must resubmit |

#### LabAttendanceStatus
| Value | Description |
|---|---|
| `present` | Student was present |
| `absent` | Student was absent |
| `excused` | Excused absence |
| `late` | Student arrived late |

---

## 3. Courses Module

**Base Path**: `/api/courses`

> **Authentication**: Courses listing/viewing endpoints are **public** (no auth required).
> Course creation/update/delete endpoints need authentication and specific roles.

---

### 3.1 List All Courses

```
GET /api/courses
```

**Auth Required**: ❌ No (Public)
**Roles**: All (public endpoint)

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `departmentId` | `integer` | ❌ | — | Filter by department ID |
| `level` | `string` | ❌ | — | Filter by course level enum (e.g. `FRESHMAN`, `GRADUATE`) |
| `status` | `string` | ❌ | — | Filter by `CourseStatus` enum (`ACTIVE`, `INACTIVE`, `ARCHIVED`) |
| `search` | `string` | ❌ | — | Search in course name or code (partial match) |
| `page` | `integer` | ❌ | `1` | Page number (1-indexed) |
| `limit` | `integer` | ❌ | `20` | Items per page (max 100) |

#### Response `200 OK`

```json
{
  "data": [
    {
      "id": 1,                              // number — Course ID (bigint)
      "departmentId": 3,                    // number — FK to departments
      "name": "Introduction to CS",         // string — Course name
      "code": "CS101",                      // string — Unique course code
      "description": "Fundamentals of...",  // string | null — Description
      "credits": 3,                         // number — Credit hours (1-6)
      "level": "FRESHMAN",                  // string — CourseLevel enum
      "syllabusUrl": "https://...",         // string | null — Syllabus URL
      "instructorId": 5,                    // number | null — Assigned instructor
      "taIds": [1, 2],                      // number[] | null — Assigned TA IDs
      "status": "ACTIVE",                   // string — CourseStatus enum
      "createdAt": "2025-01-15T10:00:00Z",  // string (ISO 8601) — Creation timestamp
      "updatedAt": "2025-01-15T10:00:00Z",  // string (ISO 8601) — Last update
      "department": {                        // object — Joined department info
        "id": 3,
        "name": "Computer Science",
        "code": "CS"
      }
    }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "limit": 20,
    "totalPages": 3
  }
}
```

---

### 3.2 Get Courses by Department

```
GET /api/courses/department/:deptId
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `deptId` | `integer` | ✅ | Department ID |

#### Response `200 OK`

Returns an **array** of course objects (same shape as items in `data` array above, including `department` relation).

#### Error Responses

| Status | Description |
|---|---|
| `404` | Department not found |

---

### 3.3 Get Course by ID

```
GET /api/courses/:id
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

#### Response `200 OK`

```json
{
  "id": 1,
  "departmentId": 3,
  "name": "Introduction to CS",
  "code": "CS101",
  "description": "Fundamentals of programming...",
  "credits": 3,
  "level": "FRESHMAN",
  "syllabusUrl": "https://example.com/syllabus.pdf",
  "instructorId": 5,
  "taIds": [1, 2],
  "status": "ACTIVE",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z",
  "department": {
    "id": 3,
    "name": "Computer Science",
    "code": "CS"
  },
  "prerequisites": [],         // CoursePrerequisite[] — loaded relation
  "sections": [],              // CourseSection[] — loaded relation
  "prerequisitesCount": 0,     // number — count of prerequisites
  "sectionsCount": 2           // number — count of active sections
}
```

#### Error Responses

| Status | Description |
|---|---|
| `404` | Course not found |

---

### 3.4 Create Course

```
POST /api/courses
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

#### Request Body (`application/json`)

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `departmentId` | `number` | ✅ | Must exist | Department to assign course to |
| `name` | `string` | ✅ | — | Course name |
| `code` | `string` | ✅ | 2-10 uppercase alphanumeric (`/^[A-Z0-9]{2,10}$/`) | Unique course code |
| `description` | `string` | ✅ | — | Course description |
| `credits` | `integer` | ✅ | 1–6 | Credit hours |
| `level` | `string` | ✅ | `CourseLevel` enum | Course level |
| `syllabusUrl` | `string` | ❌ | Valid URL | Syllabus URL |
| `instructorId` | `number` | ❌ | Must reference valid user | Instructor user ID |
| `taIds` | `number[]` | ❌ | Array of valid user IDs | TA user IDs |

#### Example Request

```json
{
  "departmentId": 1,
  "name": "Introduction to Computer Science",
  "code": "CS101",
  "description": "Fundamentals of programming and computational thinking.",
  "credits": 3,
  "level": "FRESHMAN",
  "syllabusUrl": "https://example.com/syllabus/cs101.pdf",
  "instructorId": 5,
  "taIds": [10, 11]
}
```

#### Response `201 Created`

Returns the created course object (same shape as Get Course by ID, without `prerequisitesCount`/`sectionsCount`).

#### Error Responses

| Status | Description |
|---|---|
| `400` | Invalid input data / validation failure |
| `404` | Department not found |
| `409` | Course code already exists in department |

---

### 3.5 Update Course

```
PATCH /api/courses/:id
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

#### Request Body (`application/json`) — All fields optional

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `name` | `string` | ❌ | — | Updated course name |
| `description` | `string` | ❌ | — | Updated description |
| `credits` | `integer` | ❌ | 1–6 | Updated credit hours |
| `level` | `string` | ❌ | `CourseLevel` enum | Updated course level |
| `syllabusUrl` | `string` | ❌ | — | Updated syllabus URL |
| `status` | `string` | ❌ | `CourseStatus` enum | Change course status |
| `instructorId` | `number` | ❌ | — | Change instructor |
| `taIds` | `number[]` | ❌ | — | Change TAs |

#### Response `200 OK`

Returns the updated course object.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Invalid input data |
| `404` | Course not found |

---

### 3.6 Delete Course (Soft Delete)

```
DELETE /api/courses/:id
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

#### Response `204 No Content`

Empty body.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Cannot delete course with active enrollments |
| `404` | Course not found |

---

### 3.7 Get Course Prerequisites

```
GET /api/courses/:id/prerequisites
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

#### Response `200 OK`

```json
[
  {
    "id": 1,                          // number — Prerequisite record ID
    "courseId": 5,                     // number — The course that has this prerequisite
    "prerequisiteCourseId": 2,         // number — The required prereq course ID
    "isMandatory": true,               // boolean — Whether this prereq is mandatory
    "prerequisiteCourse": {            // object — Joined prerequisite course info
      "id": 2,
      "name": "Programming Basics",
      "code": "CS100",
      "level": "FRESHMAN"
    },
    "createdAt": "2025-01-10T08:00:00Z"   // string (ISO 8601)
  }
]
```

---

### 3.8 Add Prerequisite

```
POST /api/courses/:id/prerequisites
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID to add prerequisite to |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `prerequisiteCourseId` | `number` | ✅ | ID of the prerequisite course |
| `isMandatory` | `boolean` | ✅ | Whether this prerequisite is mandatory |

#### Example Request

```json
{
  "prerequisiteCourseId": 2,
  "isMandatory": true
}
```

#### Response `201 Created`

Returns the created prerequisite record.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Circular dependency detected / Self-prerequisite |
| `404` | Course or prerequisite course not found |
| `409` | Prerequisite already exists |

---

### 3.9 Remove Prerequisite

```
DELETE /api/courses/:id/prerequisites/:prereqId
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |
| `prereqId` | `integer` | ✅ | Prerequisite record ID |

#### Response `204 No Content`

Empty body.

---

## 4. Course Sections Module

**Base Path**: `/api/sections`

---

### 4.1 Get Sections by Course

```
GET /api/sections/course/:courseId
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | `integer` | ✅ | Course ID |

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `semesterId` | `integer` | ❌ | — | Filter by semester |

#### Response `200 OK`

```json
[
  {
    "id": 11,                              // number — Section ID (bigint)
    "courseId": 1,                          // number — FK to courses
    "semesterId": 1,                       // number — FK to semesters
    "sectionNumber": "1",                  // string — Section number
    "maxCapacity": 30,                     // number — Maximum students
    "currentEnrollment": 25,               // number — Currently enrolled
    "location": "Room A101",               // string | null — Room/location
    "status": "OPEN",                      // string — SectionStatus enum
    "createdAt": "2025-01-15T10:00:00Z",
    "updatedAt": "2025-01-15T10:00:00Z",
    "course": {
      "id": 1,
      "name": "Introduction to CS",
      "code": "CS101"
    },
    "semester": {
      "id": 1,
      "name": "Fall 2025",
      "startDate": "2025-09-01",
      "endDate": "2025-12-15"
    },
    "schedules": [
      {
        "id": 1,
        "dayOfWeek": "MONDAY",            // DayOfWeek enum
        "startTime": "09:00",             // string (HH:mm)
        "endTime": "10:30",               // string (HH:mm)
        "room": "A101",                   // string | null
        "building": "Main Building",      // string | null
        "scheduleType": "LECTURE"          // ScheduleType enum
      }
    ]
  }
]
```

---

### 4.2 Get Section by ID

```
GET /api/sections/:id
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Section ID |

#### Response `200 OK`

Same shape as a single item from the array above (includes `course`, `semester`, `schedules` relations).

---

### 4.3 Create Section

```
POST /api/sections
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

#### Request Body

| Field | Type | Required | Default | Constraints | Description |
|---|---|---|---|---|---|
| `courseId` | `number` | ✅ | — | Must exist | Course to create section for |
| `semesterId` | `number` | ✅ | — | Must exist | Semester ID |
| `sectionNumber` | `integer` | ❌ | Auto-generated | >= 1 | Section number |
| `maxCapacity` | `integer` | ✅ | — | >= 1 | Maximum student capacity |
| `currentEnrollment` | `integer` | ❌ | `0` | >= 0 | Current enrollment count |
| `location` | `string` | ❌ | `null` | — | Room/location |

#### Example Request

```json
{
  "courseId": 1,
  "semesterId": 1,
  "maxCapacity": 30,
  "location": "Room A101"
}
```

#### Response `201 Created`

Returns the created section object.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Invalid input data |
| `404` | Course or semester not found |
| `409` | Section number already exists for this course/semester combo |

---

### 4.4 Update Section

```
PATCH /api/sections/:id
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor` (section owner)

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Section ID |

#### Request Body — All fields optional

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `maxCapacity` | `integer` | ❌ | >= 1, cannot be less than current enrollment | Updated max capacity |
| `currentEnrollment` | `integer` | ❌ | >= 0 | Updated enrollment count |
| `location` | `string` | ❌ | — | Updated location |
| `status` | `string` | ❌ | `SectionStatus` enum | Change section status |

#### Response `200 OK`

Returns the updated section object.

---

### 4.5 Update Section Enrollment Count

```
PATCH /api/sections/:id/enrollment
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

> Typically called automatically by the enrollment system.

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Section ID |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `currentEnrollment` | `number` | ✅ | New enrollment count |

#### Response `200 OK`

Returns the updated section object with recalculated status.

---

## 5. Course Schedules Module

**Base Path**: `/api/schedules`

---

### 5.1 Get Schedules by Section

```
GET /api/schedules/section/:sectionId
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `sectionId` | `integer` | ✅ | Section ID |

#### Response `200 OK`

```json
[
  {
    "id": 1,                        // number — Schedule ID
    "sectionId": 11,                // number — FK to sections
    "dayOfWeek": "MONDAY",          // string — DayOfWeek enum
    "startTime": "09:00",           // string — HH:mm format (24-hour)
    "endTime": "10:30",             // string — HH:mm format (24-hour)
    "room": "A101",                 // string | null
    "building": "Main Building",    // string | null
    "scheduleType": "LECTURE",      // string — ScheduleType enum
    "createdAt": "2025-01-15T10:00:00Z"
  }
]
```

---

### 5.2 Get Schedule by ID

```
GET /api/schedules/:id
```

**Auth Required**: ❌ No (Public)
**Roles**: All

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Schedule ID |

#### Response `200 OK`

Returns single schedule object with `section` relation included.

---

### 5.3 Create Schedule

```
POST /api/schedules/section/:sectionId
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `sectionId` | `integer` | ✅ | Section to add schedule to |

#### Request Body

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `dayOfWeek` | `string` | ✅ | `DayOfWeek` enum | Day of week |
| `startTime` | `string` | ✅ | HH:mm format 24-hour (`/^([0-1][0-9]\|2[0-3]):[0-5][0-9]$/`) | Start time |
| `endTime` | `string` | ✅ | HH:mm format (same regex, must be after startTime) | End time |
| `room` | `string` | ❌ | — | Room number/name |
| `building` | `string` | ❌ | — | Building name |
| `scheduleType` | `string` | ✅ | `ScheduleType` enum | Type of session |

#### Example Request

```json
{
  "dayOfWeek": "MONDAY",
  "startTime": "09:00",
  "endTime": "10:30",
  "room": "A101",
  "building": "Main Building",
  "scheduleType": "LECTURE"
}
```

#### Response `201 Created`

Returns the created schedule object.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Invalid time range (end <= start) or schedule conflict detected |
| `404` | Section not found |

---

### 5.4 Delete Schedule

```
DELETE /api/schedules/:id
```

**Auth Required**: ✅ Yes
**Roles**: `admin`, `it_admin`, `instructor`

#### Response `204 No Content`

Empty body.

---

## 6. Assignments Module

**Base Path**: `/api/assignments`

> **All endpoints require JWT authentication** (`@UseGuards(JwtAuthGuard, RolesGuard)`).

---

### 6.1 List Assignments

```
GET /api/assignments
```

**Auth Required**: ✅ Yes
**Roles**: All authenticated users

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `courseId` | `integer` | ❌ | — | Filter by course ID |
| `sectionId` | `integer` | ❌ | — | Filter by section ID |
| `status` | `string` | ❌ | — | Filter by `AssignmentStatus` enum (`draft`, `published`, `closed`, `archived`) |
| `dueBefore` | `string` | ❌ | — | Filter assignments due before this date (ISO 8601) |
| `dueAfter` | `string` | ❌ | — | Filter assignments due after this date (ISO 8601) |
| `search` | `string` | ❌ | — | Search in assignment title (partial match) |
| `page` | `integer` | ❌ | `1` | Page number |
| `limit` | `integer` | ❌ | `10` | Items per page |
| `sortBy` | `string` | ❌ | `createdAt` | Sort field: `dueDate`, `createdAt`, `title` |
| `sortOrder` | `string` | ❌ | `DESC` | Sort order: `ASC` or `DESC` |

#### Response `200 OK`

```json
{
  "data": [
    {
      "id": 3,                                    // number — Assignment ID (bigint)
      "courseId": 1,                               // number — FK to courses
      "title": "Homework 1 - Binary Search",       // string — Assignment title
      "description": "Implement binary search...",  // string | null
      "instructions": "Submit as .zip file...",     // string | null
      "maxScore": 100.00,                           // number (decimal) — Maximum possible score
      "weight": 15.00,                              // number (decimal) — Weight % in final grade
      "dueDate": "2025-06-15T23:59:59Z",           // string | null — Due date (ISO 8601)
      "availableFrom": "2025-06-01T00:00:00Z",     // string | null — Available from date
      "lateSubmissionAllowed": 0,                   // number (0 or 1) — 0=false, 1=true
      "latePenaltyPercent": 10.00,                  // number (decimal) — Late penalty %
      "submissionType": "file",                     // string — SubmissionType enum
      "maxFileSizeMb": 10,                          // number — Max file size in MB
      "allowedFileTypes": "[\"pdf\",\"zip\"]",      // string | null — JSON string of allowed types
      "status": "published",                        // string — AssignmentStatus enum
      "createdBy": 5,                               // number — Creator user ID
      "createdAt": "2025-06-01T08:00:00Z",          // string (ISO 8601)
      "updatedAt": "2025-06-01T08:00:00Z",          // string (ISO 8601)
      "course": {                                    // object — Joined course info
        "id": 1,
        "departmentId": 3,
        "name": "Introduction to CS",
        "code": "CS101",
        "description": "...",
        "credits": 3,
        "level": "FRESHMAN",
        "status": "ACTIVE"
      }
    }
  ],
  "meta": {
    "total": 12,
    "page": 1,
    "limit": 10,
    "totalPages": 2
  }
}
```

---

### 6.2 Get Assignment Details

```
GET /api/assignments/:id
```

**Auth Required**: ✅ Yes
**Roles**: All authenticated users

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Response `200 OK`

```json
{
  "id": 3,
  "courseId": 1,
  "title": "Homework 1 - Binary Search",
  "description": "Implement binary search...",
  "instructions": "Submit as .zip file...",
  "maxScore": 100.00,
  "weight": 15.00,
  "dueDate": "2025-06-15T23:59:59Z",
  "availableFrom": "2025-06-01T00:00:00Z",
  "lateSubmissionAllowed": 0,
  "latePenaltyPercent": 10.00,
  "submissionType": "file",
  "maxFileSizeMb": 10,
  "allowedFileTypes": "[\"pdf\",\"zip\"]",
  "status": "published",
  "createdBy": 5,
  "createdAt": "2025-06-01T08:00:00Z",
  "updatedAt": "2025-06-01T08:00:00Z",
  "course": { /* full course object */ },
  "submissions": [
    {
      "id": 1,                             // number — Submission ID
      "assignmentId": 3,                   // number
      "userId": 57,                        // number — Student user ID
      "submissionText": "My essay...",     // string | null
      "submissionLink": "https://...",     // string | null
      "fileId": 12,                        // number | null — FK to files
      "submissionStatus": "submitted",     // string — SubmissionStatus enum
      "isLate": 0,                         // number (0 or 1)
      "attemptNumber": 1,                  // number — Attempt count
      "submittedAt": "2025-06-10T14:30:00Z",
      "score": null,                       // number | null — Graded score
      "feedback": null,                    // string | null — Grader feedback
      "gradedBy": null,                    // number | null — Grader user ID
      "gradedAt": null,                    // string | null — Grading timestamp
      "user": {
        "user_id": 57,
        "first_name": "John",
        "last_name": "Doe",
        "email": "john@example.com"
      }
    }
  ]
}
```

#### Error Responses

| Status | Description |
|---|---|
| `404` | Assignment not found |

---

### 6.3 Create Assignment

```
POST /api/assignments
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `admin`

#### Request Body

| Field | Type | Required | Default | Constraints | Description |
|---|---|---|---|---|---|
| `courseId` | `number` | ✅ | — | Must exist | Course ID |
| `title` | `string` | ✅ | — | 3-200 chars | Assignment title |
| `description` | `string` | ❌ | `null` | — | Description |
| `instructions` | `string` | ❌ | `null` | — | Detailed instructions |
| `submissionType` | `string` | ❌ | `file` | `SubmissionType` enum | How students submit |
| `maxScore` | `number` | ❌ | `100` | 0-1000 | Maximum score |
| `weight` | `number` | ❌ | `0` | 0-100 | Weight percentage in final grade |
| `dueDate` | `string` | ❌ | `null` | ISO 8601 datetime | Due date |
| `availableFrom` | `string` | ❌ | `null` | ISO 8601 datetime | Available from date |
| `lateSubmissionAllowed` | `boolean` | ❌ | `false` | — | Allow late submissions |
| `latePenaltyPercent` | `number` | ❌ | `0` | 0-100 | Late penalty % |
| `maxFileSizeMb` | `number` | ❌ | `10` | — | Max file size in MB |
| `allowedFileTypes` | `string` | ❌ | `null` | JSON string array | Allowed file extensions |
| `status` | `string` | ❌ | `draft` | `AssignmentStatus` enum | Initial status |

#### Example Request

```json
{
  "courseId": 1,
  "title": "Homework 1 - Binary Search",
  "description": "Implement a binary search tree with insert, delete, and search operations.",
  "instructions": "Submit your code as a single .zip file. Include a README with compilation instructions.",
  "submissionType": "file",
  "maxScore": 100,
  "weight": 15,
  "dueDate": "2025-06-15T23:59:59Z",
  "availableFrom": "2025-06-01T00:00:00Z",
  "lateSubmissionAllowed": true,
  "latePenaltyPercent": 10,
  "maxFileSizeMb": 10,
  "allowedFileTypes": "[\"pdf\",\"docx\",\"zip\"]",
  "status": "draft"
}
```

#### Response `201 Created`

Returns the created assignment with joined `course` relation.

---

### 6.4 Update Assignment

```
PATCH /api/assignments/:id
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Request Body

All fields from `CreateAssignmentDto` are **optional** (uses `PartialType`).

#### Response `200 OK`

Returns the updated assignment object.

---

### 6.5 Delete Assignment (Soft Delete)

```
DELETE /api/assignments/:id
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Response `200 OK`

Empty body (assignment removed).

---

### 6.6 Change Assignment Status

```
PATCH /api/assignments/:id/status
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Request Body

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `status` | `string` | ✅ | Must follow: `draft` -> `published` -> `closed` -> `archived` | New status |

> **WARNING — Transition rules**: Only the next status in the chain is allowed. You cannot skip statuses. E.g., you cannot go from `draft` directly to `closed`.

#### Example Request

```json
{
  "status": "published"
}
```

#### Response `200 OK`

Returns the updated assignment object.

#### Error Responses

| Status | Description |
|---|---|
| `400` | Invalid status transition |
| `404` | Assignment not found |

---

### 6.7 Submit Assignment (Student)

```
POST /api/assignments/:id/submit
```

**Auth Required**: ✅ Yes
**Roles**: `student` only

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `submissionText` | `string` | ❌ | Text content for text submissions |
| `fileId` | `number` | ❌ | File ID from the files module (for file submissions) |
| `submissionLink` | `string` | ❌ | External URL (e.g., GitHub repo link) |

> At least one of `submissionText`, `fileId`, or `submissionLink` should be provided.

#### Example Request

```json
{
  "submissionText": "This is my essay submission about data structures...",
  "submissionLink": "https://github.com/student/project"
}
```

#### Response `201 Created` (via POST)

```json
{
  "id": 15,                               // number — Submission ID
  "assignmentId": 3,                      // number
  "userId": 57,                           // number — From JWT
  "submissionText": "This is my essay...",
  "submissionLink": "https://github.com/student/project",
  "fileId": null,
  "submissionStatus": "submitted",
  "isLate": 0,                            // number — 0=on-time, 1=late
  "attemptNumber": 1,                     // number — Auto-incremented
  "submittedAt": "2025-06-10T14:30:00Z",
  "score": null,
  "feedback": null,
  "gradedBy": null,
  "gradedAt": null
}
```

#### Error Responses

| Status | Description |
|---|---|
| `400` | Student not enrolled in course / Late submission not allowed / Assignment not available yet |
| `404` | Assignment not found |

#### Business Rules
- Assignment must be in `published` status
- If `availableFrom` is set, current time must be after it
- If `dueDate` is set and past, `lateSubmissionAllowed` must be `true` (otherwise 400)
- Auto-marks `isLate = 1` if submitted after `dueDate`
- Auto-increments `attemptNumber`
- Student must be enrolled in the assignment's course

---

### 6.8 Get My Submission (Student)

```
GET /api/assignments/:id/submissions/my
```

**Auth Required**: ✅ Yes
**Roles**: `student` only

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Response `200 OK`

Returns the student's **latest** submission (highest `attemptNumber`):

```json
{
  "id": 15,
  "assignmentId": 3,
  "userId": 57,
  "submissionText": "My submission...",
  "submissionLink": null,
  "fileId": 12,
  "submissionStatus": "graded",
  "isLate": 0,
  "attemptNumber": 2,
  "submittedAt": "2025-06-10T14:30:00Z",
  "score": 85.00,
  "feedback": "Well done! Consider improving error handling.",
  "gradedBy": 5,
  "gradedAt": "2025-06-12T10:00:00Z"
}
```

#### Error Responses

| Status | Description |
|---|---|
| `404` | No submission found for this student/assignment |

---

### 6.9 List All Submissions (Instructor/TA/Admin)

```
GET /api/assignments/:id/submissions
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Response `200 OK`

```json
[
  {
    "id": 15,
    "assignmentId": 3,
    "userId": 57,
    "submissionText": "My submission...",
    "submissionLink": null,
    "fileId": 12,
    "submissionStatus": "submitted",
    "isLate": 0,
    "attemptNumber": 1,
    "submittedAt": "2025-06-10T14:30:00Z",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null,
    "user": {
      "user_id": 57,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com"
    }
  }
]
```

> Returns submissions sorted by `submittedAt` DESC.

---

### 6.10 Grade a Submission

```
PATCH /api/assignments/:id/submissions/:subId/grade
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |
| `subId` | `integer` | ✅ | Submission ID |

#### Request Body

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `score` | `number` | ✅ | >= 0 | Numeric score |
| `feedback` | `string` | ❌ | — | Feedback comments |

#### Example Request

```json
{
  "score": 85,
  "feedback": "Well done! Consider improving the conclusion."
}
```

#### Response `200 OK`

```json
{
  "submissionId": 15,        // number — Graded submission ID
  "score": 85,               // number — Score assigned
  "maxScore": 100,           // number — Assignment max score
  "feedback": "Well done!",  // string | undefined
  "gradeId": 42              // number — Created grade record ID in central gradebook
}
```

> **Side effect**: Also creates a grade record in the central `grades` table with `gradeType = 'assignment'`, `isPublished = true`.

---

### 6.11 Upload Assignment Instruction (Google Drive)

```
POST /api/assignments/:id/instructions/upload
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Content-Type**: `multipart/form-data`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Form Data Fields

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `file` | `binary` | ✅ | PDF, DOCX, etc. | The instruction file |
| `title` | `string` | ❌ | Max 255 chars | Instruction title |
| `orderIndex` | `integer` | ❌ | >= 0, default `0` | Sort order |

#### Response `201 Created`

```json
{
  "assignmentId": 3,
  "driveFile": {
    "driveFileId": 123,           // number — Internal drive file record ID
    "driveId": "1abc...",          // string — Google Drive file ID
    "fileName": "HW1_Instructions_v1.pdf",
    "webViewLink": "https://drive.google.com/file/d/1abc.../view",
    "webContentLink": "https://drive.google.com/uc?id=1abc..."
  }
}
```

---

### 6.12 Upload Assignment Submission (Google Drive — Student)

```
POST /api/assignments/:id/submissions/upload
```

**Auth Required**: ✅ Yes
**Roles**: `student` only
**Content-Type**: `multipart/form-data`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Assignment ID |

#### Form Data Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | `binary` | ✅ | Submission file |
| `submissionText` | `string` | ❌ | Notes/comments |
| `submissionLink` | `string` | ❌ | External link (e.g., GitHub) |

#### Response `201 Created`

```json
{
  "submission": {
    "id": 16,
    "assignmentId": 3,
    "userId": 57,
    "submissionText": "Completed all tasks.",
    "submissionLink": "https://github.com/student/project",
    "fileId": null,
    "submissionStatus": "submitted",
    "isLate": 0,
    "attemptNumber": 1,
    "submittedAt": "2025-06-10T14:30:00Z",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null
  },
  "driveFile": {
    "driveFileId": 124,
    "driveId": "1def...",
    "fileName": "Assignment_3_Submission_20250610.zip",
    "webViewLink": "https://drive.google.com/file/d/1def.../view",
    "webContentLink": "https://drive.google.com/uc?id=1def..."
  },
  "isLate": false                // boolean — Whether submission was late
}
```

#### Business Rules

Same as regular submit (section 6.7): must be published, enrolled, respects late submission rules.

---

## 7. Labs Module

**Base Path**: `/api/labs`

> **All endpoints require JWT authentication** (`@UseGuards(JwtAuthGuard, RolesGuard)`).

---

### 7.1 List Labs

```
GET /api/labs
```

**Auth Required**: ✅ Yes
**Roles**: All authenticated users

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `courseId` | `integer` | ❌ | — | Filter by course ID |
| `status` | `string` | ❌ | — | Filter by `LabStatus` enum (`draft`, `published`, `closed`, `archived`) |
| `page` | `integer` | ❌ | `1` | Page number (>= 1) |
| `limit` | `integer` | ❌ | `20` | Items per page (1-100) |

#### Response `200 OK`

```json
{
  "data": [
    {
      "id": 1,                              // number — Lab ID (bigint)
      "courseId": 1,                         // number — FK to courses
      "title": "Binary Search Lab",          // string — Lab title
      "description": "Implement binary...",  // string | null
      "labNumber": 1,                        // number | null — Lab sequence number
      "dueDate": "2026-04-15T23:59:59Z",    // string | null — Due date (ISO 8601)
      "availableFrom": "2026-04-01T00:00:00Z", // string | null
      "maxScore": 100.00,                    // number (decimal) — Max score
      "weight": 10.00,                       // number (decimal) — Weight in final grade
      "status": "published",                 // string — LabStatus enum
      "createdBy": 5,                        // number — Creator user ID
      "createdAt": "2026-04-01T08:00:00Z",
      "updatedAt": "2026-04-01T08:00:00Z",
      "course": {
        "id": 1,
        "departmentId": 3,
        "name": "Introduction to CS",
        "code": "CS101"
      }
    }
  ],
  "meta": {
    "total": 8,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  }
}
```

---

### 7.2 Get Lab by ID

```
GET /api/labs/:id
```

**Auth Required**: ✅ Yes
**Roles**: All authenticated users

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `200 OK`

```json
{
  "id": 1,
  "courseId": 1,
  "title": "Binary Search Lab",
  "description": "Implement binary search in Python",
  "labNumber": 1,
  "dueDate": "2026-04-15T23:59:59Z",
  "availableFrom": "2026-04-01T00:00:00Z",
  "maxScore": 100.00,
  "weight": 10.00,
  "status": "published",
  "createdBy": 5,
  "createdAt": "2026-04-01T08:00:00Z",
  "updatedAt": "2026-04-01T08:00:00Z",
  "course": { /* course object */ },
  "instructions": [
    {
      "id": 1,                          // number — Instruction ID
      "labId": 1,                       // number
      "fileId": null,                   // number | null — FK to files
      "instructionText": "Step 1: Create a new Python file",  // string | null
      "orderIndex": 1,                  // number — Sort order
      "createdAt": "2026-04-01T08:00:00Z"
    }
  ]
}
```

---

### 7.3 Create Lab

```
POST /api/labs
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Request Body

| Field | Type | Required | Default | Constraints | Description |
|---|---|---|---|---|---|
| `courseId` | `integer` | ✅ | — | Must exist | Course ID |
| `title` | `string` | ✅ | — | — | Lab title |
| `description` | `string` | ❌ | `null` | — | Lab description |
| `labNumber` | `integer` | ❌ | `null` | — | Lab sequence number |
| `dueDate` | `string` | ❌ | `null` | ISO 8601 | Due date |
| `availableFrom` | `string` | ❌ | `null` | ISO 8601 | Available from date |
| `maxScore` | `number` | ❌ | `100` | — | Maximum score |
| `weight` | `number` | ❌ | `0` | — | Weight in final grade |
| `status` | `string` | ❌ | `draft` | `LabStatus` enum | Initial status |

#### Example Request

```json
{
  "courseId": 1,
  "title": "Binary Search Lab",
  "description": "Implement binary search in Python",
  "labNumber": 1,
  "dueDate": "2026-04-15T23:59:59Z",
  "availableFrom": "2026-04-01T00:00:00Z",
  "maxScore": 100,
  "weight": 10,
  "status": "draft"
}
```

#### Response `201 Created`

Returns the created lab object.

---

### 7.4 Update Lab

```
PUT /api/labs/:id
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

> **Note**: This endpoint uses **PUT** (full replacement), but since `UpdateLabDto extends PartialType(CreateLabDto)`, all fields are optional.

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Request Body

All fields from `CreateLabDto` are **optional** (uses `PartialType`).

#### Response `200 OK`

Returns the updated lab object.

---

### 7.5 Delete Lab

```
DELETE /api/labs/:id
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `admin`, `it_admin`

> **Note**: TAs **cannot** delete labs.

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `204 No Content`

Empty body.

---

### 7.6 Change Lab Status

```
PATCH /api/labs/:id/status
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `status` | `string` | ✅ | One of: `draft`, `published`, `closed`, `archived` |

> **Note**: Unlike assignments, lab status changes do **not** enforce strict one-way transitions. Any valid status value can be set.

#### Response `200 OK`

Returns the updated lab object (full Lab entity with relations).

---

### 7.7 Get Lab Instructions

```
GET /api/labs/:id/instructions
```

**Auth Required**: ✅ Yes
**Roles**: All authenticated users

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `200 OK`

```json
[
  {
    "id": 1,                        // number — Instruction ID
    "labId": 1,                     // number — FK to labs
    "fileId": null,                 // number | null — FK to files table
    "instructionText": "Step 1...", // string | null — Markdown text
    "orderIndex": 1,                // number — Sort order (ascending)
    "createdAt": "2026-04-01T08:00:00Z"
  },
  {
    "id": 2,
    "labId": 1,
    "fileId": 5,
    "instructionText": "See attached PDF",
    "orderIndex": 2,
    "createdAt": "2026-04-01T08:05:00Z"
  }
]
```

---

### 7.8 Add Instruction to Lab

```
POST /api/labs/:id/instructions
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Request Body

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `instructionText` | `string` | ❌ | `null` | Instruction content (supports markdown) |
| `fileId` | `integer` | ❌ | `null` | FK to files table for attachment |
| `orderIndex` | `integer` | ❌ | `0` | Sort order |

#### Example Request

```json
{
  "instructionText": "Step 1: Create a new Python file called `binary_search.py`",
  "orderIndex": 1
}
```

#### Response `201 Created`

Returns the created instruction object.

---

### 7.9 Submit Lab Work (Student)

```
POST /api/labs/:id/submit
```

**Auth Required**: ✅ Yes
**Roles**: `student` only

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `submissionText` | `string` | ❌ | Text/code submission content |
| `fileId` | `integer` | ❌ | File ID from files module |

#### Example Request

```json
{
  "submissionText": "def binary_search(arr, target):\n    ...",
  "fileId": 10
}
```

#### Response `201 Created`

```json
{
  "id": 5,                           // number — Submission ID
  "labId": 1,                        // number
  "userId": 57,                      // number — From JWT
  "submissionText": "def binary...",  // string | null
  "fileId": 10,                      // number | null
  "submittedAt": "2026-04-10T14:30:00Z",
  "isLate": false,                   // boolean — Auto-detected
  "status": "submitted",             // string — LabSubmissionStatus
  "score": null,                     // number | null
  "feedback": null,                  // string | null
  "gradedBy": null,                  // number | null
  "gradedAt": null                   // string | null
}
```

#### Business Rules
- Auto-detects late submission based on `lab.dueDate`
- Sets `isLate = true` if current time > dueDate

---

### 7.10 List Lab Submissions (Instructor/TA/Admin)

```
GET /api/labs/:id/submissions
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `200 OK`

```json
[
  {
    "id": 5,
    "labId": 1,
    "userId": 57,
    "submissionText": "My solution...",
    "fileId": 10,
    "submittedAt": "2026-04-10T14:30:00Z",
    "isLate": false,
    "status": "submitted",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null,
    "user": {
      "user_id": 57,
      "first_name": "John",
      "last_name": "Doe",
      "email": "john@example.com"
    },
    "file": {
      "file_id": 10,
      "file_name": "solution.py",
      "file_path": "/uploads/...",
      "mime_type": "text/x-python"
    }
  }
]
```

> Sorted by `submittedAt` DESC.

---

### 7.11 Get My Lab Submission (Student)

```
GET /api/labs/:id/submissions/my
```

**Auth Required**: ✅ Yes
**Roles**: `student` only

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `200 OK`

Returns an **array** of the student's submissions for this lab (may have multiple), sorted by `submittedAt` DESC. Includes `user` and `file` relations.

```json
[
  {
    "id": 5,
    "labId": 1,
    "userId": 57,
    "submissionText": "...",
    "fileId": 10,
    "submittedAt": "2026-04-10T14:30:00Z",
    "isLate": false,
    "status": "graded",
    "score": 90.00,
    "feedback": "Great work!",
    "gradedBy": 5,
    "gradedAt": "2026-04-12T10:00:00Z",
    "user": { /* student info */ },
    "file": { /* file info or null */ }
  }
]
```

> **Note**: Unlike assignments (which returns the latest single submission), labs returns **all** submissions as an array.

---

### 7.12 Grade Lab Submission

```
PATCH /api/labs/:id/submissions/:subId/grade
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |
| `subId` | `integer` | ✅ | Submission ID |

#### Request Body

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `status` | `string` | ✅ | One of: `submitted`, `graded`, `returned`, `resubmit` | Submission status |
| `score` | `number` | ❌ | >= 0 | Score to assign |
| `feedback` | `string` | ❌ | — | Feedback for student |

#### Example Request

```json
{
  "status": "graded",
  "score": 85,
  "feedback": "Good work! Consider optimizing your code for better performance."
}
```

#### Response `200 OK`

Returns the updated submission object with `user`, `file`, and `grader` relations:

```json
{
  "id": 5,
  "labId": 1,
  "userId": 57,
  "submissionText": "...",
  "fileId": 10,
  "submittedAt": "2026-04-10T14:30:00Z",
  "isLate": false,
  "status": "graded",
  "score": 85.00,
  "feedback": "Good work!...",
  "gradedBy": 5,
  "gradedAt": "2026-04-12T10:00:00Z",
  "user": { /* student info */ },
  "file": { /* file info or null */ },
  "grader": {
    "user_id": 5,
    "first_name": "Prof. Smith",
    "last_name": "Smith",
    "email": "smith@example.com"
  }
}
```

> **Side effect**: When `status = 'graded'` and `score` is provided, automatically creates a grade record in the central `grades` table with `gradeType = 'lab'`, `isPublished = true`.

---

### 7.13 Mark Lab Attendance

```
POST /api/labs/:id/attendance
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Request Body

| Field | Type | Required | Description |
|---|---|---|---|
| `userId` | `integer` | ✅ | Student user ID to mark |
| `attendanceStatus` | `string` | ✅ | One of: `present`, `absent`, `excused`, `late` |
| `notes` | `string` | ❌ | Additional notes |

#### Example Request

```json
{
  "userId": 57,
  "attendanceStatus": "present",
  "notes": "Arrived on time"
}
```

#### Response `201 Created`

```json
{
  "id": 10,                          // number — Attendance record ID
  "labId": 1,                        // number
  "userId": 57,                      // number
  "attendanceStatus": "present",     // string — LabAttendanceStatus
  "checkInTime": "2026-04-10T09:00:00Z",  // string | null — Auto-set for present/late
  "notes": "Arrived on time",        // string | null
  "markedBy": 5,                     // number — User who marked (from JWT)
  "createdAt": "2026-04-10T09:00:00Z"
}
```

#### Business Rules
- If a record already exists for this student+lab, it **updates** the existing record
- `checkInTime` is automatically set when status is `present` or `late`

---

### 7.14 Get Lab Attendance

```
GET /api/labs/:id/attendance
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Response `200 OK`

```json
[
  {
    "id": 10,
    "labId": 1,
    "userId": 57,
    "attendanceStatus": "present",
    "checkInTime": "2026-04-10T09:00:00Z",
    "notes": "Arrived on time",
    "markedBy": 5,
    "createdAt": "2026-04-10T09:00:00Z"
  }
]
```

> Sorted by `createdAt` ASC.

---

### 7.15 Upload Lab Instruction (Google Drive)

```
POST /api/labs/:id/instructions/upload
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`
**Content-Type**: `multipart/form-data`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Form Data Fields

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `file` | `binary` | ✅ | PDF, DOCX, etc. | Instruction file |
| `title` | `string` | ❌ | Max 255 chars | Instruction title |
| `orderIndex` | `integer` | ❌ | >= 0, default `0` | Sort order |

#### Response `201 Created`

```json
{
  "instruction": {
    "id": 3,
    "labId": 1,
    "instructionText": "Lab 1 - Getting Started Guide",
    "orderIndex": 1,
    "createdAt": "2026-04-01T08:00:00Z"
  },
  "driveFile": {
    "driveId": "1abc...",
    "fileName": "Lab_1_-_Getting_Started_Guide_v1.pdf",
    "webViewLink": "https://drive.google.com/file/d/1abc.../view",
    "webContentLink": "https://drive.google.com/uc?id=1abc..."
  }
}
```

---

### 7.16 Upload TA Material (Google Drive)

```
POST /api/labs/:id/ta-materials/upload
```

**Auth Required**: ✅ Yes
**Roles**: `instructor`, `teaching_assistant`, `admin`, `it_admin`
**Content-Type**: `multipart/form-data`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Form Data Fields

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `file` | `binary` | ✅ | — | TA material file |
| `title` | `string` | ❌ | Max 255 chars | Material title |
| `materialType` | `string` | ❌ | One of: `answer_key`, `grading_rubric`, `solution`, `notes` | Type of TA material |

#### Response `201 Created`

```json
{
  "driveFile": {
    "driveFileId": 125,
    "driveId": "1ghi...",
    "fileName": "solution_Lab_1_Answer_Key.pdf",
    "webViewLink": "https://drive.google.com/file/d/1ghi.../view",
    "webContentLink": "https://drive.google.com/uc?id=1ghi..."
  }
}
```

---

### 7.17 Upload Lab Submission (Google Drive — Student)

```
POST /api/labs/:id/submissions/upload
```

**Auth Required**: ✅ Yes
**Roles**: `student` only
**Content-Type**: `multipart/form-data`

#### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Lab ID |

#### Form Data Fields

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | `binary` | ✅ | Submission file |
| `submissionText` | `string` | ❌ | Notes/comments |

#### Response `201 Created`

```json
{
  "submission": {
    "id": 6,
    "labId": 1,
    "userId": 57,
    "submissionText": "My implementation uses iterative approach",
    "submittedAt": "2026-04-10T14:30:00Z",
    "isLate": false,
    "status": "submitted",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null
  },
  "driveFile": {
    "driveFileId": 126,
    "driveId": "1jkl...",
    "fileName": "Lab1_Submission_20260410.py",
    "webViewLink": "https://drive.google.com/file/d/1jkl.../view",
    "webContentLink": "https://drive.google.com/uc?id=1jkl..."
  },
  "isLate": false
}
```

#### Business Rules
- If a submission already exists for this student+lab, the existing record is **updated** (not duplicated)
- Auto-detects `isLate` based on `lab.dueDate`

---

## 8. Role-Based Access Matrix

### 8.1 Courses

| Endpoint | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `GET /api/courses` (list) | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `GET /api/courses/:id` (details) | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `GET /api/courses/department/:deptId` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `POST /api/courses` (create) | ❌ | ✅ | ❌ | ✅ | ✅ |
| `PATCH /api/courses/:id` (update) | ❌ | ✅ | ❌ | ✅ | ✅ |
| `DELETE /api/courses/:id` (delete) | ❌ | ❌ | ❌ | ✅ | ✅ |
| `GET /api/courses/:id/prerequisites` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `POST /api/courses/:id/prerequisites` | ❌ | ❌ | ❌ | ✅ | ✅ |
| `DELETE /api/courses/:id/prerequisites/:id` | ❌ | ❌ | ❌ | ✅ | ✅ |

### 8.2 Course Sections

| Endpoint | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `GET /api/sections/course/:courseId` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `GET /api/sections/:id` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `POST /api/sections` (create) | ❌ | ✅ | ❌ | ✅ | ✅ |
| `PATCH /api/sections/:id` (update) | ❌ | ✅ | ❌ | ✅ | ✅ |
| `PATCH /api/sections/:id/enrollment` | ❌ | ✅ | ❌ | ✅ | ✅ |

### 8.3 Course Schedules

| Endpoint | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `GET /api/schedules/section/:sectionId` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `GET /api/schedules/:id` | ✅ Public | ✅ Public | ✅ Public | ✅ Public | ✅ Public |
| `POST /api/schedules/section/:sectionId` | ❌ | ✅ | ❌ | ✅ | ✅ |
| `DELETE /api/schedules/:id` | ❌ | ✅ | ❌ | ✅ | ✅ |

### 8.4 Assignments

| Endpoint | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `GET /api/assignments` (list) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/assignments/:id` (details) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/assignments` (create) | ❌ | ✅ | ❌ | ✅ | ❌ |
| `PATCH /api/assignments/:id` (update) | ❌ | ✅ | ❌ | ✅ | ❌ |
| `DELETE /api/assignments/:id` (delete) | ❌ | ✅ | ❌ | ✅ | ❌ |
| `PATCH /api/assignments/:id/status` | ❌ | ✅ | ❌ | ✅ | ❌ |
| `POST /api/assignments/:id/submit` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `GET /api/assignments/:id/submissions/my` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `GET /api/assignments/:id/submissions` | ❌ | ✅ | ✅ | ✅ | ❌ |
| `PATCH /:id/submissions/:subId/grade` | ❌ | ✅ | ✅ | ❌ | ❌ |
| `POST /:id/instructions/upload` | ❌ | ✅ | ✅ | ✅ | ❌ |
| `POST /:id/submissions/upload` | ✅ | ❌ | ❌ | ❌ | ❌ |

### 8.5 Labs

| Endpoint | Student | Instructor | TA | Admin | IT Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `GET /api/labs` (list) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/labs/:id` (details) | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/labs` (create) | ❌ | ✅ | ✅ | ✅ | ✅ |
| `PUT /api/labs/:id` (update) | ❌ | ✅ | ✅ | ✅ | ✅ |
| `DELETE /api/labs/:id` (delete) | ❌ | ✅ | ❌ | ✅ | ✅ |
| `PATCH /api/labs/:id/status` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/labs/:id/instructions` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/labs/:id/instructions` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/labs/:id/submit` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `GET /api/labs/:id/submissions` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/labs/:id/submissions/my` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `PATCH /:id/submissions/:subId/grade` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/labs/:id/attendance` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/labs/:id/attendance` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `POST /:id/instructions/upload` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `POST /:id/ta-materials/upload` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `POST /:id/submissions/upload` | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 9. Error Handling

### 9.1 Standard Error Response Shape

```json
{
  "statusCode": 404,
  "message": "Assignment not found",
  "error": "Not Found"
}
```

Or for validation errors (`400`):

```json
{
  "statusCode": 400,
  "message": [
    "courseId must be a number",
    "title must be longer than or equal to 3 characters"
  ],
  "error": "Bad Request"
}
```

### 9.2 Common Error Codes

| Status | When |
|---|---|
| `400` | Validation failure, invalid state transition, business rule violation |
| `401` | Missing or invalid JWT token |
| `403` | Insufficient role permissions |
| `404` | Resource not found |
| `409` | Duplicate resource (e.g., course code) |

### 9.3 Business Rule Errors (400)

| Module | Error | Description |
|---|---|---|
| Courses | Course code exists | `CourseCodeAlreadyExistsException` — code+department must be unique |
| Courses | Circular prerequisite | `CircularPrerequisiteDetectedException` — detected via DFS |
| Courses | Delete with sections | `CannotDeleteCourseWithActiveSectionsException` |
| Assignments | Not published | `AssignmentNotPublishedException` — must be `published` to submit |
| Assignments | Not available yet | `AssignmentNotAvailableYetException` — before `availableFrom` |
| Assignments | Deadline passed | `SubmissionDeadlinePassedException` — past `dueDate` and late not allowed |
| Assignments | Not enrolled | Student not enrolled in the course |
| Assignments | Invalid transition | Status transition not allowed (e.g., `draft` to `closed`) |
| Sections | Section full | `SectionFullException` — enrollment exceeds capacity |
| Sections | Capacity reduction | Cannot reduce capacity below current enrollment |
| Schedules | Invalid time | `InvalidTimeRangeException` — end time <= start time |
| Schedules | Conflict | `ScheduleConflictException` — room/time overlap |

---

## 10. Flutter Integration Tips

### 10.1 HTTP Client Setup

```dart
// Base configuration
const baseUrl = 'http://your-server:3001';

// Auth header
final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $accessToken',
};
```

### 10.2 Parsing `lateSubmissionAllowed`

The backend stores this as a MySQL `TINYINT(1)` — it comes back as `0` or `1` (number), not `true`/`false`:

```dart
final isLateAllowed = (assignment['lateSubmissionAllowed'] as num) == 1;
```

### 10.3 Parsing `allowedFileTypes`

This field is a **JSON string** (not an array). Parse it:

```dart
final List<String> fileTypes = assignment['allowedFileTypes'] != null
    ? List<String>.from(jsonDecode(assignment['allowedFileTypes']))
    : [];
```

### 10.4 Decimal Fields

`maxScore`, `weight`, `latePenaltyPercent`, `score` come back as decimal numbers (may be strings from some DB drivers). Always parse:

```dart
final maxScore = double.tryParse(assignment['maxScore'].toString()) ?? 100.0;
```

### 10.5 File Uploads (multipart/form-data)

Use `dio` or `http.MultipartRequest`:

```dart
// Using Dio
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(filePath, filename: fileName),
  'title': 'My submission',
  'submissionText': 'Notes here',
});

final response = await dio.post(
  '$baseUrl/api/assignments/3/submissions/upload',
  data: formData,
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

### 10.6 Pagination Helper

```dart
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
```

### 10.7 Enum Mapping

```dart
enum AssignmentStatus { draft, published, closed, archived }

extension AssignmentStatusExt on AssignmentStatus {
  String get value => name; // 'draft', 'published', etc.

  static AssignmentStatus fromString(String s) =>
    AssignmentStatus.values.firstWhere((e) => e.name == s);
}
```

### 10.8 Date Handling

All dates are ISO 8601 strings. Parse with:

```dart
final dueDate = DateTime.parse(assignment['dueDate']); // UTC
final localDueDate = dueDate.toLocal(); // Convert to local timezone
```

### 10.9 Role-Based UI

```dart
// Show/hide actions based on role
final userRoles = currentUser.roles; // List<String>
final canCreateAssignment = userRoles.any(
  (r) => ['instructor', 'admin'].contains(r),
);
final canSubmit = userRoles.contains('student');
final canGrade = userRoles.any(
  (r) => ['instructor', 'teaching_assistant'].contains(r),
);
```

### 10.10 Handling `isLate` Differences

| Module | `isLate` Type | Values |
|---|---|---|
| Assignments | `number` (tinyint) | `0` = on-time, `1` = late |
| Labs | `boolean` | `true` / `false` |

```dart
// Assignments
final isLate = (submission['isLate'] as num) == 1;

// Labs
final isLate = submission['isLate'] as bool;
```

---

> **Last Updated**: April 2026
> **Backend Framework**: NestJS (TypeScript)
> **Database**: MySQL with TypeORM
> **File Storage**: Google Drive API
