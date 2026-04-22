# API Contracts: Phase 5 — Instructor Courses & Materials Management

**Feature**: 019-instructor-courses-materials
**Date**: April 12, 2026

---

## Contract 1: Teaching Courses List

**Endpoint**: `GET /enrollments/teaching`
**Auth**: Required (JWT)
**Roles**: `instructor`, `teaching_assistant`, `admin`

### Response `200 OK`
```json
[
  {
    "sectionId": 1,
    "userId": 5,
    "courseId": 1,
    "role": "instructor",
    "course": {
      "id": 1,
      "code": "CS101",
      "name": "Introduction to Computer Science",
      "departmentId": 3,
      "credits": 3,
      "level": "FRESHMAN",
      "status": "ACTIVE"
    },
    "section": {
      "id": 11,
      "sectionNumber": "1",
      "maxCapacity": 30,
      "currentEnrollment": 25,
      "location": "Room A101",
      "status": "OPEN"
    },
    "semester": {
      "id": 1,
      "name": "Fall 2025",
      "startDate": "2025-09-01",
      "endDate": "2025-12-15"
    }
  }
]
```

---

## Contract 2: Course Materials List

**Endpoint**: `GET /courses/{courseId}/materials`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`, `student` (published only), `admin`

### Query Parameters
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 200 | Items per page |

### Response `200 OK`
```json
{
  "data": [
    {
      "id": 42,
      "courseId": 1,
      "title": "Introduction to AI - Video",
      "type": "video",
      "weekNumber": 1,
      "url": null,
      "externalUrl": "https://www.youtube.com/embed/abc123",
      "driveFileId": null,
      "isPublished": 1,
      "viewCount": 150,
      "downloadCount": 45,
      "createdAt": "2025-09-01T10:00:00Z",
      "updatedAt": "2025-09-01T10:00:00Z"
    }
  ],
  "meta": {
    "total": 50,
    "page": 1,
    "limit": 200,
    "totalPages": 1
  }
}
```

---

## Contract 3: Upload Document

**Endpoint**: `POST /courses/{courseId}/materials/document`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`
**Content-Type**: `multipart/form-data`

### Form Data
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `document` | File | ✅ | The document file (PDF, DOCX, PPTX, etc.) |
| `title` | string | ✅ | Material title |
| `weekNumber` | integer | ❌ | Week number to associate with |
| `isPublished` | boolean | ❌ | Default: true |

### Response `201 Created`
```json
{
  "id": 43,
  "courseId": 1,
  "title": "Introduction to AI - Slides",
  "type": "document",
  "weekNumber": 1,
  "isPublished": true,
  "viewCount": 0,
  "downloadCount": 0
}
```

---

## Contract 4: Upload Video

**Endpoint**: `POST /courses/{courseId}/materials/video`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`
**Content-Type**: `multipart/form-data`

### Form Data
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `video` | File | ✅ | The video file (MP4, MOV, AVI) |
| `title` | string | ✅ | Material title |
| `weekNumber` | integer | ❌ | Week number to associate with |
| `isPublished` | boolean | ❌ | Default: true |

### Response `201 Created`
```json
{
  "id": 44,
  "courseId": 1,
  "title": "Introduction to AI - Video",
  "type": "video",
  "weekNumber": 1,
  "externalUrl": "https://www.youtube.com/embed/xyz789",
  "isPublished": true,
  "viewCount": 0,
  "downloadCount": 0
}
```

### Error `401 Unauthorized`
```json
{
  "error": "YouTube not authorized. Please contact admin to set up YouTube integration."
}
```

---

## Contract 5: Create Text/Link Material

**Endpoint**: `POST /courses/{courseId}/materials`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`
**Content-Type**: `application/json`

### Request Body
```json
{
  "title": "Reading: Chapter 1",
  "type": "link",
  "url": "https://example.com/chapter1",
  "weekNumber": 1,
  "isPublished": true
}
```

### Response `201 Created`
```json
{
  "id": 45,
  "courseId": 1,
  "title": "Reading: Chapter 1",
  "type": "link",
  "weekNumber": 1,
  "url": "https://example.com/chapter1",
  "isPublished": true,
  "viewCount": 0,
  "downloadCount": 0
}
```

---

## Contract 6: Update Material

**Endpoint**: `PUT /courses/{courseId}/materials/{materialId}`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`
**Content-Type**: `application/json`

### Request Body (all fields optional)
```json
{
  "title": "Updated Title",
  "weekNumber": 2,
  "isPublished": false
}
```

### Response `200 OK`
Returns updated material object.

---

## Contract 7: Delete Material

**Endpoint**: `DELETE /courses/{courseId}/materials/{materialId}`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`

