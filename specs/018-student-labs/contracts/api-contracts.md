# API Contracts: Student Labs Integration

**Feature**: 018-student-labs
**Date**: 2026-04-11

---

## Contract 1: Get Labs for Course

**Endpoint**: `GET /labs?courseId={id}`
**Auth**: Required (JWT Bearer token)
**Purpose**: Fetch all labs for a specific course

### Request

```
GET /labs?courseId=123
Authorization: Bearer <token>
```

### Response (200 OK)

```json
{
  "data": [
    {
      "id": "uuid-string",
      "labId": 1,
      "courseId": 123,
      "title": "Lab 1 - Introduction to Python",
      "description": "Complete the Python exercises...",
      "labNumber": 1,
      "dueDate": "2026-05-01T23:59:59Z",
      "availableFrom": "2026-04-15T00:00:00Z",
      "maxScore": 100.00,
      "weight": 10.00,
      "status": "published",
      "createdBy": 5,
      "createdAt": "2026-04-10T08:00:00Z",
      "updatedAt": "2026-04-10T08:00:00Z",
      "course": {
        "id": 123,
        "code": "CS101",
        "name": "Introduction to Computer Science"
      }
    }
  ],
  "meta": {
    "total": 5,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized — invalid or missing token |
| 404 | Course not found |

---

## Contract 2: Get Lab Details

**Endpoint**: `GET /labs/{id}`
**Auth**: Required (JWT Bearer token)
**Purpose**: Fetch single lab with full details

### Request

```
GET /labs/abc-123-uuid
Authorization: Bearer <token>
```

### Response (200 OK)

```json
{
  "id": "abc-123-uuid",
  "labId": 1,
  "courseId": 123,
  "title": "Lab 1 - Introduction to Python",
  "description": "Complete the Python exercises in the attached notebook.",
  "labNumber": 1,
  "dueDate": "2026-05-01T23:59:59Z",
  "availableFrom": "2026-04-15T00:00:00Z",
  "maxScore": 100.00,
  "weight": 10.00,
  "status": "published",
  "createdBy": 5,
  "createdAt": "2026-04-10T08:00:00Z",
  "updatedAt": "2026-04-10T08:00:00Z",
  "course": {
    "id": 123,
    "code": "CS101",
    "name": "Introduction to Computer Science",
    "instructorId": 5
  },
  "instructions": [
    {
      "id": "inst-uuid-1",
      "labId": "abc-123-uuid",
      "instructionText": "## Step 1: Install Python\n\nDownload and install Python 3.x from python.org.",
      "fileId": null,
      "file": null,
      "orderIndex": 0,
      "createdAt": "2026-04-10T08:00:00Z"
    },
    {
      "id": "inst-uuid-2",
      "labId": "abc-123-uuid",
      "instructionText": null,
      "fileId": 42,
      "file": {
        "driveId": "1aBcDeFgHiJkLmNoPqRsTuVwXyZ",
        "driveFileId": 42,
        "fileName": "lab1_notebook.ipynb",
        "webViewLink": "https://drive.google.com/file/d/1aBcD.../view",
        "iframeUrl": "https://drive.google.com/file/d/1aBcD.../preview",
        "downloadUrl": "https://drive.google.com/uc?id=1aBcD...&export=download"
      },
      "orderIndex": 1,
      "createdAt": "2026-04-10T08:00:00Z"
    }
  ]
}
```

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Lab not found |
| 403 | Forbidden — student not enrolled in this course |

---

## Contract 3: Submit Lab (Text)

**Endpoint**: `POST /labs/{id}/submit`
**Auth**: Required (JWT Bearer token)
**Content-Type**: `application/json`
**Purpose**: Submit lab work as text

### Request

```
POST /labs/abc-123-uuid/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "submissionText": "My lab work answers:\n\n1. The answer is...\n2. The result is..."
}
```

### Response (201 Created)

```json
{
  "id": "submission-uuid",
  "labId": "abc-123-uuid",
  "userId": 10,
  "submissionText": "My lab work answers:\n\n1. The answer is...\n2. The result is...",
  "submissionLink": null,
  "fileId": null,
  "file": null,
  "driveFile": null,
  "submissionStatus": "submitted",
  "score": null,
  "feedback": null,
  "gradedBy": null,
  "gradedAt": null,
  "isLate": false,
  "submittedAt": "2026-04-20T14:30:00Z"
}
```

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Lab not found |
| 400 | Lab is closed/archived — submissions not accepted |

---

## Contract 4: Submit Lab (File)

**Endpoint**: `POST /labs/{id}/submissions/upload`
**Auth**: Required (JWT Bearer token)
**Content-Type**: `multipart/form-data`
**Purpose**: Submit lab work as file upload

### Request

```
POST /labs/abc-123-uuid/submissions/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary...

