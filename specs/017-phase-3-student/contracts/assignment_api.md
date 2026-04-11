# API Contracts: Phase 3 — Student Assignments

**Date**: 2026-04-11

---

## Contract 1: List Assignments

**Endpoint**: `GET /assignments`
**Auth**: Required (JWT Bearer token)
**Role**: Student

### Request

| Parameter | Type | Required | Location | Description |
|---|---|---|---|---|
| `courseId` | `integer` | No | Query | Filter by course ID |
| `status` | `string` | No | Query | Filter by assignment status (draft/published/closed/archived) |
| `search` | `string` | No | Query | Search in title |
| `page` | `integer` | No | Query | Page number (default: 1) |
| `limit` | `integer` | No | Query | Items per page (default: 10, max: 100) |
| `sortBy` | `string` | No | Query | Sort field: dueDate, createdAt, title |
| `sortOrder` | `string` | No | Query | Sort order: ASC or DESC |

### Response `200 OK`

```json
{
  "data": [
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
      "course": {
        "id": 1,
        "name": "Introduction to CS",
        "code": "CS101"
      },
      "instructionFiles": [
        {
          "driveFileId": "1abc123",
          "fileName": "instructions.pdf",
          "webViewLink": "https://drive.google.com/file/d/1abc123/view",
          "downloadUrl": "https://drive.google.com/uc?id=1abc123&export=download"
        }
      ]
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

## Contract 2: Get Assignment Details

**Endpoint**: `GET /assignments/:id`
**Auth**: Required
**Role**: Student

### Response `200 OK`

Same shape as a single item from the list response above.

### Response `404 Not Found`

```json
{
  "message": "Assignment not found",
  "error": "Not Found",
  "statusCode": 404
}
```

---

## Contract 3: Submit Assignment (Text/Link)

**Endpoint**: `POST /assignments/:id/submit`
**Auth**: Required
**Role**: Student
**Content-Type**: `application/json`

### Request Body

```json
{
  "submissionText": "My answer here...",
  "submissionLink": "https://example.com/my-project"
}
```

**Note**: Only one of `submissionText` or `submissionLink` is required based on the assignment's `submissionType`. Both may be sent for "any" or "multiple" types.

### Response `201 Created`

```json
{
  "id": 45,
  "assignmentId": 3,
  "userId": 12,
  "submissionText": "My answer here...",
  "submissionLink": null,
  "submissionStatus": "submitted",
  "isLate": 0,
  "attemptNumber": 1,
  "submittedAt": "2025-06-10T14:30:00Z",
  "score": null,
  "feedback": null
}
```

### Response `400 Bad Request` — Late submission not allowed

```json
{
  "message": "Submission deadline has passed and late submissions are not allowed",
  "error": "Bad Request",
  "statusCode": 400
}
```

### Response `400 Bad Request` — Student not enrolled

```json
{
  "message": "Student is not enrolled in this course",
  "error": "Bad Request",
  "statusCode": 400
}
```

---

## Contract 4: Submit Assignment (File Upload)

**Endpoint**: `POST /assignments/:id/submissions/upload`
**Auth**: Required
**Role**: Student
**Content-Type**: `multipart/form-data`

### Request Form Data

| Field | Type | Required | Description |
|---|---|---|---|
| `file` | `File` | Yes | The file to upload |
| `submissionText` | `string` | No | Optional text comment |
| `submissionLink` | `string` | No | Optional URL |

### Response `201 Created`

Same shape as text/link submission response, with `driveFile` populated:

```json
{
  "id": 46,
  "assignmentId": 3,
  "userId": 12,
  "submissionStatus": "submitted",
  "isLate": 0,
  "attemptNumber": 1,
  "submittedAt": "2025-06-10T14:30:00Z",
  "driveFile": {
    "driveFileId": "1xyz789",
    "fileName": "homework1.pdf",
    "webViewLink": "https://drive.google.com/file/d/1xyz789/view",
    "downloadUrl": "https://drive.google.com/uc?id=1xyz789&export=download"
  }
}
```

---

## Contract 5: Get My Submission

**Endpoint**: `GET /assignments/:id/submissions/my`
**Auth**: Required
**Role**: Student

### Response `200 OK`

```json
{
  "id": 45,
  "assignmentId": 3,
  "userId": 12,
  "submissionText": "My answer here...",
  "submissionStatus": "graded",
  "isLate": 0,
  "attemptNumber": 1,
  "submittedAt": "2025-06-10T14:30:00Z",
  "score": 85.00,
  "feedback": "Good work, but missed edge case handling.",
  "gradedBy": 5,
  "gradedAt": "2025-06-12T10:00:00Z",
  "user": {
    "userId": 12,
    "firstName": "Ahmed",
    "lastName": "Ali",
    "email": "ahmed@eduverse.com"
  }
}
```

### Response `404 Not Found` — No submission exists

```json
{
  "message": "No submission found for this assignment",
  "error": "Not Found",
  "statusCode": 404
}
```
