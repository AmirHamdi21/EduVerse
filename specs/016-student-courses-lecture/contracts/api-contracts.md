# API Contracts: Student Courses & Lecture Viewer

**Phase**: 1 - Design & Contracts
**Date**: April 10, 2026
**Feature**: Student Courses & Lecture Viewer

## Overview

This document defines the API endpoints used by the Student Courses & Lecture Viewer feature. All endpoints require JWT authentication via `Authorization: Bearer <access_token>` header unless marked as public.

**Base URL**: `http://<host>:3001/api`
**Content-Type**: `application/json` (unless noted otherwise)
**Timeout**: 10s for standard endpoints, 30s for material-related calls

---

## 1. Enrollment Service

### 1.1 Get My Courses

**Endpoint**: `GET /enrollments/my-courses`

**Auth Required**: Yes (Student role)

**Description**: Fetch all courses the authenticated student is enrolled in.

**Query Parameters**: None

**Response `200 OK`**:
```json
{
  "data": [
    {
      "id": 1,
      "courseId": 5,
      "userId": 12,
      "role": "student",
      "status": "active",
      "enrolledAt": "2025-09-01T08:00:00Z",
      "grade": null,
      "course": {
        "id": 5,
        "code": "CS101",
        "name": "Introduction to Computer Science",
        "description": "Fundamentals of programming...",
        "credits": 3,
        "level": "FRESHMAN",
        "status": "ACTIVE",
        "instructorId": 3,
        "instructorName": "Dr. Smith",
        "taIds": [7, 8],
        "departmentId": 1,
        "department": {
          "id": 1,
          "name": "Computer Science",
          "code": "CS"
        },
        "syllabusUrl": "https://example.com/syllabus.pdf",
        "createdAt": "2025-01-15T10:00:00Z",
        "updatedAt": "2025-01-15T10:00:00Z"
      },
      "section": {
        "id": 11,
        "sectionNumber": "1",
        "location": "Room A101",
        "status": "OPEN",
        "schedules": [
          {
            "id": 1,
            "dayOfWeek": "MONDAY",
            "startTime": "09:00",
            "endTime": "10:30",
            "room": "A101",
            "building": "Main Building",
            "scheduleType": "LECTURE"
          },
          {
            "id": 2,
            "dayOfWeek": "WEDNESDAY",
            "startTime": "09:00",
            "endTime": "10:30",
            "room": "A101",
            "building": "Main Building",
            "scheduleType": "LECTURE"
          }
        ]
      }
    }
  ]
}
```

**Error Responses**:
| Status | Description |
|---|---|
| `401` | Unauthorized (invalid/missing token) |
| `500` | Internal server error |

---

## 2. Course Structure Service

### 2.1 Get Course Structure

**Endpoint**: `GET /courses/{id}/structure`

**Auth Required**: Yes (Student, Instructor, TA, Admin)

**Description**: Fetch the week-based structure for a specific course.

**Path Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

**Response `200 OK`**:
```json
{
  "courseId": 5,
  "byWeek": [
    {
      "weekNumber": 1,
      "title": "Introduction to Programming",
      "items": [
        {
          "id": "uuid-1",
          "materialId": 101,
          "orderIndex": 0,
          "title": "Week 1 - Lecture Video",
          "contentType": "VIDEO"
        },
        {
          "id": "uuid-2",
          "materialId": 102,
          "orderIndex": 1,
          "title": "Week 1 - Slides",
          "contentType": "DOCUMENT"
        }
      ]
    },
    {
      "weekNumber": 2,
      "title": "Variables and Data Types",
      "items": [
        {
          "id": "uuid-3",
          "materialId": 103,
          "orderIndex": 0,
          "title": "Week 2 - Lecture Video",
          "contentType": "VIDEO"
        }
      ]
    }
  ],
  "updatedAt": "2025-09-15T14:30:00Z"
}
```

