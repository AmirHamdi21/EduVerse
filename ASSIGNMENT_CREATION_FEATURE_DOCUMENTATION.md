# Assignment Creation Feature - Comprehensive Documentation

> **Feature:** Create and manage assignments, labs, and projects in course detail screen (Assignments Tab)  
> **Location:** Instructor Dashboard → Courses → Select Course → Assignments Tab  
> **Version:** 1.0  
> **Last Updated:** April 2026  
> **Scope:** Frontend implementation - assignment/lab/project creation, editing, management, and lifecycle

---

## Table of Contents

1. [Feature Overview](#1-feature-overview)
2. [Component Architecture](#2-component-architecture)
3. [Data Flow Architecture](#3-data-flow-architecture)
4. [Backend API Endpoints](#4-backend-api-endpoints)
5. [Data Models & TypeScript Interfaces](#5-data-models--typescript-interfaces)
6. [State Management](#6-state-management)
7. [Implementation Details](#7-implementation-details)
   - [7.1 CourseDetail Component - Assignments Tab](#71-coursedetail-component---assignments-tab)
   - [7.2 AssignmentModal Component](#72-assignmentmodal-component)
   - [7.3 Assignment Service Layer](#73-assignment-service-layer)
8. [Three Assignment Types](#8-three-assignment-types)
   - [8.1 Assignment Type](#81-assignment-type)
   - [8.2 Lab Type](#82-lab-type)
   - [8.3 Project Type](#83-project-type)
9. [Feature Matrix](#9-feature-matrix)
10. [Data Transformation Pipeline](#10-data-transformation-pipeline)
11. [Complete Variable & Props Reference](#11-complete-variable--props-reference)
12. [User Interactions](#12-user-interactions)
13. [Loading, Error & Edge Cases](#13-loading-error--edge-cases)
14. [Mock Mode vs Live Mode](#14-mock-mode-vs-live-mode)
15. [Styling & UI/UX](#15-styling--uiux)
16. [Related Features & Cross-References](#16-related-features--cross-references)
17. [Debugging & Troubleshooting](#17-debugging--troubleshooting)

---

## 1. Feature Overview

### 1.1 Purpose

The Assignment Creation feature allows instructors to create three types of assessments within a course: **Assignments** (standard homework/quizzes), **Labs** (practical sessions with safety requirements), and **Projects** (team-based long-term work with milestones). This feature provides a unified modal interface with type-specific fields and configurations.

### 1.2 Key Concept: Three-in-One Interface

**Important:** Despite having three distinct types (Assignment, Lab, Project), they all use the **same modal component** (`AssignmentModal`) with conditional rendering. The type selection dynamically changes the form fields shown to the user.

### 1.3 User Journey

1. Instructor navigates to Courses in the dashboard
2. Instructor clicks on a specific course to view details
3. Instructor clicks the **Assignments** tab
4. Instructor clicks **"Create New Assignment"** button
5. AssignmentModal opens with type selector
6. Instructor selects type: **Assignment**, **Lab**, or **Project**
7. Form fields update based on selected type
8. Instructor fills out form and saves
9. Assignment appears in the Assignments Tab card list
10. Instructor can then: Edit, Delete, Publish, Upload Instructions, View Submissions, Grade

### 1.4 Key Capabilities

- ✅ Three assignment types: Assignment, Lab, Project
- ✅ Type-specific form fields
- ✅ Create, Edit, Delete assignments
- ✅ Draft/Open/Closed status management
- ✅ Publish workflow for drafts
- ✅ Upload instruction files (Google Drive integration)
- ✅ View submissions
- ✅ Manual grading
- ✅ AI Auto-grading (for auto-gradable assignments)
- ✅ Difficulty levels (Easy, Medium, Hard)
- ✅ Course selection
- ✅ Due date management
- ✅ Late submission handling
- ✅ Plagiarism detection (for assignments)
- ✅ Auto-grading support (for assignments)
- ✅ Safety requirements (for labs)
- ✅ Team configuration (for projects)
- ✅ Milestones management (for projects)
- ✅ Deliverables selection (for projects)

---

## 2. Component Architecture

### 2.1 Component Tree

```
InstructorDashboard
 └─ CoursesPage (when viewing course detail)
     └─ CourseDetail (courseId: number)
         ├─ Tab Navigation (overview, lectures, assignments, grading, students)
         └─ Assignments Tab (activeTab === 'assignments')
             ├─ Header with "Create New Assignment" button
             ├─ Assignment Cards List
             │   ├─ Assignment Card
             │   │   ├─ Title & Metadata
             │   │   ├─ Status Badge
             │   │   └─ Action Buttons
             │   │       ├─ View Submissions
             │   │       ├─ Edit
             │   │       ├─ Delete
             │   │       ├─ Upload Instructions
             │   │       ├─ Grade Manually
             │   │       └─ AI Auto-Grading
             │   └─ Assignment Card (next)
             └─ AssignmentModal (dialog)
                 ├─ Type Selector (Assignment/Lab/Project)
                 ├─ Common Fields
                 │   ├─ Title
                 │   ├─ Description
                 │   ├─ Course
                 │   ├─ Difficulty
                 │   ├─ Due Date
                 │   └─ Status
                 ├─ Assignment-Specific Fields
                 │   ├─ Auto-Grading Toggle
                 │   ├─ Plagiarism Detection Toggle
                 │   └─ Allow Late Submissions Toggle
                 ├─ Lab-Specific Fields
                 │   ├─ Lab Room Selector
                 │   ├─ Objectives
                 │   ├─ Equipment Needed
                 │   ├─ Procedure/Steps
                 │   ├─ Safety Requirements
                 │   │   ├─ Require Lab Coat
                 │   │   ├─ Require Safety Glasses
                 │   │   ├─ Require Gloves
                 │   │   └─ Safety Instructions
                 │   └─ Require Lab Report
                 └─ Project-Specific Fields
                     ├─ Scope
                     ├─ Learning Objectives
                     ├─ Team Configuration
                     │   ├─ Min Team Size
                     │   ├─ Max Team Size
                     │   └─ Allow Individual Work
                     ├─ Milestones
                     │   ├─ Add/Remove Milestones
                     │   └─ Weight Percentage
                     ├─ Deliverables
                     │   ├─ Documentation
                     │   ├─ Code
                     │   ├─ Report
                     │   └─ Presentation
                     └─ Additional
                         ├─ Require Presentation
                         ├─ Require Documentation
                         ├─ Enable Peer Review
                         └─ Allow Late Submissions
```

### 2.2 Component Files

| Component | File Path | Purpose | Lines |
|-----------|-----------|---------|-------|
| **CourseDetail** | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | Main course detail with Assignments Tab | 1198 |
| **AssignmentModal** | `src/pages/instructor-dashboard/components/AssignmentModal.tsx` | Creation/edit modal with type-specific fields | 828 |
| **AssignmentService** | `src/services/api/assignmentService.ts` | API service for assignments | 201 |
| **Assignment Types** | `src/types/api.ts` | TypeScript interfaces | ~100 |

### 2.3 Component Relationships

```
CourseDetail (lines 127-140, 273-330, 733-900)
  │
  ├─ State: showAssignmentForm (boolean)
  │   └─ Controls AssignmentModal visibility
  │
  ├─ State: assignmentForm (AssignmentFormData | null)
  │   └─ Form data for create/edit
  │
  ├─ State: editingAssignmentIndex (number | null)
  │   └─ Index of assignment being edited
  │
  ├─ Mutations:
  │   ├─ createAssignmentMutation (line 127-136)
  │   ├─ updateAssignmentMutation (line 138-147)
  │   └─ deleteAssignmentMutation (line 149-155)
  │
  ├─ Handlers:
  │   ├─ handleSaveAssignment (line 273-299)
  │   ├─ handleEditAssignment (line 302-324)
  │   ├─ handleDeleteAssignment (line 326-330)
  │   └─ handlePublishAssignment (line 332-342)
  │
  └─ Renders:
      ├─ AssignmentModal (line 754-761)
      │   └─ Props: open, assignment, courseOptions, onClose, onSave
      │
      └─ Assignment Cards (lines 766-900)
          └─ For each assignment in courseAssignments:
              ├─ Title, description, due date
              ├─ Status badge
              └─ Action buttons
```

---

## 3. Data Flow Architecture

### 3.1 High-Level Data Flow

```
User Click: "Create New Assignment"
    │
    ▼
AssignmentModal Opens
    │
    ├─ User selects type: Assignment/Lab/Project
    ├─ Form fields render based on type
    ├─ User fills out form
    └─ User clicks "Create" or "Save Draft"
    │
    ▼
handleSaveAssignment() (CourseDetail line 273-299)
    │
    ├─ Formats due date to ISO 8601
    ├─ Maps UI status to API status
    │   draft → draft
    │   open → published
    │   closed → closed
    ├─ Creates payload:
    │   {
    │     title, description, instructions,
    │     dueDate, status, courseId,
    │     maxScore, submissionType
    │   }
    │
    ▼
Mutation Executes
    │
    ├─ IF creating: createAssignmentMutation.mutate(payload)
    │   └─ POST /api/assignments
    │
    ├─ IF updating: updateAssignmentMutation.mutate({ id, data })
    │   └─ PATCH /api/assignments/{id}
    │
    ▼
Backend Response
    │
    ├─ Success (200/201)
    │   ├─ Returns Assignment object
    │   ├─ Toast notification shown
    │   ├─ Modal closes
    │   └─ Query invalidates: ['course-assignments', course?.id]
    │
    └─ Error (4xx/5xx)
        ├─ Error toast shown
        └─ Modal stays open
    │
    ▼
React Query Refetch
    │
    ├─ useQuery for course-assignments triggers
    ├─ New assignment appears in cards
    └─ UI updates
```

### 3.2 Assignment Creation Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ User Action: Click "Create New Assignment"                      │
│                                                                  │
│ 1. Navigate to Course → Assignments Tab                         │
│ 2. Click "Create New Assignment" button                         │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ CourseDetail - Button Handler (line 741-747)                   │
│                                                                  │
│ onClick={() => {                                                │
│   setAssignmentForm(null);           // Clear form data         │
│   setEditingAssignmentIndex(null);   // Not editing             │
│   setShowAssignmentForm(true);       // Open modal              │
│ }}                                                               │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ AssignmentModal Opens                                            │
│                                                                  │
│ 1. Form initializes with defaultFormData                         │
│ 2. Type Selector shows 3 options:                               │
│    ├─ Assignment (FileText icon, blue)                          │
│    ├─ Lab (FlaskConical icon, green)                            │
│    └─ Project (FolderKanban icon, amber)                        │
│ 3. Common fields render:                                        │
│    ├─ Title (required)                                          │
│    ├─ Description (optional)                                    │
│    ├─ Course dropdown (required, auto-selected)                 │
│    ├─ Difficulty selector (easy/medium/hard)                    │
│    ├─ Due Date picker (required)                                │
│    └─ Status dropdown (draft/open/closed)                       │
│ 4. Type-specific fields render based on selection               │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ User Fills Form (Example: Assignment Type)                      │
│                                                                  │
│ Title: "Homework 3: Recursion"                                  │
│ Description: "Practice recursive functions"                     │
│ Course: "CS201 - Data Structures"                               │
│ Difficulty: Medium                                               │
│ Due Date: 2024-11-15                                            │
│ Status: Draft                                                    │
│                                                                  │
│ Assignment Options:                                             │
│ ├─ Auto-Grading: OFF                                            │
│ ├─ Plagiarism Detection: ON                                     │
│ └─ Allow Late Submissions: OFF                                  │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ User Clicks "Create Assignment"                                  │
│                                                                  │
│ Form submission triggers:                                        │
│ onSubmit={handleSubmit} → handleSubmit(e)                        │
│   → e.preventDefault()                                          │
│   → onSave(formData)  // Calls CourseDetail.handleSaveAssignment│
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ CourseDetail - handleSaveAssignment (line 273-299)             │
│                                                                  │
│ 1. Format due date:                                             │
│    const formattedDueDate = data.dueDate                        │
│      ? new Date(data.dueDate).toISOString()                     │
│      : new Date().toISOString();                                │
│    Result: "2024-11-15T00:00:00.000Z"                          │
│                                                                  │
│ 2. Map UI status to API status:                                 │
│    const toApiStatus = (uiStatus) => {                          │
│      if (uiStatus === 'open') return 'published';               │
│      if (uiStatus === 'closed') return 'closed';                │
│      return 'draft';                                            │
│    };                                                           │
│    Result: 'draft' → 'draft'                                    │
│                                                                  │
│ 3. Create payload:                                              │
│    const payload = {                                            │
│      title: "Homework 3: Recursion",                           │
│      description: "Practice recursive functions",              │
│      instructions: "Practice recursive functions",             │
│      dueDate: "2024-11-15T00:00:00.000Z",                     │
│      status: 'draft',                                           │
│      courseId: 123,                                             │
│      maxScore: 100,                                             │
│      submissionType: 'file',                                    │
│    };                                                           │
│                                                                  │
│ 4. Execute mutation:                                            │
│    createAssignmentMutation.mutate(payload);                    │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ API Request                                                      │
│                                                                  │
│ POST /api/assignments                                            │
│ Headers:                                                         │
│   Authorization: Bearer {accessToken}                           │
│   Content-Type: application/json                                │
│ Body:                                                            │
│ {                                                                │
│   "title": "Homework 3: Recursion",                             │
│   "description": "Practice recursive functions",                │
│   "instructions": "Practice recursive functions",               │
│   "dueDate": "2024-11-15T00:00:00.000Z",                       │
│   "status": "draft",                                            │
│   "courseId": 123,                                              │
│   "maxScore": 100,                                              │
│   "submissionType": "file"                                      │
│ }                                                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ Backend Response (201 Created)                                   │
│                                                                  │
│ {                                                                │
│   "id": "assignment-uuid",                                      │
│   "courseId": "123",                                            │
│   "title": "Homework 3: Recursion",                             │
│   "description": "Practice recursive functions",                │
│   "status": "draft",                                            │
│   "dueDate": "2024-11-15T00:00:00.000Z",                       │
│   "maxScore": "100",                                            │
│   "submissionType": "file",                                     │
│   "createdBy": "instructor-id",                                 │
│   "createdAt": "2024-10-20T10:00:00.000Z"                      │
│ }                                                                │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ onSuccess Handler (line 130-135)                                │
│                                                                  │
│ 1. Invalidate query cache:                                      │
│    queryClient.invalidateQueries({                              │
│      queryKey: ['course-assignments', course?.id]               │
│    });                                                          │
│                                                                  │
│ 2. Close modal:                                                 │
│    setShowAssignmentForm(false);                                │
│    setAssignmentForm(null);                                     │
│    setEditingAssignmentIndex(null);                             │
│                                                                  │
│ 3. Show success toast:                                          │
│    toast.success('Assignment created successfully');            │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│ React Query Refetch                                              │
│                                                                  │
│ 1. useQuery for ['course-assignments', course?.id] triggers     │
│ 2. GET /api/assignments?courseId=123                            │
│ 3. Response includes new assignment                             │
│ 4. courseAssignments updates                                    │
│ 5. UI re-renders with new assignment card                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Backend API Endpoints

### 4.1 Primary Endpoints

#### Create Assignment

**Endpoint:** `POST /api/assignments`

**Used By:** `AssignmentService.create(data)`

**Request Body:**

```json
{
  "title": "Homework 3: Recursion",
  "description": "Practice recursive functions",
  "instructions": "Practice recursive functions",
  "dueDate": "2024-11-15T00:00:00.000Z",
  "status": "draft",
  "courseId": 123,
  "maxScore": 100,
  "submissionType": "file"
}
```

**Response (201 Created):**

```json
{
  "id": "assignment-uuid",
  "courseId": "123",
  "title": "Homework 3: Recursion",
  "description": "Practice recursive functions",
  "instructions": "Practice recursive functions",
  "dueDate": "2024-11-15T00:00:00.000Z",
  "availableFrom": null,
  "maxScore": "100",
  "weight": "10",
  "status": "draft",
  "submissionType": "file",
  "maxFileSize": 10485760,
  "allowedFileTypes": ["pdf", "docx"],
  "latePenalty": 0,
  "createdBy": "instructor-id",
  "createdAt": "2024-10-20T10:00:00.000Z",
  "updatedAt": "2024-10-20T10:00:00.000Z"
}
```

#### Update Assignment

**Endpoint:** `PATCH /api/assignments/{id}`

**Used By:** `AssignmentService.update(id, data)`

**Request Body (partial):**

```json
{
  "title": "Updated Title",
  "status": "published"
}
```

#### Delete Assignment

**Endpoint:** `DELETE /api/assignments/{id}`

**Used By:** `AssignmentService.delete(id)`

**Response (204 No Content):** Empty

#### Get Course Assignments

**Endpoint:** `GET /api/assignments?courseId={courseId}`

**Used By:** `AssignmentService.getAll({ courseId })`

**Response (200 OK):**

```json
[
  {
    "id": "assignment-uuid-1",
    "courseId": "123",
    "title": "Homework 1",
    "status": "published",
    "dueDate": "2024-10-01T00:00:00.000Z",
    "description": "First assignment"
  },
  {
    "id": "assignment-uuid-2",
    "courseId": "123",
    "title": "Homework 2",
    "status": "draft",
    "dueDate": "2024-10-15T00:00:00.000Z",
    "description": "Second assignment"
  }
]
```

#### Get Assignment Submissions

**Endpoint:** `GET /api/assignments/{id}/submissions`

**Used By:** `AssignmentService.getSubmissions(id)`

**Response (200 OK):**

```json
[
  {
    "id": "submission-uuid",
    "assignmentId": "assignment-uuid",
    "userId": 12345,
    "submissionText": null,
    "submissionLink": null,
    "driveFile": {
      "driveId": "google-drive-id",
      "fileName": "submission.pdf",
      "webViewLink": "https://drive.google.com/...",
      "downloadUrl": "https://drive.google.com/uc?export=download"
    },
    "submissionStatus": "submitted",
    "submittedAt": "2024-10-18T15:30:00.000Z",
    "isLate": 0,
    "score": null,
    "feedback": null,
    "user": {
      "userId": 12345,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john@edu.com"
    }
  }
]
```

#### Grade Submission

**Endpoint:** `PATCH /api/assignments/{assignmentId}/submissions/{submissionId}/grade`

**Used By:** `AssignmentService.gradeSubmission(assignmentId, submissionId, { score })`

**Request Body:**

```json
{
  "score": 95
}
```

#### Update Assignment Status

**Endpoint:** `PATCH /api/assignments/{id}/status`

**Used By:** `AssignmentService.updateStatus(id, status)`

**Request Body:**

```json
{
  "status": "published"
}
```

#### Upload Instructions

**Endpoint:** `POST /api/assignments/{id}/instructions/upload`

**Used By:** `AssignmentService.uploadInstructions(assignmentId, file, title)`

**Request:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | File | ✅ Yes | Instruction file to upload |
| `title` | string | ✅ Yes | File title |

**Response (201 Created):**

```json
{
  "driveId": "google-drive-id",
  "fileName": "instructions.pdf",
  "webViewLink": "https://drive.google.com/...",
  "iframeUrl": "https://drive.google.com/file/d/.../preview",
  "downloadUrl": "https://drive.google.com/uc?export=download&id=..."
}
```

### 4.2 All Assignment Endpoints Summary

| Endpoint | Method | Used In | Purpose |
|----------|--------|---------|---------|
| `/assignments` | GET | ✅ Assignments Tab | Get all assignments (with courseId filter) |
| `/assignments` | POST | ✅ Create Assignment | Create new assignment/lab/project |
| `/assignments/{id}` | GET | Assignment detail | Get single assignment |
| `/assignments/{id}` | PATCH | ✅ Edit Assignment | Update assignment |
| `/assignments/{id}` | DELETE | ✅ Delete Assignment | Delete assignment |
| `/assignments/{id}/status` | PATCH | ✅ Publish Assignment | Change status |
| `/assignments/{id}/submissions` | GET | ✅ View Submissions | Get all submissions |
| `/assignments/{id}/submissions/my` | GET | Student view | Get my submission |
| `/assignments/{id}/submit` | POST | Student submission | Submit assignment |
| `/assignments/{aId}/submissions/{sId}/grade` | PATCH | ✅ Manual Grading | Grade submission |
| `/assignments/{id}/instructions/upload` | POST | ✅ Upload Instructions | Upload instruction file |

---

## 5. Data Models & TypeScript Interfaces

### 5.1 AssignmentFormData (Modal Form State)

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx` (lines 7-43)

```typescript
export type AssignmentFormData = {
  /** Assignment ID (only present when editing) */
  id?: number;
  
  /** Assignment title (required) */
  title: string;
  
  /** Due date in YYYY-MM-DD format (required) */
  dueDate: string;
  
  /** Number of submissions received */
  submissions: number;
  
  /** Assignment status */
  status: 'draft' | 'open' | 'closed';
  
  /** ⭐ ASSIGNMENT TYPE - Determines which fields are shown */
  assignmentType?: 'assignment' | 'lab' | 'project';
  
  /** Brief description */
  description?: string;
  
  /** Course ID */
  course?: string;
  
  /** Difficulty level */
  difficulty?: 'easy' | 'medium' | 'hard';
  
  /** Auto-grading enabled (for assignment type) */
  autoGrading?: boolean;
  
  /** Plagiarism detection enabled (for assignment type) */
  plagiarismDetection?: boolean;
  
  /** Lab room location (for lab type) */
  labRoom?: string;
  
  /** Lab objectives (for lab type) */
  objectives?: string;
  
  /** Equipment needed (for lab type) */
  equipment?: string;
  
  /** Procedure/steps (for lab type) */
  procedure?: string;
  
  /** Estimated duration in hours (for lab type) */
  estimatedDuration?: number;
  
  /** Require lab coat (for lab type) */
  requireLabCoat?: boolean;
  
  /** Require safety glasses (for lab type) */
  requireSafetyGlasses?: boolean;
  
  /** Require gloves (for lab type) */
  requireGloves?: boolean;
  
  /** Safety instructions (for lab type) */
  safetyInstructions?: string;
  
  /** Require lab report submission (for lab type) */
  requireLabReport?: boolean;
  
  /** Project scope (for project type) */
  scope?: string;
  
  /** Learning objectives (for project type) */
  learningObjectives?: string;
  
  /** Resources needed (for project type) */
  resources?: string;
  
  /** Minimum team size (for project type) */
  minTeamSize?: number;
  
  /** Maximum team size (for project type) */
  maxTeamSize?: number;
  
  /** Allow individual work (for project type) */
  allowIndividual?: boolean;
  
  /** Project milestones with weight percentages (for project type) */
  milestones?: Array<{ title: string; weight: number }>;
  
  /** Required deliverables (for project type) */
  deliverables?: string[];
  
  /** Require final presentation (for project type) */
  requirePresentation?: boolean;
  
  /** Require documentation (for project type) */
  requireDocumentation?: boolean;
  
  /** Enable peer review (for project type) */
  enablePeerReview?: boolean;
  
  /** Allow late submissions (for assignment and project types) */
  allowLateSubmissions?: boolean;
  
  /** Allow group work */
  groupWork?: boolean;
  
  /** Attached file URLs */
  attachments?: string[];
};
```

### 5.2 Assignment (Backend Response)

**Source:** `src/services/api/assignmentService.ts` (lines 10-31)

```typescript
export interface Assignment {
  /** Unique assignment ID (UUID string) */
  id: string;
  
  /** Course ID */
  courseId: string;
  
  /** Title */
  title: string;
  
  /** Description (nullable) */
  description: string | null;
  
  /** Instructions in Markdown (nullable) */
  instructions: string | null;
  
  /** Due date in ISO 8601 format (nullable) */
  dueDate: string | null;
  
  /** Available from date (nullable) */
  availableFrom: string | null;
  
  /** Maximum score (decimal as string, e.g., "100") */
  maxScore: string;
  
  /** Weight percentage (decimal as string, e.g., "10") */
  weight: string;
  
  /** Status */
  status: 'draft' | 'published' | 'closed' | 'archived';
  
  /** Submission type */
  submissionType: 'text' | 'file' | 'link' | 'any';
  
  /** Maximum file size in bytes (optional) */
  maxFileSize?: number;
  
  /** Allowed file extensions (optional) */
  allowedFileTypes?: string[];
  
  /** Late penalty percentage per day (optional) */
  latePenalty?: number;
  
  /** Creator ID */
  createdBy: string;
  
  /** Timestamps */
  createdAt?: string;
  updatedAt?: string;
  
  /** Nested course object */
  course?: { id: string; name: string; code: string };
  
  /** Instruction files (Google Drive) */
  instructionFiles?: DriveFileLink[];
}
```

### 5.3 AssignmentSubmission

**Source:** `src/services/api/assignmentService.ts` (lines 35-54)

```typescript
export interface AssignmentSubmission {
  /** Submission ID */
  id: string;
  
  /** Assignment ID */
  assignmentId: string;
  
  /** Student user ID */
  userId: number;
  
  /** Text submission */
  submissionText: string | null;
  
  /** Link submission */
  submissionLink: string | null;
  
  /** File ID (legacy) */
  fileId: number | null;
  
  /** Google Drive file info */
  file?: { id: number; name: string; url: string };
  
  /** Google Drive file link */
  driveFile?: DriveFileLink | null;
  
  /** Submission status */
  submissionStatus: 'pending' | 'submitted' | 'graded';
  
  /** Submission timestamp */
  submittedAt: string;
  
  /** Late flag (0 or 1) */
  isLate: number;
  
  /** Attempt number */
  attemptNumber?: number;
  
  /** Grade score */
  score?: string;
  
  /** Instructor feedback */
  feedback?: string;
  
  /** Grader user ID */
  gradedBy?: number;
  
  /** Grade timestamp */
  gradedAt?: string;
  
  /** Student info */
  user?: { 
    userId: number; 
    firstName: string; 
    lastName: string; 
    email: string 
  };
}
```

### 5.4 DriveFileLink

**Source:** `src/services/api/assignmentService.ts` (lines 3-8)

```typescript
export interface DriveFileLink {
  /** Google Drive file ID */
  driveId: string;
  
  /** File name */
  fileName: string;
  
  /** Web view URL */
  webViewLink: string;
  
  /** iframe embed URL */
  iframeUrl: string;
  
  /** Download URL */
  downloadUrl: string;
}
```

### 5.5 Type Configuration

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx` (lines 79-83)

```typescript
const TYPE_CONFIG = {
  assignment: { 
    label: 'Assignment', 
    icon: FileText, 
    color: 'blue' 
  },
  lab: { 
    label: 'Lab', 
    icon: FlaskConical, 
    color: 'green' 
  },
  project: { 
    label: 'Project', 
    icon: FolderKanban, 
    color: 'amber' 
  },
} as const;
```

### 5.6 Default Form Data

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx` (lines 84-116)

```typescript
const defaultFormData: AssignmentFormData = {
  title: '',
  dueDate: '',
  submissions: 0,
  status: 'draft',
  assignmentType: 'assignment',
  description: '',
  course: '',
  difficulty: undefined,
  autoGrading: false,
  plagiarismDetection: false,
  allowLateSubmissions: false,
  // Lab fields
  labRoom: '',
  objectives: '',
  equipment: '',
  procedure: '',
  estimatedDuration: undefined,
  requireLabCoat: false,
  requireSafetyGlasses: false,
  requireGloves: false,
  safetyInstructions: '',
  requireLabReport: false,
  // Project fields
  scope: '',
  learningObjectives: '',
  minTeamSize: 2,
  maxTeamSize: 4,
  allowIndividual: false,
  milestones: [],
  deliverables: [],
  requirePresentation: false,
  requireDocumentation: false,
  enablePeerReview: false,
};
```

### 5.7 Lab Rooms

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx` (line 85)

```typescript
const LAB_ROOMS = [
  'Lab A-101',
  'Lab A-102',
  'Lab B-201',
  'Lab C-301',
  'Virtual Lab'
];
```

### 5.8 Project Deliverables

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx` (line 86)

```typescript
const DELIVERABLE_OPTIONS = [
  'Documentation',
  'Code',
  'Report',
  'Presentation'
];
```

---

## 6. State Management

### 6.1 CourseDetail Component State

**Source:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`

#### Assignment-Related State Variables

| Variable | Type | Initial Value | Purpose | Lines |
|----------|------|---------------|---------|-------|
| `showAssignmentForm` | `boolean` | `false` | Controls AssignmentModal visibility | 64 |
| `assignmentForm` | `AssignmentFormData \| null` | `null` | Form data for create/edit | 65 |
| `editingAssignmentIndex` | `number \| null` | `null` | Index of assignment being edited | 66 |
| `gradingSubTab` | `'manual' \| 'auto'` | `'manual'` | Grading sub-tab selection | 67 |

#### React Query Hooks (Assignment Related)

| Hook | Query Key | Data Type | Enabled Condition | Lines |
|------|-----------|-----------|-------------------|-------|
| `useQuery` for assignments | `['course-assignments', course?.id]` | `Assignment[]` | `!!course?.id && !isMockMode` | 110-114 |
| `useQuery` for submissions | `['assignment-submissions', selectedAssignmentIdForGrading]` | `AssignmentSubmission[]` | `!!selectedAssignmentIdForGrading && !isMockMode` | 216-220 |

#### Mutations (Assignment Related)

| Mutation | Purpose | Success Handler | Error Handler | Lines |
|----------|---------|-----------------|---------------|-------|
| `createAssignmentMutation` | Create new assignment | Invalidate cache, close modal, show success toast | Show error toast | 127-136 |
| `updateAssignmentMutation` | Update existing assignment | Invalidate cache, close modal, show success toast | Show error toast | 138-147 |
| `deleteAssignmentMutation` | Delete assignment | Invalidate cache, show success toast | Show error toast | 149-155 |
| `uploadInstructionMutation` | Upload instruction file | Invalidate cache, show success toast | Show error toast | 157-168 |
| `gradeSubmissionMutation` | Grade a submission | Invalidate submissions cache, clear draft grades, show success toast | Show error toast | 222-237 |

### 6.2 AssignmentModal Component State

**Source:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx`

#### Local State Variables

| Variable | Type | Initial Value | Purpose | Lines |
|----------|------|---------------|---------|-------|
| `formData` | `AssignmentFormData` | `defaultFormData` | Current form data | 126 |

#### Refs

| Ref | Type | Purpose | Lines |
|-----|------|---------|-------|
| `modalRef` | `RefObject<HTMLDivElement>` | Focus management, focus trap | 122 |
| `previousActiveElement` | `RefObject<HTMLElement \| null>` | Restore focus on close | 123 |

#### Helper Functions

| Function | Purpose | Lines |
|----------|---------|-------|
| `update<K>` | Type-safe form field update | 191 |
| `addMilestone` | Add new milestone to array | 193-195 |
| `removeMilestone` | Remove milestone by index | 197-201 |
| `updateMilestone` | Update milestone field | 203-207 |
| `toggleDeliverable` | Toggle deliverable checkbox | 209-214 |

---

## 7. Implementation Details

### 7.1 CourseDetail Component - Assignments Tab

**File:** `src/pages/instructor-dashboard/components/CourseDetail.tsx`  
**Lines:** 733-900

#### Header Section (lines 736-748)

```typescript
<div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
  <h2 className={`text-2xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
    {t('assignments')}
  </h2>
  <button
    onClick={() => {
      setAssignmentForm(null);
      setEditingAssignmentIndex(null);
      setShowAssignmentForm(true);
    }}
    className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors text-sm"
  >
    <FileText size={16} />
    Create New Assignment
  </button>
</div>
```

#### AssignmentModal Integration (lines 754-761)

```typescript
<AssignmentModal
  open={showAssignmentForm}
  assignment={assignmentForm}
  courseOptions={[
    { value: String(course.id), label: `${course.courseCode} - ${course.courseName}` },
  ]}
  onClose={() => setShowAssignmentForm(false)}
  onSave={handleSaveAssignment}
/>
```

**Props Passed:**

| Prop | Value | Purpose |
|------|-------|---------|
| `open` | `showAssignmentForm` | Modal visibility |
| `assignment` | `assignmentForm` | Form data (null for create) |
| `courseOptions` | Array with current course | Course dropdown options |
| `onClose` | `() => setShowAssignmentForm(false)` | Close handler |
| `onSave` | `handleSaveAssignment` | Save handler |

#### Assignment Cards Rendering (lines 766-900)

```typescript
{courseAssignments.map((assignment, index) => {
  const normalizedStatus = String(assignment.status || 'draft').toLowerCase();
  return (
    <div key={assignment.id} className={`rounded-xl p-6 border shadow-sm`}>
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-start justify-between mb-4 gap-2">
        <div className="flex-1">
          <div className="flex flex-wrap items-center gap-2 sm:gap-3 mb-2">
            <h3 className={`text-lg font-semibold`}>
              {assignment.title}
            </h3>
            <span className={`px-2 py-1 rounded-full text-xs font-medium bg-indigo-100 text-indigo-700`}>
              {course.courseName}
            </span>
          </div>
          
          {/* Metadata */}
          <div className={`flex items-center gap-4 text-sm mb-3`}>
            <div className="flex items-center gap-1">
              <Calendar size={14} />
              <span>
                {assignment.dueDate
                  ? new Date(assignment.dueDate).toLocaleDateString()
                  : 'No due date'}
              </span>
            </div>
            <div className="flex items-center gap-1">
              <Users size={14} />
              <span>0/{course.enrolled} Submitted</span>
            </div>
          </div>
          
          {/* Description */}
          <p className={`text-sm mb-4`}>
            {assignment.description}
          </p>
        </div>
        
        {/* Status Badge */}
        <span className={`px-3 py-1 rounded-full text-xs font-medium ${
          normalizedStatus === 'published' 
            ? 'bg-green-100 text-green-700' 
            : 'bg-yellow-100 text-yellow-700'
        }`}>
          {normalizedStatus.toUpperCase()}
        </span>
      </div>
      
      {/* Action Buttons */}
      <div className={`flex flex-wrap items-center gap-2 pt-4 border-t`}>
        <button onClick={() => {
          setActiveTab('grading');
          setGradingSubTab('manual');
          setSelectedAssignmentIdForGrading(String(assignment.id));
        }}>
          View Submissions
        </button>
        <button onClick={() => handleEditAssignment(index)}>
          Edit
        </button>
        <button onClick={() => handleDeleteAssignment(Number(assignment.id))}>
          Delete
        </button>
        <label className="cursor-pointer">
          {uploadingInstructionId === Number(assignment.id)
            ? 'Uploading...'
            : 'Upload Instructions'}
          <input
            type="file"
            className="hidden"
            onChange={(e) => {
              handleUploadInstruction(Number(assignment.id), e.target.files?.[0] || null);
              e.currentTarget.value = '';
            }}
          />
        </label>
        <button onClick={() => {
          setActiveTab('grading');
          setGradingSubTab('manual');
          setSelectedAssignmentIdForGrading(String(assignment.id));
        }}>
          Grade Manually
        </button>
        <button onClick={() => {
          setActiveTab('grading');
          setGradingSubTab('auto');
        }}>
          <Sparkles size={16} />
          AI Auto-Grading
        </button>
        {normalizedStatus === 'draft' && (
          <button onClick={() => handlePublishAssignment(index)}>
            Publish
          </button>
        )}
      </div>
    </div>
  );
})}
```

### 7.2 AssignmentModal Component

**File:** `src/pages/instructor-dashboard/components/AssignmentModal.tsx`  
**Total Lines:** 828

#### Modal Structure

```typescript
<div className="fixed inset-0 bg-black/10 backdrop-blur-sm flex items-center justify-center z-50">
  <div
    ref={modalRef}
    role="dialog"
    aria-modal="true"
    aria-labelledby="assignment-modal-title"
    tabIndex={-1}
    onKeyDown={handleKeyDown}
    className={`rounded-lg shadow-xl w-full max-w-2xl mx-4 flex flex-col max-h-[90vh]`}
  >
    {/* Header */}
    <div className={`flex items-center justify-between p-6 border-b shrink-0`}>
      <h2 id="assignment-modal-title" className={`text-xl font-semibold`}>
        {assignment ? `Edit ${typeLabel}` : `Create New ${typeLabel}`}
      </h2>
      <button onClick={onClose} aria-label="Close dialog">
        <X size={24} />
      </button>
    </div>

    {/* Form */}
    <form onSubmit={handleSubmit} className="p-6 space-y-5 overflow-y-auto max-h-[80vh]">
      {/* Type Selector */}
      <div>
        <label>Type</label>
        <div className="grid grid-cols-3 gap-2">
          {Object.keys(TYPE_CONFIG).map((type) => (
            <button
              key={type}
              type="button"
              onClick={() => update('assignmentType', type)}
              className={`flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg border-2`}
            >
              <Icon size={16} />
              {cfg.label}
            </button>
          ))}
        </div>
      </div>

      {/* Common Fields */}
      <div className="space-y-4">
        <div>
          <label>Title</label>
          <input
            type="text"
            required
            value={formData.title}
            onChange={(e) => update('title', e.target.value)}
            placeholder={`e.g., ${assignmentType === 'lab' ? 'Lab 3: Circuit Analysis' : ...}`}
          />
        </div>
        <div>
          <label>Description</label>
          <textarea rows={3} value={formData.description} onChange={...} />
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label>Course</label>
            <CleanSelect value={formData.course} onChange={...}>
              {courses.map(course => <option key={course.value} ...>)}
            </CleanSelect>
          </div>
          <div>
            <label>Difficulty</label>
            <div className="flex gap-1">
              {['easy', 'medium', 'hard'].map(d => (
                <button onClick={() => update('difficulty', d)}>
                  {d}
                </button>
              ))}
            </div>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label>Due Date</label>
            <input type="date" required value={toInputDate(formData.dueDate)} onChange={...} />
          </div>
          <div>
            <label>Status</label>
            <CleanSelect value={formData.status} onChange={...}>
              <option value="draft">Draft</option>
              <option value="open">Open</option>
              <option value="closed">Closed</option>
            </CleanSelect>
          </div>
        </div>
      </div>

      {/* Type-Specific Fields */}
      {assignmentType === 'assignment' && (
        <div className={`border rounded-lg p-4 space-y-3`}>
          <p>Assignment Options</p>
          <Toggle label="Auto-Grading" value={formData.autoGrading} onChange={...} />
          <Toggle label="Plagiarism Detection" value={formData.plagiarismDetection} onChange={...} />
          <Toggle label="Allow Late Submissions" value={formData.allowLateSubmissions} onChange={...} />
        </div>
      )}

      {assignmentType === 'lab' && (
        <div className={`border rounded-lg p-4 space-y-4`}>
          <p>Lab Details</p>
          {/* Lab Room, Duration, Objectives, Equipment, Procedure */}
          {/* Safety Requirements Section */}
          <div className={`border rounded-lg p-3 space-y-3`}>
            <p>Safety Requirements</p>
            <Toggle label="Require Lab Coat" value={formData.requireLabCoat} onChange={...} />
            <Toggle label="Require Safety Glasses" value={formData.requireSafetyGlasses} onChange={...} />
            <Toggle label="Require Gloves" value={formData.requireGloves} onChange={...} />
            <textarea label="Safety Instructions" value={formData.safetyInstructions} onChange={...} />
          </div>
          <Toggle label="Require Lab Report" value={formData.requireLabReport} onChange={...} />
        </div>
      )}

      {assignmentType === 'project' && (
        <div className={`border rounded-lg p-4 space-y-4`}>
          <p>Project Details</p>
          {/* Scope, Learning Objectives */}
          {/* Team Configuration */}
          <div className={`border rounded-lg p-3 space-y-3`}>
            <p>Team Configuration</p>
            <input label="Min Team Size" value={formData.minTeamSize} onChange={...} />
            <input label="Max Team Size" value={formData.maxTeamSize} onChange={...} />
            <Toggle label="Allow Individual Work" value={formData.allowIndividual} onChange={...} />
          </div>
          {/* Milestones */}
          <div>
            <label>Milestones</label>
            <button onClick={addMilestone}>+ Add Milestone</button>
            {formData.milestones.map((m, i) => (
              <div key={i} className="flex gap-2 items-center">
                <input value={m.title} onChange={...} placeholder="Milestone title" />
                <input value={m.weight} onChange={...} placeholder="%" />
                <button onClick={() => removeMilestone(i)}><Trash2 /></button>
              </div>
            ))}
          </div>
          {/* Deliverables */}
          <div>
            <label>Deliverables</label>
            <div className="flex flex-wrap gap-2">
              {DELIVERABLE_OPTIONS.map(item => (
                <label key={item}>
                  <input type="checkbox" checked={formData.deliverables.includes(item)} onChange={...} />
                  {item}
                </label>
              ))}
            </div>
          </div>
          {/* Additional Toggles */}
          <Toggle label="Require Presentation" value={formData.requirePresentation} onChange={...} />
          <Toggle label="Require Documentation" value={formData.requireDocumentation} onChange={...} />
          <Toggle label="Enable Peer Review" value={formData.enablePeerReview} onChange={...} />
        </div>
      )}

      {/* Submit Buttons */}
      <div className="flex gap-3 pt-4">
        <button type="button" onClick={onClose}>
          Cancel
        </button>
        {assignment && (
          <button type="button" onClick={handleSaveDraft}>
            Save as Draft
          </button>
        )}
        <button type="submit">
          {assignment ? 'Save Changes' : `Create ${typeLabel}`}
        </button>
      </div>
    </form>
  </div>
</div>
```

### 7.3 Assignment Service Layer

**File:** `src/services/api/assignmentService.ts`  
**Total Lines:** 201

#### Key Methods

```typescript
export class AssignmentService {
  // Get all assignments with optional courseId filter
  static async getAll(params?: { courseId?: string }): Promise<Assignment[]> {
    return ApiClient.get<Assignment[]>('/assignments', { params });
  }

  // Get assignment by ID
  static async getById(id: string): Promise<Assignment> {
    return ApiClient.get<Assignment>('/assignments/' + id);
  }

  // Create assignment
  static async create(data: Partial<Assignment>): Promise<Assignment> {
    return ApiClient.post<Assignment>('/assignments', data);
  }

  // Update assignment
  static async update(id: string, data: Partial<Assignment>): Promise<Assignment> {
    return ApiClient.patch<Assignment>('/assignments/' + id, data);
  }

  // Delete assignment
  static async delete(id: string): Promise<void> {
    return ApiClient.delete('/assignments/' + id);
  }

  // Get submissions for an assignment
  static async getSubmissions(assignmentId: string): Promise<AssignmentSubmission[]> {
    return ApiClient.get<AssignmentSubmission[]>(
      '/assignments/' + assignmentId + '/submissions'
    );
  }

  // Grade a submission
  static async gradeSubmission(
    assignmentId: string, 
    submissionId: number, 
    data: { score: number }
  ): Promise<AssignmentSubmission> {
    return ApiClient.patch<AssignmentSubmission>(
      '/assignments/' + assignmentId + '/submissions/' + submissionId + '/grade',
      data
    );
  }

  // Update assignment status
  static async updateStatus(id: string, status: Assignment['status']): Promise<Assignment> {
    return ApiClient.patch<Assignment>('/assignments/' + id + '/status', { status });
  }

  // Upload instruction files
  static async uploadInstructions(
    assignmentId: string,
    file: File,
    title: string
  ): Promise<DriveFileLink> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('title', title);
    return ApiClient.post<DriveFileLink>(
      '/assignments/' + assignmentId + '/instructions/upload',
      formData
    );
  }
}
```

---

## 8. Three Assignment Types

### 8.1 Assignment Type

**Icon:** `FileText` (lucide-react)  
**Color:** Blue (`bg-blue-50`, `text-blue-700`)  
**Use Case:** Standard homework, quizzes, exercises

#### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| Title | text | ✅ Yes | `""` | Assignment title |
| Description | textarea | No | `""` | Brief description |
| Course | select | ✅ Yes | auto-selected | Course dropdown |
| Difficulty | button group | No | `undefined` | easy/medium/hard |
| Due Date | date | ✅ Yes | `""` | Due date picker |
| Status | select | No | `draft` | draft/open/closed |
| Auto-Grading | toggle | No | `false` | Enable auto-grading |
| Plagiarism Detection | toggle | No | `false` | Enable plagiarism check |
| Allow Late Submissions | toggle | No | `false` | Accept late submissions |

#### Features

- **Auto-Grading:** Automatically grades submissions (for MCQ, fill-in-blank, etc.)
- **Plagiarism Detection:** Compares submissions for similarity
- **Late Submissions:** Allows students to submit after due date
- **File Upload:** Students can upload files as submissions
- **Text Submission:** Students can type text directly
- **Link Submission:** Students can submit URLs

#### Placeholder Examples

```typescript
placeholder="e.g., Quiz 1: Variables"
```

### 8.2 Lab Type

**Icon:** `FlaskConical` (lucide-react)  
**Color:** Green (`bg-green-50`, `text-green-700`)  
**Use Case:** Lab sessions, practical experiments, workshops

#### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| Title | text | ✅ Yes | `""` | Lab title |
| Description | textarea | No | `""` | Brief description |
| Course | select | ✅ Yes | auto-selected | Course dropdown |
| Difficulty | button group | No | `undefined` | easy/medium/hard |
| Due Date | date | ✅ Yes | `""` | Due date picker |
| Status | select | No | `draft` | draft/open/closed |
| Lab Room | select | No | `""` | Lab location dropdown |
| Objectives | textarea | No | `""` | Lab objectives |
| Equipment Needed | textarea | No | `""` | Required equipment |
| Procedure/Steps | textarea | No | `""` | Step-by-step procedure |
| Estimated Duration | number | No | `undefined` | Hours (e.g., 2, 2.5, 3) |
| Require Lab Coat | toggle | No | `false` | Safety requirement |
| Require Safety Glasses | toggle | No | `false` | Safety requirement |
| Require Gloves | toggle | No | `false` | Safety requirement |
| Safety Instructions | textarea | No | `""` | Additional safety info |
| Require Lab Report | toggle | No | `false` | Require report submission |

#### Lab Rooms

```typescript
const LAB_ROOMS = [
  'Lab A-101',
  'Lab A-102',
  'Lab B-201',
  'Lab C-301',
  'Virtual Lab'
];
```

#### Safety Requirements Section

Lab type includes a dedicated safety requirements section with:
- Lab coat toggle
- Safety glasses toggle
- Gloves toggle
- Safety instructions textarea

#### Placeholder Examples

```typescript
placeholder="e.g., Lab 3: Circuit Analysis"
```

### 8.3 Project Type

**Icon:** `FolderKanban` (lucide-react)  
**Color:** Amber (`bg-amber-50`, `text-amber-700`)  
**Use Case:** Long-term team projects, capstone projects, final projects

#### Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| Title | text | ✅ Yes | `""` | Project title |
| Description | textarea | No | `""` | Brief description |
| Course | select | ✅ Yes | auto-selected | Course dropdown |
| Difficulty | button group | No | `undefined` | easy/medium/hard |
| Due Date | date | ✅ Yes | `""` | Due date picker |
| Status | select | No | `draft` | draft/open/closed |
| Scope | textarea | No | `""` | Project scope |
| Learning Objectives | textarea | No | `""` | What students will learn |
| Min Team Size | number | No | `2` | Minimum team members |
| Max Team Size | number | No | `4` | Maximum team members |
| Allow Individual Work | toggle | No | `false` | Allow solo work |
| Milestones | array | No | `[]` | Project milestones |
| Deliverables | multi-select | No | `[]` | Required deliverables |
| Require Presentation | toggle | No | `false` | Final presentation required |
| Require Documentation | toggle | No | `false` | Documentation required |
| Enable Peer Review | toggle | No | `false` | Enable peer review |
| Allow Late Submissions | toggle | No | `false` | Accept late submissions |

#### Team Configuration

```typescript
minTeamSize: 2,
maxTeamSize: 4,
allowIndividual: false
```

#### Milestones

**Structure:**

```typescript
milestones?: Array<{ 
  title: string;    // Milestone name
  weight: number;   // Percentage weight (0-100)
}>;
```

**Operations:**

| Operation | Function | Description |
|-----------|----------|-------------|
| Add | `addMilestone()` | Adds empty milestone `{ title: '', weight: 0 }` |
| Remove | `removeMilestone(index)` | Removes milestone at index |
| Update | `updateMilestone(index, field, value)` | Updates title or weight |

**UI:**

- Add Milestone button with Plus icon
- Each milestone has:
  - Text input for title
  - Number input for weight percentage
  - Delete button with Trash2 icon

#### Deliverables

**Options:**

```typescript
const DELIVERABLE_OPTIONS = [
  'Documentation',
  'Code',
  'Report',
  'Presentation'
];
```

**UI:** Checkbox-style buttons that toggle on/off

#### Placeholder Examples

```typescript
placeholder="e.g., Final Project: Web App"
```

---

## 9. Feature Matrix

### 9.1 Type Comparison

| Feature | Assignment | Lab | Project |
|---------|:----------:|:---:|:-------:|
| **Title** | ✅ | ✅ | ✅ |
| **Description** | ✅ | ✅ | ✅ |
| **Course Selection** | ✅ | ✅ | ✅ |
| **Difficulty Level** | ✅ | ✅ | ✅ |
| **Due Date** | ✅ | ✅ | ✅ |
| **Status Management** | ✅ | ✅ | ✅ |
| **Auto-Grading** | ✅ | ❌ | ❌ |
| **Plagiarism Detection** | ✅ | ❌ | ❌ |
| **Allow Late Submissions** | ✅ | ❌ | ✅ |
| **Lab Room Selection** | ❌ | ✅ | ❌ |
| **Objectives** | ❌ | ✅ | ❌ |
| **Equipment Needed** | ❌ | ✅ | ❌ |
| **Procedure/Steps** | ❌ | ✅ | ❌ |
| **Estimated Duration** | ❌ | ✅ | ❌ |
| **Safety Requirements** | ❌ | ✅ | ❌ |
| **- Lab Coat** | ❌ | ✅ | ❌ |
| **- Safety Glasses** | ❌ | ✅ | ❌ |
| **- Gloves** | ❌ | ✅ | ❌ |
| **- Safety Instructions** | ❌ | ✅ | ❌ |
| **Require Lab Report** | ❌ | ✅ | ❌ |
| **Project Scope** | ❌ | ❌ | ✅ |
| **Learning Objectives** | ❌ | ❌ | ✅ |
| **Team Configuration** | ❌ | ❌ | ✅ |
| **- Min Team Size** | ❌ | ❌ | ✅ |
| **- Max Team Size** | ❌ | ❌ | ✅ |
| **- Allow Individual Work** | ❌ | ❌ | ✅ |
| **Milestones** | ❌ | ❌ | ✅ |
| **Deliverables** | ❌ | ❌ | ✅ |
| **Require Presentation** | ❌ | ❌ | ✅ |
| **Require Documentation** | ❌ | ❌ | ✅ |
| **Enable Peer Review** | ❌ | ❌ | ✅ |

### 9.2 Common Features (All Types)

| Feature | Description |
|---------|-------------|
| Create | Create new assignment/lab/project |
| Edit | Edit existing assignment |
| Delete | Delete with confirmation |
| View Submissions | See all student submissions |
| Manual Grading | Grade submissions manually |
| Upload Instructions | Upload instruction files |
| Status Management | Draft → Published → Closed |
| Course Assignment | Assign to specific course |

### 9.3 Submission Types (Backend)

| Submission Type | Description | Supported By |
|-----------------|-------------|--------------|
| `text` | Plain text submission | Assignment |
| `file` | File upload | Assignment, Lab, Project |
| `link` | URL submission | Assignment |
| `any` | Any submission type | Assignment |

**Note:** The frontend modal does NOT expose `submissionType` in the form. It's hardcoded to `'file'` in the payload (CourseDetail line 291).

---

## 10. Data Transformation Pipeline

### 10.1 Complete Transformation Flow

```
┌──────────────────────────────────────────────────────────────┐
│ User Input in AssignmentModal                                │
│                                                              │
│ formData: {                                                  │
│   title: "Homework 3: Recursion",                           │
│   description: "Practice recursive functions",              │
│   course: "123",                                             │
│   difficulty: "medium",                                      │
│   dueDate: "2024-11-15",                                    │
│   status: "draft",                                           │
│   assignmentType: "assignment",                             │
│   autoGrading: false,                                        │
│   plagiarismDetection: true,                                 │
│   allowLateSubmissions: false                                │
│ }                                                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ handleSaveAssignment (CourseDetail line 273-299)            │
│                                                              │
│ 1. Format due date:                                         │
│    const formattedDueDate = new Date("2024-11-15")          │
│      .toISOString();                                         │
│    Result: "2024-11-15T00:00:00.000Z"                       │
│                                                              │
│ 2. Map UI status to API status:                             │
│    toApiStatus("draft") → "draft"                            │
│    toApiStatus("open") → "published"                         │
│    toApiStatus("closed") → "closed"                          │
│                                                              │
│ 3. Create API payload:                                      │
│    {                                                        │
│      title: "Homework 3: Recursion",                       │
│      description: "Practice recursive functions",          │
│      instructions: "Practice recursive functions",         │
│      dueDate: "2024-11-15T00:00:00.000Z",                 │
│      status: "draft",                                       │
│      courseId: 123,                                         │
│      maxScore: 100,                                         │
│      submissionType: "file"  ← ⚠️ HARDCODED                │
│    }                                                        │
│                                                              │
│ ⚠️ LOST DATA:                                               │
│ - assignmentType (not sent to backend)                      │
│ - difficulty (not sent to backend)                          │
│ - autoGrading (not sent to backend)                         │
│ - plagiarismDetection (not sent to backend)                 │
│ - allowLateSubmissions (not sent to backend)                │
│ - All lab-specific fields (not sent to backend)             │
│ - All project-specific fields (not sent to backend)         │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ API Request                                                   │
│                                                              │
│ POST /api/assignments                                        │
│ Body: { title, description, instructions, dueDate,          │
│         status, courseId, maxScore, submissionType }        │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Backend Response                                              │
│                                                              │
│ {                                                            │
│   id: "assignment-uuid",                                     │
│   title: "Homework 3: Recursion",                           │
│   description: "Practice recursive functions",              │
│   status: "draft",                                           │
│   dueDate: "2024-11-15T00:00:00.000Z",                      │
│   maxScore: "100",                                           │
│   submissionType: "file",                                    │
│   courseId: "123",                                           │
│   createdBy: "instructor-id",                                │
│   createdAt: "2024-10-20T10:00:00.000Z"                     │
│ }                                                            │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ React Query Cache Update                                      │
│                                                              │
│ 1. Invalidate ['course-assignments', course?.id]            │
│ 2. Refetch GET /api/assignments?courseId=123                │
│ 3. Update courseAssignments array                           │
│ 4. UI re-renders with new assignment card                   │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Assignment Card Display                                       │
│                                                              │
│ Title: Homework 3: Recursion                                │
│ Description: Practice recursive functions                   │
│ Due Date: Nov 15, 2024                                      │
│ Status: DRAFT (yellow badge)                                │
│ Submissions: 0/{course.enrolled} Submitted                  │
│                                                              │
│ Actions:                                                     │
│ - View Submissions                                          │
│ - Edit                                                      │
│ - Delete                                                    │
│ - Upload Instructions                                       │
│ - Grade Manually                                            │
│ - AI Auto-Grading                                           │
│ - Publish (if draft)                                        │
└──────────────────────────────────────────────────────────────┘
```

### 10.2 Data Loss Points

| Stage | Lost Data | Reason |
|-------|-----------|--------|
| handleSaveAssignment | `assignmentType` | Not included in API payload |
| handleSaveAssignment | `difficulty` | Not included in API payload |
| handleSaveAssignment | `autoGrading` | Not included in API payload |
| handleSaveAssignment | `plagiarismDetection` | Not included in API payload |
| handleSaveAssignment | `allowLateSubmissions` | Not included in API payload |
| handleSaveAssignment | All lab fields | Not included in API payload |
| handleSaveAssignment | All project fields | Not included in API payload |
| handleSaveAssignment | `submissions` count | Not needed for create (read-only) |
| Assignment Card | Assignment type | Not displayed in card |
| Assignment Card | Difficulty | Not displayed in card |
| Assignment Card | Safety requirements | Not displayed in card |
| Assignment Card | Team config | Not displayed in card |
| Assignment Card | Milestones | Not displayed in card |

**⚠️ Critical Issue:** Most of the rich form data collected in the modal (type, difficulty, auto-grading, lab details, project details) is NOT sent to the backend and NOT displayed in the assignment card.

### 10.3 Edit Flow

```
User clicks "Edit" on assignment card
    ↓
handleEditAssignment(index) called
    ↓
Extract assignment from courseAssignments[index]
    ↓
Map backend status to UI status:
  "published" → "open"
  "closed" → "closed"
  "draft" → "draft"
  "archived" → "closed"
    ↓
Parse due date: "2024-11-15T00:00:00.000Z" → "2024-11-15"
    ↓
Set assignmentForm:
  {
    title: assignment.title,
    description: assignment.description || '',
    dueDate: "2024-11-15",
    status: "open",
    assignmentType: 'assignment',  ← ⚠️ HARDCODED (lost on edit)
    submissions: 0
  }
    ↓
Set editingAssignmentIndex = index
    ↓
Set showAssignmentForm = true (open modal)
    ↓
Modal shows edit form with pre-filled data
```

**⚠️ Issue:** When editing, `assignmentType` is always set to `'assignment'` regardless of original type, because the backend doesn't store it.

---

## 11. Complete Variable & Props Reference

### 11.1 CourseDetail Component Variables

| Variable | Type | Source | Used in Assignments Tab? | Purpose |
|----------|------|--------|----------------------|---------|
| `course` | `Course` | Derived | ✅ Yes | Current course object |
| `courseAssignments` | `Assignment[]` | useQuery | ✅ Yes | Fetched assignments |
| `isLoadingAssignments` | `boolean` | useQuery | ❌ No | Loading state |
| `showAssignmentForm` | `boolean` | useState | ✅ Yes | Modal visibility |
| `assignmentForm` | `AssignmentFormData \| null` | useState | ✅ Yes | Form data |
| `editingAssignmentIndex` | `number \| null` | useState | ✅ Yes | Edit target index |
| `uploadingInstructionId` | `number \| null` | useState | ✅ Yes | Upload tracking |
| `selectedAssignmentIdForGrading` | `string \| null` | useState | ✅ Yes (for nav) | Grading target |
| `assignmentSubmissions` | `AssignmentSubmission[]` | useQuery | ✅ Yes (for grading) | Submissions data |

### 11.2 AssignmentModal Props

| Prop | Type | Required | Purpose |
|------|------|----------|---------|
| `open` | `boolean` | ✅ Yes | Modal visibility |
| `assignment` | `AssignmentFormData \| null` | No | Form data (null = create mode) |
| `courses` | `Array<{ value: string; label: string }>` | ✅ Yes | Course dropdown options |
| `onClose` | `() => void` | ✅ Yes | Close handler |
| `onSave` | `(data: AssignmentFormData) => void` | ✅ Yes | Save handler |

### 11.3 API Request Variables

| Variable | Value | Source | Purpose |
|----------|-------|--------|---------|
| `API_BASE_URL` | `/api` (dev) or `http://localhost:8081/api` (prod) | config.ts | Base URL |
| `accessToken` | From localStorage | TOKEN_KEYS.ACCESS_TOKEN | Auth token |
| `courseId` | From CourseDetail props | CourseDetail | Assignment course |

---

## 12. User Interactions

### 12.1 Create Assignment Flow

**User Flow:**
1. Click "Create New Assignment" button
2. Modal opens with Assignment type selected
3. User fills form fields
4. User clicks "Create Assignment"
5. Form submits
6. API call executes
7. Modal closes on success
8. New assignment appears in cards

**Code Path:**

```typescript
// Button click (line 741-747)
onClick={() => {
  setAssignmentForm(null);
  setEditingAssignmentIndex(null);
  setShowAssignmentForm(true);
}}

// Form submission (line 273-299)
const handleSaveAssignment = (data: AssignmentFormData) => {
  const formattedDueDate = data.dueDate
    ? new Date(data.dueDate).toISOString()
    : new Date().toISOString();
    
  const toApiStatus = (uiStatus) => {
    if (uiStatus === 'open') return 'published';
    if (uiStatus === 'closed') return 'closed';
    return 'draft';
  };

  const payload = {
    title: data.title,
    description: data.description || '',
    instructions: data.description || '',
    dueDate: formattedDueDate,
    status: toApiStatus(data.status),
    courseId: Number(course!.id),
    maxScore: 100,
    submissionType: 'file',
  };

  createAssignmentMutation.mutate(payload);
};
```

### 12.2 Edit Assignment Flow

**User Flow:**
1. Click "Edit" button on assignment card
2. Modal opens with pre-filled data
3. User modifies fields
4. User clicks "Save Changes"
5. PATCH API call executes
6. Modal closes on success
7. Assignment card updates

**Code Path:**

```typescript
// Edit button click (line 302-324)
const handleEditAssignment = (index: number) => {
  const assignment = courseAssignments[index];
  const normalizedStatus = String(assignment.status || 'draft').toLowerCase();
  const uiStatus = normalizedStatus === 'published' ? 'open'
    : normalizedStatus === 'closed' || normalizedStatus === 'archived' ? 'closed'
    : 'draft';
    
  let dueDateValue = '';
  if (assignment.dueDate) {
    const date = new Date(assignment.dueDate);
    if (!isNaN(date.getTime())) {
      dueDateValue = date.toISOString().split('T')[0];
    }
  }

  setAssignmentForm({
    title: assignment.title,
    description: assignment.description || '',
    dueDate: dueDateValue,
    status: uiStatus,
    submissions: 0,
    assignmentType: 'assignment',  // ⚠️ HARDCODED
  });
  setEditingAssignmentIndex(index);
  setShowAssignmentForm(true);
};
```

### 12.3 Delete Assignment Flow

**User Flow:**
1. Click "Delete" button on assignment card
2. Confirmation dialog appears
3. User confirms deletion
4. DELETE API call executes
5. Assignment card removed from list

**Code Path:**

```typescript
// Delete button (line 326-330)
const handleDeleteAssignment = (id: number) => {
  if (!window.confirm('Delete this assignment? This action cannot be undone.')) return;
  deleteAssignmentMutation.mutate(String(id));
};
```

### 12.4 Publish Assignment Flow

**User Flow:**
1. Click "Publish" button (only visible for draft assignments)
2. PATCH API call to update status
3. Status badge changes from DRAFT to PUBLISHED
4. Publish button disappears

**Code Path:**

```typescript
// Publish button (conditional rendering)
{normalizedStatus === 'draft' && (
  <button onClick={() => handlePublishAssignment(index)}>
    Publish
  </button>
)}

// Handler (line 332-342)
const handlePublishAssignment = (index: number) => {
  const assignment = courseAssignments[index];
  AssignmentService.updateStatus(String(assignment.id), 'published')
    .then(() => {
      queryClient.invalidateQueries({ queryKey: ['course-assignments', course?.id] });
      toast.success('Assignment published successfully');
    })
    .catch((error) => {
      console.error('Failed to publish assignment', error);
      toast.error('Failed to publish assignment');
    });
};
```

### 12.5 Upload Instructions Flow

**User Flow:**
1. Click "Upload Instructions" label
2. File picker dialog opens
3. User selects file
4. File uploads to Google Drive
5. "Uploading..." shown during upload
6. Success toast on completion

**Code Path:**

```typescript
// Upload label with hidden file input
<label className="cursor-pointer">
  {uploadingInstructionId === Number(assignment.id)
    ? 'Uploading...'
    : 'Upload Instructions'}
  <input
    type="file"
    className="hidden"
    onChange={(e) => {
      handleUploadInstruction(Number(assignment.id), e.target.files?.[0] || null);
      e.currentTarget.value = '';  // Reset input
    }}
  />
</label>

// Handler (line 344-357)
const handleUploadInstruction = (assignmentId: number, file: File | null) => {
  if (!file) return;
  setUploadingInstructionId(assignmentId);
  uploadInstructionMutation.mutate(
    { assignmentId: String(assignmentId), file, title: file.name },
    {
      onSettled: () => {
        setUploadingInstructionId(null);
      },
    }
  );
};
```

### 12.6 View Submissions Flow

**User Flow:**
1. Click "View Submissions" button
2. Navigate to Grading Tab
3. Set sub-tab to "Manual Grading"
4. Set selected assignment for grading
5. Grading interface loads

**Code Path:**

```typescript
<button onClick={() => {
  setActiveTab('grading');
  setGradingSubTab('manual');
  setSelectedAssignmentIdForGrading(String(assignment.id));
}}>
  View Submissions
</button>
```

### 12.7 Manual Grading Flow

**User Flow:**
1. Click "Grade Manually" or "View Submissions"
2. Navigate to Grading Tab → Manual Grading
3. Select assignment (if not already selected)
4. View list of submissions
5. Enter grade for each submission
6. Click "Save" for each grade
7. Grade saves to backend
8. Submission status updates to "Graded"

### 12.8 AI Auto-Grading Flow

**User Flow:**
1. Click "AI Auto-Grading" button
2. Navigate to Grading Tab → Auto-Graded Results
3. AI grades eligible submissions automatically
4. Results display with scores
5. Instructor can review and override grades

---

## 13. Loading, Error & Edge Cases

### 13.1 Loading States

**Assignments Query:**

```typescript
const { data: courseAssignments, isLoading: isLoadingAssignments } = useQuery({...});
```

- `isLoadingAssignments` is available but NOT used in Assignments Tab rendering
- Tab shows empty state while loading

**Assignment Card (No Loading Indicator):**

Currently, there's no loading spinner shown during assignment fetch. The tab simply shows empty assignment list until data loads.

### 13.2 Error Handling

**CourseDetail Level:**

```typescript
// createAssignmentMutation
onError: () => toast.error('Failed to create assignment')

// updateAssignmentMutation
onError: () => toast.error('Failed to update assignment')

// deleteAssignmentMutation
onError: () => toast.error('Failed to delete assignment')

// uploadInstructionMutation
onError: () => toast.error('Failed to upload instructions')
```

**Error Toasts:**

| Action | Error Message |
|--------|---------------|
| Create | "Failed to create assignment" |
| Update | "Failed to update assignment" |
| Delete | "Failed to delete assignment" |
| Upload Instructions | "Failed to upload instructions" |
| Publish | "Failed to publish assignment" |

### 13.3 Edge Cases

#### No Assignments Created

```typescript
{courseAssignments.map((assignment, index) => {
  // ... render cards
})}
```

**Behavior:**
- Empty array → No cards rendered
- No empty state message shown
- Just shows "Assignments" header with no content

**⚠️ Issue:** No empty state message for first-time users

#### Assignment Without Due Date

```typescript
<span>
  {assignment.dueDate
    ? new Date(assignment.dueDate).toLocaleDateString()
    : 'No due date'}
</span>
```

**Behavior:**
- Shows "No due date" fallback text

#### Assignment Without Description

```typescript
<p>{assignment.description}</p>
```

**Behavior:**
- Renders empty paragraph if description is null
- No visual indication

#### Draft Assignment

```typescript
{normalizedStatus === 'draft' && (
  <button onClick={() => handlePublishAssignment(index)}>
    Publish
  </button>
)}
```

**Behavior:**
- Only draft assignments show "Publish" button
- Published/Closed assignments don't show it

#### Submissions Count

```typescript
<span>0/{course.enrolled} Submitted</span>
```

**⚠️ Issue:** Submissions count is hardcoded to `0`, doesn't show actual submission count from backend.

#### Deleting Assignment

```typescript
if (!window.confirm('Delete this assignment? This action cannot be undone.')) return;
```

**Behavior:**
- Native browser confirmation dialog
- Cannot be customized
- No undo functionality

### 13.4 Validation

**Modal Form Validation:**

| Field | Validation | Error Handling |
|-------|-----------|----------------|
| Title | Required | HTML5 `required` attribute |
| Due Date | Required | HTML5 `required` attribute |
| Course | Auto-selected | Always has value |

**Missing Validations:**

- No max length for title
- No date validation (can pick past dates)
- No weight validation for milestones (can exceed 100%)
- No team size validation (min > max possible)

---

## 14. Mock Mode vs Live Mode

### 14.1 Mode Comparison

| Aspect | Mock Mode (`isMockMode = true`) | Live Mode (`isMockMode = false`) |
|--------|--------------------------------|----------------------------------|
| **API Calls** | ❌ Disabled | ✅ Enabled |
| **Assignments Query** | `enabled: false` | `enabled: true` |
| **courseAssignments** | Empty array or mock data | Fetched from `/api/assignments` |
| **Create Mutation** | ❌ Disabled | ✅ Enabled |
| **Update Mutation** | ❌ Disabled | ✅ Enabled |
| **Delete Mutation** | ❌ Disabled | ✅ Enabled |
| **Upload Instructions** | ❌ Disabled | ✅ Enabled |
| **Grading** | ❌ Disabled | ✅ Enabled |

### 14.2 Mock Mode Behavior

**Query Disabled:**

```typescript
const { data: courseAssignments, isLoading: isLoadingAssignments } = useQuery({
  queryKey: ['course-assignments', course?.id],
  queryFn: () => AssignmentService.getAll({ courseId: String(course!.id) }),
  enabled: !!course?.id && !isMockMode,  // ← Disabled in mock mode
});
```

**Result:** `courseAssignments` remains `undefined` or mock data if provided by parent component

### 14.3 Live Mode Behavior

**When `isMockMode = false`:**

1. Query executes API call to fetch assignments
2. Response populates `courseAssignments`
3. Assignment cards render with real data
4. All mutations (create, update, delete) work
5. Toast notifications shown on success/error

---

## 15. Styling & UI/UX

### 15.1 Theme Support

**Dark/Light Mode:**

```typescript
const { isDark, primaryHex = '#3b82f6' } = useTheme() as any;
```

**Assignment Card Styling:**

```typescript
className={`${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-gray-200'} rounded-xl p-6 border shadow-sm`}
```

| Element | Dark Mode | Light Mode |
|---------|-----------|------------|
| Card Background | `bg-white/5` (5% white) | `bg-white` |
| Card Border | `border-white/10` (10% white) | `border-gray-200` |
| Title Text | `text-white` | `text-gray-900` |
| Description Text | `text-slate-400` | `text-gray-600` |
| Metadata Text | `text-slate-400` | `text-gray-600` |
| Hover | `hover:bg-white/10` | `hover:bg-gray-50` |

### 15.2 Modal Styling

**Overlay:**

```typescript
className="fixed inset-0 bg-black/10 backdrop-blur-sm flex items-center justify-center z-50"
```

- Black overlay with 10% opacity
- Backdrop blur effect
- Centered vertically and horizontally
- z-index: 50 (above most elements)

**Modal Container:**

```typescript
className={`rounded-lg shadow-xl w-full max-w-2xl mx-4 flex flex-col max-h-[90vh]`}
```

- Max width: 2xl (42rem / 672px)
- Max height: 90vh (90% of viewport height)
- Horizontal margin: 4 (1rem) on each side
- Flex column layout
- Rounded corners with shadow

**Form Container:**

```typescript
className="p-6 space-y-5 overflow-y-auto max-h-[80vh]"
```

- Padding: 6 (1.5rem)
- Vertical spacing: 5 (1.25rem)
- Scrollable overflow
- Max height: 80vh

### 15.3 Type Selector Styling

```typescript
<div className="grid grid-cols-3 gap-2">
  <button className={`flex items-center justify-center gap-2 px-3 py-2.5 rounded-lg border-2`}>
    <Icon size={16} />
    {cfg.label}
  </button>
</div>
```

**Color Mapping:**

| Type | Active (Light) | Active (Dark) | Inactive (Light) | Inactive (Dark) |
|------|----------------|---------------|------------------|-----------------|
| Assignment | `bg-blue-50`, `border-blue-500`, `text-blue-700` | `bg-blue-900/30`, `border-blue-500`, `text-blue-300` | `border-gray-200`, `text-gray-500` | `border-white/10`, `text-gray-400` |
| Lab | `bg-green-50`, `border-green-500`, `text-green-700` | `bg-green-900/30`, `border-green-500`, `text-green-300` | `border-gray-200`, `text-gray-500` | `border-white/10`, `text-gray-400` |
| Project | `bg-amber-50`, `border-amber-500`, `text-amber-700` | `bg-amber-900/30`, `border-amber-500`, `text-amber-300` | `border-gray-200`, `text-gray-500` | `border-white/10`, `text-gray-400` |

### 15.4 Status Badge Styling

```typescript
<span className={`px-3 py-1 rounded-full text-xs font-medium ${
  normalizedStatus === 'published' 
    ? 'bg-green-100 text-green-700' 
    : 'bg-yellow-100 text-yellow-700'
}`}>
  {normalizedStatus.toUpperCase()}
</span>
```

| Status | Background | Text |
|--------|-----------|------|
| Published | `bg-green-100` | `text-green-700` |
| Draft | `bg-yellow-100` | `text-yellow-700` |
| Closed | `bg-yellow-100` | `text-yellow-700` |

**⚠️ Issue:** Closed status uses yellow (draft) color instead of a distinct color (e.g., gray/red)

### 15.5 Action Buttons Styling

| Button | Styling | Color |
|--------|---------|-------|
| View Submissions | Text button | `text-slate-400` / `text-gray-700` |
| Edit | Text button | `text-slate-400` / `text-gray-700` |
| Delete | Text button | `text-red-600` |
| Upload Instructions | Text button with hidden input | `text-slate-400` / `text-gray-700` |
| Grade Manually | Text button | `text-slate-400` / `text-gray-700` |
| AI Auto-Grading | Text button with icon | `text-indigo-600` |
| Publish | Text button | `text-green-600` |

### 15.6 Toggle Component

```typescript
function Toggle({ value, onChange, isDark }) {
  return (
    <button
      type="button"
      onClick={() => onChange(!value)}
      className={`relative w-10 h-5 rounded-full transition-colors ${
        value ? 'bg-indigo-600' : isDark ? 'bg-gray-600' : 'bg-gray-300'
      }`}
    >
      <span className={`absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full transition-transform ${
        value ? 'translate-x-5' : ''
      }`} />
    </button>
  );
}
```

**Styling:**

| State | Background | Knob Position |
|-------|-----------|---------------|
| ON (Light) | `bg-indigo-600` | `translate-x-5` |
| ON (Dark) | `bg-indigo-600` | `translate-x-5` |
| OFF (Light) | `bg-gray-300` | `translate-x-0` |
| OFF (Dark) | `bg-gray-600` | `translate-x-0` |

### 15.7 Accessibility

**Modal:**

- `role="dialog"` - Identifies as dialog
- `aria-modal="true"` - Indicates modal nature
- `aria-labelledby="assignment-modal-title"` - Links to title
- Focus trap with Tab key handling
- Focus restoration on close
- Escape key closes modal

**Form:**

- Semantic `<form>` element
- `required` attributes on mandatory fields
- Proper `<label>` associations

---

## 16. Related Features & Cross-References

### 16.1 Grading Tab

**File:** `src/pages/instructor-dashboard/components/CourseDetail.tsx` (lines 902-1080)

The Grading Tab is closely integrated with assignments:

```typescript
{activeTab === 'grading' && (
  <div className="space-y-6">
    {/* Sub-tabs */}
    <div className={`flex gap-2 border-b pb-2`}>
      <button onClick={() => setGradingSubTab('manual')}>
        Manual Grading
      </button>
      <button onClick={() => setGradingSubTab('auto')}>
        Auto-Graded Results
      </button>
    </div>

    {gradingSubTab === 'manual' && (
      <div className="space-y-4">
        {/* Assignment selector dropdown */}
        <CleanSelect
          value={selectedAssignmentIdForGrading || ''}
          onChange={(e) => setSelectedAssignmentIdForGrading(e.target.value)}
        >
          {courseAssignments.map(a => (
            <option value={a.id}>{a.title}</option>
          ))}
        </CleanSelect>

        {/* Submissions list with inline grading */}
        {assignmentSubmissions.map(submission => (
          <div key={submission.id}>
            <span>{submission.user?.firstName} {submission.user?.lastName}</span>
            <input
              type="number"
              value={draftGrades[submission.id] || submission.score || ''}
              onChange={(e) => handleInlineGrade(submission.id, e.target.value)}
            />
            <button onClick={() => saveInlineGrade(submission.id)}>
              Save
            </button>
          </div>
        ))}
      </div>
    )}
  </div>
)}
```

### 16.2 InstructorDashboard Assignments

**File:** `src/pages/instructor-dashboard/InstructorDashboard.tsx`

The InstructorDashboard also has assignment management at the dashboard level:

```typescript
// Lines 759-808
const handleCreateAssignment = () => {
  setEditingAssignment(null);
  setIsAssignmentModalOpen(true);
};

const handleSaveAssignment = async (data: AssignmentFormData): Promise<Assignment | void> => {
  const formattedDueDate = data.dueDate
    ? new Date(data.dueDate).toISOString()
    : new Date().toISOString();
    
  const payload = {
    title: data.title,
    description: data.description || '',
    instructions: data.description || '',
    dueDate: formattedDueDate,
    status: toApiStatus(data.status),
    courseId: Number(selectedCourseId || activeSectionId),
    maxScore: 100,
    submissionType: data.submissionType,
    allowedFileTypes: parseFileTypes(data.allowedFileTypes),
    maxFileSize: data.maxFileSize,
    latePenalty: data.latePenalty,
  };

  if (editingAssignment) {
    await AssignmentService.update(editingAssignment.id, payload);
  } else {
    const createdAssignment = await AssignmentService.create(payload);
    return createdAssignment;
  }
};
```

**Key Difference:**
- InstructorDashboard uses `SubmissionListView` and `GradingPanel` components
- CourseDetail uses inline grading in the Grading Tab

### 16.3 SharedAssignmentsPage

**File:** `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx`

Shared assignments page for instructors and TAs:

```typescript
// Lines 132-153
const createAssignmentMutation = useMutation({
  mutationFn: async (data: AssignmentFormData) => {
    const payload = {
      title: data.title,
      description: data.description,
      dueDate: data.dueDate,
      status: toApiStatus(data.status),
      courseId: Number(selectedCourseId || activeSectionId),
      submissionType: data.submissionType,
    };
    return await AssignmentService.create(payload);
  },
  onSuccess: () => {
    await queryClient.invalidateQueries({ queryKey: ['shared-course-assignments', activeSectionId] });
    setIsAssignmentModalOpen(false);
    toast.success('Assignment created successfully');
  },
});
```

### 16.4 Student Assignment Submission

**File:** `src/pages/student-dashboard/components/assignments/SubmissionForm.tsx`

Students submit assignments using SubmissionForm:

```typescript
// Lines 31-43
switch (assignment.submissionType) {
  case 'text':
    return <TextSubmission assignment={assignment} />;
  case 'link':
    return <LinkSubmission assignment={assignment} />;
  case 'file':
    return <FileUpload assignment={assignment} />;
  case 'any':
    return <AnySubmission assignment={assignment} />;
}
```

### 16.5 Assignment Service - All Methods

**File:** `src/services/api/assignmentService.ts`

| Method | Purpose | Used By |
|--------|---------|---------|
| `getAll(params?)` | Get assignments with filters | ✅ CourseDetail, InstructorDashboard |
| `getById(id)` | Get single assignment | Assignment detail views |
| `create(data)` | Create assignment | ✅ CourseDetail, InstructorDashboard |
| `update(id, data)` | Update assignment | ✅ Edit assignment |
| `delete(id)` | Delete assignment | ✅ Delete assignment |
| `updateStatus(id, status)` | Change status | ✅ Publish assignment |
| `getSubmissions(assignmentId)` | Get all submissions | ✅ Grading Tab |
| `getMySubmission(assignmentId)` | Get student's submission | Student view |
| `submitText(assignmentId, data)` | Submit text | Student submission |
| `submitFile(assignmentId, file)` | Submit file | Student submission |
| `gradeSubmission(aId, sId, data)` | Grade submission | ✅ Manual grading |
| `uploadInstructions(aId, file, title)` | Upload instructions | ✅ Upload instructions |

---

## 17. Debugging & Troubleshooting

### 17.1 Common Issues

#### Issue 1: Assignment Not Appearing After Creation

**Symptoms:** Form submits successfully but assignment doesn't appear in cards

**Possible Causes:**
1. Query not invalidating
2. Backend error not caught
3. API response doesn't match expected format

**Debugging Steps:**

```typescript
// 1. Check mutation success
createAssignmentMutation.mutate(payload, {
  onSuccess: (data) => {
    console.log('Created Assignment:', data); // ← Check response
    queryClient.invalidateQueries({ queryKey: ['course-assignments', course?.id] });
    toast.success('Assignment created successfully');
  },
  onError: (error) => {
    console.error('Create Error:', error); // ← Check error
    toast.error('Failed to create assignment');
  },
});

// 2. Check query refetch
const { data: courseAssignments } = useQuery({
  queryKey: ['course-assignments', course?.id],
  queryFn: async () => {
    const result = await AssignmentService.getAll({ courseId: String(course!.id) });
    console.log('Fetched Assignments:', result); // ← Check assignments
    return result;
  },
});

// 3. Check payload
console.log('Create Payload:', payload);
```

**Solution:**
- Verify query invalidation key matches
- Check backend returns assignment in array format
- Ensure courseId is correct

#### Issue 2: Assignment Type Not Persisted

**Cause:** `assignmentType` is NOT sent to backend, only used in frontend form

**Current Code:**

```typescript
const payload = {
  title: data.title,
  description: data.description || '',
  // ... other fields
  // ⚠️ assignmentType: data.assignmentType,  ← NOT INCLUDED
  submissionType: 'file',
};
```

**Impact:**
- When editing assignment, type always defaults to "assignment"
- Lab and Project-specific fields lost after save
- Cannot display assignment type in cards

**Solution:**

**Option A: Backend Enhancement**
Add `assignmentType` field to backend Assignment model:

```typescript
// Backend Assignment entity
@Field()
assignmentType: 'assignment' | 'lab' | 'project';
```

**Option B: Frontend Workaround**
Store assignment type in description or instructions:

```typescript
const payload = {
  ...
  instructions: `[TYPE:${data.assignmentType}] ${data.description || ''}`,
  ...
};

// On edit, extract type:
const typeMatch = assignment.instructions?.match(/\[TYPE:(\w+)\]/);
const assignmentType = typeMatch ? typeMatch[1] : 'assignment';
```

#### Issue 3: Submissions Count Always Shows 0

**Cause:** Hardcoded to `0/{course.enrolled}`

**Current Code:**

```typescript
<span>0/{course.enrolled} Submitted</span>
```

**Solution:**

Fetch actual submission count:

```typescript
// In assignment card
const { data: submissions } = useQuery({
  queryKey: ['assignment-submissions', assignment.id],
  queryFn: () => AssignmentService.getSubmissions(assignment.id),
  enabled: !!assignment.id,
});

<span>{submissions?.length || 0}/{course.enrolled} Submitted</span>
```

**⚠️ Performance Note:** This would create N+1 queries (one per assignment). Better to include submission count in assignment response from backend.

#### Issue 4: Edit Assignment Loses Type-Specific Data

**Cause:** Backend doesn't store lab/project fields

**Symptoms:**
- Create Lab with safety requirements
- Edit Lab → All safety fields are empty
- Save → Safety requirements lost

**Debugging:**

```typescript
// Check what backend returns on edit
const assignment = courseAssignments[index];
console.log('Assignment to Edit:', assignment);

// Check if lab/project fields exist:
console.log('Lab Room:', assignment.labRoom);  // undefined
console.log('Objectives:', assignment.objectives);  // undefined
```

**Solution:** Same as Issue 2 - backend needs to store and return these fields

#### Issue 5: Delete Confirmation Not Customizable

**Cause:** Uses native `window.confirm()`

**Current Code:**

```typescript
if (!window.confirm('Delete this assignment? This action cannot be undone.')) return;
```

**Solution:** Use custom confirmation dialog (e.g., from shadcn/ui or custom modal)

```typescript
const [showDeleteDialog, setShowDeleteDialog] = useState(false);
const [assignmentToDelete, setAssignmentToDelete] = useState<string | null>(null);

const handleDeleteClick = (id: string) => {
  setAssignmentToDelete(id);
  setShowDeleteDialog(true);
};

const confirmDelete = () => {
  if (assignmentToDelete) {
    deleteAssignmentMutation.mutate(assignmentToDelete);
    setShowDeleteDialog(false);
    setAssignmentToDelete(null);
  }
};
```

### 17.2 Debugging Tools

#### React DevTools

- Inspect `formData` state in AssignmentModal
- View `courseAssignments` array in CourseDetail
- Check mutation states (loading, error, success)

#### Browser Network Tab

- Filter by `assignments` to see API calls
- Check POST request payload includes all fields
- Verify response structure matches expectations

#### Console Logging

Add temporary logs in handleSaveAssignment:

```typescript
const handleSaveAssignment = (data: AssignmentFormData) => {
  console.log('=== Assignment Save Debug ===');
  console.log('Form Data:', data);
  console.log('Assignment Type:', data.assignmentType);
  console.log('Difficulty:', data.difficulty);
  console.log('Lab Fields:', {
    labRoom: data.labRoom,
    objectives: data.objectives,
    equipment: data.equipment,
    safetyRequirements: {
      labCoat: data.requireLabCoat,
      safetyGlasses: data.requireSafetyGlasses,
      gloves: data.requireGloves,
    }
  });
  console.log('Project Fields:', {
    scope: data.scope,
    teamSize: `${data.minTeamSize}-${data.maxTeamSize}`,
    milestones: data.milestones,
    deliverables: data.deliverables,
  });
  console.log('API Payload:', payload);
};
```

#### React Query DevTools

- View `['course-assignments', course?.id]` query state
- Manually invalidate query to test refetch
- Check mutation cache for optimistic updates

### 17.3 Performance Optimization

#### Current Optimizations

1. **React Query Caching:**
   ```typescript
   queryKey: ['course-assignments', course?.id]
   ```
   - Cached by course ID
   - Automatic cache invalidation on mutations

2. **Conditional Rendering:**
   - Type-specific fields only render when type selected
   - Publish button only renders for draft assignments

3. **Normalized Status:**
   ```typescript
   const normalizedStatus = String(assignment.status || 'draft').toLowerCase();
   ```
   - Handles undefined/null status
   - Case-insensitive comparison

#### Potential Improvements

1. **Optimistic Updates:**
   ```typescript
   createAssignmentMutation.mutate(payload, {
     onMutate: async (newAssignment) => {
       const previous = queryClient.getQueryData(['course-assignments', course.id]);
       queryClient.setQueryData(['course-assignments', course.id], old => [
         ...old,
         { ...newAssignment, id: 'temp-id', createdAt: new Date().toISOString() }
       ]);
       return { previous };
     },
     onError: (err, newAssignment, context) => {
       queryClient.setQueryData(['course-assignments', course.id], context.previous);
     },
   });
   ```

2. **Prefetch Submissions:**
   ```typescript
   // When user hovers "View Submissions" button
   const prefetchSubmissions = (assignmentId: string) => {
     queryClient.prefetchQuery({
       queryKey: ['assignment-submissions', assignmentId],
       queryFn: () => AssignmentService.getSubmissions(assignmentId),
     });
   };
   ```

3. **Debounced Assignment Search:**
   If assignment list grows large, add search/filter functionality

### 17.4 Testing Recommendations

#### Unit Tests

```typescript
describe('AssignmentModal', () => {
  it('should render with assignment type selected by default', () => {
    render(
      <AssignmentModal
        open={true}
        assignment={null}
        courses={[{ value: '123', label: 'CS101' }]}
        onClose={jest.fn()}
        onSave={jest.fn()}
      />
    );
    
    expect(screen.getByText('Assignment')).toBeInTheDocument();
    expect(screen.getByText('Auto-Grading')).toBeInTheDocument();
  });

  it('should show lab-specific fields when lab type selected', () => {
    render(<AssignmentModal ... />);
    
    fireEvent.click(screen.getByText('Lab'));
    
    expect(screen.getByText('Lab Room')).toBeInTheDocument();
    expect(screen.getByText('Safety Requirements')).toBeInTheDocument();
    expect(screen.getByText('Require Lab Coat')).toBeInTheDocument();
  });

  it('should show project-specific fields when project type selected', () => {
    render(<AssignmentModal ... />);
    
    fireEvent.click(screen.getByText('Project'));
    
    expect(screen.getByText('Team Configuration')).toBeInTheDocument();
    expect(screen.getByText('Milestones')).toBeInTheDocument();
    expect(screen.getByText('Deliverables')).toBeInTheDocument();
  });
});

describe('CourseDetail - Assignments Tab', () => {
  it('should create assignment and show in list', async () => {
    mockAssignmentService.create.mockResolvedValue(mockAssignment);
    mockAssignmentService.getAll.mockResolvedValue([mockAssignment]);
    
    render(<CourseDetail courseId={1} onBack={jest.fn()} courses={mockCourses} />);
    
    fireEvent.click(screen.getByText('Create New Assignment'));
    
    fireEvent.change(screen.getByLabelText('Title'), {
      target: { value: 'Test Assignment' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /create assignment/i }));
    
    await waitFor(() => {
      expect(screen.getByText('Test Assignment')).toBeInTheDocument();
    });
  });
});
```

---

## Appendix A: File Locations Quick Reference

| File | Path | Lines | Purpose |
|------|------|-------|---------|
| CourseDetail Component | `src/pages/instructor-dashboard/components/CourseDetail.tsx` | 1198 | Main course detail with Assignments Tab |
| AssignmentModal | `src/pages/instructor-dashboard/components/AssignmentModal.tsx` | 828 | Creation/edit modal with type-specific fields |
| AssignmentService | `src/services/api/assignmentService.ts` | 201 | Assignment API service layer |
| Assignment Types | `src/types/api.ts` | ~100 | TypeScript interfaces |
| InstructorDashboard | `src/pages/instructor-dashboard/InstructorDashboard.tsx` | 1440 | Parent dashboard with assignment management |
| SharedAssignmentsPage | `src/pages/shared-dashboard/components/SharedAssignmentsPage.tsx` | ~300 | Shared assignment management |
| SubmissionForm | `src/pages/student-dashboard/components/assignments/SubmissionForm.tsx` | ~200 | Student submission form |

## Appendix B: API Endpoints Quick Reference

| Endpoint | Method | Used In | Purpose |
|----------|--------|---------|---------|
| `/assignments` | GET | ✅ Assignments Tab | Get course assignments |
| `/assignments` | POST | ✅ Create Assignment | Create new assignment |
| `/assignments/{id}` | PATCH | ✅ Edit Assignment | Update assignment |
| `/assignments/{id}` | DELETE | ✅ Delete Assignment | Delete assignment |
| `/assignments/{id}/status` | PATCH | ✅ Publish Assignment | Change status |
| `/assignments/{id}/submissions` | GET | ✅ View Submissions | Get all submissions |
| `/assignments/{id}/submissions/{sId}/grade` | PATCH | ✅ Manual Grading | Grade submission |
| `/assignments/{id}/instructions/upload` | POST | ✅ Upload Instructions | Upload instruction file |

## Appendix C: Type Configuration Quick Reference

| Type | Icon | Color | Key Fields |
|------|------|-------|------------|
| Assignment | FileText | Blue | autoGrading, plagiarismDetection, allowLateSubmissions |
| Lab | FlaskConical | Green | labRoom, objectives, equipment, procedure, safety requirements, requireLabReport |
| Project | FolderKanban | Amber | scope, teamConfig, milestones, deliverables, requirePresentation |

## Appendix D: Status Mapping Quick Reference

| UI Status | API Status | Badge Color | Description |
|-----------|-----------|-------------|-------------|
| `draft` | `draft` | Yellow | Not visible to students |
| `open` | `published` | Green | Visible to students, accepting submissions |
| `closed` | `closed` | Yellow | No longer accepting submissions |
| N/A | `archived` | N/A | Archived (not used in UI) |

## Appendix E: Environment Variables

| Variable | Purpose | Default (Dev) | Default (Prod) |
|----------|---------|---------------|----------------|
| `VITE_API_BASE_URL` | Backend API URL | (uses `/api` proxy) | `http://localhost:8081/api` |
| `VITE_AI_ATTENDANCE_URL` | AI attendance service | (uses `/ai-attendance` proxy) | `http://127.0.0.1:8000` |
| `VITE_AI_QUIZ_URL` | AI quiz service | (uses `/ai-quiz` proxy) | `http://127.0.0.1:8001` |

---

**Document End**

*For questions or updates to this documentation, contact the development team.*