### Response `204 No Content`
Empty body.

---

## Contract 8: Toggle Material Visibility

**Endpoint**: `PATCH /courses/{courseId}/materials/{materialId}/visibility`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`

### Request Body
```json
{
  "isPublished": false
}
```

### Response `200 OK`
Returns updated material object with new `isPublished` value.

---

## Contract 9: Get Course Structure

**Endpoint**: `GET /courses/{courseId}/structure`
**Auth**: Required
**Roles**: All authenticated users

### Response `200 OK`
```json
[
  {
    "id": 1,
    "courseId": 1,
    "title": "Week 1: Introduction",
    "weekNumber": 1,
    "sortOrder": 1,
    "description": null,
    "createdAt": "2025-09-01T08:00:00Z"
  }
]
```

---

## Contract 10: Create Structure Item

**Endpoint**: `POST /courses/{courseId}/structure`
**Auth**: Required
**Roles**: `instructor`, `admin`

### Request Body
```json
{
  "title": "Week 2: Foundations",
  "weekNumber": 2,
  "sortOrder": 2,
  "description": "Foundations of computational thinking"
}
```

### Response `201 Created`
Returns created structure item.

---

## Contract 11: Update Structure Item

**Endpoint**: `PUT /courses/{courseId}/structure/{itemId}`
**Auth**: Required
**Roles**: `instructor`, `admin`

### Request Body (all optional)
```json
{
  "title": "Week 2: Advanced Foundations",
  "sortOrder": 3
}
```

### Response `200 OK`
Returns updated structure item.

---

## Contract 12: Delete Structure Item

**Endpoint**: `DELETE /courses/{courseId}/structure/{itemId}`
**Auth**: Required
**Roles**: `instructor`, `admin`

### Response `204 No Content`
Empty body.
**Note**: If item has associated materials, backend may warn — frontend must confirm with user first.

---

## Contract 13: Reorder Structure Items

**Endpoint**: `PATCH /courses/{courseId}/structure/reorder`
**Auth**: Required
**Roles**: `instructor`, `admin`

### Request Body
```json
{
  "itemIds": [3, 1, 2, 4]
}
```

### Response `200 OK`
Returns reordered structure items list.

---

## Contract 14: Get Section Students

**Endpoint**: `GET /sections/{sectionId}/students`
**Auth**: Required
**Roles**: `instructor`, `teaching_assistant`, `admin`

### Response `200 OK`
```json
[
  {
    "userId": 57,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "enrollmentStatus": "enrolled",
    "grade": 85.5,
    "attendanceRate": 92.0
  }
]
```

---

## Contract 15: Get Section Schedules

**Endpoint**: `GET /schedules/section/{sectionId}`
**Auth**: Required
**Roles**: All authenticated users

### Response `200 OK`
```json
[
  {
    "id": 1,
    "sectionId": 11,
    "dayOfWeek": "MONDAY",
    "startTime": "09:00",
    "endTime": "10:30",
    "room": "A101",
    "building": "Main Building",
    "scheduleType": "LECTURE"
  }
]
```

---

## Contract 16: Get Assignments (Read-Only for Deadlines)

**Endpoint**: `GET /assignments?courseId={courseId}`
**Auth**: Required
**Roles**: All authenticated users
**Phase 5 usage**: Read-only, for displaying upcoming deadlines in course overview

### Response `200 OK`
```json
{
  "data": [
    {
      "id": 3,
      "courseId": 1,
      "title": "Homework 1 - Binary Search",
      "dueDate": "2025-06-15T23:59:59Z",
      "status": "published",
      "maxScore": 100.00,
      "weight": 15.00
    }
  ],
  "meta": { "total": 5, "page": 1, "limit": 10, "totalPages": 1 }
}
```

---

## Contract 17: Get Labs (Read-Only for Deadlines)

**Endpoint**: `GET /labs?courseId={courseId}`
**Auth**: Required
**Roles**: All authenticated users
**Phase 5 usage**: Read-only, for displaying upcoming deadlines in course overview

### Response `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "courseId": 1,
      "title": "Binary Search Lab",
      "dueDate": "2025-06-15T23:59:59Z",
      "status": "published",
      "maxScore": 100.00,
      "weight": 10.00
    }
  ],
  "meta": { "total": 3, "page": 1, "limit": 20, "totalPages": 1 }
}
```