**Error Responses**:
| Status | Description |
|---|---|
| `401` | Unauthorized |
| `404` | Course not found |
| `403` | Forbidden (user not enrolled in course) |
| `500` | Internal server error |

---

## 3. Course Materials Service

### 3.1 Get Course Materials

**Endpoint**: `GET /courses/{id}/materials`

**Auth Required**: Yes (Student, Instructor, TA, Admin)

**Description**: Fetch all published materials for a specific course.

**Path Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Course ID |

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `publishedOnly` | `boolean` | ❌ | `true` | Filter to only published materials |

**Response `200 OK`**:
```json
[
  {
    "id": 101,
    "courseId": 5,
    "type": "VIDEO",
    "title": "Week 1 - Introduction to Programming - Video",
    "description": "Lecture recording for Week 1",
    "externalUrl": "https://youtube.com/watch?v=dQw4w9WgXcQ",
    "file": null,
    "isPublished": true,
    "viewCount": 45,
    "downloadCount": 0,
    "uploadedBy": 3,
    "createdAt": "2025-09-01T10:00:00Z",
    "updatedAt": "2025-09-01T10:00:00Z"
  },
  {
    "id": 102,
    "courseId": 5,
    "type": "DOCUMENT",
    "title": "Week 1 - Introduction to Programming - Slides",
    "description": "Lecture slides PDF",
    "externalUrl": null,
    "file": {
      "driveId": "1aBcDeFgHiJkLmNoPqRsTuVwXyZ",
      "fileName": "week1_slides.pdf",
      "webViewLink": "https://drive.google.com/file/d/1aBc.../view",
      "iframeUrl": "https://drive.google.com/file/d/1aBc.../preview",
      "downloadUrl": "https://drive.google.com/uc?id=1aBc...&export=download",
      "mimeType": "application/pdf",
      "fileSize": 2048576
    },
    "isPublished": true,
    "viewCount": 38,
    "downloadCount": 12,
    "uploadedBy": 3,
    "createdAt": "2025-09-01T10:05:00Z",
    "updatedAt": "2025-09-01T10:05:00Z"
  }
]
```

**Error Responses**:
| Status | Description |
|---|---|
| `401` | Unauthorized |
| `404` | Course not found |
| `500` | Internal server error |

---

### 3.2 Record Material View

**Endpoint**: `POST /materials/{id}/view`

**Auth Required**: Yes (Student)

**Description**: Record that a student has viewed a material. Used for engagement analytics.

**Path Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `id` | `integer` | ✅ | Material ID |

**Request Body**:
```json
{
  "courseId": 5
}
```

**Response `200 OK`**:
```json
{
  "success": true,
  "viewCount": 46
}
```

**Error Responses**:
| Status | Description |
|---|---|
| `401` | Unauthorized |
| `404` | Material not found |
| `500` | Internal server error |

---

## 4. Common Response Patterns

### Pagination (if applicable)
```json
{
  "data": [],
  "meta": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "totalPages": 8
  }
}
```

### Error Response
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "error": "Bad Request",
  "details": [
    {
      "field": "courseId",
      "message": "Course ID must be a positive integer"
    }
  ]
}
```

## Client-Side Contracts

### Bundle Detection (Not a backend endpoint)

Bundle detection is performed client-side using prefix matching algorithm defined in `MaterialBundleModel`. No API call required.

**Input**: `List<CourseMaterialModel>`
**Output**: `Map<String, MaterialBundleModel>` (keyed by normalized base title)

### Cache Keys (Local storage)

| Key Pattern | Value | TTL |
|---|---|---|
| `course_structure_{courseId}_{hash}` | Serialized CourseStructure JSON | 7 days |
| `course_materials_{courseId}` | Serialized List<CourseMaterial> JSON | 7 days |
| `material_viewed_{materialId}` | Boolean (true) | Session (clear on logout) |
| `downloaded_materials` | Map<materialId, filePath> | Until manually cleared |