------WebKitFormBoundary...
Content-Disposition: form-data; name="file"; filename="lab1_answers.pdf"
Content-Type: application/pdf

<binary file data>
------WebKitFormBoundary...
```

**Important**: Do NOT manually set `Content-Type` header. Let Dio auto-generate the multipart boundary.

### Response (201 Created)

```json
{
  "id": "submission-uuid",
  "labId": "abc-123-uuid",
  "userId": 10,
  "submissionText": null,
  "submissionLink": null,
  "fileId": 99,
  "file": {
    "name": "lab1_answers.pdf",
    "url": "https://drive.google.com/file/d/xyz.../view"
  },
  "driveFile": {
    "driveId": "xyz-drive-file-id",
    "driveFileId": 99,
    "fileName": "lab1_answers.pdf",
    "webViewLink": "https://drive.google.com/file/d/xyz.../view",
    "iframeUrl": "https://drive.google.com/file/d/xyz.../preview",
    "downloadUrl": "https://drive.google.com/uc?id=xyz...&export=download"
  },
  "submissionStatus": "submitted",
  "score": null,
  "feedback": null,
  "gradedBy": null,
  "gradedAt": null,
  "isLate": false,
  "submittedAt": "2026-04-20T14:30:00Z"
}
```

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Lab not found |
| 400 | Lab is closed/archived; or file exceeds size limit |
| 500 | Google Drive upload failure |

---

## Contract 5: Get My Submissions

**Endpoint**: `GET /labs/{id}/submissions/my`
**Auth**: Required (JWT Bearer token)
**Purpose**: Fetch all of the current student's submission attempts for a lab

### Request

```
GET /labs/abc-123-uuid/submissions/my
Authorization: Bearer <token>
```

### Response (200 OK)

```json
[
  {
    "id": "submission-uuid-1",
    "labId": "abc-123-uuid",
    "userId": 10,
    "submissionText": "First attempt...",
    "submissionLink": null,
    "fileId": null,
    "file": null,
    "driveFile": null,
    "submissionStatus": "graded",
    "score": 75.00,
    "feedback": "Good effort. Review question 3.",
    "gradedBy": 5,
    "gradedAt": "2026-04-22T10:00:00Z",
    "isLate": false,
    "submittedAt": "2026-04-20T14:30:00Z",
    "user": {
      "userId": 10,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@edu.example"
    }
  },
  {
    "id": "submission-uuid-2",
    "labId": "abc-123-uuid",
    "userId": 10,
    "submissionText": "Revised answers...",
    "submissionLink": null,
    "fileId": null,
    "file": null,
    "driveFile": null,
    "submissionStatus": "submitted",
    "score": null,
    "feedback": null,
    "gradedBy": null,
    "gradedAt": null,
    "isLate": false,
    "submittedAt": "2026-04-23T09:00:00Z",
    "user": {
      "userId": 10,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@edu.example"
    }
  }
]
```

**Note**: Returns an **array** of all submission attempts (unlike assignments which returns the single latest submission).

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Lab not found |

---

## Contract 6: Get Lab Instructions (separate endpoint)

**Endpoint**: `GET /labs/{id}/instructions`
**Auth**: Required (JWT Bearer token)
**Purpose**: Fetch instructions for a lab (when not included in lab detail response)

### Request

```
GET /labs/abc-123-uuid/instructions
Authorization: Bearer <token>
```

### Response (200 OK)

```json
[
  {
    "id": "inst-uuid-1",
    "labId": "abc-123-uuid",
    "instructionText": "## Step 1: Install Python\n\nDownload and install Python 3.x from python.org.",
    "fileId": null,
    "file": null,
    "orderIndex": 0,
    "createdAt": "2026-04-10T08:00:00Z"
  },
  {
    "id": "inst-uuid-2",
    "labId": "abc-123-uuid",
    "instructionText": null,
    "fileId": 42,
    "file": {
      "driveId": "1aBcDeFgHiJkLmNoPqRsTuVwXyZ",
      "driveFileId": 42,
      "fileName": "lab1_notebook.ipynb",
      "webViewLink": "https://drive.google.com/file/d/1aBcD.../view",
      "iframeUrl": "https://drive.google.com/file/d/1aBcD.../preview",
      "downloadUrl": "https://drive.google.com/uc?id=1aBcD...&export=download"
    },
    "orderIndex": 1,
    "createdAt": "2026-04-10T08:00:00Z"
  }
]
```

Instructions are ordered by `orderIndex` ascending.

### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Lab not found |
