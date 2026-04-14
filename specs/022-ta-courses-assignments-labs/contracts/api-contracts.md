# API Contracts: TA — Courses, Assignments & Labs Integration

**Date**: 2026-04-14

## Overview

This phase **consumes existing API contracts** from Phase 1/6/7. No new endpoints are introduced. This document summarizes which endpoints the TA feature uses, their request/response shapes, and role requirements.

## Authentication

All endpoints require JWT authentication:
```
Authorization: Bearer <access_token>
```

Role: `teaching_assistant` (or `instructor`, `admin` for shared endpoints).

---

## Course Endpoints

### GET /enrollments/teaching

**Purpose**: Load courses the TA is assigned to (section-scoped).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: `TeachingCourseModel[]`

```json
[
  {
    "sectionId": 11,
    "courseId": 1,
    "course": { "id": 1, "code": "CS101", "name": "Intro to CS", ... },
    "section": { "id": 11, "sectionNumber": "1", "maxCapacity": 30, "currentEnrollment": 25, ... },
    "semester": { "id": 1, "name": "Fall 2025", ... },
    "instructor": { "userId": 5, "firstName": "Dr.", "lastName": "Smith", ... }
  }
]
```

---

### GET /sections/course/{courseId}

**Purpose**: Load sections for a course (used in Sections & Labs sub-tab).
**Roles**: All authenticated users
**Response**: `SectionModel[]` (includes `course`, `semester`, `schedules` relations)

---

### GET /enrollments/sections/{sectionId}/students

**Purpose**: Load students enrolled in a section (used in Students sub-tab).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: `Student[]`
**Note**: Accessed via `EnrollmentService.getSectionStudents(sectionId)` — URL path is under `/enrollments/sections/`, not `/sections/`.

---

## Assignment Endpoints

### GET /assignments?courseId={id}

**Purpose**: Load assignments for a course (used in assignment list + grading tabs).
**Roles**: All authenticated users
**Query Params**: `courseId`, `status`, `page`, `limit`, `sortBy`, `sortOrder`
**Response**: `PaginatedResponse<AssignmentModel>`

---

### POST /assignments

**Purpose**: Create assignment (TA uses same endpoint as Instructor).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Request Body**:
```json
{
  "courseId": 1,
  "title": "Homework 1",
  "description": "...",
  "instructions": "...",
  "submissionType": "file",
  "maxScore": 100,
  "weight": 15,
  "dueDate": "2025-06-15T23:59:59Z",
  "availableFrom": "2025-06-01T00:00:00Z",
  "lateSubmissionAllowed": true,
  "latePenaltyPercent": 10,
  "maxFileSizeMb": 10,
  "allowedFileTypes": "[\"pdf\",\"zip\"]",
  "status": "draft"
}
```
**Response**: `AssignmentModel` (201 Created)

---

### PATCH /assignments/{id}

**Purpose**: Update assignment.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Request Body**: Partial `AssignmentModel` fields
**Response**: `AssignmentModel`

---

### DELETE /assignments/{id}

**Purpose**: Delete assignment (soft delete).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: 200 OK (empty body)

---

### GET /assignments/{id}/submissions

**Purpose**: Load all submissions for an assignment (used in grading).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: `AssignmentSubmissionModel[]`

---

### PATCH /assignments/{aId}/submissions/{sId}/grade

**Purpose**: Grade a submission.
**Roles**: `instructor`, `teaching_assistant`
**Request Body**:
```json
{
  "score": 85,
  "feedback": "Well done!"
}
```
**Response**:
```json
{
  "submissionId": 15,
  "score": 85,
  "maxScore": 100,
  "feedback": "Well done!",
  "gradeId": 42
}
```

---

### POST /assignments/{id}/instructions/upload

**Purpose**: Upload instruction file to Google Drive.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Content-Type**: `multipart/form-data`
**Form Fields**: `file` (binary), `title` (string), `orderIndex` (integer)
**Response**: `DriveFileModel` (201 Created)

