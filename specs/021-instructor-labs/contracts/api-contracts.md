# API Contracts: Phase 7 — Instructor Labs CRUD & Grading

**Date**: 2026-04-13  
**Feature**: Instructor Labs CRUD & Grading  
**Source**: `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` (Sections 7: Labs Module)

---

## Labs CRUD Endpoints

### GET /api/labs — List Labs

**Auth**: Required (JWT)  
**Roles**: instructor, ta, admin  
**Method**: GET

**Query Parameters**:
| Parameter | Type | Required | Description |
|---|---|---|---|
| `courseId` | string (UUID) | ❌ | Filter by course |
| `status` | string | ❌ | Filter by LabStatus enum |
| `search` | string | ❌ | Search in title |
| `page` | int | ❌ | Page number (default 1) |
| `limit` | int | ❌ | Items per page (default 10) |

**Response 200**:
```json
{
  "data": [
    {
      "id": "lab-uuid",
      "courseId": "course-uuid",
      "title": "Lab 1: Introduction",
      "description": "...",
      "labNumber": 1,
      "dueDate": "2026-05-01T23:59:59Z",
      "availableFrom": "2026-04-15T00:00:00Z",
      "maxScore": "100.00",
      "weight": "10.00",
      "status": "published",
      "createdBy": "user-uuid",
      "allowedFileTypes": "pdf,docx,zip",
      "maxFileSizeMb": 10,
      "createdAt": "2026-04-10T08:00:00Z",
      "updatedAt": "2026-04-10T08:00:00Z",
      "course": {
        "id": "course-uuid",
        "name": "Computer Science 101",
        "code": "CS101"
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

### GET /api/labs/:id — Get Lab Details

**Auth**: Required  
**Roles**: instructor, ta, admin, student  
**Method**: GET

**Response 200**: Single Lab object (same shape as list item, with `instructions` and `instructionFiles` relations included).

---

### POST /api/labs — Create Lab

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: POST

**Request Body**:
```json
{
  "courseId": "course-uuid",
  "title": "Lab 1: Introduction",
  "description": "Lab description (markdown)",
  "dueDate": "2026-05-01T23:59:59Z",
  "availableFrom": "2026-04-15T00:00:00Z",
  "maxScore": "100",
  "weight": "10",
  "status": "draft",
  "allowedFileTypes": "pdf,docx,zip",
  "maxFileSizeMb": 10
}
```

**Response 201**: Created Lab object.

---

### PUT /api/labs/:id — Update Lab

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: PUT

**Request Body**: Partial Lab object (only fields to update).

**Response 200**: Updated Lab object.

---

### DELETE /api/labs/:id — Delete Lab

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: DELETE

**Response 204**: No content.

---

## Instruction Management Endpoints

### POST /api/labs/:id/instructions — Add Text Instruction

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: POST

**Request Body**:
```json
{
  "instructionText": "# Lab Instructions\n\nStep 1: ...",
  "orderIndex": 0
}
```

**Response 201**: Created LabInstruction object.

---

### POST /api/labs/:id/instructions/upload — Upload Instruction File

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: POST (FormData)

**FormData Fields**:
| Field | Type | Required | Description |
|---|---|---|---|
| `file` | File | ✅ | The file to upload |
| `orderIndex` | int | ❌ | Sort order (default: auto-increment) |

**Response 201**:
```json
{
  "id": "instruction-uuid",
  "labId": "lab-uuid",
  "instructionText": null,
  "fileId": 123,
  "file": {
    "driveId": "drive-file-id",
    "fileName": "instructions.pdf",
    "webViewLink": "https://drive.google.com/...",
    "iframeUrl": "https://drive.google.com/file/d/.../preview",
    "downloadUrl": "https://drive.google.com/uc?export=download&...",
    "entityType": "lab_instruction"
  },
  "orderIndex": 1,
  "createdAt": "2026-04-10T08:00:00Z"
}
```

---

## Submission Management Endpoints

### GET /api/labs/:id/submissions — Get Lab Submissions

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: GET

**Response 200**:
```json
[
  {
    "id": "submission-uuid",
    "labId": "lab-uuid",
    "userId": 123,
    "user": {
      "userId": 123,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com"
    },
    "submissionText": "Student's text submission",
    "submissionStatus": "submitted",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null,
    "isLate": false,
    "submittedAt": "2026-04-28T15:30:00Z"
  }
]
```

---

### PATCH /api/labs/:labId/submissions/:subId/grade — Grade Submission

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: PATCH

**Request Body**:
```json
{
  "score": 85.5,
  "feedback": "Good work on the report. See section 3 for improvements.",
  "status": "graded"
}
```

**Response 200**:
```json
{
  "id": "submission-uuid",
  "labId": "lab-uuid",
  "userId": 123,
  "score": "85.50",
  "feedback": "Good work on the report. See section 3 for improvements.",
  "submissionStatus": "graded",
  "gradedBy": 5,
  "gradedAt": "2026-04-12T10:00:00Z",
  "isLate": false,
  "submittedAt": "2026-04-10T15:30:00Z",
  "user": {
    "userId": 123,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com"
  },
  "grader": {
    "userId": 5,
    "firstName": "Dr.",
    "lastName": "Smith",
    "email": "smith@example.com"
  }
}
```

**Side Effect**: When `status = 'graded'` AND `score` is provided, the backend automatically creates or updates a grade record in the central `grades` table (gradeType = 'lab', isPublished = true).

---

## Attendance Endpoints

### GET /api/labs/:id/attendance — Get Lab Attendance

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: GET

**Response 200**:
```json
[
  {
    "id": "attendance-uuid",
    "labId": "lab-uuid",
    "userId": 123,
    "user": {
      "userId": 123,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@example.com"
    },
    "attendanceStatus": "present",
    "checkInTime": "2026-04-10T09:05:00Z",
    "notes": null,
    "markedBy": 5,
    "createdAt": "2026-04-10T09:05:00Z"
  }
]
```

---

### POST /api/labs/:id/attendance — Mark Attendance

**Auth**: Required  
**Roles**: instructor, ta, admin  
**Method**: POST

**Request Body**:
```json
[
  {
    "userId": 123,
    "attendanceStatus": "present"
  },
  {
    "userId": 124,
    "attendanceStatus": "absent"
  }
]
```

**Response 201**: Array of created/updated LabAttendance records.

---

## File Upload Rules

| Upload Type | Endpoint | FormData Field | Max Size |
|---|---|---|---|
| Lab instruction file | `POST /labs/{id}/instructions/upload` | `file` | 50 MB (documents) |
| Lab submission file (student) | `POST /labs/{id}/submissions/upload` | `file` | Lab's maxFileSizeMb or 50 MB default |
| TA material file | `POST /labs/{id}/ta-materials/upload` | `file` | 50 MB |

**Dio FormData usage**:
```dart
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    filePath,
    filename: fileName,
  ),
  'orderIndex': orderIndex,
});
```

**IMPORTANT**: Do NOT manually set `Content-Type` header. Dio auto-generates the multipart boundary.

---

## Error Responses

| Status | Description | Handling |
|---|---|---|
| `400` | Validation error (missing required fields, invalid values) | Display field-level validation errors |
| `403` | Forbidden (user lacks role permission) | Show "Access Denied" message, hide action in UI |
| `404` | Lab/submission/instruction not found | Show "Not Found" message |
| `409` | Conflict (e.g., duplicate lab number) | Show conflict message with retry option |
| `500` | Server error | Show generic error message with retry option |