---

## Lab Endpoints

### GET /labs?courseId={id}

**Purpose**: Load labs for a course.
**Roles**: All authenticated users
**Query Params**: `courseId`, `status`, `page`, `limit`
**Response**: `PaginatedResponse<LabModel>`

---

### GET /labs/{id}

**Purpose**: Load lab detail with instructions.
**Roles**: All authenticated users
**Response**: `LabModel` (includes `course`, `instructions`, `instructionFiles` relations)

---

### POST /labs

**Purpose**: Create lab (TA uses same endpoint as Instructor).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Request Body**:
```json
{
  "courseId": 1,
  "title": "Binary Search Lab",
  "description": "...",
  "availableFrom": "2026-04-01T00:00:00Z",
  "dueDate": "2026-04-15T23:59:59Z",
  "maxScore": 100,
  "weight": 10,
  "status": "draft"
}
```
**Response**: `LabModel` (201 Created)

---

### PATCH /labs/{id}

**Purpose**: Update lab.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Request Body**: Partial `LabModel` fields
**Response**: `LabModel`

---

### DELETE /labs/{id}

**Purpose**: Delete lab (soft delete).
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: 200 OK (empty body)

---

### GET /labs/{id}/submissions

**Purpose**: Load all lab submissions.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: `LabSubmissionModel[]`

---

### PATCH /labs/{labId}/submissions/{subId}/grade

**Purpose**: Grade lab submission.
**Roles**: `instructor`, `teaching_assistant`
**Request Body**:
```json
{
  "score": 85.5,
  "feedback": "Good work",
  "status": "graded"
}
```
**Response**: `LabSubmissionModel`

---

### POST /labs/{id}/instructions/upload

**Purpose**: Upload lab instruction file.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Content-Type**: `multipart/form-data`
**Form Fields**: `file`, `title`, `orderIndex`
**Response**: `LabInstructionModel` (201 Created)

---

### POST /labs/{id}/ta-materials/upload ⚠️ CONDITIONAL

**Purpose**: Upload TA-only materials.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Content-Type**: `multipart/form-data`
**Form Fields**: `file`, `title`
**Response**: `DriveFileModel` (201 Created)
**⚠️ Note**: This endpoint is **NOT documented** in `COURSES_ASSIGNMENTS_LABS_BACKEND_API_DOCS.md` (confirmed absent by API docs audit). Presence MUST be verified by inspecting backend source at `<BACKEND_PATH>` before implementation (per T047). The contract above is a **tentative specification** — if the endpoint is not found after backend inspection, T047 renders a structured empty state instead.

---

### GET /labs/{id}/attendance

**Purpose**: Load lab attendance records.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Response**: `LabAttendanceModel[]`

---

### POST /labs/{id}/attendance

**Purpose**: Mark attendance.
**Roles**: `instructor`, `teaching_assistant`, `admin`
**Request Body**:
```json
{
  "userId": 57,
  "attendanceStatus": "present",
  "notes": "Arrived on time"
}
```
**Response**: `LabAttendanceModel` (201 Created)

---

## Course Structure & Materials Endpoints

### GET /courses/{id}/structure

**Purpose**: Load week-based course structure (used in Lectures sub-tab).
**Roles**: All authenticated users
**Response**: `CourseStructureModel`

---

### GET /courses/{id}/materials

**Purpose**: Load course materials (used in Materials sub-tab).
**Roles**: All authenticated users
**Response**: `CourseMaterialModel[]` (paginated)

---

## Error Responses

| Status | Description |
|---|---|
| `400` | Invalid input data / validation failure |
| `401` | Missing or invalid JWT |
| `403` | User lacks required role (e.g., TA accessing admin-only endpoint) |
| `404` | Resource not found |
| `409` | Conflict (e.g., duplicate code, invalid state transition) |
| `500` | Internal server error |
